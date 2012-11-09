//
//  EventsTableViewController.m
//  SBS CRM
//
//  Created by Tom Couchman on 09/02/2012.
//  Copyright (c) 2012 Shuttleworth Business Systems Limited. All rights reserved.
//

#import "EventsTableViewController2.h"
#import "AppDelegate.h"
//#import "Event.h"
//#import "Event2.h"
#import "Event2+RestKit.h"
//#import "EventComment.h"
#import "EventComment+RestKit.h"
//#import "Company2.h"
#import "Company2+RestKit.h"
#import <QuartzCore/QuartzCore.h>
#import "EventTableViewCell.h"
#import "EventDetailsTableViewController.h"
//data sync headers
#import "Format.h"
#import "NSManagedObject+CoreDataManager.h"
#import "AlertsAndBadges.h"
#import <RestKit/RestKit.h>
#import "LoadingView.h"
//#import "SBSRestKit.h"

#define REFRESH_HEADER_HEIGHT 52.0f

@interface EventsTableViewController2() <RKObjectLoaderDelegate> {
    NSUserDefaults *defaults;
    NSDictionary *eventForSegue;
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
    BOOL isMutatingArray;
    LoadingView *loadingView;
}

@property (strong, nonatomic) NSMutableArray *searchResults;
@property (nonatomic, strong) UIToolbar *keyboardToolBar;

- (void)scrollToToday;
- (void)openEventFromNotification:(NSNotification *)notification;

@end

@interface CustomSearchBar : UISearchBar

@property (readwrite, retain) UIView *inputAccessoryView;

@end

@implementation EventsTableViewController2

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
    
    // Configure RestKit and Entities
    [SBSRestKit configureRestKit];
//    [Event2 configureEntity];
//    [EventComment configureEntity];
//    [Company2 configureEntity];

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
    
//    eventIDArray = [[NSMutableArray alloc] init];
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

