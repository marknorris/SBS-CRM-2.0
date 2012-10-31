//
//  contactListTableViewController.m
//  SBS CRM
//
//  Created by Tom Couchman on 16/02/2012.
//  Copyright (c) 2012 Shuttleworth Business Systems Limited. All rights reserved.
//

#import "ContactListTableViewController.h"
#import "DDXML.h"
#import "ContactSearch.h"
#import "AppDelegate.h"
#import "ContactDetailsTableViewController.h"
#import "FetchXML.h"
#import "XMLParser.h"

@interface ContactListTableViewController() {
    NSArray *contactsArray;
    UIActivityIndicatorView *refreshSpinner;
    BOOL fetchingSearchResults;
}

- (void)loadData;

@end

@implementation ContactListTableViewController

@synthesize company = _company;

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
    //contactsArray = [[NSMutableArray alloc] init];
    fetchingSearchResults = NO;
    //set up the activity spinner
    refreshSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    refreshSpinner.frame = CGRectMake(5, 0, 20, 20);
    refreshSpinner.hidesWhenStopped = YES;
    
    [self loadData];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
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
    // Return YES for supported orientations
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
    return YES;
}

//###############################################
//#                                             #
//#                                             #
//#                  Get Data                   #
//#                                             #
//#                                             #
//###############################################

- (void)loadData
{
    fetchingSearchResults = YES;
    [self.tableView reloadData];
    
    //download the dom doc file.
    NSURL *url = [NSURL URLWithString:[appURL stringByAppendingFormat:@"/service1.asmx/searchContactsByCompanyABL?searchCompanySiteID=%@", self.company.companySiteID] ];
    FetchXML *getContactsDom = [[FetchXML alloc] initWithUrl:url delegate:self className:@"ContactSearch"];
    
    if (![getContactsDom fetchXML]) {
        [[[UIAlertView alloc] initWithTitle:@"Connection Error" message:@"Could not connect to the server" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        return;
    }
    
}

- (void)docRecieved:(NSDictionary *)docDic:(id)sender
{
    NSString *classKey = [docDic objectForKey:@"ClassName"];
    contactsArray = [[[XMLParser alloc] init]parseXMLDoc:[docDic objectForKey:@"Document"] toClass:NSClassFromString(classKey)];
    
    //create sort descriptors to order the contacts.
    NSSortDescriptor *firstNameSortDescriptor, *middleNameSortDescriptor, *lastNameSortDescriptor;
    firstNameSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"conFirstName" ascending:YES];
    middleNameSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"conMiddleName" ascending:YES];
    lastNameSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"conSurname" ascending:YES];
    // create an ordered array of the contacts
    contactsArray = [contactsArray sortedArrayUsingDescriptors:[NSArray arrayWithObjects:firstNameSortDescriptor,middleNameSortDescriptor, lastNameSortDescriptor,nil]];
    
    fetchingSearchResults = NO;
    [self.tableView reloadData];
}

//###############################################
//#                                             #
//#                                             #
//#               Table View                    #
//#                                             #
//#                                             #
//###############################################

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [contactsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ContactCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    //get the contact to be displayed.
    ContactSearch* contact = [contactsArray objectAtIndex:indexPath.row];
    
    NSString *fullName;
    NSMutableArray *nameArray = [NSMutableArray arrayWithObjects:contact.conTitle,contact.conFirstName, contact.conMiddleName, contact.conSurname, nil];
    [nameArray removeObject:@""];
    fullName = [nameArray componentsJoinedByString:@"\n"];
    cell.textLabel.text = fullName;
    cell.detailTextLabel.text = [contact.cosSiteName stringByAppendingFormat:@" - %@", contact.cosDescription];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    if (fetchingSearchResults) {
        // create a view
        UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.tableView.frame.size.width, 20)];
        
        [refreshSpinner startAnimating];
        
        customView.backgroundColor = [UIColor blackColor];
        // create the button object
        
        UILabel * headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        headerLabel.backgroundColor = [UIColor clearColor];
        headerLabel.opaque = NO;
        headerLabel.textColor = [UIColor whiteColor];
        headerLabel.font = [UIFont boldSystemFontOfSize:18];
        headerLabel.highlightedTextColor = [UIColor whiteColor];
        headerLabel.frame = CGRectMake(30.0, 0.0, 200.0, 20.0);
        
        // If you want to align the header text as centered
        // headerLabel.frame = CGRectMake(150.0, 0.0, 300.0, 44.0);
        
        headerLabel.text = @"Fetching results..."; // i.e. array element
        [customView addSubview:refreshSpinner];
        [customView addSubview:headerLabel];
    	return customView;
    }
    
    return nil;
}

//###############################################
//#                                             #
//#                                             #
//#                  Segue                      #
//#                                             #
//#                                             #
//###############################################

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //if the segue is to the details screen
    if ([segue.identifier isEqualToString:@"toContactDetails"]) {
        //get the clicked cell's row
        NSInteger row = [[self tableView].indexPathForSelectedRow row];
        //set up the details view controller
        ContactDetailsTableViewController *detailViewController = segue.destinationViewController;
        //send the object at index row.
        detailViewController.contactDetail = [contactsArray objectAtIndex:row];
        detailViewController.company = [[CompanySearch alloc] init];
        detailViewController.company = self.company;
        detailViewController.isCoreData = NO;
    }
}

@end
