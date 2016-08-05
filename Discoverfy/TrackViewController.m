//
//  TrackViewController.m
//  Discoverfy
//
//  Created by Arthur Tonelli on 7/29/16.
//  Copyright © 2016 Arthur Tonelli. All rights reserved.
//

#import "TrackViewController.h"
#import "SpotifyService.h"


@interface TrackViewController (){
    SpotifyService *spot;
}

@property (weak, nonatomic) IBOutlet UIImageView *trackImage;
@property (weak, nonatomic) IBOutlet UILabel *trackTitle;
@property (weak, nonatomic) IBOutlet UILabel *trackArtist;
@property (weak, nonatomic) IBOutlet UILabel *trackAlbum;


@end

@implementation TrackViewController

-(void)viewDidLoad{
    spot = [SpotifyService sharedService];
    
    if (self.isMainCard == NO) {
        self.trackSlider.hidden = YES;
    }
    
    [self.trackSlider setThumbImage:[UIImage new] forState:UIControlStateNormal];
    
    
    [NSTimer scheduledTimerWithTimeInterval:.1 target:self selector:@selector(updateSlider) userInfo:NULL repeats:YES];
    
    
    
}

-(void)updateUIWithTrack:(Track *)track{
    
    NSLog(@"updating UI from TrackViewController");

    
    self.trackTitle.text = track.spotifyTrack.name;
//    self.trackArtist.text = track.spotifyTrack.artists[0].identifier;
    self.trackAlbum.text = track.spotifyTrack.album.name;
    self.trackImage.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:track.spotifyTrack.album.largestCover.imageURL]];
    

    [spot.player play];

}

- (IBAction)skipButtonPressed:(id)sender {
    
    
    [self updateUIWithTrack:spot.partialTrackList[1]];
    [spot.player advanceToNextItem];
    
    [spot.partialTrackList removeObjectAtIndex:0];

}

- (IBAction)playButtonPressed:(id)sender {
    [spot.player play];
}

- (IBAction)pauseButtonPressed:(id)sender {
    [spot.player pause];
}

-(void)updateSlider{
//    if (CMTimeGetSeconds(spot.player.currentTime) == 10){
//        [spot.player seekToTime:kCMTimeZero];
//    }
    self.trackSlider.value = CMTimeGetSeconds(spot.player.currentTime);
}

@end
