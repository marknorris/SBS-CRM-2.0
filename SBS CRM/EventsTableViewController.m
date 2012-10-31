//
//  myEventsTableViewController.m
//  SBS CRM
//
//  Created by Tom Couchman on 09/02/2012.
//  Copyright (c) 2012 Shuttleworth Business Systems Limited. All rights reserved.
//

#import "EventsTableViewController.h"
#import "AppDelegate.h"
#import "Event.h"
#import <QuartzCore/QuartzCore.h>
#import "EventTableViewCell.h"
#import "EventDetailsTableViewController.h"
//data sync headers
#import "FetchXML.h"
#import "XMLParser.h"
#import "Format.h"
#import "NSManagedObject+CoreDataManager.h"
#import "AlertsAndBadges.h"

#define REFRESH_HEADER_HEIGHT 52.0f

@interface EventsTableViewController() {
    NSUserDefaults *defaults;
    NSDictionary *eventForSegue;
    FetchXML *eventsXmlFetcher;
    FetchXML *companiesXmlFetcher;
    FetchXML *contactsXmlFetcher;
    FetchXML *attachmentsXmlFetcher;
    FetchXML *communicationsXmlFetcher;
    FetchXML *searchXmlFetcher;
    NSInteger refreshState;
    UIView *refreshHeaderView;
    UILabel *refreshLabel;
    UIImageView *refreshArrow;
    UIActivityIndicatorView *refreshSpinner;
    BOOL isDragging;
    BOOL isLoading;
    NSString *textPull;
    NSString *textRelease;
    NSString *textLoading;
    NSMutableArray *eventIDArray;
    
    BOOL isMutatingArray;
}

@property (strong, nonatomic) NSMutableArray *searchResults;
@property (nonatomic, strong) UIToolbar *keyboardToolBar;

- (void)scrollToToday;
- (void)openEventFromNotification:(NSNotification *)notification;

@end

@interface CustomSearchBar : UISearchBar

@property (readwrite, retain) UIView *inputAccessoryView;

@end

@implementation EventsTableViewController

//core data
@synthesize btnAdd = _btnAdd;
@synthesize searchBar = _searchBar;
@synthesize context = _context;
//pull to refresh
@synthesize textPull = _textPull;
@synthesize textRelease = _textRelease;
@synthesize textLoading = _textLoading;
@synthesize refreshHeaderView = _refreshHeaderView;
@synthesize refreshLabel = _refreshLabel;
@synthesize refreshArrow = _refreshArrow;
@synthesize refreshSpinner = _refreshSpinner;

@synthesize searchResults = _searchResults;

@synthesize keyboardToolBar = _keyboardToolBar;

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

    if (self.keyboardToolBar == nil) {
        self.keyboardToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,-44,self.view.bounds.size.width, 44)];
        self.keyboardToolBar.tintColor = [UIColor blackColor];
        UIBarButtonItem *extraSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(search:)];
        doneButton.style = UIBarButtonItemStyleDone;
        
        [self.keyboardToolBar setItems:[[NSArray alloc] initWithObjects:extraSpace,doneButton,nil]];
        self.keyboardToolBar.alpha = 0.0;
        CGRect aFrame = self.keyboardToolBar.frame;
        self.keyboardToolBar.frame = aFrame;
    }
    
    eventIDArray = [[NSMutableArray alloc] init];
    isLoading = NO;
    //set isMutatingArray to No. Bool indicates if the data used to populate the table view is being changed.
    isMutatingArray = NO;

    //get the default alert time from userdefaults.
    defaults = [NSUserDefaults standardUserDefaults];
    appDefaultAlertTime = [defaults objectForKey:@"defaultAlertTime"];
    
    if (!appDefaultAlertTime) {
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *components;
        // set the time to midnight
        [components setHour:0]; 
        [components setMinute:0];
        appDefaultAlertTime = [gregorian dateFromComponents:components];
    }
    
    //set up pull to refresh
    [self setupStrings];
    [self addPullToRefreshHeader];

    if ([defaults valueForKey:@"refreshOnLoad"] == @"YES")
        [self startLoading];
    else
        [self refreshTableView]; //populate the tableview.

    //listen for the openEventFromNotification command when an event needs to be loaded due to  notfication (alert)
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openEventFromNotification:) name:@"openEventFromNotification" object:nil];
    //listen for the reloadcoredata notification when the tablview needs to refresh it's data.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTableView)  name:@"reloadCoreData" object:nil];
    //listen for the reloadcoredata notification when the tablview needs to refresh it's data.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTableView)  name:@"reloadEventData" object:nil];
    //listen for the reloadcoredata notification when the tablview needs to refresh it's data.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadCoreData) name:@"getCoreData" object:nil];
    // listen to notifications regarding the app entering background - to free up memory.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeEventsDataFromMemory) name:@"didEnterBackground" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTableView) name:@"willEnterForeground" object:nil];
    // Listen for Notifications regarding the display of the keyboard
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];       
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];  
}

