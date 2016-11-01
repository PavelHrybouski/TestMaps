//
//  PHServerManager.h
//  TestMaps
//
//  Created by Pavel Hrybouski on 13.10.16.
//  Copyright © 2016 Pavel Hrybouski. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PHServerManager : NSObject

@property (strong, nonatomic, readonly) NSDictionary *currentWeather;

+ (PHServerManager *) sharedManager;


- (void) getWeather:(NSDictionary *) dictionary
          onSuccess:(void(^)(NSDictionary* currentWeather)) success
          onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure;


@end