//
//  companyTableViewController.m
//  SBS CRM
//
//  Created by Tom Couchman on 13/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "companyTableViewController.h"
#import "Company.h"
#import "syncData.h"
#import "AppDelegate.h"
#import "CompanySearch.h"


@implementation companyTableViewController

@synthesize context;



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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshTableView) 
                                                 name:@"reloadCoreData"
                                               object:nil];
    
    companyArray = [[NSMutableArray alloc] init];
    [self refreshTableView];
    isSearching = NO;
    searchResults = [[NSMutableArray alloc] init];
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
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}







// ############ Refresh Data ###################
- (void)refreshTableView{
    [companyArray removeAllObjects];
    
    if (context == nil) { context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext]; }
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Company" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                        initWithKey:@"cosSiteName" ascending:YES];
    [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    NSError *error = nil;
    NSArray *deviceCompanyArray = [context executeFetchRequest:request error:&error];
    
    NSDictionary *dict = [NSDictionary dictionaryWithObject:deviceCompanyArray forKey:@"Device"];
    
    [companyArray addObject:dict];
    
    [self.tableView reloadData];
}







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
        return [companyArray count];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (isSearching)
    {
        NSLog(@"search results count: %d", [searchResults count]);
        return [searchResults count];
    }
    else{
        NSDictionary *dict = [companyArray objectAtIndex:section];
        NSArray *keys = [dict allKeys];
        id key = [keys objectAtIndex:0];
        NSArray *sectionArray = [dict objectForKey:key];
    
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
        NSString *sectionTitle = [@"Number of results: " stringByAppendingFormat:@"%d",[searchResults count]];
        return sectionTitle;
    }
    else{
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
    
    if (isSearching)
    {
        if ([searchResults count] > 0){

            CompanySearch *currentSearchResult = [searchResults objectAtIndex:indexPath.row];
            cell.textLabel.text = currentSearchResult.cosSiteName;
            cell.detailTextLabel.text = currentSearchResult.cosDescription;
        }
    }
    else{
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

//###################
//#                 #
//#     SEARCH:     #
//#                 #
//###################

// when the user clicks the search bar:
- (void) searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    isSearching = YES;
}

// when the user clicks search:
- (void) searchBarSearchButtonClicked:(UISearchBar *)searchBar1 {

    
    if ([self.searchBar.text length] < 3)
    {
        UIAlertView *stringTooShortAlert = [[UIAlertView alloc] initWithTitle:@"Search length" message:@"Search term must be 3 characters or more" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [stringTooShortAlert show];
    }
    else
    {
    //cancelled = YES;
    [searchResults removeAllObjects];
    [self.searchDisplayController.searchResultsTableView reloadData];
    //BOOL searched = NO;
    NSString *searchText = self.searchBar.text;
    
    //send the query to the server and get the results back.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{ 
        
        UIApplication *app = [UIApplication sharedApplication];  
        [app setNetworkActivityIndicatorVisible:YES];
        
        BOOL searched = [self getCompanyResults:searchText];
        
        [app setNetworkActivityIndicatorVisible:NO];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            if (searched == YES)
                [self.searchDisplayController.searchResultsTableView reloadData];
            else
            {
                UIAlertView *searchFailed = [[UIAlertView alloc] initWithTitle:@"Live search" message:@"Could not perform live search" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [searchFailed show];
            }
        });
    });
    }
    //while (cancelled == NO)
    
    
    //[self filterContentForSearchText:searchBar.text 
                               //scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      //objectAtIndex:[self.searchDisplayController.searchBar
                                                     //selectedScopeButtonIndex]]];

}

- (void) searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    cancelled = YES;
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

