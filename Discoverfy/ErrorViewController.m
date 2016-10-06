//
//  ErrorViewController.m
//  Discoverfy
//
//  Created by Arthur Tonelli on 8/27/16.
//  Copyright © 2016 Arthur Tonelli. All rights reserved.
//

#import "ErrorViewController.h"
#import "SpotifyService.h"
#import "DiscoverfyService.h"
#import "MusicViewController.h"
#import "Song.h"
#import "AppDelegate.h"
#import <Spotify/Spotify.h>
#import "DiscoverfyError.h"
#import "PopOverView.h"

@interface ErrorViewController ()

@property (nonatomic,weak) IBOutlet UILabel *text;
@property (nonatomic,weak) IBOutlet UIActivityIndicatorView *spinner;


@end

@implementation ErrorViewController

-(void)loadView{
    [super loadView];
    
    PopOverView *view = [[PopOverView alloc] init];
    
    self.view = view;
    
    self.view.bounds = CGRectMake(0, 0, 240, 128);
    
    [self addElements];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(displayView:)
                                                name:@"ConnectivityError"
                                              object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(handleNoNetworkError:)
                                                name:@"NoNetworkConnectivity"
                                              object:nil];

}


-(void)handleNoNetworkError:(NSNotification *)notification{
    
    DiscoverfyError *error = [notification object];
    self.discError = error;
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)refresh:(id)sender {
    SpotifyService *spot = [SpotifyService sharedService];
    SPTSession *session = [[SPTAuth defaultInstance]session];
    NSString *accessToken = [session accessToken];
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    if ([self.discError.appState  isEqual: @"batchError"]) {
    
            [spot queueSongsWithAccessToken:accessToken user:self.user queue:dispatch_get_main_queue() callback:^{
                self.parentController.queuing = NO;
                self.parentController.mainContainer.userInteractionEnabled = YES;
                [spot.player play];
                [self.view removeFromSuperview];
            }];
        
    } else if ([self.discError.appState isEqualToString:@"intialBatch"]){
        
        dispatch_group_t group = dispatch_group_create();
        
        dispatch_group_enter(group);
        [[DiscoverfyService sharedService]fetchSongsWithUser:self.user.name completionHandler:^(NSArray *tracks) {
            for (NSDictionary *track in tracks) {
                NSString *songID = [track valueForKey:@"songID"];
                NSString *type = [track valueForKey:@"type"];
                [Song storeSongWithSongID:songID ofType:type withUser:self.user inManangedObjectContext:context];
            }
            NSLog(@"************************************ Discoverfy fetch complete");
            dispatch_group_leave(group);
        }];
        
        
        dispatch_group_enter(group);
        [spot fetchPlaylistSongsWithAccessToken:accessToken session:session offset:0 user:self.user queue:dispatch_get_main_queue() callback:^{
            
            // Retreived Songs from Spotify Users Playlists. Next retrieve favorite artists.
            NSLog(@"******************************** Spotify fetch complete");
            dispatch_group_leave(group);
            
        }];
        
        
        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            
            NSLog(@"******************************** fetching Artists");
            
            [spot getArtistsListWithAccessToken:accessToken queue:dispatch_get_main_queue() callback:^{
                
                [spot queueSongsWithAccessToken:accessToken user:self.user queue:dispatch_get_main_queue() callback:^{
                    
                    NSLog(@"************************************** Song Queueing Complete");
                    
                }];
            }];
            
        });
        
    }
    
}

-(void)addElements{
    
    UILabel *text = [[UILabel alloc]init];
    text.text = @"An Error Occured";
    text.textColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    text.font = [UIFont fontWithName:@"Futura" size:20.0];
    text.frame = CGRectMake(20.0, 20.0, 200.0, 35.0);
    text.textAlignment = NSTextAlignmentCenter;
    self.text = text;

    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(60, 71, 120, 37)];
    [button setTitle:@"Try Again" forState:UIControlStateNormal];
    button.titleLabel.textColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    button.titleLabel.font = [UIFont fontWithName:@"Futura" size:15.0];
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    [button setBackgroundColor:[UIColor colorWithRed:65/255.0 green:230/255.0 blue:218/255.0 alpha:1.0]];
    [button addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventTouchDown];
    

    
    [self.view addSubview:self.text];
    [self.view addSubview:button];
    
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
