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
#import <QuartzCore/QuartzCore.h>


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
    
    [self prepareSlider];

    // Set up Shadow
    
        NSLog(@"track controller view: %@", NSStringFromCGRect(self.view.frame));
        NSLog(@"track controller superview: %@", NSStringFromCGRect(self.view.superview.frame));
        self.view.superview.bounds = self.view.bounds;
        self.view.superview.clipsToBounds = NO;
        self.view.superview.layer.masksToBounds = NO;
        self.view.superview.layer.shadowColor = [UIColor blackColor].CGColor;
        self.view.superview.layer.shadowOffset = CGSizeMake(0,3);
        self.view.superview.layer.shadowOpacity = 0.5;
        self.view.superview.layer.shadowRadius = 7.0f;
        self.view.superview.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.view.bounds].CGPath;
        
}

-(void)viewWillAppear:(BOOL)animated{
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
    self.trackSlider.minimumTrackTintColor = [UIColor colorWithRed:0 green:0 blue:1 alpha:1];
    self.trackSlider.maximumTrackTintColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
    
    
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
    

    self.view.layer.cornerRadius = 2;
    
    self.view.clipsToBounds = YES;
    self.view.layer.masksToBounds = YES;
    
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
    
//    [self updateUIWithTrack:spot.partialTrackList[1]];
//    [spot.player advanceToNextItem];
//    
//    [spot.partialTrackList removeObjectAtIndex:0];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SongSkipped" object:nil];


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

-(void)prepareSlider {
    UIColor *purpleColor = [UIColor colorWithRed:145.0/255.0 green:46.0/255.0 blue:205.0/255.0 alpha:1.0];
    UIColor *darkBlueColor = [UIColor colorWithRed:63.0/255.0 green:56.0/255.0 blue:220.0/255.0 alpha:1.0];
    UIColor *lightBlueColor = [UIColor colorWithRed:65.0/255.0 green:99.0/255.0 blue:251.0/255.0 alpha:1.0];
    
    NSLog(@"cool");
    UIImageView *min_trackImageView = (UIImageView*)[self.trackSlider.subviews objectAtIndex:1];
    NSLog(@"min_trackImageView: %@",min_trackImageView);
    
    CAGradientLayer *gradientLine = [CAGradientLayer layer];
    
    CGRect trackFrame = min_trackImageView.frame;
    trackFrame.size.width = self.trackSlider.frame.size.width;
    
    CGFloat currentSpot = (self.trackSlider.value / 30) * self.trackSlider.frame.size.width;
    CGFloat offset = - (self.trackSlider.frame.size.width - currentSpot);
    
    trackFrame.origin.x = offset;
    trackFrame.origin.y = 0;
    NSLog(@"trackFrame origin: %f", trackFrame.origin.x);
    
    gradientLine.frame = trackFrame;
    
    gradientLine.colors = [NSArray arrayWithObjects:
                           (id)lightBlueColor.CGColor,
                           (id)darkBlueColor.CGColor,
                           (id)purpleColor.CGColor,
                           nil];
    
    gradientLine.startPoint = CGPointMake(0.0, 0.5);
    gradientLine.endPoint = CGPointMake(1.0, 0.5);
    
    
    gradientLine.locations = [NSArray arrayWithObjects:
                              [NSNumber numberWithFloat:0.0],
                              [NSNumber numberWithFloat:0.85],
                              [NSNumber numberWithFloat:0.95],
                              nil];
    
    
    [min_trackImageView.layer insertSublayer:gradientLine atIndex:0];
    
    
}

-(void)updateSlider{

    self.trackSlider.value = CMTimeGetSeconds(spot.player.currentTime);

    UIView *view = [self.trackSlider.subviews objectAtIndex:0];
    
    UIImageView *min_trackImageView = (UIImageView*)[self.trackSlider.subviews objectAtIndex:1];
    
    CAGradientLayer *gradientLayer = (CAGradientLayer*)[min_trackImageView.layer.sublayers objectAtIndex:0];
    
    CGFloat currentSpot = (self.trackSlider.value / 30) * self.trackSlider.frame.size.width;
    CGFloat offset = - (self.trackSlider.frame.size.width - currentSpot);
    
    CGRect trackFrame = gradientLayer.frame;
    trackFrame.size.width = gradientLayer.frame.size.width;
    trackFrame.origin.x = offset;
    trackFrame.origin.y = 0;
    
    
    gradientLayer.frame = trackFrame;
    
}

- (IBAction)restartButtonPressed:(id)sender {
    
    CMTime time = CMTimeMake(0, 1);
    
    [spot.player seekToTime:time];
    
}

@end
