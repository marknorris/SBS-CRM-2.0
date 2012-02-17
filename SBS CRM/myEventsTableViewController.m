//
//  myEventsTableViewController.m
//  SBS CRM
//
//  Created by Tom Couchman on 09/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "myEventsTableViewController.h"
#import "syncData.h"
#import "AppDelegate.h"
#import "Events.h"
#import <QuartzCore/QuartzCore.h>
#import "EventTableViewCell.h"
#import "eventDetailsTableViewController.h"

#define REFRESH_HEADER_HEIGHT 52.0f

@implementation myEventsTableViewController

//core data
@synthesize context;

//pull to refresh
@synthesize textPull, textRelease, textLoading, refreshHeaderView, refreshLabel, refreshArrow, refreshSpinner;


//search
@synthesize searchDisplayController;
@synthesize searchBar;
@synthesize searchResults;

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
    
    eventIDArray = [[NSMutableArray alloc] init];
    allEventsArray = [[NSMutableArray alloc] init];
    isSearching = NO;
    isLoading = NO;
    isMutatingArray = NO;
    
    //set up pull to refresh
    [self setupStrings];
    [self addPullToRefreshHeader];
    
    
    [self refreshTableView];
    

    

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


- (void)reloadCoreData{
    //reload data from server asynchronously
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{  
        //return result of sync to reloaded - NO = failed, YES = success.
        BOOL reloaded =  [[syncData alloc] doSync];
        dispatch_sync(dispatch_get_main_queue(), ^{
            if (!reloaded)
            {
                [self stopLoading];
                //alert user the are not connected to the server
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fetch data" message:@"Could not connect to server" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];

            }
            else
            {
                //TODO check this -- cause error when it tried to reload after the if statement and there was no data!
                // put the data into the table
                [self refreshTableView];
            }
            //TODO check whether this line is needed:
            //self.tableView.scrollEnabled = YES;
        });
    });
}

