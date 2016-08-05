//
//  MusicViewController.m
//  Discoverfy
//
//  Created by Arthur Tonelli on 7/26/16.
//  Copyright © 2016 Arthur Tonelli. All rights reserved.
//

#import "MusicViewController.h"
#import "SpotifyService.h"
#import "Track.h"
#import "TrackViewController.h"


@interface MusicViewController (){
    SpotifyService *spot;
    NSString *accessToken;
    SPTSession *session;
}

@property (weak, nonatomic) IBOutlet UIView *rearContainer;
@property (weak, nonatomic) IBOutlet UIView *mainContainer;
@property (nonatomic,strong) TrackViewController *rearTrackController;
@property (nonatomic,strong) TrackViewController *trackController;

@end



@implementation MusicViewController

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    NSString *segueName = segue.identifier;
    if([segueName isEqualToString:@"embedSegue"]){
        self.trackController = (TrackViewController *) [segue destinationViewController];
        self.trackController.isMainCard = YES;
    }
    
    if([segueName isEqualToString:@"embedSegue2"]){
        self.rearTrackController = (TrackViewController *) [segue destinationViewController];
        self.rearTrackController.isMainCard = NO;
    }
    
}

-(void)viewDidLoad{
    
    CGRect screenRect = [[UIScreen mainScreen]bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    NSDictionary *rearElementsDict = NSDictionaryOfVariableBindings(_rearContainer);
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-(==%f)-[_rearContainer(==%f)]-|",screenHeight * .1,screenHeight * .8]
                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                                                      metrics:nil
                                                                        views:rearElementsDict]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:|-(==%f)-[_rearContainer(==%f)]-|",screenWidth * .1,screenWidth * .8]
                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                                                      metrics:nil
                                                                        views:rearElementsDict]];
    
    NSDictionary *frontElementsDict = NSDictionaryOfVariableBindings(_mainContainer);
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-(==%f)-[_mainContainer(==%f)]-|",screenHeight * .1,screenHeight * .8]
                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                                                      metrics:nil
                                                                        views:frontElementsDict]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:|-(==%f)-[_mainContainer(==%f)]-|",screenWidth * .1,screenWidth * .8]
                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                                                      metrics:nil
                                                                        views:frontElementsDict]];
    
    
    NSLog(@"%f %f",screenWidth,screenHeight);
    

    
    
    UIPanGestureRecognizer *gesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(wasDraggedWithGesture:)];
    [self.mainContainer addGestureRecognizer:gesture];
    
    self.mainContainer.userInteractionEnabled = YES;
    
}



-(void)viewWillAppear:(BOOL)animated{
    
    NSString *accessToken = [SPTAuth defaultInstance].session.accessToken;
    SPTSession *session = [SPTAuth defaultInstance].session;

    spot = [SpotifyService sharedService];
    
    [spot verifyDiscoverfyPlaylistWithAccessToken:accessToken session:session offset:0];
    
    
    
    [spot getArtistsListWithAccessToken:accessToken callback:^{
        
        
        NSMutableArray *randArtists = [spot getRandomArtists];
        
        NSLog(@"rand artists %@",randArtists);
        
        [spot fetchURIsFromArtistsWithAccessToken:accessToken artists:randArtists callback:^{
            
            NSMutableArray *itemsToBeRemoved = [[NSMutableArray alloc]init];
            
            for (Track *track in spot.partialTrackList) {
                
                if([spot.player canInsertItem:track.playerItem afterItem:nil]){
                    
                    [spot.player insertItem:track.playerItem afterItem:nil];

                } else {
                    
                    [itemsToBeRemoved addObject:track];
                    
                }
                
                
            }
            
            NSArray *copy = [itemsToBeRemoved copy];
            [spot.partialTrackList removeObjectsInArray:copy];

//            NSLog(@"spot partial count %@", spot.partialTrackList.count);
            
            [self.trackController updateUIWithTrack:spot.partialTrackList[0]];
            [self.rearTrackController updateUIWithTrack:spot.partialTrackList[1]];

        }];
        
    }];

    
}

