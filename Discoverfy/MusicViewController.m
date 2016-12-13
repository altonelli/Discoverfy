//
//  MusicViewController.m
//  Discoverfy
//
//  Created by Arthur Tonelli on 7/26/16.
//  Copyright © 2016 Arthur Tonelli. All rights reserved.
//

#import "MusicViewController.h"
#import "SpotifyService.h"
#import "DiscoverfyService.h"
#import "Track.h"
#import "TrackViewController.h"
#import "ErrorViewController.h"
#import "AppDelegate.h"
#import "User.h"
#import "Song.h"
#import "Reachability.h"
#import "LogInController.h"
#import "SpinnerViewController.h"
#import "DiscoverfyError.h"
#import "Constants.h"


@interface MusicViewController (){
    SpotifyService *spot;
    NSString *accessToken;
    SPTSession *session;
    NSManagedObjectContext *context;
    NSManagedObjectContext *privateContext;
    dispatch_queue_t spot_data_queue;
    CGRect screenRect;
    CGFloat screenWidth;
    CGFloat screenHeight;
}

@property (weak, nonatomic) IBOutlet UIView *rearContainer;
@property (nonatomic,strong) TrackViewController *rearTrackController;
//@property (nonatomic,strong) TrackViewController *trackController;
@property (weak, nonatomic) IBOutlet UIView *topViewColor;
@property (weak, nonatomic) IBOutlet UIView *bottomViewColor;
@property (nonatomic,strong) ErrorViewController *errorController;
@property (nonatomic,strong) SpinnerViewController *spinnerController;

@end



@implementation MusicViewController

-(void)loadView{
    [super loadView];
    
    screenRect = [[UIScreen mainScreen]bounds];
    screenWidth = screenRect.size.width;
    screenHeight = screenRect.size.height;
    
    
    [self.view setNeedsUpdateConstraints];
    
    
    
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    NSString *segueName = segue.identifier;
    if([segueName isEqualToString:@"embedSegue"]){
        self.trackController = (TrackViewController *) [segue destinationViewController];
        self.trackController.isMainCard = YES;
    }
    
    if([segueName isEqualToString:@"embedSegue2"]){
        self.rearTrackController = (TrackViewController *) [segue destinationViewController];
        self.rearTrackController.isMainCard = NO;
//        self.rearTrackController.userInteractionEnabled = NO;
    }
    
    
    if([segueName isEqualToString:@"logOutSegue"]){
        
        NSLog(@"************* LOG OUT CALLED ****************");
        
        [[spot player]pause];
        
        [[SPTAuthViewController authenticationViewController]clearCookies:nil];
        
        SPTAuth *auth = [SPTAuth defaultInstance];
        
        [auth setSession:nil];
        
        [spot emptyArrays];
        
        [self.user removeAllSongsFromUser:self.user.name inManagedObjectContext:context];
        
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:[auth sessionUserDefaultsKey]];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        LogInController *logInCtrl = [segue destinationViewController];
        
        logInCtrl.firstLoad = YES;
    }
    
}

-(void)viewDidLoad{
    [super viewDidLoad];
    
    
    self.firstPlay = YES;
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(batchReady:)
                                                name:@"BatchReady"
                                              object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(handleNoNetworkError:)
                                                name:@"NoNetworkConnectivity"
                                              object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(handleErrorResolve:)
                                                name:@"ErrorResolved"
                                              object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(handleSongSkipped:)
                                                name:@"SongSkipped"
                                              object:nil];
    
    
    
    
    // Set up context
    spot = [SpotifyService sharedService];

    spot_data_queue = dispatch_queue_create("com.discoverfy.songsQueue", DISPATCH_QUEUE_CONCURRENT);
    
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    
    context = [appDelegate managedObjectContext];
    
    dispatch_async(spot.spot_core_data_queue, ^{
    
        privateContext = [appDelegate privateContext];
        
    });
    
    
    
    session = [SPTAuth defaultInstance].session;
    accessToken = session.accessToken;
    
//    self.errorController = [[ErrorViewController alloc]init];
    
    
    self.spinnerController = [[SpinnerViewController alloc]init];
    [self.view addSubview:self.spinnerController.view];
