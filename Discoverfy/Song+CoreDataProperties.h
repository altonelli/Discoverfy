//
//  Song+CoreDataProperties.h
//  Discoverfy
//
//  Created by Arthur Tonelli on 8/10/16.
//  Copyright © 2016 Arthur Tonelli. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Song.h"

NS_ASSUME_NONNULL_BEGIN

@interface Song (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *songID;
@property (nullable, nonatomic, retain) NSString *type;
@property (nullable, nonatomic, retain) NSDate *date;
@property (nullable, nonatomic, retain) User *user;

+(Song *)storeSongWithSongID:(NSString *)songID ofType:(NSString *)type withUser:(User*)user inManangedObjectContext:(NSManagedObjectContext *)context;

+(BOOL)songExistsForUser:(User *)user trackID:(NSString *)trackID inManagedObjectContext:(NSManagedObjectContext *)context;


@end

NS_ASSUME_NONNULL_END