-(void)wasDraggedWithGesture:(UIPanGestureRecognizer *)gesture{
    
    CGPoint coords = [gesture translationInView:self.view];
    UIView *card = gesture.view;
    
    CGFloat viewWidth = CGRectGetWidth(self.view.bounds);
    CGFloat viewHeight = CGRectGetHeight(self.view.bounds);
    
    CGFloat cardCenterX = CGRectGetWidth(self.view.bounds) / 2 +coords.x;
    CGFloat cardCenterY = CGRectGetHeight(self.view.bounds) / 2 + coords.y;
    
    CGAffineTransform rotation = CGAffineTransformMakeRotation(coords.x / 300);
    
    CGAffineTransform stretch = CGAffineTransformScale(rotation, .9, .9);
    
    card.transform = stretch;
    
    card.center = CGPointMake(cardCenterX,cardCenterY);
    
    if (gesture.state == UIGestureRecognizerStateEnded) {
        
        if (card.center.x < viewWidth * .15) {
            [self songRejected];
        } else if (card.center.x > viewWidth * .85) {
            Track *track = spot.partialTrackList[0];
            [self songAcceptedWithTrack:track.spotifyTrack];
        }
        
        card.center = CGPointMake(viewWidth / 2, viewHeight / 2);
        
        rotation = CGAffineTransformMakeRotation(0);
        
        stretch = CGAffineTransformScale(rotation, 1, 1);
        
        card.transform = stretch;
        
    }
    
    
}

-(void)advanceSong{
    [spot.player advanceToNextItem];
    [self.trackController updateUIWithTrack:spot.partialTrackList[1]];
    [self.rearTrackController updateUIWithTrack:spot.partialTrackList[2]];
    if(spot.partialTrackList.count < 5){
        
        [spot loadTracks];
        
    }
    
//    [spot.player removeItem:[spot.player it]];
    [spot.partialTrackList removeObjectAtIndex:0];
}

-(void)songAcceptedWithTrack:(SPTPartialTrack *)track{
    NSLog(@"Accepted");
    NSMutableArray *trackArray = [[NSMutableArray alloc]init ];
    [trackArray addObject:track];
    NSArray *immutable = [NSArray arrayWithObject:(SPTPartialTrack *)track];
//    NSLog(@"track item %@",trackArray[0]);
    accessToken = [[[SPTAuth defaultInstance] session] accessToken];
    NSLog(@"Scopes: %@",[[SPTAuth defaultInstance] requestedScopes]);
    NSLog(@"adding %@ to %@",immutable[0],spot.discoverfyPlaylist.name);
    
    
//    [spot.discoverfyPlaylist addTracksToPlaylist:immutable withAccessToken:accessToken callback:^(NSError *error) {
//        if (error != nil){
//            NSLog(@"*** Error in adding track %@",error);
//        }
//        NSLog(@"track added %@", spot.discoverfyPlaylist);
//    }];
    
    NSError *postPlaylistError;
    NSURLRequest *req = [SPTPlaylistSnapshot createRequestForAddingTracks:immutable toPlaylist:spot.discoverfyPlaylist.uri withAccessToken:accessToken error:&postPlaylistError];
    
    [[SPTRequest sharedHandler] performRequest:req callback:^(NSError *error, NSURLResponse *response, NSData *data) {
        if(error != nil){
            NSLog(@"*** Error in adding track %@",error);
        }
        NSLog(@"response from post %@",response);
    }];
    
    
    
    
    [self advanceSong];
    
}

-(void)songRejected{
    NSLog(@"Rejected");
    
    [self advanceSong];
    
}


-(void)printArtists{
    NSLog(@"post dispatch %@", spot.artistList);
}

@end