//    self.spinnerController.view.frame = CGRectMake(screenWidth/2 - 110, screenHeight/2 - 64, 220, 128);
    
    
    
    if([[DiscoverfyService sharedService]hasNetworkConnection]){
        
        dispatch_group_t group = dispatch_group_create();
        
        dispatch_group_enter(group);
//        [[DiscoverfyService sharedService]fetchSongsWithUser:self.user.name completionHandler:^(NSArray *tracks) {
//            for (NSDictionary *track in tracks) {
//                NSString *songID = [track valueForKey:@"songID"];
//                NSString *type = [track valueForKey:@"type"];
//                [Song storeSongWithSongID:songID ofType:type withUser:self.user inManangedObjectContext:context];
//            }
//            NSLog(@"************************************ Discoverfy fetch complete");
//            dispatch_group_leave(group);
//        }];
        NSLog(@"**********HERE**************");
        NSLog(@"here is your username: %@", self.user.name);
        
        [[DiscoverfyService sharedService]fetchSongsWithUser:self.user.name offset:0 limit:100 addToArray:NULL completionHandler:^(NSMutableArray *tracks) {
            
            NSLog(@"total songs downladed: %lu",(unsigned long)tracks.count);
            
            dispatch_async(spot.spot_core_data_queue, ^{
                [privateContext performBlock:^{
                    
                    for (NSDictionary *track in tracks) {
                        NSString *songID = [track valueForKey:@"songID"];
                        NSString *type = [track valueForKey:@"type"];
                        [Song storeSongWithSongID:songID ofType:type withUser:self.user inManangedObjectContext:privateContext];
                    }
                
                }];
                
            });
            
            
//            User *user = [User findUserWithUsername:self.user.name inManagedObjectContext:context];
//            [user countAllSongsFromUser:self.user.name inManagedObjectContext:context];
            dispatch_async(spot.spot_core_data_queue, ^{
                [privateContext performBlock:^{
                    
                    NSNumber *discCount = [self.user countAllSongsFromUser:self.user.name inManagedObjectContext:privateContext];
                    NSLog(@"************************************ Discoverfy fetch complete: %@", discCount);
                }];
            });
            dispatch_group_leave(group);
        }];
        
        dispatch_group_enter(group);
        [spot fetchAllSavedSongsWithAccessToken:accessToken user:self.user callback:^{
            dispatch_async(spot.spot_core_data_queue, ^{
                [privateContext performBlock:^{
                    NSNumber *savedCount = [self.user countAllSongsFromUser:self.user.name inManagedObjectContext:privateContext];
                    NSLog(@"************************* Saved Songs fetch Complete: %@", savedCount);
                }];
            });
            dispatch_group_leave(group);
        }];

        
        dispatch_group_enter(group);
        [spot fetchPlaylistSongsWithAccessToken:accessToken session:session offset:0 user:self.user queue:spot_data_queue callback:^{
            
            // Retreived Songs from Spotify Users Playlists. Next retrieve favorite artists.
            dispatch_async(spot.spot_core_data_queue, ^{
                [privateContext performBlock:^{
                    NSNumber * spotCount = [self.user countAllSongsFromUser:self.user.name inManagedObjectContext:privateContext];
                    NSLog(@"******************************** Spotify fetch complete: %@", spotCount);
                }];
            });
            dispatch_group_leave(group);
            
        }];
 
        
        dispatch_group_notify(group, spot_data_queue, ^{
            
            NSLog(@"******************************** fetching Artists");
            
            
            [spot queueInitialSongsUsingTracksWithAccessToken:accessToken user:self.user callback:^{
                
                [privateContext performBlock:^{
                    NSNumber * totalCount = [self.user countAllSongsFromUser:self.user.name inManagedObjectContext:privateContext];
                    NSLog(@"total inital fetch complete: %@", totalCount);
                }];
                
                NSLog(@"********************* Song Queueing via track complete");
            }];
            
            
            
//            [spot getArtistsListWithAccessToken:accessToken queue:spot_data_queue callback:^{
//                
//                [spot queueSongsWithAccessToken:accessToken user:self.user queue:spot_data_queue callback:^{
//                    
//                    NSLog(@"************************************** Song Queueing Complete");
//                    
//                }];
//            }];
            
        });
        
    } else {
        
//        Handle Error
        
        [[DiscoverfyService sharedService]handleError:NULL withState:@"initialBatch"];
        
        
        
    }
    

    

    
        

    // Set up Swiping
    self.mainContainer.userInteractionEnabled = YES;


    UIPanGestureRecognizer *gesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(wasDraggedWithGesture:)];
    [self.mainContainer addGestureRecognizer:gesture];
    
    
    
    
    
    // Set up background gradient colors
    
    UIColor* skyBlue = [UIColor colorWithRed:71.0/255.0 green:181.0/255.0 blue:255.0/255.0 alpha:1.0];
    UIColor* teal = [UIColor colorWithRed:54.0/255.0 green:236.0/255.0 blue:244.0/255.0 alpha:1.0];
    UIColor* purpleColor = [UIColor colorWithRed:148.0/255.0 green:44.0/255.0 blue:203/255.0 alpha:1.0];
    UIColor* blueColor = [UIColor colorWithRed:63.0/255.0 green:98.0/255.0 blue:240.0/255.0 alpha:1.0];
    UIColor* midBlueColor = [UIColor colorWithRed:65.0/255.0 green:184.0/255.0 blue:240.0/255.0 alpha:1.0];

    UIColor* greyColor = [UIColor colorWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1.0];
    UIColor* whiteColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
    
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)blueColor.CGColor,(id)midBlueColor.CGColor, (id)teal.CGColor, nil];
    
