//
//  eventsListTableViewController.m
//  SBS CRM
//
//  Created by Tom Couchman on 15/02/2012.
//  Copyright (c) 2012 Shuttleworth Business Systems Limited. All rights reserved.
//

#import "eventsListTableViewController.h"
#import "EventTableViewCell.h"
#import "eventDetailsTableViewController.h"
#import "fetchXML.h"
#import "XMLParser.h"

@interface  eventsListTableViewController(){
        UIActivityIndicatorView *refreshSpinner;
        BOOL fetchingSearchResults;
}
- (void)refreshTableView:(NSArray *)eventsArray;
@end 

@implementation eventsListTableViewController

@synthesize company;
@synthesize contact;
@synthesize advancedURL;
@synthesize orderByCreatedDate;


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
    //eventsArray = [[NSMutableArray alloc] init];
    fetchingSearchResults = NO;
    //set up the activity spinner
    refreshSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    refreshSpinner.frame = CGRectMake(5, 0, 20, 20);
    refreshSpinner.hidesWhenStopped = YES;
    
    orderedEventsArray = [[NSMutableArray alloc] init];
    
    //listen for the reloadcoredata notification when the tablview needs to refresh it's data.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(getData) 
                                                 name:@"reloadEventData"
                                               object:nil];
    
    [self getData];
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
    return YES;
}



//###############################################
//#                                             #
//#                                             #
//#                  Get Data                   #
//#                                             #
//#                                             #
//###############################################

- (void)getData{
    fetchingSearchResults = YES;
    
    //download the dom doc file.
    fetchXML *getContactsDom = [[fetchXML alloc] initWithUrl:nil delegate:self className: @"EventSearch"];
    
    UIAlertView *connectionErrorAlert = [[UIAlertView alloc] initWithTitle:@"Connection Error" message:@"Could not connect to the server" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    
    NSLog(@"advanced url: %@",advancedURL);
    //depending on the dom document, set the appropriate URL
    if (advancedURL)
    {
          NSLog(@"company: %@",company.coaCompanyName);
        if (![getContactsDom fetchXMLWithURL:advancedURL])
        {[connectionErrorAlert show]; return;} 
        
    }
    else if (contact) // if there is a contact ID perform the search by contact
    {
        if (![getContactsDom fetchXMLWithURL:[appURL stringByAppendingFormat:@"/service1.asmx/searchEventsByContactABL?searchContactID=%@",contact.contactID]])
        {[connectionErrorAlert show]; return;}
    }
    else if (company) // if there is a company site id perform the search by company site
    {
        if (![getContactsDom fetchXMLWithURL:[appURL stringByAppendingFormat:@"/service1.asmx/searchEventsByCompanyABL?searchCompanySiteID=%@",company.companySiteID]])
        {[connectionErrorAlert show]; return;}
    }
    else
    {
        [[[UIAlertView alloc] initWithTitle:@"Connection Error" message:@"Cannot determine URL" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }

}
    
-(void)docRecieved:(NSDictionary *)docDic:(id)sender{
    NSString *classKey = [docDic objectForKey:@"ClassName"];
    NSArray *eventsArray = [[[XMLParser alloc] init]parseXMLDoc:[docDic objectForKey:@"Document"] toClass:NSClassFromString(classKey)];
    fetchingSearchResults = NO;
    
    
    [self refreshTableView:eventsArray];
}








//###############################################
//#                                             #
//#                                             #
//#          Prepare TableView Data             #
//#                                             #
//#                                             #
//###############################################

- (void)refreshTableView:(NSArray *)eventsArray{
    //declare sort descriptors, order key and setup date formatters.
    NSSortDescriptor *dateSortDescriptor, *timeSortDescriptor;
    NSString *orderKey;
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateStyle:NSDateFormatterMediumStyle];
    NSDateFormatter *dfToDate = [[NSDateFormatter alloc] init];
    [dfToDate setDateFormat:@"dd/MM/yyyy"];
    
    [orderedEventsArray removeAllObjects];
    
    if ([eventsArray count] == 0) { // if there are no results then reload the table view data and return;
        [self.tableView reloadData]; return;
    }
    
    // set the sort descriptors depending on whether the results are to be ordered by eveDueDate or eveCreatedDate.
    if (!orderByCreatedDate){
        dateSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"eveDueDate" ascending:YES];
        timeSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"eveDueTime" ascending:YES];
        orderKey = @"eveDueDate";
    }
    else {
        dateSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"eveCreatedDate" ascending:YES];
        timeSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"eveCreatedTime" ascending:YES];
        orderKey = @"eveCreatedDate";
    }
    
    // create an ordered array of the events
    NSMutableArray *sortedArray = [[NSMutableArray alloc] initWithArray:[eventsArray sortedArrayUsingDescriptors:[NSArray arrayWithObjects:dateSortDescriptor,timeSortDescriptor,nil]]];
    eventsArray = nil; // clear the events array
    
    //replace null dates with date to avoid issues with placing values in array, and sorting. NSNull, does not allow sorting using @selector(compare:)
    for (EventSearch *eve in sortedArray)
        if ([eve valueForKey:orderKey] == NULL) [eve setValue:[dfToDate dateFromString:@"01/01/9999"] forKey:orderKey];
    
    //get an ordered array of the unique dates, by selecting the unique values for orderKey (eveduedate or evecreated date), then resorting.
    NSArray *uniqueDates = [[sortedArray valueForKeyPath:[NSString stringWithFormat:@"@distinctUnionOfObjects.%@",orderKey]] sortedArrayUsingSelector:@selector(compare:)];
    
    //loop through each of the unique dates and use a predicate to create an array of all events that match that date. Place them in to a dictionary, and then the dictionary array.
    for (NSDate *currentDate in uniqueDates)
    {
        //set a predicate and get results. Strange formatting is because predicate with format automatically adds quotation marks when you use variable substitution.
        NSPredicate *predicate = [NSPredicate predicateWithFormat:[orderKey stringByAppendingString:@" == %@"], currentDate];
        NSArray *filteredEventsArray = [sortedArray filteredArrayUsingPredicate:predicate];
        
        NSString *datestring;
        NSDate *defaultDate = [dfToDate dateFromString:@"01/01/9999"];
        NSLog(@"currentDate: %@",currentDate);
        if ([currentDate isEqualToDate:defaultDate])
            datestring = @"No Due Date";
        else
            datestring = [df stringFromDate:currentDate];
        NSDictionary *dict = [NSDictionary dictionaryWithObject:filteredEventsArray forKey:datestring];
        [orderedEventsArray addObject:dict];
    }
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
    if (!fetchingSearchResults)
    {
        // Return the number of sections.
        return [orderedEventsArray count];
    }
    else // if the tableview date is being fetched, the just display 1 section.
        return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!fetchingSearchResults)
    {
        // Return the number of rows in the section.
        NSDictionary *dict = [orderedEventsArray objectAtIndex:section];
        NSArray *keys = [dict allKeys];
        id key = [keys objectAtIndex:0];
        NSArray *tArr = [dict objectForKey:key];
        
        return [tArr count];
    }
    else // if the tableview date is being fetched, the just display 0 cells.
        return 0;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:
