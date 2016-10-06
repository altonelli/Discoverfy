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


@interface MusicViewController (){
    SpotifyService *spot;
    NSString *accessToken;
    SPTSession *session;
    NSManagedObjectContext *context;
    dispatch_queue_t spot_data_queue;
    CGRect screenRect;
    CGFloat screenWidth;
    CGFloat screenHeight;
    ErrorViewController *errorController;
}

@property (weak, nonatomic) IBOutlet UIView *rearContainer;
@property (nonatomic,strong) TrackViewController *rearTrackController;
@property (nonatomic,strong) TrackViewController *trackController;
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
        
        [[SPTAuth defaultInstance]setSession:nil];
        
        [spot emptyArrays];
        
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
    
    
    
    
    // Set up context
    spot_data_queue = dispatch_queue_create("com.discoverfy.songsQueue", DISPATCH_QUEUE_CONCURRENT);
    
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    context = [appDelegate managedObjectContext];
    
    session = [SPTAuth defaultInstance].session;
    accessToken = session.accessToken;
    
    spot = [SpotifyService sharedService];
    self.errorController = [[ErrorViewController alloc]init];
    
    
    self.spinnerController = [[SpinnerViewController alloc]init];
    [self.view addSubview:self.spinnerController.view];
    self.spinnerController.view.frame = CGRectMake(screenWidth/2 - 120, screenHeight/2 - 64, 240, 128);
    [self.spinnerController startSpinner];
    
    
    
    if([[DiscoverfyService sharedService]hasNetworkConnection]){
        
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
        [spot fetchPlaylistSongsWithAccessToken:accessToken session:session offset:0 user:self.user queue:spot_data_queue callback:^{
            
            // Retreived Songs from Spotify Users Playlists. Next retrieve favorite artists.
            NSLog(@"******************************** Spotify fetch complete");
            dispatch_group_leave(group);
            
        }];
 
        
        dispatch_group_notify(group, spot_data_queue, ^{
            
            NSLog(@"******************************** fetching Artists");
            
            [spot getArtistsListWithAccessToken:accessToken queue:spot_data_queue callback:^{
                
                [spot queueSongsWithAccessToken:accessToken user:self.user queue:spot_data_queue callback:^{
                    
                    NSLog(@"************************************** Song Queueing Complete");
                    
                }];
            }];
            
        });
        
    } else {
        
//        Handle Error
        
        [[DiscoverfyService sharedService]handleError:NULL withState:@"initialBatch"];
        
        
        
    }
    

    

    
        

    // Set up Swiping
    self.mainContainer.userInteractionEnabled = YES;


    UIPanGestureRecognizer *gesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(wasDraggedWithGesture:)];
    [self.mainContainer addGestureRecognizer:gesture];
    
    
}

-(void)batchReady:(NSNotification *)notification {
    if (self.firstPlay == YES) {
        
        self.firstPlay = NO;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.spinnerController stopSpinner];
            [self.spinnerController.view removeFromSuperview];
            
            
            self.mainContainer.userInteractionEnabled = YES;


            
            
            [self.trackController updateUIWithTrack:spot.partialTrackList[0]];
            [self.rearTrackController updateUIWithTrack:spot.partialTrackList[1]];
            
        });
        
        
    }
}

-(void)pauseApp{
    
//    NSLog(@"pause app called");
//    [spot.player pause];
    self.mainContainer.userInteractionEnabled = NO;
    
}

-(void)handleNoNetworkError:(NSNotification *)notification{
    
    NSLog(@"pause app with notification called");
    [spot.player pause];
    self.mainContainer.userInteractionEnabled = NO;
    
    self.errorController.view.frame = CGRectMake((screenWidth/2 - 120), (screenHeight/2 - 64), 240, 128);
    
    [self.view addSubview:self.errorController.view];
    

    
}

