//
//  PHDataManger.m
//  TestMaps
//
//  Created by Pavel Hrybouski on 12.10.16.
//  Copyright © 2016 Pavel Hrybouski. All rights reserved.
//

#import "PHDataManger.h"
#import "PHLocations.h"
#import "PHLocations+CoreDataProperties.h"
#import <MapKit/MKReverseGeocoder.h>

@interface PHDataManger()
@property (strong, nonatomic) CLGeocoder *geoCoder;
@property (strong, nonatomic) CLPlacemark *placemark;
@end



@implementation PHDataManger
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

+ (PHDataManger*) sharedManager {
    
    static PHDataManger* manager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[PHDataManger alloc] init];
    });
    
    return manager;
}

- (void) deleteAllObjects {
    
    NSArray* allObjects = [self allObjects];
    
    for (id object in allObjects) {
        [self.managedObjectContext deleteObject:object];
    }
    [self.managedObjectContext save:nil];
}

- (NSArray*) allObjects {
    
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription* description =
    [NSEntityDescription entityForName:@"PHLocations"
                inManagedObjectContext:self.managedObjectContext];
    
    [request setEntity:description];
    
    NSError* requestError = nil;
    NSArray* resultArray = [self.managedObjectContext executeFetchRequest:request error:&requestError];
    if (requestError) {
        NSLog(@"%@", [requestError localizedDescription]);
    }
    NSLog(@"%@", resultArray);
    return resultArray;
}




- (PHLocations*) addLocationToCoreData:(CLLocation *) aUserLocation {
//    [self deleteAllObjects];
    
    
    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
    PHLocations* currentLocation = [NSEntityDescription insertNewObjectForEntityForName:@"PHLocations"
                                  inManagedObjectContext:self.managedObjectContext];
    NSNumber *latitudeNumber = [NSNumber numberWithDouble:aUserLocation.coordinate.latitude];
    NSNumber *longitudeNumber = [NSNumber numberWithDouble:aUserLocation.coordinate.longitude];
    currentLocation.latitude  =  latitudeNumber;
    currentLocation.longitude =  longitudeNumber;
    currentLocation.date = [NSDate date];

    [geoCoder
     reverseGeocodeLocation:aUserLocation
     completionHandler:^(NSArray *placemarks, NSError *error) {
         
         NSString* message = nil;
         
         if (error) {
             
             message = [error localizedDescription];
             
         } else {
             
             if ([placemarks count] > 0) {
                 
                 MKPlacemark* placeMark = [placemarks firstObject];
                 NSDictionary *dict = [[NSDictionary alloc] initWithDictionary:placeMark.addressDictionary];

                 currentLocation.city = [dict objectForKey:@"City"];
             }
    
    
    
         }}];

    
    NSError* error = nil;
    
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"%@", [error localizedDescription]);
    }
    
    return currentLocation;
   
}


#pragma mark - Core Data stack



- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "org.PH.TestMaps" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"TestMaps" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"TestMaps.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        [[NSFileManager defaultManager] removeItemAtURL:storeURL error:&error];
        [_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error];
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}



@end