(NSString *)title atIndex:(NSInteger)index {
    return index;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 80; 
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSDictionary *dict = [orderedEventsArray objectAtIndex:section];
    NSArray *keys = [dict allKeys];
    id key = [keys objectAtIndex:0];
    return key;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"EventCell";
    
    EventTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.backgroundColor = [UIColor whiteColor];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"EventTableViewCell" owner:self options:nil] objectAtIndex:0];
    }

    NSDictionary *dict = [orderedEventsArray objectAtIndex:indexPath.section];
    NSArray *keys = [dict allKeys];
    id key = [keys objectAtIndex:0];
    NSArray *tArr = [dict objectForKey:key];
    
    EventSearch* event = [tArr objectAtIndex:indexPath.row];

        cell.eventTitle.text = [@"EN" stringByAppendingFormat:[event.eveNumber stringByAppendingFormat:@" - %@",event.eveTitle]];
        cell.siteNameDesc.text = [company.cosSiteName stringByAppendingFormat:@" - %@",company.cosDescription];
        cell.eventComments.text = event.eveComments;
        cell.eventTypeType2.text = [event.eventType stringByAppendingFormat:@" - %@",event.eventType2];
    if (orderByCreatedDate){
        int hours = [event.eveCreatedTime integerValue] / 3600;
        int minutes = ([event.eveCreatedTime integerValue] / 60) % 60;
        cell.eventDueTime.text = [NSString stringWithFormat:@"%02d:%02d",hours,minutes];
    }
    else{
        int hours = [event.eveDueTime integerValue] / 3600;
        int minutes = ([event.eveDueTime integerValue] / 60) % 60;
        cell.eventDueTime.text = [NSString stringWithFormat:@"%02d:%02d",hours,minutes];
    }
    
    if ([event.eveStatus isEqualToString:@"9"]) {
        cell.unreadClosedImage.hidden = false;
        cell.unreadClosedImage.image = [UIImage imageNamed:@"circlered.png"];
    }
    
    return cell;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    

// when fetching data, display a custom header that contains a refresh spinner.
    if (fetchingSearchResults)
    {
        // create a view
        UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.tableView.frame.size.width, 20)];
    
        [refreshSpinner startAnimating];
        
        customView.backgroundColor = [UIColor blackColor];
        
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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
        [self performSegueWithIdentifier:@"toEventDetails" sender:self];
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
    if ([segue.identifier isEqualToString:@"toEventDetails"])
    {
        //get the clicked cell's row
        NSInteger row = [[self tableView].indexPathForSelectedRow row];
        NSInteger section = [[self tableView].indexPathForSelectedRow section];
        
        NSDictionary *dict = [orderedEventsArray objectAtIndex:section];
        NSArray *keys = [dict allKeys];
        id key = [keys objectAtIndex:0];
        NSArray *tArr = [dict objectForKey:key];
        
        //get the event at that row from the event array
        EventSearch* event = [tArr objectAtIndex:row];
        
        //put the event into the eventDetails variable in the details view
        eventDetailsTableViewController *detailViewController = segue.destinationViewController;
        detailViewController.eventDetails = event;
        detailViewController.company = company;
        if (contact)
            detailViewController.contact = contact;
        detailViewController.isCoreData = NO;
        //TODO:
        //where to get the rest of the data?
    }
    
}


@end
