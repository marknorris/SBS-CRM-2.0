//
//  mapViewController.m
//  SBS CRM
//
//  Created by Tom Couchman on 14/02/2012.
//  Copyright (c) 2012 Shuttleworth Business Systems Limited. All rights reserved.
//

#import "MapViewController.h"
#import "MyLocation.h"

@implementation MapViewController

@synthesize mapView = _mapView;
@synthesize address = _address;
@synthesize companyName = _companyName;
@synthesize mapTypeSwitcher = _mapTypeSwitcher;
@synthesize addressCoord = _addressCoord;
@synthesize lastLocation = _lastLocation;
@synthesize locationMgr = _locationMgr;

/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}*/

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self goToLocation];
    
    self.locationMgr = [[CLLocationManager alloc] init];
    self.locationMgr.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationMgr.delegate = self;
    [self.locationMgr startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    self.lastLocation = newLocation;
}

- (void)viewDidUnload
{
    [self setMapTypeSwitcher:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
    return YES;
}

- (IBAction)closeClick:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)refreshClick:(id)sender
{
    [self goToLocation];
}

-(void)goToLocation
{
    CLLocationCoordinate2D locationCoords = [self addressCoordinates];
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(locationCoords,200,200);
    MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:viewRegion]; 
    
    self.mapView.delegate = self;
    [self.mapView setRegion:adjustedRegion animated:YES];   
    
    MyLocation *location = [[MyLocation alloc] initWithName:self.companyName address:self.address coordinate:locationCoords];
    
    MKPinAnnotationView *mapPin = [[MKPinAnnotationView alloc] initWithAnnotation:location reuseIdentifier:@"Pin"];
    mapPin.canShowCallout = YES;
    UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    mapPin.rightCalloutAccessoryView = infoButton;
    
    [self.mapView addAnnotation:location];
    [self.mapView selectAnnotation:location animated:YES];
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    MKPinAnnotationView *pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"PinView"];
    pin.canShowCallout = YES;
    UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    pin.rightCalloutAccessoryView = infoButton;
    pin.animatesDrop = YES;
    
    return pin;
}

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Navigate using..." delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Google Maps",@"TomTom",@"NavFree", nil];
    [actionSheet showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{    
    double fromlat = self.lastLocation.coordinate.latitude;
    double fromlon = self.lastLocation.coordinate.longitude;
    double lat = self.addressCoord.latitude;
    double lon = self.addressCoord.longitude;
    
    if (buttonIndex == 0) {
        NSString *urlString = [NSString stringWithFormat:@"http://maps.google.com/maps?daddr=%f,%f&saddr=%f,%f", lat, lon,fromlat, fromlon, [self.companyName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        NSURL *ttURL = [[NSURL alloc] initWithString:urlString];
        [[UIApplication sharedApplication] openURL:ttURL];
    }
    if (buttonIndex == 1) {
        NSString *urlString = [NSString stringWithFormat:@"tomtomhome:geo:action=navigateto&lat=%f&long=%f&name=%@", lat, lon, [self.companyName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        NSURL *ttURL = [[NSURL alloc] initWithString:urlString];
        [[UIApplication sharedApplication] openURL:ttURL];
    }
    
    if (buttonIndex == 2) {
        NSString *urlString = [NSString stringWithFormat:@"navfree://%f,%f", lat, lon];
        NSURL *ttURL = [[NSURL alloc] initWithString:urlString];
        [[UIApplication sharedApplication] openURL:ttURL];
    }
    
}

- (IBAction)mapTypeSwitchClick:(id)sender
{
    //NSLog(@"index: %@",mapTypeSwitcher.selectedSegmentIndex);

    switch (self.mapTypeSwitcher.selectedSegmentIndex)
    {
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

- (CLLocationCoordinate2D)addressCoordinates 
{    
    //CLLocationCoordinate2D addressCoord;
    //addressCoord.longitude = 0.0;
    //addressCoord.latitude = 0.0;
    
    self.addressCoord = CLLocationCoordinate2DMake(0.0, 0.0);
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://maps.google.com/maps/geo?q=%@&output=csv", 
                  [self.address stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    
    NSError *error;
    //NSLog(@"URL: %@",url);
    NSString *coordinatesString = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
    //NSString *coordinatesString = [NSString stringWithContentsOfURL:url usedEncoding:NSString error:&error];
    //NSString *coordinatesString = [[NSString alloc] initWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    NSArray *coordinateArray = [coordinatesString componentsSeparatedByString:@","];

    if ([coordinateArray count] >= 4 && [[coordinateArray objectAtIndex:0] isEqualToString:@"200"]) {
        //addressCoord.latitude = [[coordinateArray objectAtIndex:2] doubleValue];
        //addressCoord.longitude = [[coordinateArray objectAtIndex:3] doubleValue];
        self.addressCoord = CLLocationCoordinate2DMake([[coordinateArray objectAtIndex:2] doubleValue], [[coordinateArray objectAtIndex:3] doubleValue]);
    }
    
    return self.addressCoord;
}

@end
