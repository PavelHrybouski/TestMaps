//
//  ViewController.h
//  TestMaps
//
//  Created by Pavel Hrybouski on 12.10.16.
//  Copyright © 2016 Pavel Hrybouski. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreLocation/CoreLocation.h>

@class MKMapView;
@class PHMapAnnotation;
@interface ViewController : UIViewController <CLLocationManagerDelegate>{
    CLLocationManager *locationManager;

}

@property(nonatomic) BOOL hasBeenUpdated;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) NSMutableDictionary *locationDictionary;

-(IBAction)setMap:(id)sender;
-(IBAction)getLocation:(id)sender;

@end

