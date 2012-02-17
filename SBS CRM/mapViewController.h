//
//  mapViewController.h
//  SBS CRM
//
//  Created by Tom Couchman on 14/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface mapViewController : UIViewController
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) NSString *address;
@property (strong, nonatomic) NSString *companyName;
@property (strong, nonatomic) IBOutlet UISegmentedControl *mapTypeSwitcher;



-(CLLocationCoordinate2D)addressCoordinates;
-(void)goToLocation;


@end
