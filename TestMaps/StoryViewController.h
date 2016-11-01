//
//  StoryViewController.h
//  TestMaps
//
//  Created by Pavel Hrybouski on 13.10.16.
//  Copyright © 2016 Pavel Hrybouski. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PHDataManger.h"
@class PHLocations;

@interface StoryViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext* managedObjectContext;
@property (strong, nonatomic) PHLocations *selectedLocation;
@property (strong, nonatomic) MKMapView * mapView;

@end