- (void)removeEventsDataFromMemory
{
    [eventIDArray removeAllObjects];
    [self.tableView reloadData];
}

- (void)openEventFromNotification:(NSNotification *)notification
{
    //NSString *notificationEventID = [notification.userInfo objectForKey:@"id"];
    [self.navigationController popToRootViewControllerAnimated:NO];
    self.tabBarController.selectedIndex = 0;
    eventForSegue = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[notification.userInfo objectForKey:@"id"],[notification.userInfo objectForKey:@"core"], nil] forKeys:[NSArray arrayWithObjects:@"id",@"core",nil]];
    [self performSegueWithIdentifier:@"pushDetails" sender:nil];
}

- (void)viewDidUnload
{
    [self setSearchBar:nil];
    [self setBtnAdd:nil];
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
    
    if ([[defaults objectForKey:@"initialID"] length]) {
        eventForSegue = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[defaults objectForKey:@"initialID"],[defaults objectForKey:@"initialCore"],nil] forKeys:[NSArray arrayWithObjects:@"id",@"core",nil]];
        [self performSegueWithIdentifier:@"pushDetails" sender:nil];
    }
    
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

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    
}

//------------------------------------------------------------------
//  Reaload Core Data
//------------------------------------------------------------------

- (void)reloadCoreData
{    
    UIAlertView *domGetFailed = [[UIAlertView alloc] initWithTitle:@"Connection Error" message:@"Could not connect to the server" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    
    //keep track of the number of core data entities that have been refreshed.
    refreshState = 5;
    NSLog(@"user: %d",appUserID);
    
    NSURL *url = [NSURL URLWithString:[appURL stringByAppendingFormat:@"/service1.asmx/syncEventsABL?userID=%d",appUserID]];
    
    eventsXmlFetcher = [[FetchXML alloc] initWithUrl:url delegate:self className:@"EventSearch"];
    
    if (![eventsXmlFetcher fetchXML]) {
        [domGetFailed show]; 
        return;
    }
    
    url = [NSURL URLWithString:[appURL stringByAppendingFormat:@"/service1.asmx/syncContactsABL?userID=%d",appUserID]];    
    
    contactsXmlFetcher = [[FetchXML alloc] initWithUrl:url delegate:self className:@"ContactSearch"];

    if (![contactsXmlFetcher fetchXML]) {
        [domGetFailed show]; 
        return;
    }
    
    url = [NSURL URLWithString:[appURL stringByAppendingFormat:@"/service1.asmx/syncCompaniesABL?userID=%d",appUserID]];
    
    companiesXmlFetcher = [[FetchXML alloc] initWithUrl:url delegate:self className:@"CompanySearch"];
    
    if (![companiesXmlFetcher fetchXML]) {
        [domGetFailed show]; 
        return;
    }

    url = [NSURL URLWithString:[appURL stringByAppendingFormat:@"/service1.asmx/syncCommunicationABL?userID=%d",appUserID]];
    
    communicationsXmlFetcher = [[FetchXML alloc] initWithUrl:url delegate:self className:@"CommunicationSearch"];
    
    if (![communicationsXmlFetcher fetchXML]) {
        [domGetFailed show]; 
        return;
    }
    
    url = [NSURL URLWithString:[appURL stringByAppendingFormat:@"/service1.asmx/syncAttachmentsABL?userID=%d",appUserID]];
    
    attachmentsXmlFetcher = [[FetchXML alloc] initWithUrl:url delegate:self className:@"AttachmentSearch"];
    
    if (![attachmentsXmlFetcher fetchXML]) {
        [domGetFailed show]; 
        return;
    }

}

-(void)fetchXMLError:(NSString *)errorResponse:(id)sender
{
    if (self.view.window) // don't display if this view is not active. TODO:make sure this method is never even called!
    {
        // If error recieved, display alert.
        [[[UIAlertView alloc] initWithTitle:@"Error Fetching Data" message:errorResponse delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }
    [self stopLoading];
}

-(void)docRecieved:(NSDictionary *)docDic:(id)sender
{
    NSLog(@"Class Name: %@", [docDic objectForKey:@"ClassName"]);
    NSLog(@"Document: %@", [docDic objectForKey:@"Document"]);
    
    //if (sender == getEventsDom)
        //NSLog(@"THIS IS YOUR SENDER");
    
    NSString *classKey = [docDic objectForKey:@"ClassName"];
    NSArray *Array = [[[XMLParser alloc] init]parseXMLDoc:[docDic objectForKey:@"Document"] toClass:NSClassFromString(classKey)];
    
    //Fill the array's correspoding core data entity and reduce the refreshed state for each store that takes place.
    if (sender == eventsXmlFetcher) { 
        refreshState--;
        
        //set the alerts and badges for events in array
        [AlertsAndBadges setAlertsAndBadges:Array];
        
        [NSManagedObject storeInCoreData:Array forEntityName:@"Event"]; 

        eventsXmlFetcher = nil;
    }
    else if (sender == companiesXmlFetcher) {
        [NSManagedObject storeInCoreData:Array forEntityName:@"Company"]; refreshState--;
    }
    else if (sender == contactsXmlFetcher) {
        [NSManagedObject storeInCoreData:Array forEntityName:@"Contact"]; refreshState--;
    }
    else if (sender == communicationsXmlFetcher) {
        [NSManagedObject storeInCoreData:Array forEntityName:@"Communication"]; refreshState--;
    }
    else if (sender == attachmentsXmlFetcher) {
        [NSManagedObject storeInCoreData:[Array count] > 0 ? Array : nil forEntityName:@"Attachment"]; refreshState--;
    }
    
    //when all are refreshed;
    if (refreshState == 0) {
        //inform the other views that the data is ready to be displayed.
        [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadCoreData" object:self];
        
        [self refreshTableView];
        [self performSelector:@selector(scrollToToday) withObject:nil afterDelay:0.5];
    }
    
}

//------------------------------------------------------------------
//  Prepare TableView Data
//------------------------------------------------------------------

- (void)refreshTableView{
    
    //remove all current event ID stored in eventIDArray
    [eventIDArray removeAllObjects];

    if (self.context == nil) {
        self.context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    }
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:self.context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    
    //create and set sort descriptors to order array by due date and time.
    NSSortDescriptor *dateSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"eveDueDate" ascending:YES];
    NSSortDescriptor *timeSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"eveDueTime" ascending:YES];
    [request setSortDescriptors:[NSArray arrayWithObjects:dateSortDescriptor,timeSortDescriptor,nil]];
    NSError *error = nil;
    //NSArray *eventsArray = [context executeFetchRequest:request error:&error];
    
    //fetch only unique eveDueDates.
    [request setResultType:NSDictionaryResultType];
    [request setPropertiesToFetch:[NSArray arrayWithObject:@"eveDueDate"]];
    [request setReturnsDistinctResults:YES];
    //get results of predicate
    NSArray *dueDateArray = [self.context executeFetchRequest:request error:&error];
    
    if ([dueDateArray count] == 0) { // if there are no results then return;
        isMutatingArray = NO;

        [self.tableView reloadData];
        if (isLoading)
            [self stopLoading];
        return;
    }
    
    //change the properties to fetch both eveduedate and event ID
    [request setPropertiesToFetch:[NSArray arrayWithObjects:@"eventID",@"eveDueDate",nil]];
    [request setReturnsDistinctResults:NO];

    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateStyle:NSDateFormatterMediumStyle];
    
    BOOL nullField;
    
    for (NSDictionary *currentDateDictionary in dueDateArray) {
        //get the current date from the current date dictionary.
        NSDate *currentDate = [currentDateDictionary objectForKey:@"eveDueDate"];
        NSMutableArray *tempIDArray = [[NSMutableArray alloc]init];
        //set a predicate and get results.
        [request setPredicate:[NSPredicate predicateWithFormat:@"eveDueDate == %@", currentDate]];
        error = nil;
        NSArray *tempIDDictionaryArray = [self.context executeFetchRequest:request error:&error];
        NSLog(@"temp array count: %d", [tempIDDictionaryArray count]);
        
        for (NSDictionary *eventDic in tempIDDictionaryArray) {
            if ([eventDic objectForKey:@"eventID"] != nil)
            [tempIDArray addObject:[eventDic objectForKey:@"eventID"]];
        }

        NSString *datestring;
        
        if (currentDate == NULL) {
            nullField = true;
            datestring = @"No Due Date";
        }
        else
            datestring = [df stringFromDate:currentDate];
        
        NSDictionary *dict = [NSDictionary dictionaryWithObject:tempIDArray forKey:datestring];
        [eventIDArray addObject:dict];
    }
    
    //if there are items with no date, move them to the end of the array.
    if (nullField == true) {
        [eventIDArray insertObject:[eventIDArray objectAtIndex:0] atIndex:[eventIDArray count]];
        [eventIDArray removeObjectAtIndex:0];
    }
    
    isMutatingArray = NO;
    [self.tableView reloadData];
    if (isLoading)
        [self stopLoading];

}

//------------------------------------------------------------------
//  Table View
//------------------------------------------------------------------

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [eventIDArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSDictionary *dict = [eventIDArray objectAtIndex:section];
    NSArray *keys = [dict allKeys];
    id key = [keys objectAtIndex:0];
    NSArray *tArr = [dict objectForKey:key];
    
    return [tArr count];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return index;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSDictionary *dict = [eventIDArray objectAtIndex:section];
    NSArray *keys = [dict allKeys];
    id key = [keys objectAtIndex:0];

    return key;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    return 80; 
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //set the cell to the custom cell created in EventTableViewCell nib
    EventTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"eventCell"];

    if (cell == nil) // if the cell is nil, load even cell nib
        cell = [[[NSBundle mainBundle] loadNibNamed:@"EventTableViewCell" owner:self options:nil] objectAtIndex:0];

    // if the event array is mutating the tableview refresh will fail therefore return.
    if (isMutatingArray == YES)
        return cell;
    
    NSDictionary *dict = [eventIDArray objectAtIndex:indexPath.section];
    NSArray *keys = [dict allKeys];
    id key = [keys objectAtIndex:0];
    NSArray *tArr = [dict objectForKey:key];
    NSString *currentID = [tArr objectAtIndex:indexPath.row];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"eventID == %@", currentID];

    // fetch the event identified by currentID.
    NSArray *eventsArray = [NSManagedObject fetchObjectsForEntityName:@"Event" withPredicate:predicate withSortDescriptors:nil];
    
    if (![eventsArray count]) 
        return cell;
    
    Event* event = [eventsArray objectAtIndex:0];
    
    predicate = [NSPredicate predicateWithFormat:@"companySiteID == %@", event.companySiteID];
    NSArray *companyArray = [NSManagedObject fetchObjectsForEntityName:@"Company" withPredicate:predicate withSortDescriptors:nil];
    
    CompanySearch *company = [[CompanySearch alloc] init];
    
    if ([companyArray count])
        company = [companyArray objectAtIndex:0];
    else {
        company.cosSiteName = @"No company";
        company.cosDescription = @"Can't display details.";
    }

    cell.eventTitle.text = [@"EN" stringByAppendingFormat:[event.eveNumber stringByAppendingFormat:@" - %@",event.eveTitle]];
    cell.eventComments.text = event.eveComments;
    cell.eventTypeType2.text = [event.eventType stringByAppendingFormat:@" - %@",event.eventType2];
    cell.siteNameDesc.text = [company.cosSiteName stringByAppendingFormat:@" - %@",company.cosDescription];
    
    [Format timeStringFromSecondsSinceMidnight:[event.eveDueTime integerValue]];
    
    int hours = [event.eveDueTime integerValue] / 3600;
    int minutes = ([event.eveDueTime integerValue] / 60) % 60;
    
    cell.eventDueTime.text = [NSString stringWithFormat:@"%02d:%02d",hours,minutes];
    
    //if event is watched by me intead of internal contact set watch image
    if (event.watched == 1) 
        cell.watchedImage.hidden = FALSE; // show the watched image
    else 
        cell.watchedImage.hidden = TRUE; // hide the watched image
    
    //if event is unread for me show unread image; else hide it.
    if (event.readEvent == 0) 
        cell.unreadClosedImage.hidden = FALSE;
    else 
        cell.unreadClosedImage.hidden = TRUE;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"pushDetails" sender:self];
}