- (void)refreshTableView{
    
    isMutatingArray = YES;
    [[NSNotificationCenter defaultCenter] 
     postNotificationName:@"reloadCoreData" 
     object:self];
    [eventIDArray removeAllObjects];
    
    if (context == nil) { context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext]; }
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Events" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    // max number to load:
    //[request setFetchBatchSize:<#(NSUInteger)#>];
    
    [request setEntity:entity];
    
    //create and set sort descriptors to order array by due date and time.
    NSSortDescriptor *dateSortDescriptor = [[NSSortDescriptor alloc]
                                        initWithKey:@"eveDueDate" ascending:YES];
    NSSortDescriptor *timeSortDescriptor = [[NSSortDescriptor alloc]
                                            initWithKey:@"eveDueTime" ascending:YES];
    [request setSortDescriptors:[NSArray arrayWithObjects:dateSortDescriptor,timeSortDescriptor,nil]];

    
    NSError *error = nil;
    NSArray *eventsArray = [context executeFetchRequest:request error:&error];
    
    if ([eventsArray count] == 0)
    {
        [self startLoading];
        return;
    }
    
    
    //TODO make the for below better!
    
    Events *event = [eventsArray objectAtIndex:0];
    NSDate *currentDate = event.eveDueDate;
    NSMutableArray *tempIDArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < [eventsArray count]; i++)
    {
        NSLog(@"currentDate:%@", currentDate);
        event = [eventsArray objectAtIndex:i];
        if ([event.eveDueDate isEqualToDate:currentDate])
            [tempIDArray addObject:event.eventID];
        else
        {
            
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            [df setDateStyle:NSDateFormatterMediumStyle];
            NSString *dateString;
            dateString = [df stringFromDate:currentDate];
            if ([dateString isEqualToString:@"Jan 1, 1901"])
                dateString = @"No Due Date";
            NSDictionary *dict = [NSDictionary dictionaryWithObject:tempIDArray forKey:dateString];
            [eventIDArray addObject:dict];
            tempIDArray = [[NSMutableArray alloc] init];
            [tempIDArray addObject:event.eventID];
            currentDate = event.eveDueDate;
        }
    }
    
    //for last one
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateStyle:NSDateFormatterMediumStyle];
    NSString *dateString;
    dateString = [df stringFromDate:currentDate];
    if ([dateString isEqualToString:@"Jan 1, 9999"])
        dateString = @"No Due Date";
    NSDictionary *dict = [NSDictionary dictionaryWithObject:tempIDArray forKey:dateString];
    [eventIDArray addObject:dict];
    isMutatingArray = NO;
    [self.tableView reloadData];
    if (isLoading)
        [self stopLoading];
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
    

    // load data from the server (via pull to refresh method)
    //[self startLoading];
    
    /*
    if (context == nil) { context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext]; }
    
    NSEntityDescription *entity;
    NSFetchRequest *request;
    NSError *error; 
    NSMutableArray *arr;
    
    //log events count
    
    entity = [NSEntityDescription entityForName:@"Events" inManagedObjectContext:context];
    request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    arr = [[context executeFetchRequest:request error:&error] mutableCopy];
    NSLog(@"Events:%d", arr.count);
    
    //log Company count
    
    entity = [NSEntityDescription entityForName:@"Company" inManagedObjectContext:context];
    request = [[NSFetchRequest alloc] init];
    [request setEntity:entity]; 
    arr = [[context executeFetchRequest:request error:&error] mutableCopy];
    NSLog(@"Company:%d", arr.count);
    
    //log Contact count
    
    entity = [NSEntityDescription entityForName:@"Contact" inManagedObjectContext:context];
    request = [[NSFetchRequest alloc] init];
    [request setEntity:entity]; 
    arr = [[context executeFetchRequest:request error:&error] mutableCopy];
    NSLog(@"Contact:%d", arr.count);
    
    //log Communication count
    
    entity = [NSEntityDescription entityForName:@"Communication" inManagedObjectContext:context];
    request = [[NSFetchRequest alloc] init];
    [request setEntity:entity]; 
    arr = [[context executeFetchRequest:request error:&error] mutableCopy];
    NSLog(@"Communication:%d", arr.count);
    
    //log Attachment count
    
    entity = [NSEntityDescription entityForName:@"Attachment" inManagedObjectContext:context];
    request = [[NSFetchRequest alloc] init];
    [request setEntity:entity]; 
    arr = [[context executeFetchRequest:request error:&error] mutableCopy];
    NSLog(@"Attachment:%d", arr.count);
    

    */
    

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
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return [eventIDArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    NSDictionary *dict = [eventIDArray objectAtIndex:section];
    NSArray *keys = [dict allKeys];
    id key = [keys objectAtIndex:0];
    NSArray *tArr = [dict objectForKey:key];
    
    return [tArr count];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:
(NSString *)title atIndex:(NSInteger)index {
    return index;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSDictionary *dict = [eventIDArray objectAtIndex:section];
    NSArray *keys = [dict allKeys];
    id key = [keys objectAtIndex:0];
    return key;
}



-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 80; 
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    
    //set the cell to the custom cell created in EventTableViewCell nib
    static NSString *CellIdentifier = @"eventCell";
    
    EventTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.backgroundColor = [UIColor whiteColor];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"EventTableViewCell" owner:self options:nil] objectAtIndex:0];
    }

    if (isMutatingArray == YES)
        return cell;
    
    NSDictionary *dict = [eventIDArray objectAtIndex:indexPath.section];
    NSArray *keys = [dict allKeys];
    id key = [keys objectAtIndex:0];
    NSArray *tArr = [dict objectForKey:key];
    NSString *currentID = [tArr objectAtIndex:indexPath.row];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Events" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];

    
    [request setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"eventID == %@", currentID];
    [request setPredicate:predicate];
    NSError *error = nil;
    NSArray *eventsArray = [context executeFetchRequest:request error:&error];
    Events* event = [eventsArray objectAtIndex:0];

 
    entity = [NSEntityDescription entityForName:@"Company" inManagedObjectContext:context];
    [request setEntity:entity];
    predicate = [NSPredicate predicateWithFormat:
                 @"companySiteID == %@", event.companySiteID];
    [request setPredicate:predicate];
    
    NSArray *companyArray = [context executeFetchRequest:request error:&error];
    
    
    CompanySearch *company = [[CompanySearch alloc] init];
    if ([companyArray count] > 0)
    {
        company = [companyArray objectAtIndex:0];
    }
    else
    {
        company.cosSiteName = @"No company";
        company.cosDescription = @"Can't display details.";
    }
    
    if (![eventsArray count])
    {
        NSLog(@"error");
    }
    else
    {

        cell.eventTitle.text = event.eveTitle;
                NSLog(@"title : %@", event.eveTitle);
        cell.eventComments.text = event.eveComments;
                    NSLog(@"title : %@", event.eveTitle);
        cell.eventTypeType2.text = [event.eventType stringByAppendingFormat:@" - %@",event.eventType2];
        cell.siteNameDesc.text = [company.cosSiteName stringByAppendingFormat:@" - %@",company.cosDescription];
        
        int hours = [event.eveDueTime integerValue] / 3600;
        int minutes = ([event.eveDueTime integerValue] / 60) % 60;
        cell.eventDueTime.text = [NSString stringWithFormat:@"%02d:%02d",hours,minutes];
        
        /*
        EventsCellData* currentCell = [[EventsCellData alloc] init];
        currentCell.eventTitle = event.eveTitle;
        currentCell.eventComments = event.eveComments;
        currentCell.eventTypeType2 = cell.eventTypeType2.text;
        currentCell.siteNameDesc = cell.siteNameDesc.text;
        currentCell.eventDueTime = cell.eventDueTime.text;
        [allEventsArray addObject:currentCell];
        NSLog(@"COUNT OF EVENT CELL DATA: %d", [allEventsArray count]);
        */
    }
    

    // max number to load:
    //[request setFetchBatchSize:<#(NSUInteger)#>];
    
    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"pushDetails" sender:self];
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}






