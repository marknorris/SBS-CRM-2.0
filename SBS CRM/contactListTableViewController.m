//
//  contactListTableViewController.m
//  SBS CRM
//
//  Created by Tom Couchman on 16/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "contactListTableViewController.h"
#import "DDXML.h"
#import "contactSearch.h"
#import "AppDelegate.h"
#import "contactDetailsTableViewController.h"

@interface contactListTableViewController(){
    NSMutableArray *contactsArray;
}

- (BOOL)fetchDataFromServer;
- (void)loadData;

@end

@implementation contactListTableViewController

@synthesize company;

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
    contactsArray = [[NSMutableArray alloc] init];
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
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)loadData{
    //reload data from server asynchronously
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{  
        
        UIApplication *app = [UIApplication sharedApplication];  
        [app setNetworkActivityIndicatorVisible:YES];
        
        BOOL loaded =  [self fetchDataFromServer];
        
        [app setNetworkActivityIndicatorVisible:NO];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            if (!loaded)
            {
                //alert user the are not connected to the server
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fetch data" message:@"Could not retrieve the data" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
            }
            // put the data into the table
            [self.tableView reloadData];
        });
    });
}

- (BOOL)fetchDataFromServer{
 
    
    //get the data from the server
    NSError* error = nil;    
    //url will depend on the query
    NSURL *url;
    if (company) // if there is a company site id perform the search by company site
    {
        url = [[NSURL alloc] initWithString:[appURL stringByAppendingFormat:@"/service1.asmx/searchContactsByCompany?searchCompanySiteID=%@",company.companySiteID]];
    }
    else
    {
        // a site id is required to perform the search so return 0 to indicate failure.
        return 0;
    }
    
    NSString *xmlString = [[NSString alloc] initWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    //remove xmlns from the xml file 
    xmlString = [xmlString stringByReplacingOccurrencesOfString:@"xmlns" withString:@"noNSxml"];
    NSLog(@"xml string: %@",xmlString);
    NSData *xmlData = [xmlString dataUsingEncoding:NSUTF8StringEncoding];
    DDXMLDocument *eventsDocument = [[DDXMLDocument alloc] initWithData:xmlData options:0 error:&error];
    if (error)
        return NO;
    
    NSArray* nodes = nil;
    nodes = [[eventsDocument rootElement] children];
    
    
    for (DDXMLElement *element in nodes)
    { 
        contactSearch *contactToSave = [[contactSearch alloc] init];
        DDXMLElement *contactID = [[element nodesForXPath:@"contactID" error:nil] objectAtIndex:0];
        contactToSave.contactID = contactID.stringValue;
        DDXMLElement *conTitle = [[element nodesForXPath:@"conTitle" error:nil] objectAtIndex:0];
        contactToSave.conTitle = conTitle.stringValue;
        DDXMLElement *conFirstName = [[element nodesForXPath:@"conFirstName" error:nil] objectAtIndex:0];
        contactToSave.conFirstName = conFirstName.stringValue;
        DDXMLElement *conMiddleName = [[element nodesForXPath:@"conMiddleName" error:nil] objectAtIndex:0];
        contactToSave.conMiddleName = conMiddleName.stringValue;
        DDXMLElement *conSurname = [[element nodesForXPath:@"conSurname" error:nil] objectAtIndex:0];
        contactToSave.conSurname = conSurname.stringValue;
        
        contactToSave.companySiteID = company.companySiteID;
        DDXMLElement *cosDescription = [[element nodesForXPath:@"cosDescription" error:nil] objectAtIndex:0];
        contactToSave.cosDescription = cosDescription.stringValue;
        DDXMLElement *cosSiteName = [[element nodesForXPath:@"cosSiteName" error:nil] objectAtIndex:0];
        contactToSave.cosSiteName = cosSiteName.stringValue;
        
        [contactsArray addObject:contactToSave];
    }

    return YES;
}






#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
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
    
    contactSearch* contact = [contactsArray objectAtIndex:indexPath.row];
    
    NSString *fullName = @"";
    if ([contact.conTitle length])
        fullName = [contact.conTitle stringByAppendingFormat:@" "];
    if ([contact.conFirstName length])
        fullName = [fullName stringByAppendingFormat:@"%@ ", contact.conFirstName];
    if ([contact.conMiddleName length])
        fullName = [fullName stringByAppendingFormat:@"%@ ", contact.conMiddleName];
    if ([contact.conSurname length])
        fullName = [fullName stringByAppendingFormat:@"%@", contact.conSurname];
    cell.textLabel.text = fullName;
    
    
    cell.detailTextLabel.text = [contact.cosSiteName stringByAppendingFormat:@" - %@", contact.cosDescription];
    
    /*
    cell.eventTitle.text = event.eveTitle;
    cell.eventComments.text = event.eveComments;
    cell.eventTypeType2.text = [event.eventType stringByAppendingFormat:@" - %@",event.eventType2];
    //cell.siteNameDesc.text = [company.cosSiteName stringByAppendingFormat:@" - %@",company.cosDescription];
    
    int hours = [event.eveDueTime integerValue] / 3600;
    int minutes = ([event.eveDueTime integerValue] / 60) % 60;
    cell.eventDueTime.text = [NSString stringWithFormat:@"%02d:%02d",hours,minutes];
    */
    
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
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //if the segue is to the details screen
    if ([segue.identifier isEqualToString:@"toContactDetails"])
    {
        //get the clicked cell's row
        NSInteger row = [[self tableView].indexPathForSelectedRow row];
        //set up the details view controller
        contactDetailsTableViewController *detailViewController = segue.destinationViewController;
        //send the object at index row.
        detailViewController.contactDetail = [contactsArray objectAtIndex:row];
        detailViewController.company = [[CompanySearch alloc] init];
        detailViewController.company = company;
        detailViewController.isCoreData = NO;
    }

}


@end
