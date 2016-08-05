
//  SpotifyService.m
//  Discoverfy
//
//  Created by Arthur Tonelli on 7/27/16.
//  Copyright © 2016 Arthur Tonelli. All rights reserved.
//

#import "SpotifyService.h"
#import "Track.h"

@interface SpotifyService (){
    SPTPlaylistList *playlist;
    BOOL hasDiscoverfyPlaylist;
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
        _artistList = [[NSMutableArray alloc]init];
        _uriList = [[NSMutableArray alloc]init];
        _partialTrackList = [[NSMutableArray alloc]init];
        self.player = [[AVQueuePlayer alloc]init];
        self.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(trackDidFinish:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:self.player.currentItem];
    
    }
    return self;
}

-(void)trackDidFinish:(NSNotification *)notification{
    AVPlayerItem *item = [notification object];
    [item seekToTime:kCMTimeZero];
}

-(void)getArtistsListWithAccessToken:(NSString *)accessToken callback:(void (^)(void))callbackBlock {
    
    NSURL *url = [NSURL URLWithString:@"https://api.spotify.com/v1/me/top/artists?limit=20"];
    
    NSError *error;
    NSURLRequest *artistsReq = [SPTRequest createRequestForURL:url withAccessToken:accessToken httpMethod:@"GET" values:nil valueBodyIsJSON:YES sendDataAsQueryString:YES error:&error];
    
    [[SPTRequest sharedHandler]performRequest:artistsReq callback:^(NSError *error, NSURLResponse *response, NSData *data) {
        if(error != nil){
            NSLog(@"*** Error on top artist get %@",error);
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
    }];
}

-(void)fetchURIsFromArtistsWithAccessToken:(NSString *)accessToken artists:(NSMutableArray *)artists callback:(void(^)(void))callbackBlock{
    
    
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"https://api.spotify.com/v1/recommendations?seed_artists="];
    
    for (NSString *artistID in artists){
        [urlString appendString:[NSString stringWithFormat:@"%@,",artistID]];
    }
    
    [urlString deleteCharactersInRange:NSMakeRange([urlString length]-1, 1)];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSLog(@"spotify url %@", url);
    
    NSError *error;
    NSURLRequest *songReq = [SPTRequest createRequestForURL:url withAccessToken:accessToken httpMethod:@"GET" values:nil valueBodyIsJSON:YES sendDataAsQueryString:YES error:&error];
    
    [[SPTRequest sharedHandler]performRequest:songReq callback:^(NSError *error, NSURLResponse *response, NSData *data) {
        if(error != nil){
            NSLog(@"*** Error on song get %@",error);
            return;
        }
        
        NSError *err;
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
        
        
        
        if(err != nil){
            NSLog(@"error of results dictionary %@",err);
        }
        
        NSArray *tracks = [jsonDict objectForKey:@"tracks"];
        
        for (NSDictionary *track in tracks){
            [self.uriList addObject:track];
            
            NSError *partialError;
            SPTPartialTrack *partialtrack = [SPTPartialTrack partialTrackFromDecodedJSON:track error:&partialError];
            
            if(error != nil){
                NSLog(@"*** Partial Error %@",partialError);
            }
            
            Track *newTrack = [[Track alloc]initWithSpotifyTrack:partialtrack];
            
            [self.partialTrackList addObject:newTrack];
            
        };
        
        callbackBlock();
        
    }];
   
}

-(void)verifyDiscoverfyPlaylistWithAccessToken:(NSString *)accessToken session:(SPTSession *)session offset:(int)offset{
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.spotify.com/v1/me/playlists?offset=%d&limit=50",offset]];
    
    NSError *error;
    NSURLRequest *playlistsReq = [SPTRequest createRequestForURL:url withAccessToken:accessToken httpMethod:@"GET" values:nil valueBodyIsJSON:YES sendDataAsQueryString:YES error:&error];
    
    
    
    [[SPTRequest sharedHandler]performRequest:playlistsReq callback:^(NSError *error, NSURLResponse *response, NSData *data) {
        if (error != nil){
            NSLog(@"*** Error on playlist get %@",error);
        }
        playlist = [SPTPlaylistList playlistListFromData:data withResponse:response error:&error];
        
        NSArray *items = [playlist valueForKey:@"items"];
        
        for (SPTPartialPlaylist *partial in items){
            NSLog(@"partial playlist name %@", partial.name);
            if ([partial.name  isEqual: @"Discoverfy App"]) {
                hasDiscoverfyPlaylist = YES;
                
                NSLog(@"FOUND!");
                
                [SPTPlaylistSnapshot playlistWithURI:partial.uri session:session callback:^(NSError *error, id object) {
                    if (error != nil){
                        NSLog(@"*** Error on playlist snapshot create %@",error);
                    }
                    
                    self.discoverfyPlaylist = object;
                    
                }];
                
                break;
            }
        }
        
        if ((items.count == 50) && hasDiscoverfyPlaylist != YES){
            NSLog(@"Reached limit and no playlist found");
            [self verifyDiscoverfyPlaylistWithAccessToken:accessToken session:session offset:(offset+50)];
        } else if (items.count < 50 && hasDiscoverfyPlaylist != YES){
            NSLog(@"Below limit and no item found. Creating new Playlist.");
            
            [SPTPlaylistList createPlaylistWithName:@"Discoverfy App" publicFlag:NO session:session callback:^(NSError *error, SPTPlaylistSnapshot *playlist) {
                if (error != nil){
                    NSLog(@"*** Error on playlist create %@",error);
                } else {
                    self.discoverfyPlaylist = playlist;
                    NSLog(@"Discoverfy playlist created");
                }
                
            }];
            
        } else {
            NSLog(@"Below limit and item found! %@",self.discoverfyPlaylist.name);
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

-(void)loadTracks{
    NSString *accessToken = [[[SPTAuth defaultInstance] session]accessToken];
    
    
    [self getArtistsListWithAccessToken:accessToken callback:^{
        
        
        NSMutableArray *randArtists = [self getRandomArtists];
        
        [self fetchURIsFromArtistsWithAccessToken:accessToken artists:randArtists callback:^{
            
            NSMutableArray *itemsToBeRemoved = [[NSMutableArray alloc]init];
            
            for (Track *track in self.partialTrackList) {
                
                if([self.player canInsertItem:track.playerItem afterItem:nil]){
                    
                    [self.player insertItem:track.playerItem afterItem:nil];
                    
                } else {
                    
                    [itemsToBeRemoved addObject:track];
                    
                }
                
            }
            NSArray *copy = [itemsToBeRemoved copy];
            [self.partialTrackList removeObjectsInArray:copy];
            
        }];
        
    }];
}


//-(void) addTrack

@end