//------------------------------------------------------------------
//  PULL REFRESH
//------------------------------------------------------------------

- (void)setupStrings
{
    textPull = [[NSString alloc] initWithString:@"Pull down to refresh..."];
    textRelease = [[NSString alloc] initWithString:@"Release to refresh..."];
    textLoading = [[NSString alloc] initWithString:@"Loading..."];
    NSLog(@"%@", textPull);
    NSLog(@"%@", textRelease);
    NSLog(@"%@", textLoading);
}

- (void)addPullToRefreshHeader
{
    refreshHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0 - REFRESH_HEADER_HEIGHT, self.tableView.frame.size.width, REFRESH_HEADER_HEIGHT)];
    refreshHeaderView.backgroundColor = [UIColor whiteColor];
    refreshHeaderView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    refreshLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.tableView.frame.size.width / 2) - 160, 0, 320, REFRESH_HEADER_HEIGHT)];
    refreshLabel.backgroundColor = [UIColor clearColor];
    refreshLabel.font = [UIFont boldSystemFontOfSize:12.0];
    refreshLabel.textAlignment = UITextAlignmentCenter;
    refreshLabel.textColor = [UIColor blackColor];
    refreshLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    
    refreshArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrowblack.png"]];
    refreshArrow.frame = CGRectMake(floorf((self.tableView.frame.size.width / 2) - 150), (floorf(REFRESH_HEADER_HEIGHT - 44) / 2), 44, 44);
    refreshArrow.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    
    refreshSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    refreshSpinner.frame = CGRectMake(floorf((self.tableView.frame.size.width / 2) - 130), floorf((REFRESH_HEADER_HEIGHT - 20) / 2), 20, 20);
    refreshSpinner.hidesWhenStopped = YES;
    refreshSpinner.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    
    [refreshHeaderView addSubview:refreshLabel];
    [refreshHeaderView addSubview:refreshArrow];
    [refreshHeaderView addSubview:refreshSpinner];
    [self.tableView addSubview:refreshHeaderView];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (isLoading) return;
    isDragging = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (isLoading) {
        // Update the content inset, good for section headers
        if (scrollView.contentOffset.y > 0)
            self.tableView.contentInset = UIEdgeInsetsZero;
        else if (scrollView.contentOffset.y >= -REFRESH_HEADER_HEIGHT)
            self.tableView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
    } else if (isDragging && scrollView.contentOffset.y < 0) {
        // Update the arrow direction and label
        [UIView beginAnimations:nil context:NULL];
        
        if (scrollView.contentOffset.y < -REFRESH_HEADER_HEIGHT) {
            // User is scrolling above the header
            refreshLabel.text = textRelease;
            [refreshArrow layer].transform = CATransform3DMakeRotation(M_PI, 0, 0, 1);
        } else { // User is scrolling somewhere within the header
            refreshLabel.text = textPull;
            [refreshArrow layer].transform = CATransform3DMakeRotation(M_PI * 2, 0, 0, 1);
        }
        
        [UIView commitAnimations];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (isLoading) return;
    isDragging = NO;
    
    if (scrollView.contentOffset.y <= -REFRESH_HEADER_HEIGHT) {
        // Released above the header
        [self startLoading];
    }
    
}

