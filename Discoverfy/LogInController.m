//
//  LogInController.m
//  Discoverfy
//
//  Created by Arthur Tonelli on 7/26/16.
//  Copyright © 2016 Arthur Tonelli. All rights reserved.
//

#import "LogInController.h"
#import "MusicViewController.h"
#import "AppDelegate.h"
#import "User.h"
#import "User+CoreDataProperties.h"
#import <Spotify/Spotify.h>
#import "SpotifyService.h"
#import "DiscoverfyService.h"

@interface LogInController () <SPTAuthViewDelegate>

@property (atomic, readwrite) SPTAuthViewController *authViewController;
//@property (atomic, readwrite) BOOL firstLoad;

@end

@implementation LogInController

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    MusicViewController *mainView = [segue destinationViewController];
    NSString *username = [[[SPTAuth defaultInstance]session]canonicalUsername];
    AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    dispatch_sync([[SpotifyService sharedService]spot_core_data_queue], ^{
        
        NSManagedObjectContext *privateContext = [appDelegate privateContext];
        [privateContext performBlock:^{
            
            mainView.user = [User findUserWithUsername:username inManagedObjectContext:privateContext];
            for (NSManagedObject *song in mainView.user.songs){
                [context deleteObject:song];
            }
            [context save:nil];
            NSLog(@"Successfully deleted songs from user. Count now: %u",mainView.user.songs.count);
            
        }];
        
    });
    
    
    

    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        [[DiscoverfyService sharedService]createUser:username];
        
    });
    
    NSLog(@"testUser: %@", mainView.user );
}

- (void)viewDidLoad {
//    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(sessionUpdateNotification:) name:@"sessionUpdated" object:nil];
    self.firstLoad = YES;
    
}

-(void)sessionUpdateNotification:(NSNotification *)notification {
    
    NSLog(@"session updated. in session update notification method.");
    
    if(self.navigationController.topViewController == self){
        SPTAuth *auth = [SPTAuth defaultInstance];
        if(auth.session && [auth.session isValid]){
            [self showPlayer];
        }
    }
}

-(void)showPlayer {
    self.firstLoad = NO;
    [self performSegueWithIdentifier:@"ShowPlayer" sender:nil];
}

-(void)authenticationViewController:(SPTAuthViewController *)authenticationViewController didFailToLogin:(NSError *)error{
    NSLog(@"*** failed to log in: %@",error);
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)authenticationViewController:(SPTAuthViewController *)authenticationViewController didLoginWithSession:(SPTSession *)session{
    [self dismissViewControllerAnimated:YES completion:^{
        [self showPlayer];
    }];
}

-(void)authenticationViewControllerDidCancelLogin:(SPTAuthViewController *)authenticationViewController{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)openLoginPage{
    
//    self.authViewController = [SPTAuthViewController authenticationViewController];
//    self.authViewController.delegate = self;
//    self.authViewController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
//    self.authViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
//    
//    self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
//    self.definesPresentationContext = YES;
//    
//    [self presentViewController:self.authViewController animated:NO completion:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    SPTAuth *auth = [SPTAuth defaultInstance];
    
    if(auth.session == nil){
        return;
    }
    
    if([auth.session isValid] && self.firstLoad){
        [self showPlayer];
        return;
    }
    
    if(auth.hasTokenRefreshService){
        [self renewTokenAndShowPlayer];
        return;
    }
}

-(void) renewTokenAndShowPlayer{
    SPTAuth *auth = [SPTAuth defaultInstance];
    
    [auth renewSession:auth.session callback:^(NSError *error, SPTSession *session) {
        auth.session = session;
        
        if(error){
            NSLog(@"*** Error renewing session: %@",error);
            return;
        }
        
        [self showPlayer];
    }];
}

- (IBAction)logInButtonPressed:(id)sender {
    [self openLoginPage];
    NSURL *loginURL = [[SPTAuth defaultInstance] loginURL];
    
    [[UIApplication sharedApplication] performSelector:@selector(openURL:) withObject:loginURL afterDelay:0.5];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
