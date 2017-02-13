//
//  ErrorViewController.h
//  Discoverfy
//
//  Created by Arthur Tonelli on 8/27/16.
//  Copyright © 2016 Arthur Tonelli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "MusicViewController.h"
#import "DiscoverfyError.h"

@interface ErrorViewController : UIViewController

@property (nonatomic,strong) DiscoverfyError *discError;
@property (nonatomic,strong) User *user;
@property (nonatomic,weak) MusicViewController *parentController;

-(id)initWithDiscoverfyError:(DiscoverfyError *)discError;


@end