//    CAGradientLayer *gradient = [CAGradientLayer layer];
//    gradient.frame = self.view.bounds;
//    gradient.colors = [NSArray arrayWithObjects:(id)whiteColor.CGColor, (id)whiteColor.CGColor, nil];
    
    
    gradient.locations = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0],[NSNumber numberWithFloat:0.7], [NSNumber numberWithFloat:1.0], nil];
    
    
    [self.view.layer insertSublayer:gradient atIndex:0];
    
    
}

-(void)batchReady:(NSNotification *)notification {
    if (self.firstPlay == YES) {
        
        self.firstPlay = NO;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.spinnerController.view removeFromSuperview];
            
            
            self.mainContainer.userInteractionEnabled = YES;


            
            
            [self.trackController updateUIWithTrack:spot.partialTrackList[0] andPrepareTrack:spot.partialTrackList[1]];
            [self.rearTrackController updateUIWithTrack:spot.partialTrackList[1] andPrepareTrack:spot.partialTrackList[2]];
            
        });
        
        
    }
}

-(void)handleSongSkipped:(NSNotification *)notification{
    [self moveCardLeft];
    
//    [self centerCard];
//    
//    [self advanceSong];
}

-(void)moveCardLeft {

//    UIView *cardContainer = self.trackController.view.superview;
//    UIView *mainView = self.view;
//    
//    NSLog(@"cardContainer: %@ | mainView: %@", cardContainer, mainView);
    UIView *card = self.trackController.view.superview;
    UIImageView *overlayImage = self.trackController.overlayImage;
    overlayImage.hidden = NO;
    overlayImage.alpha = 0.0;
    overlayImage.image = [UIImage imageNamed:@"removeSongImage.jpg"];
    
    CGRect initialCardFrame = card.frame;
    NSLog(@"card frame: %@", NSStringFromCGRect(initialCardFrame));
    CGPoint initialCardCenter = card.center;
    
    [UIView transitionWithView:card
                      duration:0.3
                       options:UIViewAnimationOptionBeginFromCurrentState
                    animations:^{
                        CGFloat finalWidth = initialCardFrame.size.width * .9;
                        CGFloat finalHeight = initialCardFrame.size.height * .9;
                        
                        
//                        CGFloat finalX = - (self.view.frame.size.width * .15) - card.frame.size.width;
//                        CGFloat finalX = (self.view.frame.size.width * .15);
//
//                        CGFloat finalY = initialCardFrame.origin.y;
                        
                        CGFloat finalX = -100;
                        
                        CGFloat finalY = initialCardCenter.y;
                        
                        CGRect finalRect = CGRectMake(finalX, finalY, finalWidth, finalHeight);
                        
                        NSLog(@"move to left: %@", NSStringFromCGRect(finalRect));
                        
                        
                        
                        CGFloat scale = log10f(- pow((3 * ((0 - self.view.center.x) / self.view.frame.size.width)),4.0) + 10);
                        CGAffineTransform rotation = CGAffineTransformMakeRotation(-0.25);
                        CGAffineTransform stretch = CGAffineTransformScale(rotation, scale, scale);
                        
                        card.transform = stretch;
                        card.center = CGPointMake(finalX, finalY);
                        overlayImage.alpha = 1.0;
//                        card.frame = finalRect;
                    }
                    completion:^(BOOL finished) {
                        
                        overlayImage.alpha = 0.0;
                        overlayImage.hidden = YES;

                        CGAffineTransform rotationReset = CGAffineTransformMakeRotation(0);
                        
                        CGAffineTransform stretchReset = CGAffineTransformScale(rotationReset, 1, 1);
                        
                        card.transform = stretchReset;
                        card.frame = initialCardFrame;
                        
                        [self advanceSong];
                    }];
    
//    [UIView animateWithDuration:0.5
//                          delay:0.0
//                        options:UIViewAnimationOptionLayoutSubviews
//                     animations:^{
//                         CGFloat finalWidth = initialCardFrame.size.width * .8;
//                         CGFloat finalHeight = initialCardFrame.size.height * .8;
//                         
//                         
//                         CGFloat finalX = self.view.frame.size.width * .15;
//                         CGFloat finalY = initialCardFrame.origin.y;
//                         
//                         CGRect finalRect = CGRectMake(finalX, finalY, finalWidth, finalHeight);
//                         
//                         NSLog(@"move to left: %@", NSStringFromCGRect(finalRect));
//
//                         
//
//                          CGFloat scale = log10f(- pow((3 * ((finalX - self.view.center.x) / self.view.frame.size.width)),4.0) + 10);
//                          CGAffineTransform rotation = CGAffineTransformMakeRotation(finalX / 400);
//                          CGAffineTransform stretch = CGAffineTransformScale(rotation, scale, scale);
//
//                         card.transform = stretch;
//                         card.frame = finalRect;
//                         
//                         
//                     }
//                     completion:^(BOOL finished) {
//                         
//                         CGAffineTransform rotationReset = CGAffineTransformMakeRotation(0);
//                         
//                         CGAffineTransform stretchReset = CGAffineTransformScale(rotationReset, 1, 1);
//                         
//                         card.transform = stretchReset;
//                         card.frame = initialCardFrame;
//                         
//                         [self advanceSong];
//                         
//                     }];
}

