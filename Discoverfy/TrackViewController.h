//
//  TrackViewController.h
//  Discoverfy
//
//  Created by Arthur Tonelli on 7/29/16.
//  Copyright © 2016 Arthur Tonelli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "Track.h"

@interface TrackViewController : UIViewController

@property (weak, nonatomic) IBOutlet UISlider *trackSlider;
@property (weak, nonatomic) IBOutlet UIImageView *overlayImage;
@property (nonatomic) BOOL isMainCard;

-(void)updateUIWithTrack:(Track *)track;

@end