- (void)viewDidUnload
{
    [self setSearchBar:nil];
    [self setBtnAdd:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    loadingView = nil;
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
    return interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
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
            Event2 *event = [[self fetchedResultsController] objectAtIndexPath:[[self tableView] indexPathForSelectedRow]];            
            //send the event id to the detail view controller
            EventDetailsTableViewController *detailViewController = segue.destinationViewController;
            detailViewController.eventDetails = [[EventSearch alloc] init];
            detailViewController.eventDetails.eventID = [event.eventID stringValue];
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

//------------------------------------------------------------------
//  Table View
//------------------------------------------------------------------

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
//    NSLog(@"numberOfSectionsInTableView: %d", [[[self fetchedResultsController] sections] count]);
    return [[[self fetchedResultsController] sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
//    NSLog(@"numberOfRowsInSection: %d", [[[[self fetchedResultsController] sections] objectAtIndex:section] numberOfObjects]);
    return [[[[self fetchedResultsController] sections] objectAtIndex:section] numberOfObjects];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    Event2 *event = [[[[[self fetchedResultsController] sections] objectAtIndex:section] objects] objectAtIndex:0];
    
//    NSLog(@"%@", [[[self.fetchedResultsController sections] objectAtIndex:section] name]);
    NSString *eveDueDate = [NSString stringWithFormat:@"%@", event.eveDueDate];

    if ([eveDueDate hasPrefix:@"9999-01-01"]) {
        return @"No due date specified";
    } else {
        return [NSDateFormatter localizedStringFromDate:event.eveDueDate dateStyle:NSDateFormatterFullStyle timeStyle:NSDateFormatterNoStyle];
    }
    
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

    // Get the Event
    Event2 *event = (Event2 *)[[self fetchedResultsController] objectAtIndexPath:indexPath];
//    // Get the Company associated with the Event
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"companySiteID == %@", event.companySiteID];
//    NSArray *companyArray = [NSManagedObject fetchObjectsForEntityName:@"Company" withPredicate:predicate withSortDescriptors:nil];
//    
//    CompanySearch *company = [[CompanySearch alloc] init];
//    
//    if ([companyArray count])
//        company = [companyArray objectAtIndex:0];
//    else {
//        company.cosSiteName = @"No company";
//        company.cosDescription = @"Can't display details.";
//    }

    cell.eventTitle.text = [@"EN" stringByAppendingFormat:[[event.eveNumber stringValue] stringByAppendingFormat:@" - %@", event.eveTitle]];
    
    NSLog(@"event.eventComments.count: %i", event.eventComments.count);
    
    EventComment *comment = [event firstEventComment];
    
    if (comment) {
        NSString *ecoDateTime = [NSDateFormatter localizedStringFromDate:comment.ecoDateTime dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterShortStyle];
        cell.eventComments.text = [NSString stringWithFormat:@"%@ %@\n%@", ecoDateTime, comment.ecoBy, comment.ecoComment];
    } else {
        cell.eventComments.text = @"";
    }
    
    cell.eventTypeType2.text = event.evtDescription;
    
    if ([event.ettDescription length] > 0) {
        cell.eventTypeType2.text = [cell.eventTypeType2.text stringByAppendingFormat:@" - %@", event.ettDescription];
    }
    
//    cell.siteNameDesc.text = [company.cosSiteName stringByAppendingFormat:@" - %@", company.cosDescription];
    NSLog(@"cosSiteName: %@", event.eventCompany.cosSiteName);
    NSLog(@"cosDescription: %@", event.eventCompany.cosDescription);
    cell.siteNameDesc.text = [event.eventCompany.cosSiteName stringByAppendingFormat:@" - %@", event.eventCompany.cosDescription];
    cell.eventDueTime.text = [NSDateFormatter localizedStringFromDate:event.eveDueDateTime dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];

    // If Event is watched by me instead of internal contact set watched image
    if ([event.watched boolValue]) 
        cell.watchedImage.hidden = NO;
    else 
        cell.watchedImage.hidden = YES;
    
    //if event is unread for me show unread image; else hide it.
    if ([event.evoRead boolValue]) 
        cell.unreadClosedImage.hidden = YES;
    else 
        cell.unreadClosedImage.hidden = NO;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"pushDetails" sender:self];
}

#pragma mark - Custom methods

//------------------------------------------------------------------
//  PULL REFRESH
//------------------------------------------------------------------

- (void)setupStrings
{
    textPull = [[NSString alloc] initWithString:@"Pull down to refresh..."];
    textRelease = [[NSString alloc] initWithString:@"Release to refresh..."];
    textLoading = [[NSString alloc] initWithString:@"Loading..."];
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

- (void)stopLoadingComplete:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    // Reset the header
    refreshLabel.text = textPull;
    refreshArrow.hidden = NO;
    [refreshSpinner stopAnimating];
}

- (IBAction)clickToday:(id)sender
{
    //[self performSelector:@selector(scrollToToday) withObject:nil afterDelay:0.5];
    [self scrollToToday];
}

- (void)scrollToToday
{
    // Scroll to today (or soonest day after) - this is recalculated each time instead of during the refresh incase the data has not been updated since before today
    for (Event2 *event in self.fetchedResultsController.fetchedObjects) {

        // If the Event Due Date is today or after today
        if ([event.eveDueDateTime compare:[NSDate date]] == NSOrderedSame || [event.eveDueDateTime compare:[NSDate date]] == NSOrderedDescending) {
            NSIndexPath *indexPath = [[self fetchedResultsController] indexPathForObject:event];
            // Scroll the Event into view
            [[self tableView] scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
            break;
        }
    }
    
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

- (void)removeEventsDataFromMemory
{
    //    [eventIDArray removeAllObjects];
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

//------------------------------------------------------------------
//  Reaload Core Data
//------------------------------------------------------------------

- (void)reloadCoreData
{    
    [Event2 loadObjectsWithDelegate:self];
//    [EventComment loadObjectsWithDelegate:self];
    loadingView = [LoadingView loadingViewInView:self.parentViewController.view withText:@"Loading Events"];
}

//------------------------------------------------------------------
//  Prepare TableView Data
//------------------------------------------------------------------

//- (NSComparisonResult)compareObject:(id)object1 toObject:(id)object2 {
//    if (NULL_OBJECT([object1 valueForKeyPath:[self key]]) && NULL_OBJECT([object2 valueForKeyPath:[self key]]))
//        return NSOrderedSame;
//    if (NULL_OBJECT([object1 valueForKeyPath:[self key]]))
//        return NSOrderedDescending;
//    if (NULL_OBJECT([object2 valueForKeyPath:[self key]]))
//        return NSOrderedAscending;
//    return [super compareObject:object1 toObject:object2];
//}

- (void)refreshTableView
{
    
    if (self.context == nil) {
        self.context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    }
    
    NSFetchRequest *fetchRequest = [Event2 fetchRequest];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"eveDueDate" ascending:YES];
    fetchRequest.sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    
    NSFetchedResultsController *frc = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[Event2 currentContext] sectionNameKeyPath:[sortDescriptor key] cacheName:nil];
    self.fetchedResultsController = frc;
    
    NSError *error = nil;
    
    if (![[self fetchedResultsController] performFetch:&error]) {
        NSLog(@"Error!");
        abort();
    }
    
    isMutatingArray = NO;
    [self.tableView reloadData];
    if (isLoading)
        [self stopLoading];
}

#pragma  mark - Scroll view delegate

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

#pragma mark - URL delegate

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
    [self stopLoading];
    
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

#pragma mark - Search bar delegate

//------------------------------------------------------------------
//  Search
//------------------------------------------------------------------

// when the user clicks search:
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self search:nil];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    //cancelled = YES;
    //[getCompaniesDom cancel];
    //isSearching = NO;
    [searchBar resignFirstResponder];
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    return NO;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    return NO;
}

