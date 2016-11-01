//
//  ViewController.m
//  TestMaps
//
//  Created by Pavel Hrybouski on 12.10.16.
//  Copyright © 2016 Pavel Hrybouski. All rights reserved.
//

#import "ViewController.h"
#import <MapKit/MapKit.h>
#import "PHMapAnnotation.h"
#import "PHLocations.h"
#import "PHDataManger.h"
#import "PHLocations+CoreDataProperties.h"
#import "UIView+MKAnnotationView.h"
#import "PHServerManager.h"

@interface ViewController () <MKMapViewDelegate, CLLocationManagerDelegate>
@property (strong, nonatomic) CLGeocoder *geoCoder;
@property (strong, nonatomic) MKDirections* directions;
@property (strong, nonatomic) CLPlacemark *placemark;
@end

@implementation ViewController{
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        [super viewDidLoad];
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.mapView.showsUserLocation = YES;
    
    self.mapView.delegate = self;
    
    
    [self.view addSubview:self.mapView];
    self.geoCoder = [[CLGeocoder alloc] init];
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(actionAdd:)];
    UIBarButtonItem *zoomButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(actionShowAll:)];
    self.navigationItem.rightBarButtonItems = @[zoomButton,addButton];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(addPinFromList:)
                                                 name:@"ADDaPIN"
                                               object:nil];

}




# pragma mark - Actions

-(void) actionAdd: (UIBarButtonItem *) sender{
    PHMapAnnotation *annotation = [[PHMapAnnotation alloc] init];
    
    annotation.coordinate = self.mapView.region.center;
    annotation.title =   [NSString stringWithFormat:@"%f", annotation.coordinate.latitude];
    annotation.subtitle = [NSString stringWithFormat:@"%f", annotation.coordinate.longitude]   ;
    [self.mapView addAnnotation:annotation];
}


-(void) actionShowAll: (UIBarButtonItem *) sender{
    
    MKMapRect zoomRect = MKMapRectNull;
    for (id <MKAnnotation> annotation in self.mapView.annotations) {
        CLLocationCoordinate2D location = annotation.coordinate;
        MKMapPoint center = MKMapPointForCoordinate(location);
        static double delta = 20000;
        
        
        MKMapRect rect = MKMapRectMake(center.x - delta, center.y -delta, delta*2, delta*2);
        zoomRect = MKMapRectUnion(zoomRect, rect);
        
    }
    zoomRect = [self.mapView mapRectThatFits:zoomRect];
    [self.mapView setVisibleMapRect:zoomRect edgePadding:UIEdgeInsetsMake(50, 50, 50, 50) animated:YES];
    
    
}


- (void) actionDescription:(UIButton*) sender {
    
    MKAnnotationView* annotationView = [sender superAnnotationView];
    
    if (!annotationView) {
        return;
    }
    
    CLLocationCoordinate2D coordinate = annotationView.annotation.coordinate;
    
    CLLocation* location = [[CLLocation alloc] initWithLatitude:coordinate.latitude
                                                      longitude:coordinate.longitude];
    
    if ([self.geoCoder isGeocoding]) {
        [self.geoCoder cancelGeocode];
    }
    
    [self.geoCoder
     reverseGeocodeLocation:location
     completionHandler:^(NSArray *placemarks, NSError *error) {
         
         NSString* message = nil;
         
         if (error) {
             
             message = [error localizedDescription];
             
         } else {
             
             if ([placemarks count] > 0) {
                 
                 MKPlacemark* placeMark = [placemarks firstObject];
                 
                 message = [placeMark.addressDictionary description];
                 
             } else {
                 message = @"No Placemarks Found";
             }
         }
         
         [self showAlertWithTitle:@"Location" andMessage:message];
     }];
    
}


