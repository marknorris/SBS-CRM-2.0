//
//  mapViewController.m
//  SBS CRM
//
//  Created by Tom Couchman on 14/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "mapViewController.h"

@implementation mapViewController

@synthesize mapView;
@synthesize address;
@synthesize companyName;
@synthesize mapTypeSwitcher;


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
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)closeClick:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)refreshClick:(id)sender {
    [self goToLocation];
}

-(void)goToLocation{
    CLLocationCoordinate2D locationCoords = [self addressCoordinates];
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(locationCoords,200,200);
    MKCoordinateRegion adjustedRegion = [mapView regionThatFits:viewRegion]; 
    
    MKPointAnnotation *annotationPoint = [[MKPointAnnotation alloc] init];
    annotationPoint.coordinate = locationCoords;
    annotationPoint.title = companyName;
    annotationPoint.subtitle = address;
    [mapView addAnnotation:annotationPoint]; 
    [mapView setRegion:adjustedRegion animated:YES];   
    [mapView selectAnnotation:annotationPoint animated:YES];
}

- (IBAction)mapTypeSwitchClick:(id)sender {
    //NSLog(@"index: %@",mapTypeSwitcher.selectedSegmentIndex);

    switch (mapTypeSwitcher.selectedSegmentIndex)
    {
        case 0:
            mapView.mapType = MKMapTypeStandard;
            break;
        case 1:
            mapView.mapType = MKMapTypeSatellite;
            break;
        case 2:
            mapView.mapType = MKMapTypeHybrid;
            break;
        default:
            break;
    }
}


-(CLLocationCoordinate2D)addressCoordinates {
    
    CLLocationCoordinate2D addressCoord;
    addressCoord.longitude = 0.0;
    addressCoord.latitude = 0.0;
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://maps.google.com/maps/geo?q=%@&output=csv", 
                  [address stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    
    NSError *error;
    NSLog(@"URL: %@",url);
    NSString *coordinatesString = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
    //NSString *coordinatesString = [NSString stringWithContentsOfURL:url usedEncoding:NSString error:&error];
    
    //NSString *coordinatesString = [[NSString alloc] initWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    
    
    NSArray *coordinateArray = [coordinatesString componentsSeparatedByString:@","];

    
    
    if([coordinateArray count] >= 4 && [[coordinateArray objectAtIndex:0] isEqualToString:@"200"]) {
        addressCoord.latitude = [[coordinateArray objectAtIndex:2] doubleValue];
        addressCoord.longitude = [[coordinateArray objectAtIndex:3] doubleValue];
    }
    
    return addressCoord;
    
}

@end
