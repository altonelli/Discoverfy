
//  SpotifyService.m
//  Discoverfy
//
//  Created by Arthur Tonelli on 7/27/16.
//  Copyright © 2016 Arthur Tonelli. All rights reserved.
//

#import "SpotifyService.h"
#import "Track.h"
#import "User+CoreDataProperties.h"
#import "Song+CoreDataProperties.h"
#import "AppDelegate.h"
#import "CoreDataService.h"
#import "Reachability.h"
#import "DiscoverfyService.h"
#import "DiscoverfyItem.h"

@interface SpotifyService (){
    SPTPlaylistList *playlist;
    BOOL hasDiscoverfyPlaylist;
    SPTAuth *auth;
    AppDelegate *appDelegate;
    NSManagedObjectContext *context;
    NSManagedObjectContext *privateContext;
}

@end

@implementation SpotifyService

+(id)sharedService {
    static SpotifyService *sharedSpotifyService = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedSpotifyService = [[self alloc]init];
    });
    
    return sharedSpotifyService;
}

-(id)init{
    if(self = [super init]){
        auth = [SPTAuth defaultInstance];
        
        appDelegate = [[UIApplication sharedApplication]delegate];
        
        _topTrackList = [[NSArray alloc]init];
        
        _artistList = [[NSMutableArray alloc]init];
        _uriList = [[NSMutableArray alloc]init];
        _partialTrackList = [[NSMutableArray alloc]init];
//        self.player = [[AVQueuePlayer alloc]init];

        _player = [[AVQueuePlayer alloc]init];
        
        _spot_service_queue = dispatch_queue_create("com.discoverfy.addToPlayerQueue", DISPATCH_QUEUE_SERIAL);
        _spot_core_data_queue = dispatch_queue_create("com.discoverfy.addToCoreDataQueue", DISPATCH_QUEUE_SERIAL);
        
        context = [appDelegate managedObjectContext];
        
        dispatch_sync(self.spot_core_data_queue, ^{
            
            privateContext = [appDelegate privateContext];
            
        });

        self.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(trackDidFinish:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:self.player.currentItem];
    
    }
    return self;
}

-(void)trackDidFinish:(NSNotification *)notification{
//    AVPlayerItem *item = [notification object];
    
    DiscoverfyItem *item = [notification object];
    [item seekToTime:kCMTimeZero];
}

-(void)getArtistsListWithAccessToken:(NSString *)accessToken queue:(dispatch_queue_t)queue callback:(void (^)(void))callbackBlock {
    
    NSURL *url = [NSURL URLWithString:@"https://api.spotify.com/v1/me/top/artists?limit=20&time_range=short_term"];
    
    NSError *error;
    NSURLRequest *artistsReq = [SPTRequest createRequestForURL:url withAccessToken:accessToken httpMethod:@"GET" values:nil valueBodyIsJSON:YES sendDataAsQueryString:YES error:&error];
    
    [[SPTRequest sharedHandler]performRequest:artistsReq callback:^(NSError *error, NSURLResponse *response, NSData *data) {
        dispatch_async(queue, ^{
        if(error != nil){
            NSLog(@"*** Error on top artist get %@",error);
            [[DiscoverfyService sharedService]handleError:NULL withState:@"batchError"];
            return;
        }
            
        NSError *err;
        NSDictionary *test = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
        
        NSArray *items = [test valueForKey:@"items"];
        for(NSObject *artist in items){
            NSString *name = [artist valueForKey:@"id"];
            [self.artistList addObject:name];
        }
            
        callbackBlock();
            
        });
        return;
        
    }];
}

-(void)queueSongsWithAccessToken:(NSString *)accessToken user:(User*)user queue:(dispatch_queue_t)queue callback:(nullable void (^)(void))callbackBlock{


        [self getArtistsListWithAccessToken:accessToken queue:queue callback:^{
                
            NSMutableArray *randomArtists = [self getRandomArtists];
            
                [self fetchRecommendedSongsFromArtists:randomArtists accessToken:accessToken queue:queue callback:^(NSArray *resultTracks) {
                
                [self convertTracksWithTracks:resultTracks user:user];
                    
                    if (callbackBlock != nil) {
                        return callbackBlock();
                    }
            }];
        }];

}

