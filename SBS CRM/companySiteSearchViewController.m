//
//  companySiteSearchViewController.m
//  SBS CRM 2.0
//
//  Created by Tom Couchman on 01/06/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "companySiteSearchViewController.h"
#import "AppDelegate.h"
#import "XMLParser.h"
#import "CompanySearch.h"

@interface companySiteSearchViewController ()

@property NSMutableArray *searchResults;
@property fetchXML *getCompaniesDom;
@property BOOL fetchingSearchResults;
@end

@implementation companySiteSearchViewController
@synthesize searchBarOutlet;

@synthesize searchResults, getCompaniesDom, fetchingSearchResults;

@synthesize delegate;
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [self setSearchBarOutlet:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
       return [searchResults count];
}





- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:
(NSString *)title atIndex:(NSInteger)index {
    return index;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if ([searchBarOutlet.text length] < 3)
    return @"Click search to fetch results";

    NSString *sectionTitle = [@"Number of results: " stringByAppendingFormat:@"%d",[searchResults count]];
    return sectionTitle;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if ([searchResults count] > 0){
        
        CompanySearch *currentSearchResult = [searchResults objectAtIndex:indexPath.row];
        cell.textLabel.text = currentSearchResult.cosSiteName;
        cell.detailTextLabel.text = currentSearchResult.cosDescription;
    }

    
    
    return cell;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    // create the parent view that will hold header Label
	UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.tableView.frame.size.width, 20)];
    if (fetchingSearchResults)
    {
        
        //[something addSubview:refreshSpinner];
        //[refreshSpinner startAnimating];
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
        //[customView addSubview:refreshSpinner];
        [customView addSubview:headerLabel];
    	return customView;
    }
    
    return nil;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CompanySearch *selectedSearchResult = [searchResults objectAtIndex:indexPath.row];
    [delegate companySiteSearchViewController:self didSelectCompany:selectedSearchResult];
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)btnCancel_Click:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}



// when the user clicks search:
- (void) searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    
    if ([searchBar.text length] < 3)
    {
        UIAlertView *stringTooShortAlert = [[UIAlertView alloc] initWithTitle:@"Search length" message:@"Search term must be 3 characters or more" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [stringTooShortAlert show];
    }
    else
    {
        //cancelled = YES;
        [searchResults removeAllObjects];
        //fetchingSearchResults = YES;
        [self.searchDisplayController.searchResultsTableView reloadData];
        
        //replace spaces in the search string with + to allow use as url
        NSString *searchText = [searchBar.text stringByReplacingOccurrencesOfString:@" " withString:@"+"];
        
        NSURL *url = [NSURL URLWithString:[appURL stringByAppendingFormat:@"/service1.asmx/searchCompaniesABL?searchString=%@",searchText]];
        
        getCompaniesDom = [[fetchXML alloc] initWithUrl:url delegate:self className:@"CompanySearch"];
        
        if (![getCompaniesDom fetchXML])
        {
            UIAlertView *domGetFailed = [[UIAlertView alloc] initWithTitle:@"Connection Error" message:@"Could not connect to the server" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil]; 
            [domGetFailed show];
        }        
        
        
        //     [self.searchDisplayController.searchResultsTableView reloadData];
        
    }
    //while (cancelled == NO)
    
    
    //[self filterContentForSearchText:searchBar.text 
    //scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
    //objectAtIndex:[self.searchDisplayController.searchBar
    //selectedScopeButtonIndex]]];
    
}

- (void) searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    //cancelled = YES;
    [getCompaniesDom cancel];
    //isSearching = NO;
    [searchResults removeAllObjects];
    [self.searchDisplayController.searchResultsTableView reloadData];
}


-(void)fetchXMLError:(NSString *)errorResponse:(id)sender{
    if (self.view.window) // don't display if this view is not active. TODO:make sure this method is never even called!
    {
        // If error recieved, display alert.
        [[[UIAlertView alloc] initWithTitle:@"Error Fetching Data" message:errorResponse delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }
    //fetchingSearchResults = NO;
}

-(void)docRecieved:(NSDictionary *)docDic:(id)sender{
    NSString *classKey = [docDic objectForKey:@"ClassName"];
        searchResults = [[NSMutableArray alloc] init];
    [searchResults addObjectsFromArray:[[[XMLParser alloc] init]parseXMLDoc:[docDic objectForKey:@"Document"] toClass:NSClassFromString(classKey)]];
    
    //sort the array:
    NSSortDescriptor *nameSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"cosSiteName" ascending:YES];

    searchResults = [[NSMutableArray alloc] initWithArray:[searchResults sortedArrayUsingDescriptors:[NSArray arrayWithObjects:nameSortDescriptor,nil]]];
    
    //fetchingSearchResults = NO;
    [self.searchDisplayController.searchResultsTableView reloadData];
}


@end