- (void)startLoading
{
    isLoading = YES;
    
    // Show the header
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    self.tableView.contentInset = UIEdgeInsetsMake(REFRESH_HEADER_HEIGHT, 0, 0, 0);
    refreshLabel.text = textLoading;
    refreshArrow.hidden = YES;
    [refreshSpinner startAnimating];
    [UIView commitAnimations];
    
    // Refresh action!
    [self reloadCoreData];
}

- (void)stopLoading
{
    isLoading = NO;
    // Hide the header
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDidStopSelector:@selector(stopLoadingComplete:finished:context:)];
    self.tableView.contentInset = UIEdgeInsetsZero;
    UIEdgeInsets tableContentInset = self.tableView.contentInset;
    tableContentInset.top = 0.0;
    self.tableView.contentInset = tableContentInset;
    [refreshArrow layer].transform = CATransform3DMakeRotation(M_PI * 2, 0, 0, 1);
    [UIView commitAnimations];
}

- (void)stopLoadingComplete:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    // Reset the header
    refreshLabel.text = textPull;
    refreshArrow.hidden = NO;
    [refreshSpinner stopAnimating];
}

//------------------------------------------------------------------
//  SEGUE
//------------------------------------------------------------------

//# when a segue is called send the appropriate data to the destination view controller #
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //if the segue is to the details screen
    if ([segue.identifier isEqualToString:@"pushDetails"]) {
        
        if (sender == self) {
            NSInteger row = [[self tableView].indexPathForSelectedRow row];
            NSInteger section = [[self tableView].indexPathForSelectedRow section];
            
            //retrieve the event ID for the clicked event
            NSDictionary *dict = [eventIDArray objectAtIndex:section];
            NSArray *keys = [dict allKeys];
            id key = [keys objectAtIndex:0];
            NSArray *tArr = [dict objectForKey:key];
            NSString *currentID = [tArr objectAtIndex:row];
            
            //send the event id to the detail view controller
            EventDetailsTableViewController *detailViewController = segue.destinationViewController;
            detailViewController.eventDetails = [[EventSearch alloc] init];
            detailViewController.eventDetails.eventID = currentID;
            detailViewController.isCoreData = YES;
        }
        else {   
            //clear the user defaults for initial id and view
            [defaults setObject:@"" forKey:@"initialID"];
            [defaults setObject:@"" forKey:@"initialView"];
            [defaults setObject:@"" forKey:@"initialCore"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            defaults = [NSUserDefaults standardUserDefaults];

            //send the event id to the detail view controller
            EventDetailsTableViewController *detailViewController = segue.destinationViewController;
            detailViewController.eventDetails = [[EventSearch alloc] init];
            detailViewController.eventDetails.eventID = [eventForSegue objectForKey:@"id"];
            detailViewController.eventDetails.eveNumber = [eventForSegue objectForKey:@"number"];
            detailViewController.isCoreData = [[eventForSegue objectForKey:@"core"] intValue];
        }
        
    }
}