-(void)fetchRecommendedSongsFromArtists:(NSMutableArray *)artists accessToken:(NSString *)accessToken queue:(dispatch_queue_t)queue callback:(void(^)(NSArray *resultTracks))callbackBlock{
    
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"https://api.spotify.com/v1/recommendations?seed_artists="];
    
    for (NSString *artistID in artists){
        [urlString appendString:[NSString stringWithFormat:@"%@,",artistID]];
    }
    
    [urlString deleteCharactersInRange:NSMakeRange([urlString length]-1, 1)];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSError *error;
    NSURLRequest *songReq = [SPTRequest createRequestForURL:url withAccessToken:accessToken httpMethod:@"GET" values:nil valueBodyIsJSON:YES sendDataAsQueryString:YES error:&error];
    
    [[SPTRequest sharedHandler]performRequest:songReq callback:^(NSError *error, NSURLResponse *response, NSData *data) {
        dispatch_async(queue, ^{

        if(error != nil){
            NSLog(@"*** Error on song get %@",error);
            [[DiscoverfyService sharedService]handleError:NULL withState:@"batchError"];

            return;
        }
        
        NSError *err;
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
        
        
        
        if(err != nil){
            NSLog(@"error of results dictionary %@",err);
            [[DiscoverfyService sharedService]handleError:NULL withState:@"batchError"];
            return;
        }
        
        NSArray *tracks = [jsonDict objectForKey:@"tracks"];
        
            callbackBlock(tracks);
        });
        return;
    }];
   
}

-(void)convertTracksWithTracks:(NSArray *)tracks user:(User *)user{
    for (NSDictionary *track in tracks){

        NSError *partialError;
        SPTPartialTrack *partialtrack = [SPTPartialTrack partialTrackFromDecodedJSON:track error:&partialError];

        if(partialError != nil){
            NSLog(@"*** Partial Error %@",partialError);
            [[DiscoverfyService sharedService]handleError:NULL withState:@"batchError"];
            
            return;

        }

        
        
        if (![Song songExistsForUser:user trackID:partialtrack.identifier inManagedObjectContext:context]){
            
            Track *newTrack = [[Track alloc]initWithSpotifyTrack:partialtrack];
            
            [newTrack addToService:self withQueue:self.spot_service_queue];
            
            
        } else {
            
//            NSLog(@"Already have song, ignoring.");
            
        }
    };
    
}

-(void)fetchPlaylistSongsWithAccessToken:(NSString *)accessToken session:(SPTSession *)session offset:(int)offset user:(User *)user queue:(dispatch_queue_t)queue callback:(void(^)(void))callbackBlock{
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.spotify.com/v1/me/playlists?offset=%d&limit=50",offset]];
    
    NSError *error;
    NSURLRequest *playlistsReq = [SPTRequest createRequestForURL:url withAccessToken:accessToken httpMethod:@"GET" values:nil valueBodyIsJSON:YES sendDataAsQueryString:YES error:&error];
    
    [[SPTRequest sharedHandler]performRequest:playlistsReq callback:^(NSError *error, NSURLResponse *response, NSData *data) {
        if (error != nil){
            NSLog(@"*** Error on playlist get %@",error);
            [[DiscoverfyService sharedService]handleError:NULL withState:@"initialError"];
            return;
        }
        playlist = [SPTPlaylistList playlistListFromData:data withResponse:response error:&error];
        
        NSArray *items = [playlist valueForKey:@"items"];
        
        for (SPTPartialPlaylist *partialPlaylist in items){
            
            if ([partialPlaylist.name  isEqual: @"Discoverfy App"]) {
                hasDiscoverfyPlaylist = YES;
                
                NSLog(@"FOUND!");
                
                [SPTPlaylistSnapshot playlistWithURI:partialPlaylist.uri session:session callback:^(NSError *error, id object) {
                    if (error != nil){
                        NSLog(@"*** Error on playlist snapshot create %@",error);
                        [[DiscoverfyService sharedService]handleError:NULL withState:@"initialError"];
                        return;
                    }
                    
                    self.discoverfyPlaylist = object;
                    
                }];
                
                
            }
            
            NSString *username = user.name;
            NSString *ownerName = partialPlaylist.owner.canonicalUserName;
            
            if ([username isEqualToString:ownerName]){
                
//                NSLog(@"playlist of %@: %@",username,partialPlaylist.name);

                [self getTracksFromPlaylist:partialPlaylist user:user accessToken:auth.session.accessToken offset:0];
                
            }
        }
        
        if ((items.count == 50) && hasDiscoverfyPlaylist != YES){
//            NSLog(@"Reached limit and no playlist found");
            [self fetchPlaylistSongsWithAccessToken:accessToken session:session offset:(offset + 50) user:user queue:queue callback:nil];
        } else if (items.count < 50 && hasDiscoverfyPlaylist != YES){
//            NSLog(@"Below limit and no item found. Creating new Playlist.");
            
            [SPTPlaylistList createPlaylistWithName:@"Discoverfy App" publicFlag:YES session:session callback:^(NSError *error, SPTPlaylistSnapshot *returnedPlaylist) {
                if (error != nil){
                    NSLog(@"*** Error on playlist create %@",error);
                    [[DiscoverfyService sharedService]handleError:NULL withState:@"initialError"];
                    return;
                } else {
                    self.discoverfyPlaylist = returnedPlaylist;
//                    NSLog(@"Discoverfy playlist created");
                }
                
                dispatch_async(queue, ^{
                
                callbackBlock();
                
                });
                
            }];
            
        } else if(items.count == 50 && hasDiscoverfyPlaylist == YES) {
//            NSLog(@"Below limit and item found! %@",self.discoverfyPlaylist.name);
//            NSLog(@"Retrieving other playlists");
            [self fetchPlaylistSongsWithAccessToken:accessToken session:session offset:(offset + 50) user:user queue:queue callback:nil];
        } else {
//            NSLog(@"Below limit and item was previously found; name: %@",self.discoverfyPlaylist.name);
            dispatch_async(queue, ^{

            callbackBlock();
                
            });
        }
        
    }];

}

