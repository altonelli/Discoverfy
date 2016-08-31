//
//  CoreDataService.m
//  Discoverfy
//
//  Created by Arthur Tonelli on 8/10/16.
//  Copyright © 2016 Arthur Tonelli. All rights reserved.
//

#import "CoreDataService.h"

@implementation CoreDataService {
    NSManagedObjectContext *context;
    AppDelegate *appDelegate;
}

+(id)sharedService {
    static CoreDataService *coreDataService = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        coreDataService = [[self alloc]init];
    });
    
    return coreDataService;
}

-(id)init{
    if (self = [super init]){
//        appDelegate = [[UIApplication sharedApplication]delegate];
//        context = [appDelegate managedObjectContext];
        
        
    }
    
    return self;
}




//+(User *)findUserWithUsername:(NSString *)username inManagedObjectContext:(NSManagedObjectContext *)context{
//    User *user;
//    
//    NSEntityDescription *userEntityDesc = [NSEntityDescription entityForName:@"User" inManagedObjectContext:context];
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@",username];
//    NSFetchRequest *request = [[NSFetchRequest alloc]init];
//    
//    request.predicate = predicate;
//    request.entity = userEntityDesc;
//    
//    NSError *error;
//    
////    NSAsynchronousFetchRequest *asynchFetch = [[NSAsynchronousFetchRequest alloc]initWithFetchRequest:request completionBlock:^(NSAsynchronousFetchResult * _Nonnull result) {
////        
////        
////        NSLog(@"result: %@", result);
////    }];
//    NSArray *matches = [context executeRequest:request error:&error];
//    
//    if(matches.count == 0 || error){
//        NSLog(@"*** Error on User fetch, %@", error);
//    } else {
//        user = matches[0];
//    }
//    
//    return user;
//}

-(void)storeSong:(NSString *)songID user:(User *)user type:(NSString *)type date:(NSDate * _Nullable)date{
    NSEntityDescription *songEntityDesc = [NSEntityDescription entityForName:@"Song" inManagedObjectContext:context];
    Song *song = [[Song alloc]initWithEntity:songEntityDesc insertIntoManagedObjectContext:context];
    
    song.songID = songID;
    song.type = type;
    
    if(date){
        song.date = date;
    }
    
    [user addSongsObject:song];
    
    NSError *error;
    [context save:&error];
    
    if (error) {
        NSLog(@"*** Error on song save: %@", error);
    } else {
        NSLog(@"Song saved: %@",song);
        NSLog(@"User song count now: %d", user.songs.count);
    }
    
}

@end