-(void)centerCard {
    
    [UIView animateWithDuration:0.0 animations:^{
        
        CGFloat finalWidth = [UIScreen mainScreen].bounds.size.width * .8;
        CGFloat finalHeight = [UIScreen mainScreen].bounds.size.height * .8 - 48;
        
        //        CGFloat finalX = ([UIScreen mainScreen].bounds.size.width / 2) - (finalWidth / 2);
        //        CGFloat finalY = ([UIScreen mainScreen].bounds.size.height * .45 + 48) - (finalHeight / 2);
        //
        CGFloat finalX = 0;
        CGFloat finalY = 0;
        
        CGRect finalRect = CGRectMake(finalX,finalY,finalWidth,finalHeight);
        NSLog(@"screen size: %@", NSStringFromCGSize([UIScreen mainScreen].bounds.size));
        NSLog(@"second move origin: %@", NSStringFromCGPoint(self.view.frame.origin));
        self.view.frame = finalRect;
        NSLog(@"final move origin: %@", NSStringFromCGPoint(self.view.frame.origin));
        
    } completion:^(BOOL finished) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SongSkipped" object:nil];
        
    }];
    
}

-(void)pauseApp{
    
//    NSLog(@"pause app called");
//    [spot.player pause];
    self.mainContainer.userInteractionEnabled = NO;
    
}

