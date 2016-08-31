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
#import "User.h"

@interface SpotifyService : NSObject

@property (nonatomic,strong) NSMutableArray *artistList;
@property (nonatomic,strong) NSMutableArray *uriList;
@property (nonatomic,strong) NSMutableArray *partialTrackList;

@property (nonatomic,strong) SPTPlaylistSnapshot *discoverfyPlaylist;

@property (nonatomic,strong) AVQueuePlayer *player;


+(id)sharedService;

-(void)getArtistsListWithAccessToken:(NSString *)accessToken queue:(dispatch_queue_t)queue callback:(void (^)(void))callbackBlock;

-(void)fetchPlaylistSongsWithAccessToken:(NSString *)accessToken session:(SPTSession *)session offset:(int)offset user:(User *)user queue:(dispatch_queue_t)queue  callback:(void(^)(void))callbackBlock;

-(void)fetchRecommendedSongsFromArtists:(NSMutableArray *)artists accessToken:(NSString *)accessToken queue:(dispatch_queue_t)queue callback:(void(^)(NSArray *))callbackBlock;

-(void)convertTracksWithTracks:(NSArray *)tracks user:(User *)user completion:(nullable void (^)(void))callbackBlock;

-(void)queueSongsWithAccessToken:(NSString *)accessToken user:(User*)user queue:(dispatch_queue_t)queue callback:(nullable void (^)(void))callbackBlock;

-(NSMutableArray *)getRandomArtists;

@end
