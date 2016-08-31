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

@interface Track : NSObject

@property (nonatomic, strong) SPTPartialTrack *spotifyTrack;
@property (nonatomic, strong) AVPlayerItem *playerItem;

-(id)initWithSpotifyTrack:(SPTPartialTrack *)track;
-(void)addToService:(SpotifyService *)spot;

@end