-(NSMutableArray *)getRandomArtists{
    
    NSMutableArray *smallArray = [[NSMutableArray alloc]init];
    
    for (int i = 0; i < 5; i++){
        int num = arc4random_uniform(20);
        [smallArray addObject:self.artistList[num]];
    }

    return smallArray;
}

-(void)getTracksFromPlaylist:(SPTPartialPlaylist *)userPlaylist user:(User *)user accessToken:(NSString *)accessToken offset:(int)offset {
    
    NSString *uriString = userPlaylist.uri.absoluteString;
    NSString *uriPrefix = [NSString stringWithFormat:@"spotify:user:%@:playlist:",user.name];
    NSRange range = NSMakeRange(uriPrefix.length,uriString.length - uriPrefix.length);
    NSString *playlistID = [uriString substringWithRange:range];

    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.spotify.com/v1/users/%@/playlists/%@/tracks?limit=100&offset=%d",user.name,playlistID,offset]];
    NSError *errorTrackGet;
    NSURLRequest *request = [SPTRequest createRequestForURL:url withAccessToken:accessToken httpMethod:@"GET" values:nil valueBodyIsJSON:YES sendDataAsQueryString:YES error:&errorTrackGet];
    
    [[SPTRequest sharedHandler]performRequest:request callback:^(NSError *error, NSURLResponse *response, NSData *data) {
        
        if (error != nil) {
            NSLog(@"*** Error on track get from %@: %@",userPlaylist.name,error);
            [[DiscoverfyService sharedService]handleError:NULL withState:@"initialError"];
            return;
        }
        
        
        NSDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        
        NSArray *tracks = [dataDict objectForKey:@"items"];
        
        for (id track in tracks){
            
            NSString *trackID;
            
            if (![[[track objectForKey:@"track"] objectForKey:@"id"] isKindOfClass:[NSNull class]]){
                trackID = [[track objectForKey:@"track"]objectForKey:@"id"];
            }
            
            
            if (trackID){
//                NSLog(@"about to add a spotify song to cored data, %@", context);
                dispatch_async(self.spot_core_data_queue, ^{
//                    NSLog(@"core data thread from adding to spotify song to core data: %@, %@",[NSThread currentThread],context);
                    [privateContext performBlock:^{
                        
                        Song *song = [Song storeSongWithSongID:trackID ofType:@"Spotify" withUser:user inManangedObjectContext:privateContext];
                        
                    }];
                    
                });
                
            }
            
            
        }
        
        if (tracks.count == 100){
            [self getTracksFromPlaylist:userPlaylist user:user accessToken:accessToken offset:offset+100];
        }
        
    }];
}

-(void)queueInitialSongsUsingTracksWithAccessToken:(NSString *)accessToken user:(User*)user callback:(void(^)(void))callbackBlock{
    
    [self fetchTopTracksWithAccessToken:accessToken callback:^(NSArray *trackIDs) {
        
        [self queueBatchSongsUsingTracksWithAccessToken:accessToken user:user callback:^{
            
            if (callbackBlock != nil) {
                return callbackBlock();
            }
            
        }];
        
    }];
    
}

