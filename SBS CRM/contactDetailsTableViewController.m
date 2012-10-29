//
//  contactDetailsTableViewController.m
//  SBS CRM
//
//  Created by Tom Couchman on 14/02/2012.
//  Copyright (c) 2012 Shuttleworth Business Systems Limited. All rights reserved.
//

#import "contactDetailsTableViewController.h"
#import "mapViewController.h"
#import "AppDelegate.h"
#import "Communication.h"
#import "CommunicationSearch.h"
#import "eventsListTableViewController.h"
#import "DDXML.h"
#import "advancedSearchTableViewController.h"

#import "fetchXML.h"
#import "XMLParser.h"

#import "NSManagedObject+CoreDataManager.h"

#import "Reachability.h"

@interface contactDetailsTableViewController()

-(void)getCoreData;
 
@end

@implementation contactDetailsTableViewController

@synthesize contactDetail;
@synthesize company;

@synthesize isCoreData;

@synthesize contactNameOutlet;
@synthesize siteNameDescriptionOutlet;
@synthesize addressOutlet;
@synthesize eventsOutlet;
@synthesize addressCell;
@synthesize cellAdvancedEvents;

@synthesize communicationArray;

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
    
    communicationArray = [[NSMutableArray alloc] init];
    //TODO: not sure if this is ever filled from other views, if so change this:

    //[communicationArray addObject:@"hi"];
    //NSLog(@"count: %d", [communicationArray count]);
    //[self.tableView reloadData];
    
    
    //company = [[CompanySearch alloc] init];
    
    //create a name string using all of the name data available for the contact
    NSMutableArray *nameArray = [NSMutableArray arrayWithObjects:contactDetail.conTitle,contactDetail.conFirstName,contactDetail.conMiddleName,contactDetail.conSurname, nil];
    [nameArray removeObject:@""];
    fullName = [nameArray componentsJoinedByString:@"\n"];
    contactNameOutlet.text = fullName;
    
    
    if (isCoreData)
    {
        [self getCoreData];
    }
    else// if not core data retrieve data from the server
    {
        //Create an alert to display if the data cannot be loaded
        UIAlertView *domGetFailed = [[UIAlertView alloc] initWithTitle:@"Connection Error" message:@"Could not connect to the server" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        NSURL *url = [NSURL URLWithString:[appURL stringByAppendingFormat:@"/service1.asmx/searchCommunicationByContactIDABL?contactID=%@",contactDetail.contactID]];
        
        fetchXML *getCommunicationDom = [[fetchXML alloc] initWithUrl:url delegate:self className:@"CommunicationSearch"];

        if (![getCommunicationDom fetchXML])
        {[domGetFailed show]; return;}
        
        
        if (!company) // need company when the user has come from a user search.
        {
            NSURL *url = [NSURL URLWithString:[appURL stringByAppendingFormat:@"/service1.asmx/searchCompaniesByCompanySiteIDABL?companySiteID=%@",contactDetail.companySiteID]];
            
            fetchXML *getCompanyDom = [[fetchXML alloc] initWithUrl:url delegate:self className:@"CompanySearch"];
            
            if (![getCompanyDom fetchXML])
            {[domGetFailed show]; return;}
            //NSLog(@"url: %@", [appURL stringByAppendingFormat:@"/service1.asmx/searchCompaniesByCompanySiteIDABL?companySiteID=%@",contactDetail.companySiteID]);
        }
        
        
    }   
    
    //TODO: make sure userweb passwords are left out!.
    //loop though and delete them I guess.
    
}
    
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

}
    
    

