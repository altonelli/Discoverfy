//
//  DiscoverfyService.m
//  Discoverfy
//
//  Created by Arthur Tonelli on 8/26/16.
//  Copyright © 2016 Arthur Tonelli. All rights reserved.
//

#import "DiscoverfyService.h"
#import <Spotify/Spotify.h>
#import "Reachability.h"

@implementation DiscoverfyService

+(id)sharedService{
    static DiscoverfyService *sharedDiscoverfyService = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDiscoverfyService = [[self alloc]init];
    });
    
    return sharedDiscoverfyService;
}

-(void)createUser:(NSString *)user{
    NSString *post = [NSString stringWithFormat:@"user=%@",user];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]init];
    [request setURL:[NSURL URLWithString:@"https://discoverfy.herokuapp.com/api/users"]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postData];
    
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration:defaultConfigObject];
    
    NSURLSessionDataTask *dataTask = [defaultSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error){
            NSLog(@"*** Error on user post: %@",error);
        } else {
//            NSLog(@"data: %@", [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]);
        }
    }];
    
    [dataTask resume];
    
}

-(void)fetchSongsWithUser:(NSString *)user completionHandler:(void (^)(NSArray *tracks))callbackBlock{
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration:defaultConfigObject];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://discoverfy.herokuapp.com/api/user/%@/songs",user]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSURLSessionDataTask *dataTask = [defaultSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            NSLog(@"*** Error on songs get: %@",error);
        } else {
//            NSLog(@"Successful data get: %@",[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]);
            NSArray *tracks = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
//            NSLog(@"Tracks data: %@", tracks);
           
            callbackBlock(tracks);
            
        }
    }];
    
    [dataTask resume];
    
}

-(void)postSongWithSongID:(NSString *)songID type:(NSString *)type user:(NSString *)user{
    
    NSString *post = [NSString stringWithFormat:@"songID=%@&type=%@&user=%@",songID,type,user];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]init];
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://discoverfy.herokuapp.com/api/users/%@/songs",user]]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postData];
    
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration:defaultConfigObject];
    
    NSURLSessionDataTask *dataTask = [defaultSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            NSLog(@"*** Error on song post: %@",error);
        } else {
//            NSLog(@"Successful post: %@",[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]);
        }
    }];
    
    [dataTask resume];
    
}

-(BOOL)hasNetworkConnection {
    
    Reachability *network = [Reachability reachabilityWithHostname:@"https://developer.spotify.com/"];
    NetworkStatus status = [network currentReachabilityStatus];
    
    switch (status){
            
        case NotReachable:
            return NO;
        
        case ReachableViaWWAN:
            return YES;
            
        case ReachableViaWiFi:
            return YES;
        
        default:
            return NO;
            
    }
    
}

@end