/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/






- (void)setupStrings{
    textPull = [[NSString alloc] initWithString:@"Pull down to refresh..."];
    textRelease = [[NSString alloc] initWithString:@"Release to refresh..."];
    textLoading = [[NSString alloc] initWithString:@"Loading..."];
}

- (void)addPullToRefreshHeader {
    refreshHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0 - REFRESH_HEADER_HEIGHT, 320, REFRESH_HEADER_HEIGHT)];
    refreshHeaderView.backgroundColor = [UIColor blackColor];
    
    refreshLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, REFRESH_HEADER_HEIGHT)];
    refreshLabel.backgroundColor = [UIColor clearColor];
    refreshLabel.font = [UIFont boldSystemFontOfSize:12.0];
    refreshLabel.textAlignment = UITextAlignmentCenter;
    refreshLabel.textColor = [UIColor whiteColor];
    
    refreshArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrowwhite.png"]];
    refreshArrow.frame = CGRectMake(floorf((REFRESH_HEADER_HEIGHT - 44) / 2),
                                    (floorf(REFRESH_HEADER_HEIGHT - 44) / 2),
                                    44, 44);
    
    refreshSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    refreshSpinner.frame = CGRectMake(floorf(floorf(REFRESH_HEADER_HEIGHT - 20) / 2), floorf((REFRESH_HEADER_HEIGHT - 20) / 2), 20, 20);
    refreshSpinner.hidesWhenStopped = YES;
    
    [refreshHeaderView addSubview:refreshLabel];
    [refreshHeaderView addSubview:refreshArrow];
    [refreshHeaderView addSubview:refreshSpinner];
    [self.tableView addSubview:refreshHeaderView];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (isLoading) return;
    isDragging = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
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
            refreshLabel.text = self.textRelease;
            [refreshArrow layer].transform = CATransform3DMakeRotation(M_PI, 0, 0, 1);
        } else { // User is scrolling somewhere within the header
            refreshLabel.text = self.textPull;
            [refreshArrow layer].transform = CATransform3DMakeRotation(M_PI * 2, 0, 0, 1);
        }
        [UIView commitAnimations];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (isLoading) return;
    isDragging = NO;
    if (scrollView.contentOffset.y <= -REFRESH_HEADER_HEIGHT) {
        // Released above the header
        [self startLoading];
    }
}

- (void)startLoading {
    if (isSearching == YES)
        return;
    else
    {
    //TODO check whether this line is needed:
    //self.tableView.scrollEnabled = NO;
    isLoading = YES;
    
    // Show the header
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    self.tableView.contentInset = UIEdgeInsetsMake(REFRESH_HEADER_HEIGHT, 0, 0, 0);
    refreshLabel.text = self.textLoading;
    refreshArrow.hidden = YES;
    [refreshSpinner startAnimating];
    [UIView commitAnimations];
    
    // Refresh action!
    [self reloadCoreData];
    }
}