-(void)fetchXMLError:(NSString *)errorResponse:(id)sender{
    if (self.view.window) // don't display if this view is not active. TODO:make sure this method is never event called!
    {
        // If error recieved, display alert.
        [[[UIAlertView alloc] initWithTitle:@"Error Fetching Data" message:errorResponse delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }
}

-(void)docRecieved:(NSDictionary *)docDic:(id)sender{
    NSString *classKey = [docDic objectForKey:@"ClassName"];
    NSArray *Array = [[[XMLParser alloc] init]parseXMLDoc:[docDic objectForKey:@"Document"] toClass:NSClassFromString(classKey)];
    
    if ([Array count] > 0)
    {
        
        //Fill the array's correspoding core data entity and reduce the refreshed state for each store that takes place.
        if (classKey == @"CommunicationSearch" && [Array count] > 0) //first ensure that the array is not empty
        { //determine if the contact is the customer or our contact:
            for (CommunicationSearch *com in Array)
            {
                if (![com.cotDescription isEqualToString:@"UserWebPassword"]) 
                    [communicationArray addObject:com];
            }
            //NSLog(@"count: %d", [communicationArray count]);
            //[communicationArray addObject:@"hi"];
             //communicationArray = [NSMutableArray arrayWithArray:Array];
           //[communicationArray addObjectsFromArray:[NSMutableArray arrayWithArray:Array]];
        }
        else if (classKey == @"CompanySearch") {
            company = [Array objectAtIndex:0];
            //update the site name label
            siteNameDescriptionOutlet.text = [company.cosSiteName stringByAppendingFormat:@" - %@",company.cosDescription];
        }
    }
    //each time a data fetch completes, refresh the tableview to disaplay it.
    [self.tableView reloadData];
}


    
    
    


-(void)getCoreData{
    //load other required data from core data
    
    // use a predicate to select the communication methods for the contact and remove UserWebPassword from the results
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(contactID == %@) AND cotDescription != 'UserWebPassword'", contactDetail.contactID];
    
    //Sort acendingly by the communication type
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                        initWithKey:@"cotDescription" ascending:YES];
    
    [communicationArray removeAllObjects];
    // request the data
    communicationArray = [NSMutableArray arrayWithArray:[NSManagedObject fetchObjectsForEntityName:@"Communication" withPredicate:predicate withSortDescriptors:[NSArray arrayWithObject:sortDescriptor]]];
    
    if (!company)
    {

        //load the address from the company entity using companySiteID as a predicate
        predicate = [NSPredicate predicateWithFormat:@"companySiteID == %@", contactDetail.companySiteID];
        NSArray *companyArray = [NSManagedObject fetchObjectsForEntityName:@"Company" withPredicate:predicate withSortDescriptors:nil];
        if([companyArray count] > 0)
        {
            company = [companyArray objectAtIndex:0];
            siteNameDescriptionOutlet.text = [company.cosSiteName stringByAppendingFormat:@" - %@",company.cosDescription];
        }
    }
    else {
        siteNameDescriptionOutlet.text = [company.cosSiteName stringByAppendingFormat:@" - %@",company.cosDescription];
    }

    [self.tableView reloadData];
    
}








- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    
    // Return the number of sections.
    return 2;
    
    //[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:2]
                  //withRowAnimation:UITableViewRowAnimationFade]; 

}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    // Return the number of rows in the section.
    if (section == 0) 
    {
        //NSLog(@"count before noofrowsatsection: %d", [communicationArray count]);
        return [communicationArray count];
    }
    else if (section == 2)
        return 2;
    else
        return 1;
    
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";


    switch (indexPath.section)
    {
    case 0:
        {
            
            //if ([communicationArray count] > 0)
                                //[self.tableView insertRowsAtIndexPaths:0 withRowAnimation:UITableViewRowAnimationTop];
            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
            }
            
            if ([communicationArray count] > indexPath.row)
            {
                CommunicationSearch *communication = [[CommunicationSearch alloc] init];
                communication = [communicationArray objectAtIndex:indexPath.row];
                //NSLog(@"desction:%@",communication.cotDescription);
                //label the cell according to the data inside (cannot use objcetive c switch statement with strings).
                if ([communication.cotDescription isEqualToString:@"Email"])
                    cell.detailTextLabel.text = communication.cmnEmail;
                else if ([communication.cotDescription isEqualToString:@"Fax"] || [communication.cotDescription isEqualToString:@"Telephone"] || [communication.cotDescription isEqualToString:@"Mobile"])
                {
                    NSString *tel = @"";
                    if ([communication.cmnInternationalCode length])
                    {
                        tel = [tel stringByAppendingFormat:@"+%@", communication.cmnInternationalCode];
                        if ([communication.cmnAreaCode length] && [[communication.cmnAreaCode substringToIndex:1] isEqualToString:@"0"])
                            tel = [tel stringByAppendingFormat:@"%@", [communication.cmnAreaCode substringFromIndex:1]];
                        else
                            tel = [tel stringByAppendingFormat:@"%@", communication.cmnAreaCode];
                    }
                    else
                        tel = communication.cmnAreaCode;
                    
                    cell.detailTextLabel.text = [tel stringByAppendingFormat:@"%@",communication.cmnNumber];
                }
                cell.textLabel.text = communication.cotDescription;
            }
            return cell;
        }
    case 1:
        {
            NSMutableArray *addressArray = [NSMutableArray arrayWithObjects:company.addStreetAddress, company.addStreetAddress2, company.addStreetAddress3, company.addTown, company.addCounty, company.couCountryName, company.addPostCode, nil];
            [addressArray removeObject:@""];
            fullAddress = [addressArray componentsJoinedByString:@"\n"];
            addressOutlet.text = fullAddress;
            NSLog(@"address: %@",fullAddress);
            return addressCell;
        }
   case 2: // events cell
        {
            if (indexPath.row == 0)
                return eventsOutlet;
            else 
                return cellAdvancedEvents;
        }
        default:
        {
            UITableViewCell *defaultcell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (defaultcell == nil) {
                defaultcell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
            }
            return defaultcell;
        }
    }

    
    //NSLog(@"%@", indexPath.section);

}
 

