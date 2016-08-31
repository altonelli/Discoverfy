//
//  CoreDataService.h
//  Discoverfy
//
//  Created by Arthur Tonelli on 8/10/16.
//  Copyright © 2016 Arthur Tonelli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "AppDelegate.h"
#import "User.h"
#import "Song.h"

@interface CoreDataService : NSObject

+(id)sharedService;
-(User *)findUserWithUsername:(NSString *)username;
-(void)storeSong:(NSString *)songID user:(User *)user type:(NSString *)type date:(NSDate * _Nullable)date;

@end