#pragma mark - Keyboard

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

#pragma mark - RKObjectLoaderDelegate

//@required

/**
 * Sent when an object loaded failed to load the collection due to an error
 */
- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error
{
    NSLog(@"%s", __FUNCTION__);
    NSLog(@"objectLoader: %@ error: %@", objectLoader, error);
}

//@optional

/**
 When implemented, sent to the delegate when the object laoder has completed successfully
 and loaded a collection of objects. All objects mapped from the remote payload will be returned
 as a single array.
 */
- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects
{
    NSLog(@"%s", __FUNCTION__);
    NSLog(@"objectLoader: %@ objects: %@ object count: %d", objectLoader, objects, objects.count);
//    NSLog(@"%@", [objectLoader response]);
}

/**
 When implemented, sent to the delegate when the object loader has completed succesfully.
 If the load resulted in a collection of objects being mapped, only the first object
 in the collection will be sent with this delegate method. This method simplifies things
 when you know you are working with a single object reference.
 */
- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObject:(id)object
{
    NSLog(@"%s", __FUNCTION__);
    NSLog(@"objectLoader: %@ object: %@", objectLoader, object);
}

/**
 When implemented, sent to the delegate when an object loader has completed successfully. The
 dictionary will be expressed as pairs of keyPaths and objects mapped from the payload. This
 method is useful when you have multiple root objects and want to differentiate them by keyPath.
 */
- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjectDictionary:(NSDictionary *)dictionary
{
    NSLog(@"%s", __FUNCTION__);
    NSLog(@"objectLoader: %@ dictionary: %@", objectLoader, dictionary);
}

/**
 Invoked when the object loader has finished loading
 */
- (void)objectLoaderDidFinishLoading:(RKObjectLoader *)objectLoader
{
    NSLog(@"%s", __FUNCTION__);
    NSLog(@"objectLoader: %@", objectLoader);
    [loadingView removeView];
    [self stopLoading];
}

