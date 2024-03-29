//
//  mapViewController.h
//  SBS CRM
//
//  Created by Tom Couchman on 14/02/2012.
//  Copyright (c) 2012 Shuttleworth Business Systems Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface MapViewController : UIViewController <MKMapViewDelegate, UIActionSheetDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) NSString *address;
@property (strong, nonatomic) NSString *companyName;
@property (nonatomic) CLLocationCoordinate2D addressCoord;
@property (nonatomic, retain) CLLocation *lastLocation;
@property (strong, nonatomic) IBOutlet UISegmentedControl *mapTypeSwitcher;
@property (nonatomic, retain) CLLocationManager *locationMgr;

- (CLLocationCoordinate2D)addressCoordinates;
- (void)goToLocation;

@end
