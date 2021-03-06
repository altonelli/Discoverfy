//
//  DiscoverfyService.h
//  Discoverfy
//
//  Created by Arthur Tonelli on 8/26/16.
//  Copyright © 2016 Arthur Tonelli. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DiscoverfyService : NSObject

+(id)sharedService;

-(void)createUser:(NSString *)user;
-(void)fetchSongsWithUser:(NSString *)user completionHandler:(void (^)(NSArray *tracks))callbackBlock;

-(void)fetchSongsWithUser:(NSString *)user offset:(int)offset limit:(int)limit addToArray:(NSMutableArray *_Nullable)array completionHandler:(void (^)(NSMutableArray *tracks))callbackBlock;
-(void)fetchAllSongsWithUser:(NSString *)user completionHandler:(void (^)(NSMutableArray *tracks))callbackBlock;


-(void)postSongWithSongID:(NSString *)songID type:(NSString *)type user:(NSString *)user;
-(BOOL)hasNetworkConnection;


-(void)handleError:(NSError * _Nullable)error withState:(NSString *)state;


@end