- (IBAction)clickToday:(id)sender
{
    //[self performSelector:@selector(scrollToToday) withObject:nil afterDelay:0.5];
    [self scrollToToday];
}

- (void)scrollToToday
{
    //scroll to today (or soonest day after) - this is recalculated each time instead of during the refresh incase the data has not been updated since before today
    NSDateFormatter *dfToString = [[NSDateFormatter alloc] init];
    [dfToString setDateStyle:NSDateFormatterMediumStyle];
    NSDateFormatter *dfToDate = [[NSDateFormatter alloc] init];
    [dfToDate setDateStyle:NSDateFormatterMediumStyle];
    
    //loop through all of the dictionaries in the array
    //need an index so no using fast enumeration
    
    BOOL eventFound = false;
    
    for (NSInteger i = 0; i < [eventIDArray count]; i++) {
        NSDictionary *dict = [eventIDArray objectAtIndex:i];
        //get the key of the current dictionary
        NSArray *keys = [dict allKeys];
        id key = [keys objectAtIndex:0];
        
        // convert the key to a date using the dfToDate Formatter
        NSDate *keyDate = [dfToDate dateFromString:key];
        
        //get todays date without the time
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *components = [gregorian components:(NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit) fromDate:[NSDate date]];
        //create a date from the components
        NSDate *today = [gregorian dateFromComponents:components];
        
        //if the date is after today or is today
        if([keyDate compare: today] == NSOrderedDescending || [keyDate compare: today] == NSOrderedSame) {
            //goto the position of the row
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:i] atScrollPosition:UITableViewScrollPositionTop animated:YES];
            
            eventFound = true;
            //stop looping
            break;
        }
        
    }
    
    if (eventFound == false)
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:[eventIDArray count] - 1] atScrollPosition:0 animated:YES];
    
}