-(void)wasDraggedWithGesture:(UIPanGestureRecognizer *)gesture{
    
    CGPoint coords = [gesture translationInView:self.view];
    UIView *card = gesture.view;
    
    CGFloat viewWidth = CGRectGetWidth(self.view.bounds);
    CGFloat viewHeight = CGRectGetHeight(self.view.bounds);
    
    int viewCenterX = viewWidth * .5;
    
    CGFloat cardCenterX = CGRectGetWidth(self.view.bounds) / 2 +coords.x;
    CGFloat cardCenterY = CGRectGetHeight(self.view.bounds) / 2 + coords.y;
    
    CGFloat scale = log10f(- pow((3 * ((cardCenterX - viewCenterX) / viewWidth)),4.0) + 10);
    
    CGAffineTransform rotation = CGAffineTransformMakeRotation(coords.x / 400);
    
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
                
        rotation = CGAffineTransformMakeRotation(0);
        
        stretch = CGAffineTransformScale(rotation, 1, 1);
        
        card.transform = stretch;
        
    }
    
    
}

-(void)advanceSong{

    if(spot.partialTrackList.count < 10 && self.queuing != YES){
        
        if([[DiscoverfyService sharedService]hasNetworkConnection]){
            
            self.queuing = YES;
            
            dispatch_async(spot_data_queue, ^{
                
                [spot queueSongsWithAccessToken:accessToken user:self.user queue:spot_data_queue callback:^{
                    NSLog(@"hit song queue call back, %hhd", self.queuing);
                    self.queuing = NO;
                }];
            });
            
        } else {
            
            [self pauseApp];
            [[DiscoverfyService sharedService]handleError:NULL withState:@"swipe"];
            
        }
            
        
        }
    
    
    
    if (spot.partialTrackList.count == 3 && self.queuing != YES) {
        
//        [self pauseApp];
        [[DiscoverfyService sharedService]handleError:NULL withState:@"batchError"];
        
    } else {
        
            
            [spot.player advanceToNextItem];
            [self.trackController updateUIWithTrack:spot.partialTrackList[1]];
            [self.rearTrackController updateUIWithTrack:spot.partialTrackList[2]];
            [spot.partialTrackList removeObjectAtIndex:0];
            
//        if (self.errorController.view.hidden == NO){
//            [spot.player pause];
//        }
        
        
    }
    
    
    
}

-(void)songAcceptedWithTrack:(SPTPartialTrack *)track{
    dispatch_async(spot_data_queue, ^{

        NSLog(@"Accepted");
        NSMutableArray *trackArray = [[NSMutableArray alloc]init ];
        [trackArray addObject:track];
        NSArray *immutable = [NSArray arrayWithObject:(SPTPartialTrack *)track];
        
        accessToken = [[[SPTAuth defaultInstance] session] accessToken];
        
        NSError *postPlaylistError;
        NSURLRequest *req = [SPTPlaylistSnapshot createRequestForAddingTracks:immutable toPlaylist:spot.discoverfyPlaylist.uri withAccessToken:accessToken error:&postPlaylistError];
        
        [[SPTRequest sharedHandler] performRequest:req callback:^(NSError *error, NSURLResponse *response, NSData *data) {
            if(error != nil){
                NSLog(@"*** Error in adding track %@",error);
            }
            NSLog(@"response from post %@",response);
        }];
        
        [Song storeSongWithSongID:track.identifier ofType:@"Liked" withUser:self.user inManangedObjectContext:context];
        
        [[DiscoverfyService sharedService] postSongWithSongID:track.identifier type:@"Liked" user:self.user.name];
        
    });
    
    [self advanceSong];
    
}

-(void)songRejectedWithTrack:(SPTPartialTrack *)track{
    dispatch_async(spot_data_queue, ^{
        
        NSLog(@"Rejected");
        
        [Song storeSongWithSongID:track.identifier ofType:@"Disliked" withUser:self.user inManangedObjectContext:context];
        
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
