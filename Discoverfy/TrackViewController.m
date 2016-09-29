//
//  TrackViewController.m
//  Discoverfy
//
//  Created by Arthur Tonelli on 7/29/16.
//  Copyright © 2016 Arthur Tonelli. All rights reserved.
//

#import "TrackViewController.h"
#import "SpotifyService.h"
//#import "AlbumImageView.h"


@interface TrackViewController (){
    SpotifyService *spot;
}

@property (weak, nonatomic) IBOutlet AlbumImageView *trackImage;
@property (weak, nonatomic) IBOutlet UILabel *trackTitle;
@property (weak, nonatomic) IBOutlet UILabel *trackArtist;
@property (weak, nonatomic) IBOutlet UILabel *trackAlbum;


@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *pauseButton;
@property (weak, nonatomic) IBOutlet UIButton *restartButton;
@property (weak, nonatomic) IBOutlet UIButton *skipButton;


@end

@implementation TrackViewController

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    NSLog(@"*** touched track view controller");
}


-(void)viewDidLoad{
    spot = [SpotifyService sharedService];
    
    if (self.isMainCard == NO) {
        self.trackSlider.hidden = YES;
    }
    
    [self.trackSlider setThumbImage:[UIImage new] forState:UIControlStateNormal];
    
    
    [NSTimer scheduledTimerWithTimeInterval:.1 target:self selector:@selector(updateSlider) userInfo:NULL repeats:YES];
    
    self.view.layer.borderWidth = 1;
    
    self.view.layer.borderColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0].CGColor;

//    self.view.layer.borderColor = [UIColor colorWithRed:18/255.0 green:122/255.0 blue:216/255.0 alpha:1.0].CGColor;
    self.view.layer.cornerRadius = 2;
    self.view.layer.masksToBounds = YES;
    
    self.playButton.hidden = YES;
    self.overlayImage.hidden = YES;

    self.overlayImage.userInteractionEnabled = YES;
    self.trackImage.userInteractionEnabled = YES;

    
    UIView *subView = self.view.subviews[0];
    
    
        
    CGRect cardRect = [subView bounds];
    CGFloat cardWidth = cardRect.size.width;
    CGFloat cardHeight = cardRect.size.height;
    
//    NSLog(@"card width:%f and card height: %f",cardWidth,cardHeight);
//    
    NSLog(@"card view subview subviews: %@",subView.subviews);
//
//    NSLog(@"************************sub view constraints: %@",subView.bounds);
    
//    NSDictionary *elementsDict = NSDictionaryOfVariableBindings(_trackImage,_overlayImage, _trackSlider,_trackTitle, _trackArtist,_trackAlbum,_playButton,_pauseButton,_restartButton,_skipButton);
//    
//    
//    [subView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-(==%f)-[_trackImage(<=%f)]-(==-%f)-[_overlayImage(<=%f)]-(==0)-[_trackSlider]-[_trackTitle(==33)]-[_trackArtist(==24)]-[_trackAlbum(==24)]-[_playButton(==40)]-(==-40)-[_pauseButton(==40)]-|",cardHeight * 0.015,cardWidth * 1,cardWidth * 1,cardWidth * 1]
//                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
//                                                                      metrics:nil
//                                                                        views:elementsDict]];
//    
//    [subView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:|-(==%f)-[_trackImage(<=%f)]-(==-%f)-[_overlayImage(<=%f)]-(==%f)-|",cardHeight * 0,cardWidth * 1,cardWidth * 1,cardWidth * 1,cardHeight * 0]
//                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
//                                                                      metrics:nil
//                                                                        views:elementsDict]];
//    [subView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:|-(==%f)-[_trackSlider(<=%f)]-(==%f)-|",cardHeight * 0,cardWidth * 1,cardHeight * 0]
//                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
//                                                                      metrics:nil
//                                                                        views:elementsDict]];
//    
//    
//    [subView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:|-(<=%f)-[_trackTitle(==%f)]-(<=%f)-|",cardWidth * .025,cardWidth * .95,cardWidth * .025]
//                                                                    options:NSLayoutFormatDirectionLeadingToTrailing
//                                                                    metrics:nil
//                                                                      views:elementsDict]];
//    [subView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:|-(<=%f)-[_trackArtist(==%f)]-(<=%f)-|",cardWidth * .025,cardWidth * .95,cardWidth * .025]
//                                                                    options:NSLayoutFormatDirectionLeadingToTrailing
//                                                                    metrics:nil
//                                                                      views:elementsDict]];
//    [subView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:|-[_trackAlbum(<=%f)]-|",cardWidth * 1]
//                                                                    options:NSLayoutFormatDirectionLeadingToTrailing
//                                                                    metrics:nil
//                                                                      views:elementsDict]];
    

    
    
    
    
    
    