//------------------------------------------------------------------
//  Search
//------------------------------------------------------------------

// when the user clicks search:
- (void) searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self search:nil];
}

- (void) searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    //cancelled = YES;
    //[getCompaniesDom cancel];
    //isSearching = NO;
    [searchBar resignFirstResponder];
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    return NO;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    return NO;
}

- (void)search:(id)sender
{
    if ([self.searchBar.text length] < 3) {
        UIAlertView *alertStringTooShortAlert = [[UIAlertView alloc] initWithTitle:@"Search length" message:@"Event ID too short" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertStringTooShortAlert show];
    }
    else {
        NSCharacterSet *decimalSet = [NSCharacterSet decimalDigitCharacterSet];
        // if trimming decimal characters out of string leaves nothing then proceed, else show alert and return
        
        if (![[self.searchBar.text stringByTrimmingCharactersInSet:decimalSet] isEqualToString:@""]) {
            UIAlertView *alertInvalidCharacters = [[UIAlertView alloc] initWithTitle:@"Invalid Search Criteria" message:@"Please enter integer value" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertInvalidCharacters show];
            return;
        }
        
        // look for the event within core data:
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"eveNumber == %@", _searchBar.text];
        NSArray *eventsArray = [NSManagedObject fetchObjectsForEntityName:@"Event" withPredicate:predicate withSortDescriptors:nil];
        
        // if event is found then we know it is core data, else it will need to be searched for from event details view using web service.
        // store details of event (id, and if stored in core data) in 'eventForSegue'
        if ([eventsArray count])  {
            eventForSegue = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:_searchBar.text,@"1", nil] forKeys:[NSArray arrayWithObjects:@"number",@"core",nil]];
        }
        else {
            eventForSegue = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:_searchBar.text,@"0", nil] forKeys:[NSArray arrayWithObjects:@"number",@"core",nil]];
        }
        
        [self performSegueWithIdentifier:@"pushDetails" sender:@"search"];
    }
}

