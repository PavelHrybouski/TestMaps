//
//  PHLocations+CoreDataProperties.h
//  TestMaps
//
//  Created by Pavel Hrybouski on 12.10.16.
//  Copyright © 2016 Pavel Hrybouski. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "PHLocations.h"

NS_ASSUME_NONNULL_BEGIN

@interface PHLocations (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *latitude;
@property (nullable, nonatomic, retain) NSNumber *longitude;
@property (nullable, nonatomic, retain) NSDate *date;
@property (nullable, nonatomic, retain) NSString *city;

@end

NS_ASSUME_NONNULL_END
