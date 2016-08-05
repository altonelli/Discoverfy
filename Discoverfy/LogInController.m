//
//  LogInController.m
//  Discoverfy
//
//  Created by Arthur Tonelli on 7/26/16.
//  Copyright © 2016 Arthur Tonelli. All rights reserved.
//

#import "LogInController.h"
#import <Spotify/Spotify.h>

@interface LogInController () <SPTAuthViewDelegate>

@property (atomic, readwrite) SPTAuthViewController *authViewController;
@property (atomic, readwrite) BOOL firstLoad;

@end

@implementation LogInController

- (void)viewDidLoad {
//    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(sessionUpdateNotification:) name:@"sessionUpdated" object:nil];
    self.firstLoad = YES;
    
}

-(void)sessionUpdateNotification:(NSNotification *)notification {
    
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
    
    self.authViewController = [SPTAuthViewController authenticationViewController];
    self.authViewController.delegate = self;
    self.authViewController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    self.authViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    self.definesPresentationContext = YES;
    
    [self presentViewController:self.authViewController animated:NO completion:nil];
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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