//    NSDictionary *topUIElements = NSDictionaryOfVariableBindings(_trackImage, _trackSlider,_overlayImage);
//    
//    [subView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-(==%f)-[_trackImage(==%f)]-(==-%f)-[_overlayImage(==%f)]-(==0)-[_trackSlider(==30)]-(>=%f)-|",cardHeight * 0.015,cardWidth * 1,cardWidth * 1,cardWidth * 1, cardHeight * .985 - cardWidth + 30]
//                                                                    options:NSLayoutFormatDirectionLeadingToTrailing
//                                                                    metrics:nil
//                                                                      views:topUIElements]];
//    
//    [subView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:|-(==0)-[_trackImage(==%f)]-(==-%f)-[_overlayImage(==%f)]-(==-%f)-[_trackSlider(==%f)]-(==0)-|",cardWidth * 1,cardWidth * 1,cardWidth * 1,cardWidth * 1,cardWidth * 1]
//                                                                    options:NSLayoutFormatDirectionLeadingToTrailing
//                                                                    metrics:nil
//                                                                      views:topUIElements]];
//    
//    
//    NSDictionary *textUIElements = NSDictionaryOfVariableBindings(_trackTitle, _trackArtist,_trackAlbum);
//    
//    [subView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-(>=%f)-[_trackTitle(==%f)]-(==-%f)-[_trackArtist(==%f)]-(==0)-[_trackAlbum(==30)]-(>=%f)-|",cardHeight * 0.025,36.0,24.0,24.0, cardHeight * .96 - cardWidth + 114]
//                                                                    options:NSLayoutFormatDirectionLeadingToTrailing
//                                                                    metrics:nil
//                                                                      views:textUIElements]];
//    
//    [subView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:|-(==%f)-[_trackTitle(<=%f)]-(==-%f)-[_trackArtist(<=%f)]-(==-%f)-[_trackAlbum(<=%f)]-(==%f)-|",cardWidth * .05,cardWidth * .9,cardWidth * .9,cardWidth * .9,cardWidth * .9,cardWidth * .9,cardWidth * .05]
//                                                                    options:NSLayoutFormatDirectionLeadingToTrailing
//                                                                    metrics:nil
//                                                                      views:textUIElements]];
//    
//    NSDictionary *buttonUIElements = NSDictionaryOfVariableBindings(_playButton, _skipButton,_pauseButton,_restartButton);
//    
//    [subView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-(>=%f)-[_skipButton(==%d)]-(==-%d)-[_playButton(==%d)]-(==-%d)-[_pauseButton(==%d)]-(==%d)-[_restartButton(==%d)]-(>=%d)-|",cardHeight * 0.05,36,42,48,48,48,42, 36, 0]
//                                                                    options:NSLayoutFormatDirectionLeadingToTrailing
//                                                                    metrics:nil
//                                                                      views:buttonUIElements]];
//    
//    [subView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:|-(>=%f)-[_skipButton(<=%d)]-(>=%d)-[_playButton(<=%d)]-(==-%d)-[_pauseButton(==%d)]-(>=%d)-[_restartButton(<=%d)]-(>=%f)-|",cardWidth * 0.05,36,20,48,48,48,20, 36, cardWidth * 0.05]
//                                                                    options:NSLayoutFormatDirectionLeadingToTrailing
//                                                                    metrics:nil
//                                                                      views:buttonUIElements]];

    
    
}

-(void)updateUIWithTrack:(Track *)track{
    self.overlayImage.hidden = YES;
    
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
    self.playButton.hidden = YES;
    self.pauseButton.hidden = NO;
}

- (IBAction)pauseButtonPressed:(id)sender {
    [spot.player pause];
    self.playButton.hidden = NO;
    self.pauseButton.hidden = YES;
}

-(void)updateSlider{
//    if (CMTimeGetSeconds(spot.player.currentTime) == 10){
//        [spot.player seekToTime:kCMTimeZero];
//    }
    self.trackSlider.value = CMTimeGetSeconds(spot.player.currentTime);
}

- (IBAction)restartButtonPressed:(id)sender {
    
    CMTime time = CMTimeMake(0, 1);
    
    [spot.player seekToTime:time];
    
}

@end
