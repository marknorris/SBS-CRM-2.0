//
//  companySiteSearchViewController.m
//  SBS CRM 2.0
//
//  Created by Tom Couchman on 01/06/2012.
//  Copyright (c) 2012 Shuttleworth Business Systems Limited. All rights reserved.
//

#import "CompanySiteSearchViewController.h"
#import "AppDelegate.h"
#import "XMLParser.h"
#import "CompanySearch.h"

@interface CompanySiteSearchViewController ()

@property (nonatomic, strong) NSMutableArray *searchResults;
@property (nonatomic, strong) FetchXML *getCompaniesDom;
@property (nonatomic) BOOL fetchingSearchResults;

@end

@implementation CompanySiteSearchViewController

@synthesize searchBarOutlet = _searchBarOutlet;
@synthesize searchResults = _searchResults;
@synthesize getCompaniesDom = _getCompaniesDom;
@synthesize fetchingSearchResults = _fetchingSearchResults;
@synthesize delegate = _delegate;

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
    return [self.searchResults count];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index 
{
    return index;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if ([self.searchBarOutlet.text length] < 3)
        return @"Click search to fetch results";
    
    NSString *sectionTitle = [@"Number of results: " stringByAppendingFormat:@"%d", [self.searchResults count]];
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
    
    if ([self.searchResults count] > 0) {
        CompanySearch *currentSearchResult = [self.searchResults objectAtIndex:indexPath.row];
        cell.textLabel.text = currentSearchResult.cosSiteName;
        cell.detailTextLabel.text = currentSearchResult.cosDescription;
    }
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    // create the parent view that will hold header Label
	UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.tableView.frame.size.width, 20)];
    
    if (self.fetchingSearchResults) {
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
    CompanySearch *selectedSearchResult = [self.searchResults objectAtIndex:indexPath.row];
    [self.delegate companySiteSearchViewController:self didSelectCompany:selectedSearchResult];
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)btnCancel_Click:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

// when the user clicks search:
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar 
{
    
    if ([searchBar.text length] < 3) {
        UIAlertView *stringTooShortAlert = [[UIAlertView alloc] initWithTitle:@"Search length" message:@"Search term must be 3 characters or more" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [stringTooShortAlert show];
    }
    else {
        //cancelled = YES;
        [self.searchResults removeAllObjects];
        //fetchingSearchResults = YES;
        [self.searchDisplayController.searchResultsTableView reloadData];
        
        //replace spaces in the search string with + to allow use as url
        NSString *searchText = [searchBar.text stringByReplacingOccurrencesOfString:@" " withString:@"+"];
        
        NSURL *url = [NSURL URLWithString:[appURL stringByAppendingFormat:@"/service1.asmx/searchCompaniesABL?searchString=%@", searchText]];
        
        self.getCompaniesDom = [[FetchXML alloc] initWithUrl:url delegate:self className:@"CompanySearch"];
        
        if (![self.getCompaniesDom fetchXML]) {
            UIAlertView *domGetFailed = [[UIAlertView alloc] initWithTitle:@"Connection Error" message:@"Could not connect to the server" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil]; 
            [domGetFailed show];
        }        
        
        //     [self.searchDisplayController.searchResultsTableView reloadData];
    }

}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    //cancelled = YES;
    [self.getCompaniesDom cancel];
    //isSearching = NO;
    [self.searchResults removeAllObjects];
    [self.searchDisplayController.searchResultsTableView reloadData];
}

- (void)fetchXMLError:(NSString *)errorResponse:(id)sender
{
    if (self.view.window) // don't display if this view is not active. TODO:make sure this method is never even called!
    {
        // If error recieved, display alert.
        [[[UIAlertView alloc] initWithTitle:@"Error Fetching Data" message:errorResponse delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }
    //fetchingSearchResults = NO;
}

- (void)docRecieved:(NSDictionary *)docDic:(id)sender
{
    NSString *classKey = [docDic objectForKey:@"ClassName"];
    self.searchResults = [[NSMutableArray alloc] init];
    [self.searchResults addObjectsFromArray:[[[XMLParser alloc] init]parseXMLDoc:[docDic objectForKey:@"Document"] toClass:NSClassFromString(classKey)]];
    
    //sort the array:
    NSSortDescriptor *nameSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"cosSiteName" ascending:YES];
    
    self.searchResults = [[NSMutableArray alloc] initWithArray:[self.searchResults sortedArrayUsingDescriptors:[NSArray arrayWithObjects:nameSortDescriptor,nil]]];
    
    //fetchingSearchResults = NO;
    [self.searchDisplayController.searchResultsTableView reloadData];
}

@end