- (void)stopLoading {

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

- (void)stopLoadingComplete:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    // Reset the header
    refreshLabel.text = self.textPull;
    refreshArrow.hidden = NO;
    [refreshSpinner stopAnimating];
}





//########## SEARCH ############
- (void) searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    isSearching = YES;
}

- (void) searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    isSearching = NO;
    [searchResults removeAllObjects];
    [self.searchDisplayController.searchResultsTableView reloadData];
}

//when the search result changes delete all of the currently displayed results.
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if ([searchText length] == 0)
    {
        [searchResults removeAllObjects];
        [self.searchDisplayController.searchResultsTableView reloadData];    
    }
}


- (void) searchBarSearchButtonClicked:(UISearchBar *)searchBar1 {
    [searchResults removeAllObjects];
    [self.searchDisplayController.searchResultsTableView reloadData];
    [self filterContentForSearchText:searchBar.text 
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchDisplayController.searchBar
                                                     selectedScopeButtonIndex]]];
    [self.searchDisplayController.searchResultsTableView reloadData];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller 
shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    //[self filterContentForSearchText:[self.searchDisplayController.searchBar text] 
    //scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
    //objectAtIndex:searchOption]];
    [searchResults removeAllObjects];
    [self filterContentForSearchText:searchBar.text 
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchDisplayController.searchBar
                                                     selectedScopeButtonIndex]]];
    [self.searchDisplayController.searchResultsTableView reloadData];
    return YES;
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller 
shouldReloadTableForSearchString:(NSString *)searchString
{
    return NO;
}

- (void)filterContentForSearchText:(NSString*)searchText 
                             scope:(NSString*)scope
{
    // remove previous search results.
    [searchResults removeAllObjects];
    //create array of objectes to search
    NSMutableArray *searchArray = [[NSMutableArray alloc] init];
    /*
    for ()
        

    
    for (NSInteger j = 0; j < [fTweets count]; j++)
    {
        NSDictionary *dict = [fTweets objectAtIndex:j];
        NSArray *keys = [dict allKeys];
        id key = [keys objectAtIndex:0];
        NSArray *array = [dict objectForKey:key];
        
        [searchArray addObjectsFromArray:array];
    }
    
    
    for (Tweet *tTemp in searchArray)
    {
        
        NSString *sTemp  = @"";
        if ([scope isEqualToString:@"Username"])
        {
            sTemp = tTemp.userName;
        }
        else if ([scope isEqualToString:@"Text"])
        {
            sTemp = tTemp.text;
        }
        else if ([scope isEqualToString:@"Both"])
        {
            sTemp = tTemp.text;
            sTemp = [sTemp stringByAppendingString:tTemp.userName];
        }
        NSRange titleResultsRange = [sTemp rangeOfString:searchText options:NSCaseInsensitiveSearch];
        
        if (titleResultsRange.length != 0)
        {
            NSLog (@"username: %@", tTemp.userName);
            [searchResults addObject:tTemp];
            //NSLog (@"count: %@", [searchResults count]);
        }
    }
    
    
    [searchArray removeAllObjects] ;
    [self.searchDisplayController.searchResultsTableView reloadData];
     */
}
//########## END SEARCH ############


//# when a segue is called send the appropriate data to the destination view controller #
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //if the segue is to the details screen
    if ([segue.identifier isEqualToString:@"pushDetails"])
    {
        NSInteger row = [[self tableView].indexPathForSelectedRow row];
        NSInteger section = [[self tableView].indexPathForSelectedRow section];
        
        //retrieve the event ID for the clicked event
        NSDictionary *dict = [eventIDArray objectAtIndex:section];
        NSArray *keys = [dict allKeys];
        id key = [keys objectAtIndex:0];
        NSArray *tArr = [dict objectForKey:key];
        NSString *currentID = [tArr objectAtIndex:row];
        
        //send the event id to the detail view controller
        eventDetailsTableViewController *detailViewController = segue.destinationViewController;
        detailViewController.eventDetails = [[eventSearch alloc] init];
        detailViewController.eventDetails.eventID = currentID;
        detailViewController.isCoreData = YES;
    }
}



@end