-(void)queueBatchSongsUsingTracksWithAccessToken:(NSString *)accessToken user:(User*)user callback:(void(^)(void))callbackBlock{
    
    [self fetchRecommendedSongsFromTracks:self.topTrackList accessToken:accessToken callback:^(NSArray *resultTracks) {
        
        [self convertTracksWithTracks:resultTracks user:user];
        
        if (callbackBlock != nil) {
            return callbackBlock();
        }
        
    }];
    
}


-(NSArray *)getFiveRandomFromArray:(NSArray*)array{
    
    NSMutableArray *mutableArray = [[NSMutableArray alloc]init];
    
    int arrayCount = self.topTrackList.count;
    
    for (int i = 0; i < 5; i++){
        int num = arc4random_uniform(arrayCount);
        [mutableArray addObject:array[num]];
    }
    
    
    NSArray *smallArray = [NSArray arrayWithArray:mutableArray];
    
    return smallArray;
}

-(void)fetchTopTracksWithAccessToken:(NSString *)accessToken callback:(void (^)(NSArray *trackIDs))callbackBlock {
    
    NSURL *url = [NSURL URLWithString:@"https://api.spotify.com/v1/me/top/tracks?limit=20&time_range=short_term"];
    
    NSError *error;
    NSURLRequest *artistsReq = [SPTRequest createRequestForURL:url withAccessToken:accessToken httpMethod:@"GET" values:nil valueBodyIsJSON:YES sendDataAsQueryString:YES error:&error];
    
    [[SPTRequest sharedHandler]performRequest:artistsReq callback:^(NSError *error, NSURLResponse *response, NSData *data) {

            if(error != nil){
                NSLog(@"*** Error on top track get %@",error);
                [[DiscoverfyService sharedService]handleError:NULL withState:@"batchError"];
                return;
            }
            
            NSError *err;
            NSDictionary *trackDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
            
            NSArray *items = [trackDictionary valueForKey:@"items"];
        
            NSMutableArray *tempIDArray = [[NSMutableArray alloc]init];
        
        if (!self.topTrackList){
            self.topTrackList = [[NSArray alloc]init];
        }
        
            for(NSObject *track in items){
                NSString *id = [track valueForKey:@"id"];
                [tempIDArray addObject:id];
            }
        
        self.topTrackList = [NSArray arrayWithArray:tempIDArray];
        NSLog(@"topTrackList count: %lu", (unsigned long)[self.topTrackList count]);
            
            callbackBlock(self.topTrackList);
        
        return;
        
    }];
    
}


-(void)fetchRecommendedSongsFromTracks:(NSArray *)tracks accessToken:(NSString *)accessToken callback:(void(^)(NSArray *resultTracks))callbackBlock{

    
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"https://api.spotify.com/v1/recommendations?seed_tracks="];
    
    NSArray *fiveRandom = [self getFiveRandomFromArray:tracks];
    
    for (NSString *artistID in fiveRandom){
        [urlString appendString:[NSString stringWithFormat:@"%@,",artistID]];
    }
    
    [urlString deleteCharactersInRange:NSMakeRange([urlString length]-1, 1)];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSError *error;
    NSURLRequest *songReq = [SPTRequest createRequestForURL:url withAccessToken:accessToken httpMethod:@"GET" values:nil valueBodyIsJSON:YES sendDataAsQueryString:YES error:&error];
    
    [[SPTRequest sharedHandler]performRequest:songReq callback:^(NSError *error, NSURLResponse *response, NSData *data) {
            
            if(error != nil){
                NSLog(@"*** Error on song get %@",error);
                [[DiscoverfyService sharedService]handleError:NULL withState:@"batchError"];
                
                return;
            }
            
            NSError *err;
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
            
            
            
            if(err != nil){
                NSLog(@"error of results dictionary %@",err);
                [[DiscoverfyService sharedService]handleError:NULL withState:@"batchError"];
                return;
            }
            
            NSArray *recommendedTracks = [jsonDict objectForKey:@"tracks"];
            
            callbackBlock(recommendedTracks);
        
        return;
    }];
    
}


-(void)emptyArrays{
    
    for (DiscoverfyItem*item in self.player.items){
        [item.asset cancelLoading];
        [self.player removeItem:item];
    }
    
        [self.player removeAllItems];
    
        [self.artistList removeAllObjects];
        [self.uriList removeAllObjects];
        [self.partialTrackList removeAllObjects];
        self.discoverfyPlaylist = nil;

    
}


@end