-(void)handleNoNetworkError:(NSNotification *)notification{
    DiscoverfyError *discError = (DiscoverfyError *)[notification object];
    
    NSLog(@"Thread for NSnotification: %@", [NSThread currentThread]);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [spot.player pause];
        self.trackController.playButton.hidden = NO;
        self.trackController.pauseButton.hidden = YES;
        
//        self.mainContainer.userInteractionEnabled = NO;
//        self.trackController.view.userInteractionEnabled = NO;
        
        self.errorController = [[ErrorViewController alloc]initWithDiscoverfyError:discError];
        
        self.errorController.view.frame = CGRectMake((screenWidth/2 - 120), (screenHeight/2 - 64), 240, 128);
        
        if([self.spinnerController.view isDescendantOfView:self.view]){
            
            [self.spinnerController.view removeFromSuperview];
            
        }
        
        [self.view addSubview:self.errorController.view];
        
    });
    
    
    
    

    
}

-(void)handleErrorResolve:(NSNotification *)notification{
    
    NSLog(@"App Resolved error");
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [spot.player play];
        self.trackController.playButton.hidden = YES;
        self.trackController.pauseButton.hidden = NO;
        
//        self.mainContainer.userInteractionEnabled = YES;
//        self.trackController.view.userInteractionEnabled = YES;
        
//        [self.errorController.view removeFromSuperview];
        
    });
    
    
    
    
}

-(void)wasDraggedWithGesture:(UIPanGestureRecognizer *)gesture{
    
    CGPoint coords = [gesture translationInView:self.view];
    UIView *card = gesture.view;
    
    CGFloat viewWidth = CGRectGetWidth(self.view.bounds);
    CGFloat viewHeight = CGRectGetHeight(self.view.bounds);
    
    int viewCenterX = viewWidth * .5;
    
    CGFloat cardCenterX = CGRectGetWidth(self.view.bounds) / 2 + coords.x;
    CGFloat cardCenterY = CGRectGetHeight(self.view.bounds) / 2 + coords.y;
    
    CGFloat percentFromCenter = 1 - pow(( (cardCenterX - viewCenterX) / viewWidth) ,4) / 4;
    
    CGFloat scale = percentFromCenter ;
    
    CGAffineTransform rotation = CGAffineTransformMakeRotation(coords.x / 700);
    
    CGAffineTransform stretch = CGAffineTransformScale(rotation, scale, scale);
    
    card.transform = stretch;
    
    card.center = CGPointMake(cardCenterX,cardCenterY);
    
    if (cardCenterX < viewCenterX * .9){
        self.trackController.overlayImage.hidden = NO;
        self.trackController.overlayImage.image = [UIImage imageNamed:@"removeSongImage.jpg"];
    } else if (cardCenterX > viewCenterX * 1.1){
        self.trackController.overlayImage.hidden = NO;
        self.trackController.overlayImage.image = [UIImage imageNamed:@"addSongImage.jpg"];
    } else {
        self.trackController.overlayImage.hidden = YES;
    }
    
    CGFloat opacity = MIN(1.5 * fabsf((cardCenterX - viewCenterX) / viewCenterX),.8);
    
    self.trackController.overlayImage.alpha = opacity;
    
    if (gesture.state == UIGestureRecognizerStateEnded) {
        
        Track *track = spot.partialTrackList[0];
        if (card.center.x < viewWidth * .15) {
                [self songRejectedWithTrack:track.spotifyTrack];
        } else if (card.center.x > viewWidth * .85) {
                [self songAcceptedWithTrack:track.spotifyTrack];
        }
        
        
        self.trackController.overlayImage.hidden = YES;
        
        card.center = CGPointMake(viewWidth / 2, viewHeight * .45 + 48);
        
        NSLog(@"dragged move center: %@", NSStringFromCGPoint(card.center));
                
        rotation = CGAffineTransformMakeRotation(0);
        
        stretch = CGAffineTransformScale(rotation, 1, 1);
        
        card.transform = stretch;
        
    }
    
    
}

