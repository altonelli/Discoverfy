//
//  User+CoreDataProperties.h
//  Discoverfy
//
//  Created by Arthur Tonelli on 8/10/16.
//  Copyright © 2016 Arthur Tonelli. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "User.h"

NS_ASSUME_NONNULL_BEGIN

@interface User (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSSet<Song *> *songs;

+(User *)findUserWithUsername:(NSString *)username inManagedObjectContext:(NSManagedObjectContext *)context;

-(void)removeAllSongsFromUser:(NSString *)username inManagedObjectContext:(NSManagedObjectContext *)context;

-(void)countAllSongsFromUser:(NSString *)username inManagedObjectContext:(NSManagedObjectContext *)context;


@end

@interface User (CoreDataGeneratedAccessors)

- (void)addSongsObject:(Song *)value;
- (void)removeSongsObject:(Song *)value;
- (void)addSongs:(NSSet<Song *> *)values;
- (void)removeSongs:(NSSet<Song *> *)values;


@end

NS_ASSUME_NONNULL_END
