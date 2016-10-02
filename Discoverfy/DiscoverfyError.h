//
//  DiscoverfyError.h
//  Discoverfy
//
//  Created by Arthur Tonelli on 9/28/16.
//  Copyright © 2016 Arthur Tonelli. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DiscoverfyError : NSObject

@property (nonatomic,strong) NSError *error;
@property (nonatomic,strong) NSString *appState;

@end
