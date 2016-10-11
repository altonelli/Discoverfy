//
//  User+CoreDataProperties.m
//  Discoverfy
//
//  Created by Arthur Tonelli on 8/10/16.
//  Copyright © 2016 Arthur Tonelli. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "User+CoreDataProperties.h"

@implementation User (CoreDataProperties)

@dynamic name;
@dynamic songs;

+(User *)findUserWithUsername:(NSString *)username inManagedObjectContext:(NSManagedObjectContext *)context{
//    NSLog(@"in function");
    User *user = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"User"];
    request.predicate = [NSPredicate predicateWithFormat:@"name = %@",username];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if(!matches || error || matches.count > 1){
        NSLog(@"*** Error on user fetch: %@",error);
    } else if (matches.count) {
        user = [matches firstObject];
    } else {
        NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"User" inManagedObjectContext:context];
        user = [[User alloc] initWithEntity:entityDesc insertIntoManagedObjectContext:context];
        user.name = username;
    }
    
    NSLog(@"Here is your user: %@", user);
    
    return user;
}

-(void)removeAllSongsFromUser:(NSString *)username inManagedObjectContext:(NSManagedObjectContext *)context{
    User *user = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"User"];
    request.predicate = [NSPredicate predicateWithFormat: @"name = %@",username];
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if(!matches || error || matches.count > 1){
        NSLog(@"*** Error on use fetch: %@",error);
    } else {
        user = [matches firstObject];
        for (NSManagedObject *song in user.songs){
            [context deleteObject:song];
        }
        NSLog(@"Successfully deleted songs from user. Count now: %u",user.songs.count);
    }
    
}

-(void)countAllSongsFromUser:(NSString *)username inManagedObjectContext:(NSManagedObjectContext *)context{
    User *user = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"User"];
    request.predicate = [NSPredicate predicateWithFormat: @"name = %@",username];
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if(!matches || error || matches.count > 1){
        NSLog(@"*** Error on use fetch: %@",error);
    } else {
        user = [matches firstObject];
    
        NSLog(@"Count for user is now: %u",user.songs.count);
    }
    
}

@end