- (void)viewDidUnload
{
    [self setContactNameOutlet:nil];
    [self setSiteNameDescriptionOutlet:nil];
    [self setAddressOutlet:nil];
    [self setEventsOutlet:nil];
    [self setAddressCell:nil];
    [self setCellAdvancedEvents:nil];
    [self setCellAdvancedEvents:nil];
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
    //if the user has clicked on a contact methods cell
    if (indexPath.section == 0)
    {
        if([[[communicationArray objectAtIndex:indexPath.row] cotDescription] isEqualToString:@"Telephone"] || [[[communicationArray objectAtIndex:indexPath.row] cotDescription] isEqualToString:@"Mobile"])  
        {
            CommunicationSearch *tempCommunication = [communicationArray objectAtIndex:indexPath.row];
            NSString *tel = @"";
            if ([tempCommunication.cmnInternationalCode length])
            {
                tel = [tel stringByAppendingFormat:@"+%@", tempCommunication.cmnInternationalCode];
                if ([tempCommunication.cmnAreaCode length] && [[tempCommunication.cmnAreaCode substringToIndex:1] isEqualToString:@"0"])
                    tel = [tel stringByAppendingFormat:@"%@", [tempCommunication.cmnAreaCode substringFromIndex:1]];
                else
                    tel = [tel stringByAppendingFormat:@"%@", tempCommunication.cmnAreaCode];
                
            }
            else
                tel = tempCommunication.cmnAreaCode;
            
            //append the number to the tel string and remove all non-integer values (i.e. spaces)
            tel = [[[tel stringByAppendingFormat:@"%@",tempCommunication.cmnNumber] componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat: @"tel://%@",tel]]];
        }
        else if ([[[communicationArray objectAtIndex:indexPath.row] cotDescription] isEqualToString:@"Email"])                                   
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat: @"mailto://%@", [[communicationArray objectAtIndex:indexPath.row] cmnEmail]]]];
    }
    else if (indexPath.section == 1)
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
    if ([segue.identifier isEqualToString:@"toMap"])
    {
        //set up the required data in the Map View controller        
        mapViewController *mapController = segue.destinationViewController;
        mapController.address = [fullAddress stringByReplacingOccurrencesOfString:@"\n" withString:@", "];
        mapController.companyName = contactDetail.cosSiteName;
    }
    else if ([segue.identifier isEqualToString:@"toEventsList"])
    {
        // create list view controller, set the required variables.       
        eventsListTableViewController *listViewController = segue.destinationViewController;
        listViewController.contact = contactDetail;
        listViewController.company = company;
    }
    else if([segue.identifier isEqualToString:@"toAdvancedSearch"])
    {
        advancedSearchTableViewController *_advancedSearchTableViewController = segue.destinationViewController;
        _advancedSearchTableViewController.companySiteID = company.companySiteID;
        _advancedSearchTableViewController.cosSiteName = company.cosSiteName;
        _advancedSearchTableViewController.company = company;
        _advancedSearchTableViewController.contactID = contactDetail.contactID;
        _advancedSearchTableViewController.fullName = fullName;
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
