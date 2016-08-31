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
    
    return self;
}

-(void)addToService:(SpotifyService *)spot {
    
    AVURLAsset *asset = [[AVURLAsset alloc]initWithURL:self.spotifyTrack.previewURL options:nil];
    NSArray *keys = @[@"playable"];
    
    [asset loadValuesAsynchronouslyForKeys:keys completionHandler:^{
        
        self.playerItem = [AVPlayerItem playerItemWithAsset:asset];
        
        if([spot.player canInsertItem:self.playerItem afterItem:nil]){
            NSLog(@"fingers crossed.");
            
            //// Here is your error!
            
//            if(spot.player.items.count == 0){
//                spot.player
//            }
            
            [spot.player insertItem:self.playerItem afterItem:nil];
            [spot.partialTrackList addObject:self];
            if (spot.partialTrackList.count == 5) {
                [[NSNotificationCenter defaultCenter]postNotificationName:@"BatchReady" object:self];
            }
            
        } else {
            NSLog(@"Unable to add, as unplayable");
        }
         
    }];
}

@end
