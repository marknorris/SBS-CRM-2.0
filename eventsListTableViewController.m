//
//  eventsListTableViewController.m
//  SBS CRM
//
//  Created by Tom Couchman on 15/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "eventsListTableViewController.h"
#import "syncData.h"
#import "EventTableViewCell.h"
#import "eventDetailsTableViewController.h"

@implementation eventsListTableViewController

@synthesize company;
@synthesize contact;

//@synthesize companySiteID;
//@synthesize contactID;

@synthesize viewTitle;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)getData{
    //reload data from server asynchronously
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{  
        
        BOOL loaded =  [self getDataFromServer];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            if (!loaded)
            {
                //alert user the are not connected to the server
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fetch data" message:@"Could not retrieve the data" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
            }
            // put the data into the table
            //[self refreshTableView];
            [self.tableView reloadData];
        });
    });
}

- (BOOL)getDataFromServer{
    
    UIApplication *app = [UIApplication sharedApplication];  
    [app setNetworkActivityIndicatorVisible:YES]; 
    //get the data from the server
    NSError* error = nil;    
    //url will depend on the query
    NSURL *url;
    if (contact) // if there is a contact ID perform the search by contact
    {
        url = [[NSURL alloc] initWithString:[appURL stringByAppendingFormat:@"/service1.asmx/searchEventsByContact?searchContactID=%@",contact.contactID]];
    }
    else if (company) // if there is a company site id perform the search by company site
    {
        url = [[NSURL alloc] initWithString:[appURL stringByAppendingFormat:@"/service1.asmx/searchEventsByCompany?searchCompanySiteID=%@",company.companySiteID]];
    }
    else
    {
        // a contact id or site id are required to perform the search so return 0 to indicate failure.
        return 0;
    }
    
    NSString *xmlString = [[NSString alloc] initWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    //remove xmlns from the xml file 
    xmlString = [xmlString stringByReplacingOccurrencesOfString:@"xmlns" withString:@"noNSxml"];
    NSLog(@"xml string: %@",xmlString);
    NSData *xmlData = [xmlString dataUsingEncoding:NSUTF8StringEncoding];
    DDXMLDocument *eventsDocument = [[DDXMLDocument alloc] initWithData:xmlData options:0 error:&error];
    
    [app setNetworkActivityIndicatorVisible:NO];
    
    if (error)
        return NO;
    
    NSArray* nodes = nil;
    nodes = [[eventsDocument rootElement] children];
    
    NSMutableArray *eventsArray = [[NSMutableArray alloc] init];
    
    for (DDXMLElement *element in nodes)
    { 
        eventSearch *currentEvent = [[eventSearch alloc] init];
        DDXMLElement *eveNumber = [[element nodesForXPath:@"eveNumber" error:nil] objectAtIndex:0];
        currentEvent.eveNumber = eveNumber.stringValue;
        DDXMLElement *eveStatus = [[element nodesForXPath:@"eveStatus" error:nil] objectAtIndex:0];
        currentEvent.eveStatus = eveStatus.stringValue;
        DDXMLElement *eveTitle = [[element nodesForXPath:@"eveTitle" error:nil] objectAtIndex:0];
        currentEvent.eveTitle = eveTitle.stringValue;
        DDXMLElement *ourContactID = [[element nodesForXPath:@"ourContactID" error:nil] objectAtIndex:0];
        currentEvent.ourContactID = ourContactID.stringValue;
        DDXMLElement *eventType = [[element nodesForXPath:@"eventType" error:nil] objectAtIndex:0];
        currentEvent.eventType = eventType.stringValue;
        DDXMLElement *eventType2 = [[element nodesForXPath:@"eventType2" error:nil] objectAtIndex:0];
        currentEvent.eventType2 = eventType2.stringValue;
        DDXMLElement *eventPriority = [[element nodesForXPath:@"eventPriority" error:nil] objectAtIndex:0];
        currentEvent.eventPriority = eventPriority.stringValue;
        DDXMLElement *companySiteID = [[element nodesForXPath:@"companySiteID" error:nil] objectAtIndex:0];
        currentEvent.companySiteID = companySiteID.stringValue;
        DDXMLElement *eventID = [[element nodesForXPath:@"eventID" error:nil] objectAtIndex:0];
        currentEvent.eventID = eventID.stringValue;
        DDXMLElement *contactID = [[element nodesForXPath:@"contactID" error:nil] objectAtIndex:0];
        currentEvent.contactID = contactID.stringValue;
        DDXMLElement *eveComments = [[element nodesForXPath:@"eveComments" error:nil] objectAtIndex:0];
        currentEvent.eveComments = eveComments.stringValue;
        DDXMLElement *eveCreatedDate = [[element nodesForXPath:@"eveCreatedDate" error:nil] objectAtIndex:0];
        currentEvent.eveCreatedDate = eveCreatedDate.stringValue;
        DDXMLElement *eveCreatedTime = [[element nodesForXPath:@"eveCreatedTime" error:nil] objectAtIndex:0];
        currentEvent.eveCreatedTime = eveCreatedTime.stringValue;        
        DDXMLElement *eveDueDate = [[element nodesForXPath:@"eveDueDate" error:nil] objectAtIndex:0];
        
        NSString *stringDate = eveDueDate.stringValue;
        if ([stringDate isEqualToString:@""])
            stringDate = @"01/01/9999 00:00:00";
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"dd/MM/yyyy HH:mm:ss"];
        currentEvent.eveDueDate = [df dateFromString:stringDate];

        DDXMLElement *eveDueTime = [[element nodesForXPath:@"eveDueTime" error:nil] objectAtIndex:0];
        currentEvent.eveDueTime = eveDueTime.stringValue;
        DDXMLElement *eveEndDate = [[element nodesForXPath:@"eveEndDate" error:nil] objectAtIndex:0];
        currentEvent.eveEndDate = eveEndDate.stringValue;
        DDXMLElement *eveEndTime = [[element nodesForXPath:@"eveEndTime" error:nil] objectAtIndex:0];
        currentEvent.eveEndTime = eveEndTime.stringValue;
        DDXMLElement *eveCreatedBy = [[element nodesForXPath:@"eveCreatedBy" error:nil] objectAtIndex:0];
        currentEvent.eveCreatedBy = eveCreatedBy.stringValue;
        
        [eventsArray addObject:currentEvent];
    }
    
    NSSortDescriptor *dateSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"eveDueDate"
                                                 ascending:YES];
    NSSortDescriptor *timeSortDescriptor = [[NSSortDescriptor alloc]
                                            initWithKey:@"eveDueTime" ascending:YES];
    NSArray *sortedArray = [eventsArray sortedArrayUsingDescriptors:[NSArray arrayWithObjects:dateSortDescriptor,timeSortDescriptor,nil]];
    
    //initialist the ordered array
    orderedEventsArray = [[NSMutableArray alloc] init];
    
    //TODO make This better:
    //once the events have been loaded, sort them into an array of dictionaries so they can be grouped on the tableview:
    eventSearch *event = [sortedArray objectAtIndex:0];
    NSDate *currentDate = event.eveDueDate;
    NSMutableArray *tempIDArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < [sortedArray count]; i++)
    {
        NSLog(@"currentDate:%@", currentDate);
        event = [sortedArray objectAtIndex:i];
        if ([event.eveDueDate isEqualToDate:currentDate])
        {
            [tempIDArray addObject:event];
            NSLog(@"array count: %d",[tempIDArray count]);
        }
        else
        {
            
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            [df setDateStyle:NSDateFormatterMediumStyle];
            NSString *dateString;
            dateString = [df stringFromDate:currentDate];
            if ([dateString isEqualToString:@"Jan 1, 1901"])
                dateString = @"No Due Date";
            NSDictionary *dict = [NSDictionary dictionaryWithObject:tempIDArray forKey:dateString];
            [orderedEventsArray addObject:dict];
            tempIDArray = [[NSMutableArray alloc] init];
            [tempIDArray addObject:event];
            currentDate = event.eveDueDate;
            NSLog(@"array count: %d",[tempIDArray count]);
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
    [orderedEventsArray addObject:dict];
    
    
    
    
    
    
    //NSLog(@"array count: %d",[eventsArray count]);
    //NSLog(@"ordered array count: %d",[orderedEventsArray count]);
    
    return YES;
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
    [self getData];
    
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







#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [orderedEventsArray count];
    //return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSDictionary *dict = [orderedEventsArray objectAtIndex:section];
    NSArray *keys = [dict allKeys];
    id key = [keys objectAtIndex:0];
    NSArray *tArr = [dict objectForKey:key];
    
    return [tArr count];
    //return [eventsArray count];
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
    //return [NSString stringWithFormat:@"Events for %@",viewTitle];
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
    
    eventSearch* event = [tArr objectAtIndex:indexPath.row];

        cell.eventTitle.text = event.eveTitle;
        cell.siteNameDesc.text = [company.cosSiteName stringByAppendingFormat:@" - %@",company.cosDescription];
        cell.eventComments.text = event.eveComments;
        cell.eventTypeType2.text = [event.eventType stringByAppendingFormat:@" - %@",event.eventType2];
        //cell.siteNameDesc.text = [company.cosSiteName stringByAppendingFormat:@" - %@",company.cosDescription];
        
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
    
    
    
    
    
    
    // Configure the cell...
    
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
        [self performSegueWithIdentifier:@"toEventDetails" sender:self];
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
        eventSearch* event = [tArr objectAtIndex:row];
        
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
