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
#import "UIImage+animatedGIF.h"

@interface LogInController () <SPTAuthViewDelegate> {
    User *user;
}

@property (atomic, readwrite) SPTAuthViewController *authViewController;
@property (nonatomic, strong) UIImageView *logoView;
//@property (atomic, readwrite) BOOL firstLoad;

@end

@implementation LogInController

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([[segue identifier]isEqualToString:@"ShowPlayer"]){
        
        MusicViewController *mainView = (MusicViewController *)[segue destinationViewController];
        mainView.user = user;
        
    }
    
}

- (void)viewDidLoad {
//    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(sessionUpdateNotification:) name:@"sessionUpdated" object:nil];
    self.firstLoad = YES;
    
    // Set up background gradient colors
    
    UIColor* skyBlue = [UIColor colorWithRed:71.0/255.0 green:181.0/255.0 blue:255.0/255.0 alpha:1.0];
    UIColor* teal = [UIColor colorWithRed:54.0/255.0 green:236.0/255.0 blue:244.0/255.0 alpha:1.0];
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)skyBlue.CGColor, (id)teal.CGColor, nil];
    
    gradient.locations = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0], [NSNumber numberWithFloat:1.0], nil];
    
    
    [self.view.layer insertSublayer:gradient atIndex:0];
    
    
    // Add Logo to center of Screen
    
    CGFloat screenWidth = self.view.bounds.size.width;
    CGFloat screenHeight = self.view.bounds.size.height;
    
    CGFloat logoX = screenWidth / 2 - 100;
    CGFloat logoY = screenHeight / 2 - 100;
    
    CGRect logoFrame = CGRectMake(logoX, logoY, 200, 200);

    
    UIImage *logo = [UIImage imageNamed:@"FinalLogo.png"];
    self.logoView = [[UIImageView alloc]initWithFrame:logoFrame];
    self.logoView.image = logo;
    
    [self.view addSubview:self.logoView];
    
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
    [self prepUserForSegueWithCompletionBlock:^{
        
        NSLog(@"woooo back to showplayer!");
        [self performSegueWithIdentifier:@"ShowPlayer" sender:nil];
        
    }];
}

-(void)prepUserForSegueWithCompletionBlock:(void(^)(void))completionBlock {
    
    NSString *username = [[[SPTAuth defaultInstance]session]canonicalUsername];
    AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_group_enter(group);
    dispatch_sync([[SpotifyService sharedService]spot_core_data_queue], ^{
        
        NSManagedObjectContext *privateContext = [appDelegate privateContext];
        [privateContext performBlock:^{
            
            user = [User findUserWithUsername:username inManagedObjectContext:privateContext];
            for (NSManagedObject *song in user.songs){
                [privateContext deleteObject:song];
            }

            [privateContext save:nil];
            
            dispatch_group_leave(group);
        }];
        
    });
    
    
    
    
    dispatch_group_enter(group);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        [[DiscoverfyService sharedService]createUser:username];
        dispatch_group_leave(group);

        
    });
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"woooo leaving group!");
        completionBlock();
        return;
    });
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
    SPTSession *oldSession;
    
    if ([[NSUserDefaults standardUserDefaults]objectForKey:auth.sessionUserDefaultsKey] != nil) {

        // add gif view to show working
        
        NSURL *gifPath = [[NSBundle mainBundle]URLForResource:@"newLoading" withExtension:@"gif"];
        NSData *gifData = [[NSData alloc] initWithContentsOfURL:gifPath];
        
        self.logoView.image = [UIImage animatedImageWithAnimatedGIFData:gifData];
        
        
        NSData *defaultsData = [[NSUserDefaults standardUserDefaults]objectForKey:auth.sessionUserDefaultsKey];
        oldSession = [NSKeyedUnarchiver unarchiveObjectWithData:defaultsData];
        [auth setSession:oldSession];
        
        NSLog(@"here is your tokenRefreshService from defaults: %@",auth.tokenRefreshURL);
        

    }
    
    
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
        
        NSLog(@"got new token");
        NSLog(@"session after: %@", auth.session.accessToken);
        NSLog(@"encrypted token after: %@", auth.session.encryptedRefreshToken);
        
        NSData *sessionData = [NSKeyedArchiver archivedDataWithRootObject:auth.session];
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        
        if ([defaults objectForKey:auth.sessionUserDefaultsKey] != nil) {
            [defaults removeObjectForKey:auth.sessionUserDefaultsKey];
        }
        
        [defaults setObject:sessionData forKey:auth.sessionUserDefaultsKey];
        [defaults synchronize];
        
        if(error){
            NSLog(@"*** Error renewing session: %@",error);
            return;
        }
        
        [self showPlayer];
    }];
}


- (IBAction)logInButtonPressed:(id)sender {
    [self openLoginPage];
    SPTAuth *auth = [SPTAuth defaultInstance];
//    NSURL *loginURL = [auth loginURL];
//    NSLog(@"login URL: %@",loginURL);
    NSURL *newLogInURL = [SPTAuth loginURLForClientId:auth.clientID withRedirectURL:auth.redirectURL scopes:auth.requestedScopes responseType:@"code"];
    
//    [[UIApplication sharedApplication] performSelector:@selector(openURL:) withObject:loginURL afterDelay:0.5];
    [[UIApplication sharedApplication] performSelector:@selector(openURL:) withObject:newLogInURL afterDelay:0.5];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
