//
//  companyTableViewController.m
//  SBS CRM
//
//  Created by Tom Couchman on 13/02/2012.
//  Copyright (c) 2012 Shuttleworth Business Systems Limited. All rights reserved.
//

#import "CompanyTableViewController.h"
#import "Company.h"
#import "AppDelegate.h"
#import "CompanySearch.h"
#import "XMLParser.h"
#import "NSManagedObject+CoreDataManager.h"

@interface CompanyTableViewController()
{
    NSMutableArray *companyArray;
    //Search:
    NSMutableArray *allEventsArray;
    UIActivityIndicatorView *refreshSpinner;
}

@property (nonatomic, retain) FetchXML *getCompaniesDom;

@end

@implementation CompanyTableViewController

//search
@synthesize searchDisplayController = _searchDisplayController2;
@synthesize searchBar = _searchBar;
@synthesize searchResults = _searchResults;

@synthesize getCompaniesDom = _getCompaniesDom;

@synthesize isSearching = _isSearching;
@synthesize fetchingSearchResults = _fetchingSearchResults;

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTableView) name:@"reloadCoreData" object:nil];
    
    companyArray = [[NSMutableArray alloc] init];
    [self refreshTableView];
    self.isSearching = NO;
    self.fetchingSearchResults = NO;
    self.searchResults = [[NSMutableArray alloc] init];
    
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
- (void)refreshTableView
{
    [companyArray removeAllObjects];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"cosSiteName" ascending:YES];
    NSArray *deviceCompanyArray = [NSManagedObject fetchObjectsForEntityName:@"Company" withPredicate:nil withSortDescriptors:[NSArray arrayWithObject: sortDescriptor]];
    NSDictionary *dict = [NSDictionary dictionaryWithObject:deviceCompanyArray forKey:@"Device"];
    
    [companyArray addObject:dict];
    
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
    if (self.isSearching) {
        return 1;
    }
    else {
        return [companyArray count];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (self.isSearching) {
        //NSLog(@"search results count: %d", [searchResults count]);
        return [self.searchResults count];
    }
    else {
        NSDictionary *dict = [companyArray objectAtIndex:section];
        NSArray *keys = [dict allKeys];
        id key = [keys objectAtIndex:0];
        NSArray *sectionArray = [dict objectForKey:key];
        
        return [sectionArray count];
    }
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return index;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (self.isSearching) {
        if ([self.searchBar.text length] < 3)
            return @"Click search to fetch results";
        
        NSString *sectionTitle = [@"Number of results: " stringByAppendingFormat:@"%d", [self.searchResults count]];
        return sectionTitle;
    }
    else {
        NSDictionary *dict = [companyArray objectAtIndex:section];
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
    
    if (self.isSearching) {
        
        if ([self.searchResults count] > 0) {
            CompanySearch *currentSearchResult = [self.searchResults objectAtIndex:indexPath.row];
            cell.textLabel.text = currentSearchResult.cosSiteName;
            cell.detailTextLabel.text = currentSearchResult.cosDescription;
        }
        
    }
    else {
        NSDictionary *dict = [companyArray objectAtIndex:indexPath.section];
        NSArray *keys = [dict allKeys];
        id key = [keys objectAtIndex:0];
        NSArray *sectionArray = [dict objectForKey:key];
        Company *currentCompany = [sectionArray objectAtIndex:indexPath.row];
        
        cell.textLabel.text = currentCompany.cosSiteName;
        cell.detailTextLabel.text = currentCompany.cosDescription;
    }
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    // create the parent view that will hold header Label
	UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.tableView.frame.size.width, 20)];
    if (self.fetchingSearchResults) {
        //[something addSubview:refreshSpinner];
        [refreshSpinner startAnimating];
        //return refreshSpinner;
        
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
- (void) searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    self.isSearching = YES;
}

// when the user clicks search:
- (void) searchBarSearchButtonClicked:(UISearchBar *)searchBar1
{
    
    if ([self.searchBar.text length] < 3) {
        UIAlertView *stringTooShortAlert = [[UIAlertView alloc] initWithTitle:@"Search length" message:@"Search term must be 3 characters or more" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [stringTooShortAlert show];
    }
    else {
        //cancelled = YES;
        [self.searchResults removeAllObjects];
        self.fetchingSearchResults = YES;
        [self.searchDisplayController.searchResultsTableView reloadData];
        
        //replace spaces in the search string with + to allow use as url
        NSString *searchText = [self.searchBar.text stringByReplacingOccurrencesOfString:@" " withString:@"+"];
        
        NSURL *url = [NSURL URLWithString:[appURL stringByAppendingFormat:@"/service1.asmx/searchCompaniesABL?searchString=%@", searchText]];
        
        self.getCompaniesDom = [[FetchXML alloc] initWithUrl:url delegate:self className:@"CompanySearch"];
        
        if (![self.getCompaniesDom fetchXML]) {
            UIAlertView *domGetFailed = [[UIAlertView alloc] initWithTitle:@"Connection Error" message:@"Could not connect to the server" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil]; 
            [domGetFailed show];
        }        
        
    }
    
}

- (void) searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    //cancelled = YES;
    [self.getCompaniesDom cancel];
    self.isSearching = NO;
    [self.searchResults removeAllObjects];
    [self.searchDisplayController.searchResultsTableView reloadData];
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

//when the search result changes delete all of the currently displayed results.
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if ([searchText length] == 0) {
        [self.searchResults removeAllObjects];
        [self.searchDisplayController.searchResultsTableView reloadData];    
    }
}

-(void)fetchXMLError:(NSString *)errorResponse:(id)sender
{
    if (self.view.window) { // don't display if this view is not active. TODO:make sure this method is never even called!
        // If error recieved, display alert.
        [[[UIAlertView alloc] initWithTitle:@"Error Fetching Data" message:errorResponse delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }
    
    self.fetchingSearchResults = NO;
}

-(void)docRecieved:(NSDictionary *)docDic:(id)sender
{
    NSString *classKey = [docDic objectForKey:@"ClassName"];
    [self.searchResults addObjectsFromArray:[[[XMLParser alloc] init]parseXMLDoc:[docDic objectForKey:@"Document"] toClass:NSClassFromString(classKey)]];
    
    //sort the array:
    NSSortDescriptor *nameSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"cosSiteName" ascending:YES];
    self.searchResults = [[NSMutableArray alloc] initWithArray:[self.searchResults sortedArrayUsingDescriptors:[NSArray arrayWithObjects:nameSortDescriptor, nil]]];
    
    self.fetchingSearchResults = NO;
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
    if ([segue.identifier isEqualToString:@"pushDetails"]) {
        //set up the required data in the detail View controller
        CompanySearch *currentCompany;
        
        if (!self.isSearching) {
            NSInteger row = [[self tableView].indexPathForSelectedRow row];
            NSInteger section = [[self tableView].indexPathForSelectedRow section];
            NSDictionary *dict = [companyArray objectAtIndex:section];
            NSArray *keys = [dict allKeys];
            id key = [keys objectAtIndex:0];
            NSArray *sectionArray = [dict objectForKey:key];
            currentCompany = [sectionArray objectAtIndex:row];
        }
        else {
            NSInteger row = [[self.searchDisplayController searchResultsTableView].indexPathForSelectedRow row];
            currentCompany = [self.searchResults objectAtIndex:row];
        }
        
        CompanyDetailsTableViewController *detailController = segue.destinationViewController;
        detailController.companyDetail = currentCompany;
    }
}

@end
