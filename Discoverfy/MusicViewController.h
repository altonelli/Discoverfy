//
//  MusicViewController.h
//  Discoverfy
//
//  Created by Arthur Tonelli on 7/26/16.
//  Copyright © 2016 Arthur Tonelli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Spotify/Spotify.h>
#import <AVFoundation/AVFoundation.h>
#import "User.h"


@interface MusicViewController : UIViewController <SPTAudioStreamingDelegate, SPTAudioStreamingPlaybackDelegate>

@property (nonatomic,strong) User* user;
@property (nonatomic) BOOL firstPlay;
@property (nonatomic) BOOL queuing;



-(void)printArtists;

@end
