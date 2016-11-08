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
#import "ImageButton.h"
#import "UIFont+AutoHeightFont.h"
#import "AutoHeightFont.h"


@interface TrackViewController (){
    SpotifyService *spot;
}

@property (weak, nonatomic) IBOutlet AlbumImageView *trackImage;
@property (weak, nonatomic) IBOutlet UILabel *trackTitle;
@property (weak, nonatomic) IBOutlet UILabel *trackArtist;
@property (weak, nonatomic) IBOutlet UILabel *trackAlbum;


//@property (weak, nonatomic) IBOutlet UIButton *playButton;
//@property (weak, nonatomic) IBOutlet UIButton *pauseButton;
@property (weak, nonatomic) IBOutlet UIButton *restartButton;
@property (weak, nonatomic) IBOutlet UIButton *skipButton;
@property (weak, nonatomic) IBOutlet ImageButton *overlayButton;


@end

@implementation TrackViewController


-(void)viewDidAppear:(BOOL)animated{
//    UIView *subView = self.view.subviews[0];
//    
//    NSLog(@"card view subview subviews: %@",subView.subviews);
//    NSLog(@"***** CARD BOUNDS: %@", NSStringFromCGRect(subView.bounds));
//    NSLog(@"***** IMAGE1 BOUNDS: %@", NSStringFromCGRect(subView.subviews[2].frame));
//    NSLog(@"***** IMAGE1 HIDDEN: %hhd", subView.subviews[2].hidden);
//    NSLog(@"***** IMAGE2 BOUNDS: %@", NSStringFromCGRect(subView.subviews[3].frame));
//    NSLog(@"***** IMAGE2 HIDDEN: %hhd", subView.subviews[3].hidden);
}

-(void)viewDidLoad{
    spot = [SpotifyService sharedService];
    
    UIView *subView = self.view.subviews[0];
    
    CGRect cardRect = [subView bounds];
    CGFloat cardWidth = cardRect.size.width;
    CGFloat cardHeight = cardRect.size.height;
    
    CGFloat titleHeight = cardHeight - cardWidth - 80;
    CGFloat titleSpace = titleHeight * .05;
    
    NSDictionary *imageElements = NSDictionaryOfVariableBindings(_trackImage,_trackTitle,_trackArtist,_trackAlbum);
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-(==0)-[_trackImage(<=%f)]-(>=%f)-[_trackTitle(==%f)]-(>=%f)-[_trackArtist(==%f)]-(>=%f)-[_trackAlbum(==%f)]-(>=80)-|",(cardWidth),titleSpace,(titleHeight * .35),titleSpace,(titleHeight * .30),titleSpace,(titleHeight * .30)]
                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                                                      metrics:nil
                                                                        views:imageElements]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:|-(==0)-[_trackImage(<=%f)]-(==0)-|",(cardWidth)]
                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                                                      metrics:nil
                                                                        views:imageElements]];
    
    UIFont *titleAutoFont = [UIFont autoHeightFontWithName:self.trackTitle.font.fontName forUILabelSize:self.trackTitle.frame.size withMinSize:0];
    self.trackTitle.font = titleAutoFont;
    
    UIFont *artistAutoFont = [UIFont autoHeightFontWithName:self.trackArtist.font.fontName forUILabelSize:self.trackArtist.frame.size withMinSize:0];
    self.trackArtist.font = artistAutoFont;
    
    UIFont *albumAutoFont = [UIFont autoHeightFontWithName:self.trackAlbum.font.fontName forUILabelSize:self.trackAlbum.frame.size withMinSize:0];
    self.trackAlbum.font = albumAutoFont;

    
    NSDictionary *overlayImageElements = NSDictionaryOfVariableBindings(_overlayImage);
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-(==0)-[_overlayImage(<=%f)]-(>=0)-|",(cardWidth)]
                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                                                      metrics:nil
                                                                        views:overlayImageElements]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:|-(==0)-[_overlayImage(<=%f)]-(==0)-|",(cardWidth)]
                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                                                      metrics:nil
                                                                        views:overlayImageElements]];
    
    
    
    if (self.isMainCard == NO) {
        self.trackSlider.hidden = YES;
    }
    
    [self.trackSlider setThumbImage:[UIImage new] forState:UIControlStateNormal];
    
    
    [NSTimer scheduledTimerWithTimeInterval:.05 target:self selector:@selector(updateSlider) userInfo:NULL repeats:YES];
    
    self.view.layer.borderWidth = 1;
    
    self.view.layer.borderColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0].CGColor;
    
    UIColor* skyBlue = [UIColor colorWithRed:71.0/255.0 green:181.0/255.0 blue:255.0/255.0 alpha:1.0];
    UIColor* teal = [UIColor colorWithRed:54.0/255.0 green:236.0/255.0 blue:244.0/255.0 alpha:1.0];
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)skyBlue.CGColor, (id)teal.CGColor, nil];
    
    gradient.locations = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.25], [NSNumber numberWithFloat:0.45], nil];
    
    
    [self.view.layer insertSublayer:gradient atIndex:0];
    
    

//    self.view.layer.borderColor = [UIColor colorWithRed:18/255.0 green:122/255.0 blue:216/255.0 alpha:1.0].CGColor;
    self.view.layer.cornerRadius = 2;
    self.view.layer.masksToBounds = YES;
    
    self.view.clipsToBounds = YES;
    
    self.playButton.hidden = YES;
    self.overlayImage.hidden = YES;
    

    
    self.overlayImage.layer.cornerRadius = 2;
    self.overlayImage.layer.masksToBounds = YES;

    
    self.trackImage.layer.cornerRadius = 2;
    self.trackImage.layer.masksToBounds = YES;

}

-(void)updateUIWithTrack:(Track *)track{
    self.overlayImage.hidden = YES;
    
    self.trackTitle.text = track.spotifyTrack.name;
    SPTPartialArtist *artist = track.spotifyTrack.artists[0];
    self.trackArtist.text = artist.name;
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