- (void) actionDirection:(UIButton*) sender {
    
    MKAnnotationView* annotationView = [sender superAnnotationView];
    
    if (!annotationView) {
        return;
    }
    
    if ([self.directions isCalculating]) {
        [self.directions cancel];
    }
    
    CLLocationCoordinate2D coordinate = annotationView.annotation.coordinate;
    
    MKDirectionsRequest* request = [[MKDirectionsRequest alloc] init];
    
    request.source = [MKMapItem mapItemForCurrentLocation];
    
    MKPlacemark* placemark = [[MKPlacemark alloc] initWithCoordinate:coordinate
                                                   addressDictionary:nil];
    
    MKMapItem* destination = [[MKMapItem alloc] initWithPlacemark:placemark];
    
    request.destination = destination;
    
    request.transportType = MKDirectionsTransportTypeAutomobile;
    
    request.requestsAlternateRoutes = YES;
    
    self.directions = [[MKDirections alloc] initWithRequest:request];
    
    [self.directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        
        if (error) {
            [self showAlertWithTitle:@"Error" andMessage:[error localizedDescription]];
        } else if ([response.routes count] == 0) {
            [self showAlertWithTitle:@"Error" andMessage:@"No routes found"];
        } else {
            
            [self.mapView removeOverlays:[self.mapView overlays]];
            
            NSMutableArray* array = [NSMutableArray array];
            
            for (MKRoute* route in response.routes) {
                [array addObject:route.polyline];
            }
            
            [self.mapView addOverlays:array level:MKOverlayLevelAboveRoads];
        }
        
    }];
}


-(IBAction)setMap:(id)sender{
    switch ((((UISegmentedControl *) sender).selectedSegmentIndex)) {
        case 0:
            self.mapView.mapType = MKMapTypeStandard;
            break;
        case 1:
            self.mapView.mapType = MKMapTypeSatellite;
            break;
        case 2:
            self.mapView.mapType = MKMapTypeHybrid;
            break;
            
        default:
            break;
    }
}

-(IBAction)getLocation:(id)sender{
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    [locationManager requestWhenInUseAuthorization];
    
    [locationManager startUpdatingLocation];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
        
    
    
    
    self.hasBeenUpdated = NO;
    
    
}

-(void)addPinFromList:(NSNotification *) notification{
    
    PHMapAnnotation *annotation = [[PHMapAnnotation alloc] init];
    CLLocationCoordinate2D coord;
    coord.longitude = [[notification.userInfo objectForKey:@"object.longitude"] doubleValue];
    coord.latitude = [[notification.userInfo objectForKey:@"object.latitude"]doubleValue];
    annotation.coordinate = coord;
    
    
    annotation.title =   [NSString stringWithFormat:@"%f", annotation.coordinate.latitude];
    annotation.subtitle = [NSString stringWithFormat:@"%f", annotation.coordinate.longitude]   ;
    [self.mapView addAnnotation:annotation];
    
//    MKMapRect zoomRect = MKMapRectNull;
//    MKCoordinateRegion region;
//    MKCoordinateSpan span;
//    span.latitudeDelta = 0.005;
//    span.longitudeDelta = 0.005;
//    
//    region.span = span;
//    region.center = coord;
//    [self.mapView setRegion:region animated:YES];
//    for (id <MKAnnotation> annotation in self.mapView.annotations) {
//        //      CLLocationCoordinate2D location = annotation.coordinate;
//        MKMapPoint center = MKMapPointForCoordinate(coord);
//        static double delta = 20000;
//        
//        
//        MKMapRect rect = MKMapRectMake(center.x - delta, center.y -delta, delta*2, delta*2);
//        zoomRect = MKMapRectUnion(zoomRect, rect);
//        
//    }
//    zoomRect = [self.mapView mapRectThatFits:zoomRect];
//    [self.mapView setVisibleMapRect:zoomRect edgePadding:UIEdgeInsetsMake(50, 50, 50, 50) animated:YES];
    
}
- (IBAction)Info:(id)sender{
    
    NSString *latitudeString = [NSString stringWithFormat:@"%f", self.mapView.userLocation.coordinate.latitude];
    NSString *longitudeString = [NSString stringWithFormat:@"%f", self.mapView.userLocation.coordinate.longitude];
    
    NSDictionary * locationDictionary  = [[NSDictionary alloc]initWithObjectsAndKeys:
                                          
                                          latitudeString , @"latitude",
                                          longitudeString, @"longitude",
                                          nil];
    
    [[PHServerManager sharedManager] getWeather:locationDictionary onSuccess:^(NSDictionary *currentWeather) {
        
        
        
        
        
        
        NSTimeInterval interval= [[[currentWeather objectForKey:@"sys"] objectForKey:@"sunset" ] doubleValue];
        NSDateFormatter *newDateFormatter = [[NSDateFormatter alloc]init];
        newDateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"ru_RU"];
        NSDate *sunsetDate = [NSDate dateWithTimeIntervalSince1970:interval];
        [newDateFormatter setDateFormat:@"E, d MMM yyyy HH:mm:ss Z"];
        
        
        [self showAlertWithTitle:@"CURRENT WEATHER" andMessage:[NSString stringWithFormat:@"Clouds = %@\n Main = %@\n Sunset = %@\n Wind = %@", [currentWeather objectForKey:@"clouds"],[currentWeather objectForKey: @"main" ] , [newDateFormatter stringFromDate:sunsetDate],[currentWeather objectForKey:@"wind"]]];
        
        
        
    } onFailure:^(NSError *error, NSInteger statusCode) {
        
    }];
    
    
}


