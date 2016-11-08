//
//  AppDelegate.m
//  Discoverfy
//
//  Created by Arthur Tonelli on 7/26/16.
//  Copyright © 2016 Arthur Tonelli. All rights reserved.
//

#import <Spotify/Spotify.h>
#import "SpotifyService.h"
#import "AppDelegate.h"
#import "Config.h"
#import "MusicViewController.h"

@interface AppDelegate ()

@property (nonatomic,strong) SPTSession *session;
@property (nonatomic,strong) SPTAudioStreamingController *player;

@end

@implementation AppDelegate




- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    
    SPTAuth *auth = [SPTAuth defaultInstance];
    [auth setTokenSwapURL:[NSURL URLWithString:@"https://discoverfy.herokuapp.com/swap"]];
    [auth setTokenRefreshURL:[NSURL URLWithString:@"https://discoverfy.herokuapp.com/refresh"]];
    
    [auth setClientID:@kClientId];
    [auth setRedirectURL:[NSURL URLWithString:@kCallbackURL]];
    [auth setRequestedScopes:@[SPTAuthStreamingScope, SPTAuthPlaylistReadPrivateScope, SPTAuthPlaylistModifyPrivateScope,SPTAuthPlaylistModifyPublicScope, @"user-top-read"]];
    [auth setSessionUserDefaultsKey:@"userDefaultsKey"];
    
//    NSURL *loginURL = [auth loginURL];
//    
//    [application performSelector:@selector(openURL:) withObject:loginURL afterDelay:0.5];
    
    return YES;
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    SPTAuth *auth = [SPTAuth defaultInstance];
    
    SPTAuthCallback authCallback = ^(NSError *error, SPTSession *session){
        
        NSLog(@"call back called");
        
        if (error != nil){
            NSLog(@"*** Autherror: %@", error);
            return;
        }
        
        auth.session = session;
        
        NSData *sessionData = [NSKeyedArchiver archivedDataWithRootObject:auth.session];
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        
        if ([defaults objectForKey:auth.sessionUserDefaultsKey] != nil) {
            [defaults removeObjectForKey:auth.sessionUserDefaultsKey];
        }
        
        [defaults setObject:sessionData forKey:auth.sessionUserDefaultsKey];
        [defaults synchronize];
        
        
        [[NSNotificationCenter defaultCenter]postNotificationName:@"sessionUpdated" object:self];
        
    };


    
    if([auth canHandleURL:url]) {
        
        NSLog(@"can handle url");
        
        [auth handleAuthCallbackWithTriggeredAuthURL:url callback:authCallback];
        
        return YES;
    }
    
    return NO;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [[[SpotifyService sharedService]player]pause];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [[[SpotifyService sharedService]player]play];

}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    SpotifyService* spot = [SpotifyService sharedService];
    
    [spot emptyArrays];
    
    
    [self saveContext];
    
    NSLog(@"GOOD BYE");
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize privateContext = _privateContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.altonelli.Discoverfy" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Discoverfy" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Discoverfy.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
//    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];

    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

- (NSManagedObjectContext *)privateContext {
    // Returns the private managed object context for the application with parent context of managedObjectContext (which is already bound to the persistent store coordinator for the application.)
    if (_privateContext != nil) {
        return _privateContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _privateContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    
    [_privateContext setParentContext:[self managedObjectContext]];
    return _privateContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
