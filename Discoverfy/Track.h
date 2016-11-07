//
//  Track.h
//  Discoverfy
//
//  Created by Arthur Tonelli on 7/28/16.
//  Copyright © 2016 Arthur Tonelli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Spotify/Spotify.h>
#import <AVFoundation/AVFoundation.h>
#import "SpotifyService.h"
#import "DiscoverfyItem.h"

@interface Track : NSObject

@property (nonatomic, strong) SPTPartialTrack *spotifyTrack;
//@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (atomic, weak) DiscoverfyItem *playerItem;


-(id)initWithSpotifyTrack:(SPTPartialTrack *)track;
-(void)addToService:(SpotifyService *)spot withQueue:(dispatch_queue_t)queue;

@end