#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    [self showAlertWithTitle:@"Error" andMessage:@"Failed to Get Your Location"];
    
}


- (void)locationManager:(CLLocationManager *)manager
didUpdateLocations:(NSArray<CLLocation *> *)locations{
    if (manager != locationManager)
        
    {
        [manager stopUpdatingLocation];
        return;
    }
    if (!self.hasBeenUpdated) {
        [[PHDataManger sharedManager] addLocationToCoreData:[locations lastObject]];
        self.hasBeenUpdated = YES;
    }
    
    [locationManager stopUpdatingLocation];
    [self.geoCoder
     reverseGeocodeLocation:locations.lastObject
     completionHandler:^(NSArray *placemarks, NSError *error) {
         
         NSString* message = nil;
         
         if (error) {
             
             message = [error localizedDescription];
             
         } else {
             
             if ([placemarks count] > 0) {
                 
                 MKPlacemark* placeMark = [placemarks firstObject];
                 
                 message = [placeMark.addressDictionary description];
                 
             } else {
                 message = @"No Placemarks Found";
             }
         }
         
         [self showAlertWithTitle:@"Location" andMessage:message];
     }];
    
}


#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)aMapView didUpdateUserLocation:(MKUserLocation *)aUserLocation {
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta = 0.005;
    span.longitudeDelta = 0.005;
    CLLocationCoordinate2D location;
    location.latitude = aUserLocation.coordinate.latitude;
    location.longitude = aUserLocation.coordinate.longitude;
    region.span = span;
    region.center = location;
    [aMapView setRegion:region animated:YES];
    
    self.mapView.userLocation.title = [NSString stringWithFormat:@"%f", self.mapView.userLocation.coordinate.latitude];
    self.mapView.userLocation.subtitle = [NSString stringWithFormat:@"%f", self.mapView.userLocation.coordinate.longitude];
    
}


- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view didChangeDragState:(MKAnnotationViewDragState)newState
fromOldState:(MKAnnotationViewDragState)oldState {
    
    if (newState == MKAnnotationViewDragStateEnding) {
        
        CLLocationCoordinate2D location = view.annotation.coordinate;
        MKMapPoint point = MKMapPointForCoordinate(location);
        
        NSLog(@"\nlocation = {%f, %f}\npoint = %@", location.latitude, location.longitude, MKStringFromMapPoint(point));
    }
    
}
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    
    static NSString* identifier = @"Annotation";
    
    MKPinAnnotationView* pin = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    
    if (!pin) {
        pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        pin.pinTintColor = [UIColor purpleColor];
        pin.animatesDrop = YES;
        pin.canShowCallout = YES;
        pin.draggable = YES;
        
        UIButton* descriptionButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        [descriptionButton addTarget:self action:@selector(actionDescription:) forControlEvents:UIControlEventTouchUpInside];
        pin.rightCalloutAccessoryView = descriptionButton;
        
        UIButton* directionButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
        [directionButton addTarget:self action:@selector(actionDirection:) forControlEvents:UIControlEventTouchUpInside];
        pin.leftCalloutAccessoryView = directionButton;
        
    } else {
        pin.annotation = annotation;
    }
    
    return pin;
}







- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}


- (void) showAlertWithTitle:(NSString*) title andMessage:(NSString*) message {
    
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:title
                                  message:message
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             
                             
                         }];
    
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
    
    
    
}
-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay{
    
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        
        MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithPolyline:overlay];
        renderer.lineWidth = 5.0;
        renderer.strokeColor = [UIColor colorWithRed:0.f green:0.5f blue:1.f alpha:0.9f];
        return renderer;
        
    }
    return nil;
}

-(void)dealloc{
    
    if ([self.geoCoder isGeocoding]) {
        
        [self.geoCoder cancelGeocode];
        
    }    if ([self.directions isCalculating]) {
        
        [self.directions cancel];
    }
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    
}


@end