- (BOOL)getCompanyResults:(NSString *)searchText{
    
    NSError *error;
    //replace spaces with + so the query can be sent as a url
    searchText = [searchText stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    url = [[NSURL alloc] initWithString:[appURL stringByAppendingFormat:@"/service1.asmx/searchCompanies?searchString=%@",searchText]];
    
    xmlString = [[NSString alloc] initWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    
    //remove xmlns from the xml file 
    xmlString = [xmlString stringByReplacingOccurrencesOfString:@"xmlns" withString:@"noNSxml"];
    xmlData = [xmlString dataUsingEncoding:NSUTF8StringEncoding];
    companiesDocument = [[DDXMLDocument alloc] initWithData:xmlData options:0 error:&error];
    if (error)
        return NO;

    
    //create an array of the nodes in the document
    NSArray* nodes = nil;
    nodes = [[companiesDocument rootElement] children];
    
    
    //loop through each of the element and place them in to the compaySearch class.
    for (DDXMLElement *element in nodes)
    { 
        CompanySearch *companySearchResult = [[CompanySearch alloc] init];
        DDXMLElement *companySiteID = [[element nodesForXPath:@"companySiteID" error:&error] objectAtIndex:0];
        companySearchResult.companySiteID = companySiteID.stringValue;
        DDXMLElement *coaCompanyName = [[element nodesForXPath:@"coaCompanyName" error:&error] objectAtIndex:0];
        companySearchResult.coaCompanyName = coaCompanyName.stringValue;
        DDXMLElement *cosSiteName = [[element nodesForXPath:@"cosSiteName" error:&error] objectAtIndex:0];
        companySearchResult.cosSiteName = cosSiteName.stringValue;     
        DDXMLElement *cosDescription = [[element nodesForXPath:@"cosDescription" error:&error] objectAtIndex:0];
        companySearchResult.cosDescription = cosDescription.stringValue;  
        DDXMLElement *addStreetAddress = [[element nodesForXPath:@"addStreetAddress" error:&error] objectAtIndex:0];
        companySearchResult.addStreetAddress = addStreetAddress.stringValue; 
        DDXMLElement *addStreetAddress2 = [[element nodesForXPath:@"addStreetAddress2" error:&error] objectAtIndex:0];
        companySearchResult.addStreetAddress2 = addStreetAddress2.stringValue; 
        DDXMLElement *addStreetAddress3 = [[element nodesForXPath:@"addStreetAddress3" error:&error] objectAtIndex:0];
        companySearchResult.addStreetAddress3 = addStreetAddress3.stringValue; 
        DDXMLElement *addTown = [[element nodesForXPath:@"addTown" error:&error] objectAtIndex:0];
        companySearchResult.addTown = addTown.stringValue;  
        DDXMLElement *addCounty = [[element nodesForXPath:@"addCounty" error:&error] objectAtIndex:0];
        companySearchResult.addCounty = addCounty.stringValue; 
        DDXMLElement *addPostCode = [[element nodesForXPath:@"addPostCode" error:&error] objectAtIndex:0];
        companySearchResult.addPostCode = addPostCode.stringValue; 
        DDXMLElement *couCountryName = [[element nodesForXPath:@"couCountryName" error:&error] objectAtIndex:0];
        companySearchResult.couCountryName = couCountryName.stringValue; 
        
        //NSLog(@"result: %@", companySearchResult.companySiteID);
        //add the result to the results array;
        [searchResults addObject:companySearchResult];
        //NSLog(@"count: %@", [searchResults count]);
        
        if (error)
            return NO;
    }
    
    
    
    //if (cancelled == YES)
        //return NO;
    
    return YES;
}





 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //if the segue is to the details screen
    if ([segue.identifier isEqualToString:@"pushDetails"])
    {
        //set up the required data in the detail View controller
        CompanySearch *currentCompany;
        if(!isSearching)
        {
            NSInteger row = [[self tableView].indexPathForSelectedRow row];
            NSInteger section = [[self tableView].indexPathForSelectedRow section];
            NSDictionary *dict = [companyArray objectAtIndex:section];
            NSArray *keys = [dict allKeys];
            id key = [keys objectAtIndex:0];
            NSArray *sectionArray = [dict objectForKey:key];
            currentCompany = [sectionArray objectAtIndex:row];
        }
        else{
            NSInteger row = [[self.searchDisplayController searchResultsTableView].indexPathForSelectedRow row];
            currentCompany = [searchResults objectAtIndex:row];
        }
        
        companyDetailsTableViewController *detailController = segue.destinationViewController;
        detailController.companyDetail = currentCompany;
        

    }
}

@end