-(void)advanceSong{
    NSLog(@"Thread of advance song: %@", [NSThread currentThread]);
    
    [spot.player advanceToNextItem];
    [self.trackController updateUIWithTrack:spot.partialTrackList[1] andPrepareTrack:spot.partialTrackList[2]];
    [self.rearTrackController updateUIWithTrack:spot.partialTrackList[2] andPrepareTrack:spot.partialTrackList[3]];
    [spot.partialTrackList removeObjectAtIndex:0];

    if(spot.partialTrackList.count < 10 && self.queuing != YES){
        
        if([[DiscoverfyService sharedService]hasNetworkConnection]){
            
            self.queuing = YES;
            
            dispatch_async(spot_data_queue, ^{
                
                [spot queueBatchSongsUsingTracksWithAccessToken:accessToken user:self.user callback:^{
                    self.queuing = NO;
                }];
                
//                [spot queueSongsWithAccessToken:accessToken user:self.user queue:spot_data_queue callback:^{
//                    self.queuing = NO;
//                }];
            });
            
        } else {
            
            [[DiscoverfyService sharedService]handleError:NULL withState:@"batchError"];
            
        }
        
        
        }

    
    
    if (spot.partialTrackList.count == 3 && self.queuing != YES) {
        
        [[DiscoverfyService sharedService]handleError:NULL withState:@"batchError"];
        
    }
    
    
    
    
}

-(void)songAcceptedWithTrack:(SPTPartialTrack *)track{
    dispatch_async(spot_data_queue, ^{
        
        NSMutableArray *trackArray = [[NSMutableArray alloc]init ];
        [trackArray addObject:track];
        NSArray *immutable = [NSArray arrayWithObject:(SPTPartialTrack *)track];
        
        accessToken = [[[SPTAuth defaultInstance] session] accessToken];
        
        NSError *postPlaylistError;
        NSURLRequest *req = [SPTPlaylistSnapshot createRequestForAddingTracks:immutable toPlaylist:spot.discoverfyPlaylist.uri withAccessToken:accessToken error:&postPlaylistError];
        
        [[SPTRequest sharedHandler] performRequest:req callback:^(NSError *error, NSURLResponse *response, NSData *data) {
            if(error != nil){
                NSLog(@"*** Error in adding track %@",error);
                [[DiscoverfyService sharedService]handleError:NULL withState:@"batchError"];

//                [[DiscoverfyService sharedService]handleError:NULL withState:@"swipeError"];

            }
//            NSLog(@"response from post %@",response);
        }];
        dispatch_async(spot.spot_core_data_queue, ^{
            
            [privateContext performBlock:^{
                
                [Song storeSongWithSongID:track.identifier ofType:@"Liked" withUser:self.user inManangedObjectContext:privateContext];

            }];
            
            
        });
        
        [[DiscoverfyService sharedService] postSongWithSongID:track.identifier type:@"Liked" user:self.user.name];
        
    });
    
    
    [self advanceSong];
    
}

-(void)songRejectedWithTrack:(SPTPartialTrack *)track{
    dispatch_async(spot.spot_core_data_queue, ^{
        
        [privateContext performBlock:^{
            
            [Song storeSongWithSongID:track.identifier ofType:@"Disliked" withUser:self.user inManangedObjectContext:privateContext];
            
        }];
        
        
        [[DiscoverfyService sharedService] postSongWithSongID:track.identifier type:@"Disliked" user:self.user.name];
        
    });
    
    [self advanceSong];
    
}

-(void)updateViewConstraints{
    
    // Set up UI and Constraints
    
    
    NSDictionary *rearElementsDict = NSDictionaryOfVariableBindings(_rearContainer);
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-(==%f)-[_rearContainer(<=%f)]-(==%f)-|",(64 + screenHeight * .05),(screenHeight * .8 - 32),(screenHeight * .15 - 32)]
                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                                                      metrics:nil
                                                                        views:rearElementsDict]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:|-(==%f)-[_rearContainer(<=%f)]-(==%f)-|",screenWidth * .1,screenWidth * .8,screenWidth * .1]
                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                                                      metrics:nil
                                                                        views:rearElementsDict]];
    
    NSDictionary *frontElementsDict = NSDictionaryOfVariableBindings(_mainContainer);
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-(==%f)-[_mainContainer(<=%f)]-(==%f)-|",(64 + screenHeight * .05),(screenHeight * .8 - 32),(screenHeight * .15 - 32)]
                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                                                      metrics:nil
                                                                        views:frontElementsDict]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:|-(==%f)-[_mainContainer(<=%f)]-(==%f)-|",screenWidth * .1,screenWidth * .8,screenWidth * .1]
                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                                                      metrics:nil
                                                                        views:frontElementsDict]];
    
    [super updateViewConstraints];
    
}




-(void)printArtists{
    NSLog(@"post dispatch %@", spot.artistList);
}

@end