/**
 Informs the delegate that the object loader has serialized the source object into a serializable representation
 for sending to the remote system. The serialization can be modified to allow customization of the request payload independent of mapping.
 
 @param objectLoader The object loader performing the serialization.
 @param sourceObject The object that was serialized.
 @param serialization The serialization of sourceObject to be sent to the remote backend for processing.
 */
- (void)objectLoader:(RKObjectLoader *)objectLoader didSerializeSourceObject:(id)sourceObject toSerialization:(inout id<RKRequestSerializable> *)serialization
{
    NSLog(@"%s", __FUNCTION__);
    NSLog(@"objectLoader: %@ sourceObject: %@ serialization: %@", objectLoader, sourceObject, serialization);
}

/**
 Sent when an object loader encounters a response status code or MIME Type that RestKit does not know how to handle.
 
 Response codes in the 2xx, 4xx, and 5xx range are all handled as you would expect. 2xx (successful) response codes
 are considered a successful content load and object mapping will be attempted. 4xx and 5xx are interpretted as
 errors and RestKit will attempt to object map an error out of the payload (provided the MIME Type is mappable)
 and will invoke objectLoader:didFailWithError: after constructing an NSError. Any other status code is considered
 unexpected and will cause objectLoaderDidLoadUnexpectedResponse: to be invoked provided that you have provided
 an implementation in your delegate class.
 
 RestKit will also invoke objectLoaderDidLoadUnexpectedResponse: in the event that content is loaded, but there
 is not a parser registered to handle the MIME Type of the payload. This often happens when the remote backend
 system RestKit is talking to generates an HTML error page on failure. If your remote system returns content
 in a MIME Type other than application/json or application/xml, you must register the MIME Type and an appropriate
 parser with the [RKParserRegistry sharedParser] instance.
 
 Also note that in the event RestKit encounters an unexpected status code or MIME Type response an error will be
 constructed and sent to the delegate via objectLoader:didFailsWithError: unless your delegate provides an
 implementation of objectLoaderDidLoadUnexpectedResponse:. It is recommended that you provide an implementation
 and attempt to handle common unexpected MIME types (particularly text/html and text/plain).
 
 @optional
 */
- (void)objectLoaderDidLoadUnexpectedResponse:(RKObjectLoader *)objectLoader
{
    NSLog(@"%s", __FUNCTION__);
    NSLog(@"objectLoader: %@", objectLoader);
    NSString *errorMessage = [NSString stringWithFormat:@"An error occurred while loading data from the server\r\r%@", objectLoader.URLRequest.URL];
    
    if (!objectLoader.response.isOK) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:errorMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
    }

}

/**
 Invoked just after parsing has completed, but before object mapping begins. This can be helpful
 to extract data from the parsed payload that is not object mapped, but is interesting for one
 reason or another. The mappableData will be made mutable via mutableCopy before the delegate
 method is invoked.
 
 Note that the mappable data is a pointer to a pointer to allow you to replace the mappable data
 with a new object to be mapped. You must dereference it to access the value.
 */
- (void)objectLoader:(RKObjectLoader *)loader willMapData:(inout id *)mappableData
{
    NSLog(@"%s", __FUNCTION__);
}

/**
 Sent when a request has finished loading
 
 @param request The RKRequest object that was handling the loading.
 @param response The RKResponse object containing the result of the request.
 */
- (void)request:(RKRequest*)request didLoadResponse:(RKResponse*)response
{
    NSLog(@"%s", __FUNCTION__);
    NSLog(@"request: %@ response: %@", request, response);
//    NSLog(@"%@", [request URL]);
//    NSLog(@"response: %@", response);
//    NSLog(@"Response code: %d", [response statusCode]);
//    NSLog(@"Response MIME type: %@", [response MIMEType]);
//    NSLog(@"Response body: %@", [response bodyAsString]);
}

@end
