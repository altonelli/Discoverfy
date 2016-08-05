//
//  Track.m
//  Discoverfy
//
//  Created by Arthur Tonelli on 7/28/16.
//  Copyright © 2016 Arthur Tonelli. All rights reserved.
//

#import "Track.h"

@implementation Track



-(id)initWithSpotifyTrack:(SPTPartialTrack *)track {
    self = [super init];
    
    self.spotifyTrack = track;
        
    self.playerItem = [[AVPlayerItem alloc] initWithURL:self.spotifyTrack.previewURL];
    
    
    return self;
}

@end
