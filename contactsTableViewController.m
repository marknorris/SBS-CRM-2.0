//
//  contactsTableViewController.m
//  SBS CRM
//
//  Created by Tom Couchman on 13/02/2012.
//  Copyright (c) 2012 Shuttleworth Business Systems Limited. All rights reserved.
//

#import "contactsTableViewController.h"
#import "Contact.h"
#import "AppDelegate.h"
#import "ContactSearch.h"

#import "XMLParser.h"

#import "CoreDataManager.h"

@interface contactsTableViewController()
    @property (nonatomic, retain) fetchXML *getContactsDom;
@end


@implementation contactsTableViewController


//search
@synthesize searchDisplayController;
@synthesize searchBar;
@synthesize searchResults;

@synthesize getContactsDom;

@synthesize isSearching;
@synthesize fetchingSearchResults;

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
    
    // listen out for notifications calling to reload core data (syncs all happen at the same time).
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshTableView) 
                                                 name:@"reloadCoreData"
                                               object:nil];
    
    
    contactsArray = [[NSMutableArray alloc] init];
    //load data into the tableview.
    [self refreshTableView];
    
    isSearching = NO;
    searchResults = [[NSMutableArray alloc] init];

    //set up the activity spinner
    refreshSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    refreshSpinner.frame = CGRectMake(5, 0, 20, 20);
    refreshSpinner.hidesWhenStopped = YES;
    
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
//#          Prepare TableView Data             #
//#                                             #
//#                                             #
//###############################################

