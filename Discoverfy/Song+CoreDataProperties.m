//
//  Song+CoreDataProperties.m
//  Discoverfy
//
//  Created by Arthur Tonelli on 8/10/16.
//  Copyright © 2016 Arthur Tonelli. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Song+CoreDataProperties.h"

@implementation Song (CoreDataProperties)

@dynamic songID;
@dynamic type;
@dynamic date;
@dynamic user;

+(Song *)storeSongWithSongID:(NSString *)songID ofType:(NSString *)type withUser:(User*)user inManangedObjectContext:(NSManagedObjectContext *)context{
    Song *song = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Song"];
    request.predicate = [NSPredicate predicateWithFormat:@"songID = %@ AND user = %@", songID, user];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if(!matches || error || matches.count > 1){
        NSLog(@"*** Error on song fetch: %@; matches: %@", error,matches);
    } else if(matches.count) {
        song = [matches firstObject];
    } else {
        NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Song" inManagedObjectContext:context];
        
        song = [[Song alloc]initWithEntity:entityDesc insertIntoManagedObjectContext:context];
        
        song.songID = songID;
        song.type = type;
        song.user = user;

    }
    
    return song;
}

+(BOOL)songExistsForUser:(User *)user trackID:(NSString *)trackID inManagedObjectContext:(NSManagedObjectContext *)context{
    BOOL res = NO;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Song"];
    request.predicate = [NSPredicate predicateWithFormat:@"songID = %@ AND user = %@",trackID,user];
    request.fetchLimit = 1;
    
    NSError *error;
    NSArray *match = [context executeFetchRequest:request error:&error];
    
//    NSLog(@"match is here: %@",match);
    
    if(error){
        NSLog(@"*** Error on checking if song exists: %@", error);
    } else if (!match) {
        NSLog(@"No Match");
    } else if (match.count == 0){
        NSLog(@"Matches equals zero");
    } else {
//        NSLog(@"Match: %@", [match firstObject]);
        res = YES;
    }

    return res;
}


@end