//------------------------------------------------------------------
//  Keyboard
//------------------------------------------------------------------

- (void)keyboardWillShow:(NSNotification *)note
{  
    if (self.view.window)
        self.keyboardToolBar.alpha = 0; // set alpha to 0 so that the keyboard toolbar can be faded into view in keyboardDidShow
}  

- (void)keyboardDidShow:(NSNotification *)note
{  
    if (self.view.window) { //if this view is visible, add toolbar to keyboard
        // if clause is just an additional precaution, you could also dismiss it  
        UIWindow* tempWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:1];  
        UIView* keyboard;  
        
        for(int i=0; i<[tempWindow.subviews count]; i++) {  
            keyboard = [tempWindow.subviews objectAtIndex:i];  
            
            // keyboard found, add the button  
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 3.2) {  
                if([[keyboard description] hasPrefix:@"<UIPeripheralHost"] == YES)  
                    [keyboard addSubview:self.keyboardToolBar];  
            } else {  
                if([[keyboard description] hasPrefix:@"<UIKeyboard"] == YES)  
                    [keyboard addSubview:self.keyboardToolBar];  
            }  
            
        }  
        
        //fade keyboard into view, to soften popup.
        [UIView beginAnimations:@"showToolBar" context:nil];
        [UIView setAnimationDuration:.3];
        CGRect aFrame = self.keyboardToolBar.frame;
        self.keyboardToolBar.frame = aFrame;
        self.keyboardToolBar.alpha = 1;
        [UIView commitAnimations];
    }
    
}  

@end
