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

-(void)addToService:(SpotifyService *)spot withQueue:(dispatch_queue_t)queue{
    
    
    AVURLAsset *asset = [[AVURLAsset alloc]initWithURL:self.spotifyTrack.previewURL options:nil];
    NSArray *keys = @[@"playable"];
    NSLog(@"preview asset1: %@",asset);
//    NSLog(@"add to service thread: %@", [NSThread currentThread]);
    
    [asset loadValuesAsynchronouslyForKeys:keys completionHandler:^{
        
        NSError *assetError;
        AVKeyValueStatus status = [asset statusOfValueForKey:@"playable" error:&assetError];
        NSLog(@"asset: %@ | status: %ld | error: %@",asset, (long)status, assetError);

        if (status == AVKeyValueStatusLoaded || status == AVKeyValueStatusLoading) {
        dispatch_async(spot.spot_service_queue, ^{
//            self.playerItem = [AVPlayerItem playerItemWithAsset:asset];
            self.playerItem = [DiscoverfyItem playerItemWithAsset:asset];

            NSLog(@"new player item: %@, asset: %@", self.playerItem, self.playerItem.asset);
            if([spot.player canInsertItem:self.playerItem afterItem:nil]){
                NSLog(@"queued song: %@ with asset: %@ on thread: %@", self.spotifyTrack.name,self.playerItem.asset, [NSThread currentThread]);
                
//                // Here is your error!
//                
//                            if(spot.player.items.count == 0){
//                
//                                spot.player = [[AVQueuePlayer alloc] initWithPlayerItem:self.playerItem];
//                
//                            } else {
                
                
                [spot.player insertItem:self.playerItem afterItem:nil];
                [spot.partialTrackList addObject:self];
                
                NSLog(@"track added: %@; count: %lu on thread: %@",self.spotifyTrack.name, (unsigned long)spot.player.items.count, [NSThread currentThread]);
                
//                            }
                
                if (spot.partialTrackList.count == 5) {
                    [[NSNotificationCenter defaultCenter]postNotificationName:@"BatchReady" object:self];
                    return;
                }
                
            } else {
                NSLog(@"Unable to add, as unplayable");
                return;
            }
            
        });
        } else {
            NSLog(@"*** Error in asset load: %@", assetError);
            [asset cancelLoading];
            return;
        }
        
    }];
}

-(void)dealloc{
    NSLog(@"DEALLOC %@",self.spotifyTrack.name);
}

@end
