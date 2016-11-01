//
//  PHMapAnnotation.h
//  TestMaps
//
//  Created by Pavel Hrybouski on 12.10.16.
//  Copyright © 2016 Pavel Hrybouski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MKAnnotation.h>

@interface PHMapAnnotation : NSObject <MKAnnotation>
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;

@end