// ############ Refresh Data ###################
- (void)refreshTableView{
    [contactsArray removeAllObjects];
    
    //retrieve contacts from core data:                                                                                      
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                        initWithKey:@"conFirstName" ascending:YES];
    NSArray *deviceContactArray = [NSManagedObject fetchObjectsForEntityName:@"Contact" withPredicate:nil withSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    NSDictionary *dict = [NSDictionary dictionaryWithObject:deviceContactArray forKey:@"Device"];
    
    [contactsArray addObject:dict];
    
    //fill tableview.
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
    if (isSearching)
    {
        return 1;
    }
    else
    {
        return [contactsArray count];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section: source depends on whether search results or core data are being displayed.
    if (isSearching)
    {
        //NSLog(@"search results count: %d", [searchResults count]);
        return [searchResults count];
    }
    else{
        NSDictionary *dict = [contactsArray objectAtIndex:section];
        //NSArray *keys = [dict allKeys]; // don't need to search for all keys as there is only one, "Device"
        //id key = [keys objectAtIndex:0];
        NSArray *sectionArray = [dict objectForKey:@"Device"];
        
        return [sectionArray count];
    }
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:
(NSString *)title atIndex:(NSInteger)index {
    return index;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (isSearching)
    {
        if ([searchBar.text length] < 3)
            return @"Click search to fetch results";
        NSString *sectionTitle = [@"Number of results: " stringByAppendingFormat:@"%d",[searchResults count]];
        return sectionTitle;
    }
    else{
        NSDictionary *dict = [contactsArray objectAtIndex:section];
        NSArray *keys = [dict allKeys];
        id key = [keys objectAtIndex:0];
        return key;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if (isSearching)
    {
        if ([searchResults count] > 0){
            
            ContactSearch *currentSearchResult = [searchResults objectAtIndex:indexPath.row];
            NSMutableArray *nameArray = [NSMutableArray arrayWithObjects:currentSearchResult.conTitle,currentSearchResult.conFirstName, currentSearchResult.conMiddleName, currentSearchResult.conSurname, nil];
            [nameArray removeObject:@""];
            cell.textLabel.text = [nameArray componentsJoinedByString:@"\n"];
            cell.detailTextLabel.text = [currentSearchResult.cosSiteName stringByAppendingFormat:@" - %@", currentSearchResult.cosDescription];
        }
    }
    else{
        NSDictionary *dict = [contactsArray objectAtIndex:indexPath.section];
        //NSArray *keys = [dict allKeys];
        //id key = [keys objectAtIndex:0];
        NSArray *sectionArray = [dict objectForKey:@"Device"];
        Contact *currentContact = [sectionArray objectAtIndex:indexPath.row];
        
        NSMutableArray *nameArray = [NSMutableArray arrayWithObjects:currentContact.conTitle,currentContact.conFirstName, currentContact.conMiddleName, currentContact.conSurname, nil];
        [nameArray removeObject:@""];
        cell.textLabel.text = [nameArray componentsJoinedByString:@"\n"];
        cell.detailTextLabel.text = [currentContact.cosSiteName stringByAppendingFormat:@" - %@", currentContact.cosDescription];
    }
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    // create the parent view that will hold header Label
	UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.tableView.frame.size.width, 20)];
    if (fetchingSearchResults)
    {
        
        
        
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
        [customView addSubview:refreshSpinner];// add refresh spinner to the custom view
        [refreshSpinner startAnimating]; // begin spinner animation.
        [customView addSubview:headerLabel]; //add the custom view to the header
    	return customView;
    }
    
    return nil;
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

#pragma mark - Table view delegate

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



//###############################################
//#                                             #
//#                                             #
//#                   Search:                   #
//#                                             #
//#                                             #
//###############################################

// when the user clicks the search bar:
- (void) searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    isSearching = YES;
}

// when the user clicks search:
- (void) searchBarSearchButtonClicked:(UISearchBar *)searchBar1 {
    
    
    if ([self.searchBar.text length] < 3) //ensure the search string is at least 3 characters long.
    {
        UIAlertView *stringTooShortAlert = [[UIAlertView alloc] initWithTitle:@"Search length" message:@"Search term must be 3 characters or more" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [stringTooShortAlert show];
    }
    else
    {
        
        [searchResults removeAllObjects];
        fetchingSearchResults = YES; //TODO:make sure this gets set back to no!
        [self.searchDisplayController.searchResultsTableView reloadData];
        
        

        
        NSString *searchText = [self.searchBar.text stringByReplacingOccurrencesOfString:@" " withString:@"+"];
        NSURL *url = [NSURL URLWithString:[appURL stringByAppendingFormat:@"/service1.asmx/searchContactsABL?searchString=%@",searchText]];
        getContactsDom = [[fetchXML alloc] initWithUrl:url delegate:self className:@"ContactSearch"];
        
        if (![getContactsDom fetchXML])
        {
            UIAlertView *domGetFailed = [[UIAlertView alloc] initWithTitle:@"Connection Error" message:@"Could not connect to the server" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [domGetFailed show];
        }
        //NSLog(@"url: %@", [appURL stringByAppendingFormat:@"/service1.asmx/searchContactsABL?searchString=%@",searchText]);

    }
}

- (void) searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    //TODO: Test This:
    [getContactsDom cancel];
    //cancelled = YES;
    isSearching = NO;
    [searchResults removeAllObjects];
    [self.searchDisplayController.searchResultsTableView reloadData];
}

- (void)filterContentForSearchText:(NSString*)searchText 
                             scope:(NSString*)scope
{
    
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller 
shouldReloadTableForSearchString:(NSString *)searchString
{
    return NO;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller 
shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    //[self filterContentForSearchText:[self.searchDisplayController.searchBar text] 
    //scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
    //objectAtIndex:searchOption]];
    //[searchResults removeAllObjects];
    //[self filterContentForSearchText:searchBar.text 
    //scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
    //objectAtIndex:[self.searchDisplayController.searchBar
    //selectedScopeButtonIndex]]];
    //[self.searchDisplayController.searchResultsTableView reloadData];
    return NO;
}



//when the search result changes delete all of the currently displayed results.
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if ([searchText length] == 0)
    {
        [searchResults removeAllObjects];
        
        [self.searchDisplayController.searchResultsTableView reloadData];    
    }
}


-(void)fetchXMLError:(NSString *)errorResponse:(id)sender{
    if (self.view.window) // don't display if this view is not active. TODO:make sure this method is never even called!
    {
        // If error recieved, display alert.
        [[[UIAlertView alloc] initWithTitle:@"Error Fetching Data" message:errorResponse delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }
    fetchingSearchResults = NO;
}

-(void)docRecieved:(NSDictionary *)docDic:(id)sender{
    NSString *classKey = [docDic objectForKey:@"ClassName"];
    [searchResults addObjectsFromArray:[[[XMLParser alloc] init]parseXMLDoc:[docDic objectForKey:@"Document"] toClass:NSClassFromString(classKey)]];
    
    /*
    NSSortDescriptor *nameSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"conFirstName" ascending:YES];
    //sort the array:
      NSMutableArray *sortedArray = [[NSMutableArray alloc] initWithArray:[searchResults sortedArrayUsingDescriptors:[NSArray arrayWithObjects:nameSortDescriptor,nil]]];
    */
    
    
    fetchingSearchResults = NO;
    [self.searchDisplayController.searchResultsTableView reloadData];
}






//###############################################
//#                                             #
//#                                             #
//#                   SEGUE                     #
//#                                             #
//#                                             #
//###############################################

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //if the segue is to the details screen
    if ([segue.identifier isEqualToString:@"pushDetails"])
    {
        
        contactDetailsTableViewController *detailViewController = segue.destinationViewController;
        
        //set up the required data in the detail View controller
        ContactSearch *currentContact;
        if(!isSearching)
        {
            // find the data in the array that has been selected
            NSInteger row = [[self tableView].indexPathForSelectedRow row];
            NSInteger section = [[self tableView].indexPathForSelectedRow section];
            NSDictionary *dict = [contactsArray objectAtIndex:section];
            NSArray *sectionArray = [dict objectForKey:@"Device"];
            currentContact = [sectionArray objectAtIndex:row];
            detailViewController.isCoreData = YES;
        }
        else{
            // find the search result that has been selected
            NSInteger row = [[self.searchDisplayController searchResultsTableView].indexPathForSelectedRow row];
            currentContact = [searchResults objectAtIndex:row];
            detailViewController.isCoreData = NO;
        }
        

        //NSLog(@"contact surname: %@",currentContact.conSurname);
        // Send the data through to the detailViewController.
        detailViewController.contactDetail = currentContact;
    }
}


@end
