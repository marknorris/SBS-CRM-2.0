//
//  companyDetailsTableViewController.m
//  SBS CRM
//
//  Created by Tom Couchman on 14/02/2012.
//  Copyright (c) 2012 Shuttleworth Business Systems Limited. All rights reserved.
//

#import "companyDetailsTableViewController.h"
#import "mapViewController.h"
#import "eventsListTableViewController.h"
#import "contactListTableViewController.h"
#import "advancedSearchTableViewController.h"

#import "Reachability.h"

@implementation companyDetailsTableViewController

@synthesize txtAddress;
@synthesize lblSiteName;
@synthesize lblDescription;
@synthesize cellAddress;

@synthesize companyDetail;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    lblSiteName.text = companyDetail.cosSiteName;
    lblDescription.text = companyDetail.cosDescription;
    
    //create an array of address components, remove blanks, put in string with newlines between them.
    NSMutableArray *addressArray = [NSMutableArray arrayWithObjects:companyDetail.addStreetAddress, companyDetail.addStreetAddress2, companyDetail.addStreetAddress3, companyDetail.addTown,companyDetail.addCounty, companyDetail.couCountryName, companyDetail.addPostCode, nil];
    [addressArray removeObject:@""];
    fullAddress = [addressArray componentsJoinedByString:@"\n"];

    txtAddress.text = fullAddress;
        
}

- (void)viewDidUnload
{
    [self setLblDescription:nil];
    [self setLblSiteName:nil];
    [self setTxtAddress:nil];
    [self setCellAddress:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // check for internet connection
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNetworkStatus:) name:kReachabilityChangedNotification object:nil];
    
    internetReachable = [Reachability reachabilityForInternetConnection];
    [internetReachable startNotifier];
    
    // check if a pathway to a googlemaps exists
    hostReachable = [Reachability reachabilityWithHostName: @"maps.google.com"];
    [hostReachable startNotifier];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        //check internet connection
        if (internetActive)
        {
            if (hostActive)
                [self performSegueWithIdentifier:@"toMap" sender:self];
            else {
                UIAlertView *noInternetConnection = [[UIAlertView alloc] initWithTitle:@"Google Maps Unavailable" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [noInternetConnection show];
                [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow]  animated:YES];
            }
            
        }
        else {
            UIAlertView *noInternetConnection = [[UIAlertView alloc] initWithTitle:@"No Internet Connection" message:@"Please connect and try again" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [noInternetConnection show];
            [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow]  animated:YES];
        }
        
    }
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //if the segue is to the details screen
    if ([segue.identifier isEqualToString:@"toMap"])
    {
        //set up the required data in the Map View controller        
        mapViewController *mapController = segue.destinationViewController;
        mapController.address = [fullAddress stringByReplacingOccurrencesOfString:@"\n" withString:@", "];
        mapController.companyName = companyDetail.cosSiteName;
        
    }
    else if ([segue.identifier isEqualToString:@"toEventsList"])
    {
        // create list view controller, set the required variables.     
        eventsListTableViewController *listViewController = segue.destinationViewController;
        listViewController.company = companyDetail;
    }
    else if([segue.identifier isEqualToString:@"toAdvancedSearch"])
    {
        advancedSearchTableViewController *_advancedSearchTableViewController = segue.destinationViewController;
        _advancedSearchTableViewController.companySiteID = companyDetail.companySiteID;
        _advancedSearchTableViewController.cosSiteName = companyDetail.cosSiteName;
        _advancedSearchTableViewController.company = companyDetail;
        
    }
    else if ([segue.identifier isEqualToString:@"toContactList"])
    {
        // create list view controller, set the required variables.     
        contactListTableViewController *listViewController = segue.destinationViewController;
        listViewController.company = [[CompanySearch alloc] init];
        listViewController.company = companyDetail;
    }
}



-(void) checkNetworkStatus:(NSNotification *)notice
{
    // called after network status changes
    NetworkStatus internetStatus = [internetReachable currentReachabilityStatus];
    switch (internetStatus)
    {
        case NotReachable:
        {
            NSLog(@"The internet is down.");
            internetActive = NO;
            
            break;
        }
        case ReachableViaWiFi:
        {
            NSLog(@"The internet is working via WIFI.");
            internetActive = YES;
            
            break;
        }
        case ReachableViaWWAN:
        {
            NSLog(@"The internet is working via WWAN.");
            internetActive = YES;
            
            break;
        }
    }
    
    NetworkStatus hostStatus = [hostReachable currentReachabilityStatus];
    switch (hostStatus)
    {
        case NotReachable:
        {
            NSLog(@"A gateway to the host server is down.");
            hostActive = NO;
            
            break;
        }
        case ReachableViaWiFi:
        {
            NSLog(@"A gateway to the host server is working via WIFI.");
            hostActive = YES;
            
            break;
        }
        case ReachableViaWWAN:
        {
            NSLog(@"A gateway to the host server is working via WWAN.");
            hostActive = YES;
            
            break;
        }
    }
}


@end
