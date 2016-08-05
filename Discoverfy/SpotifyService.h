//
//  SpotifyService.h
//  Discoverfy
//
//  Created by Arthur Tonelli on 7/27/16.
//  Copyright © 2016 Arthur Tonelli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Spotify/Spotify.h>
#import <AVFoundation/AVFoundation.h>

@interface SpotifyService : NSObject

@property (nonatomic,strong) NSMutableArray *artistList;
@property (nonatomic,strong) NSMutableArray *uriList;
@property (nonatomic,strong) NSMutableArray *partialTrackList;

@property (nonatomic,strong) SPTPlaylistSnapshot *discoverfyPlaylist;

@property (nonatomic,strong) AVQueuePlayer *player;


+(id)sharedService;

-(void)getArtistsListWithAccessToken:(NSString *)accessToken callback:(void (^)(void))callbackBlock;
-(void)fetchURIsFromArtistsWithAccessToken:(NSString *)accessToken artists:(NSMutableArray *)artists callback:(void(^)(void))callbackBlock;
-(void)verifyDiscoverfyPlaylistWithAccessToken:(NSString *)accessToken session:(SPTSession *)session offset:(int)offset;

-(NSMutableArray *)getRandomArtists;
-(void)loadTracks;

@end
