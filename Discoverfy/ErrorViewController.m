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

@interface ErrorViewController ()

@end

@implementation ErrorViewController

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
    
    self.view.layer.borderWidth = 1;
    
    self.view.layer.borderColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0].CGColor;
    
    //    self.view.layer.borderColor = [UIColor colorWithRed:18/255.0 green:122/255.0 blue:216/255.0 alpha:1.0].CGColor;
    self.view.layer.cornerRadius = 2;
    self.view.layer.masksToBounds = YES;
//    NSLog(@"******************************************************** parent of error view controller and current ctrl: %@ | %@",self.parentViewController, self);
}

-(void)displayView:(NSNotification *)notification{
    
    self.view.hidden = NO;
    
}

-(void)handleNoNetworkError:(NSNotification *)notification{
    
    self.view.hidden = NO;
    
    
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
    
    if ([self.errorState  isEqual: @"batchError"]) {
    
            [spot queueSongsWithAccessToken:accessToken user:self.user queue:dispatch_get_main_queue() callback:^{
                self.parentController.queuing = NO;
                self.parentController.mainContainer.userInteractionEnabled = YES;
                [spot.player play];
                self.view.hidden = YES;
            }];
        
    } else if ([self.errorState isEqualToString:@"intial"]){
        
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
