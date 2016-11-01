//
//  PHServerManager.m
//  TestMaps
//
//  Created by Pavel Hrybouski on 13.10.16.
//  Copyright © 2016 Pavel Hrybouski. All rights reserved.
//

#import "PHServerManager.h"
#import "AFNetworking.h"

@interface PHServerManager()

@property (strong, nonatomic) AFHTTPSessionManager *sessionManager;

@end

@implementation PHServerManager

+ (PHServerManager *) sharedManager{
    static PHServerManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[PHServerManager alloc]init];
    });
    return manager;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        NSURL *url = [NSURL URLWithString:@"http://api.openweathermap.org/data/2.5/"];
        self.sessionManager =[[AFHTTPSessionManager alloc] initWithBaseURL:url];
    }
    return self;
}
- (void) getWeather:(NSDictionary *) dictionary
          onSuccess:(void(^)(NSDictionary* currentWeather)) success
          onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure{
    
   NSDictionary* params =
    [NSDictionary dictionaryWithObjectsAndKeys:
  
     
    [dictionary objectForKey:@"latitude"],  @"lat"  ,
    [dictionary objectForKey:@"longitude"], @"lon"  ,
    @"9e051ba4ec03af027c43451b078b0d92",    @"appid",
     nil];
    
    
    
    
    [self.sessionManager GET:@"weather?"
                  parameters:params
                     success:^(NSURLSessionTask *task, id responseObject) {
                         NSLog(@"JSON: %@", responseObject);
                         success(responseObject);
                      
                     }
                     failure:^(NSURLSessionTask *operation, NSError *error) {
                         NSLog(@"Error: %@", error);
                         if (failure) {
                             
                             failure(error, nil);
                         }
                         
                     }];
    
}

@end
