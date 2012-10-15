//
//  advancedSearchTableViewController.m
//  SBS CRM
//
//  Created by Tom Couchman on 24/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "advancedSearchTableViewController.h"
#import "AppDelegate.h"
#import "DDXML.h"
#import "eventsListTableViewController.h"

@interface advancedSearchTableViewController ()
{
@private
    NSString *item;
    NSMutableArray *itemArray;
    NSString *sourceCellIdentifier;
    //create an array for the eventTypes
    NSMutableArray *eventTypeArray;
    NSMutableArray *eventType2Array;
    
    NSMutableArray *contactArray;
    
    NSString *internalContactID;
    NSString *eventTypeID;
    NSString *eventType2ID;
}

- (BOOL)fetchContacts:(NSString *)companySiteID;
- (BOOL)fetchEventTypes;
- (BOOL)fetchEventType2s;
@end

@implementation advancedSearchTableViewController

@synthesize companySiteID;
@synthesize cosSiteName;

@synthesize fullName;
@synthesize contactID;

@synthesize company;

@synthesize cellCompanySite;
@synthesize cellType1;
@synthesize cellContact;
@synthesize lblType1CellDetail;
@synthesize cellType2;
@synthesize cellDueDateFrom;
@synthesize cellDueDateTo;
@synthesize cellCreatedDateFrom;
@synthesize cellCreatedDateTo;
@synthesize segStatus;
@synthesize txtTitle;
@synthesize txtComments;
@synthesize cellInternalContact;
@synthesize cellNoOfRecords;
@synthesize segOrderBy;



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
    internalContactID = @"All";
    eventTypeID = @"All";
    eventType2ID = @"All";
    if (!contactID)
        contactID = @"All";
/*
    //get todays date with the time set to 00:00
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregorian components:(NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit) fromDate:[NSDate date]];
    NSDate *today = [gregorian dateFromComponents:components];
    //create a string to hold today's date in short style
    NSDateFormatter *dfToString = [[NSDateFormatter alloc] init];
    [dfToString setDateStyle:NSDateFormatterShortStyle];
    NSString *dateString = [dfToString stringFromDate:today];
    */
    
    //fill all date cells with this date:
    /*
    cellDueDateFrom.detailTextLabel.text = dateString;
    cellDueDateTo.detailTextLabel.text = dateString;
    cellCreatedDateFrom.detailTextLabel.text = dateString;
    cellCreatedDateTo.detailTextLabel.text = dateString;*/
    
    cellCompanySite.detailTextLabel.text = cosSiteName;
    if (fullName)
        cellContact.detailTextLabel.text = fullName;
    
    itemArray = [[NSMutableArray alloc] init];
    eventTypeArray = [[NSMutableArray alloc] init];
    eventType2Array = [[NSMutableArray alloc] init];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [self setCellType1:nil];
    [self setLblType1CellDetail:nil];
    [self setCellContact:nil];
    [self setCellType2:nil];
    [self setCellCompanySite:nil];
    [self setCellDueDateFrom:nil];
    [self setCellDueDateTo:nil];
    [self setCellCreatedDateFrom:nil];
    [self setCellCreatedDateTo:nil];
    [self setSegStatus:nil];
    [self setTxtTitle:nil];
    [self setTxtComments:nil];
    [self setCellInternalContact:nil];
    [self setCellNoOfRecords:nil];
    [self setSegOrderBy:nil];
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

#pragma mark - Table view data source
/*
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    
    return cell;
}
*/

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
    
    //depending upon which cell has been clicked get the array information and the default item
    
    
    /*
    //test array
    //Create the array to be sent:
    itemArray = [NSArray arrayWithObjects:
                 @"All",
                 @"Angry Birds",
                 @"Chess",
                 @"Russian Roulette",
                 @"Spin the Bottle",
                 @"Texas Hold'em Poker",
                 @"Tic-Tac-Toe",
                 nil];
    */
    //reset the item array
    [itemArray removeAllObjects];
    
    switch (indexPath.section) {
        case 0:
            if (indexPath.row == 1)
            {
                // fetch the array and if successfull:
                if([self fetchContacts:companySiteID])
                {
                    item = cellContact.detailTextLabel.text;
                    sourceCellIdentifier = @"cellContact.detailTextLabel.text";
                    [self performSegueWithIdentifier:@"toLookUpTableView" sender:self];
                }
            }
            break;
        case 1:
            if (indexPath.row == 0)
            {
                if([self fetchEventTypes])
                {
                    item = cellType1.detailTextLabel.text;
                    sourceCellIdentifier = @"cellType1.detailTextLabel.text";
                    [self performSegueWithIdentifier:@"toLookUpTableView" sender:self];
                }
            }
            else
            {
                if([self fetchEventType2s])
                {
                    item = cellType2.detailTextLabel.text;
                    sourceCellIdentifier = @"cellType2.detailTextLabel.text";
                    [self performSegueWithIdentifier:@"toLookUpTableView" sender:self];
                }
            }
            break;
        case 2:
            if (indexPath.row == 0)
            {
                item = cellDueDateFrom.detailTextLabel.text;
                sourceCellIdentifier = @"cellDueDateFrom.detailTextLabel.text";
                [self performSegueWithIdentifier:@"toDateTimePicker" sender:self];
            }
            else
            {

                item = cellDueDateTo.detailTextLabel.text;
                sourceCellIdentifier = @"cellDueDateTo.detailTextLabel.text";
                [self performSegueWithIdentifier:@"toDateTimePicker" sender:self];

            }
            break;
        case 3:
            if (indexPath.row == 0)
            {

                item = cellCreatedDateFrom.detailTextLabel.text;
                sourceCellIdentifier = @"cellCreatedDateFrom.detailTextLabel.text";
                [self performSegueWithIdentifier:@"toDateTimePicker" sender:self];
            }
            else
            {
                    item = cellCreatedDateTo.detailTextLabel.text;
                    sourceCellIdentifier = @"cellCreatedDateTo.detailTextLabel.text";
                    [self performSegueWithIdentifier:@"toDateTimePicker" sender:self];
            }
            break;
        case 6: 
            // fetch the array and if successfull:
            if([self fetchContacts:[NSString stringWithFormat:@"%d", appCompanySiteID]])
            {
                item = cellInternalContact.textLabel.text;
                sourceCellIdentifier = @"cellInternalContact.textLabel.text";
                [self performSegueWithIdentifier:@"toLookUpTableView" sender:self];

            }
            break;
        case 7: 
            item = cellNoOfRecords.textLabel.text;
            //create an array of the desired array to send the picker view
            itemArray = [[NSMutableArray alloc] init];
            [itemArray addObject:@"50"];
            [itemArray addObject:@"100"];
            [itemArray addObject:@"150"];
            [itemArray addObject:@"200"];
        
            sourceCellIdentifier = @"cellNoOfRecords.textLabel.text";
            [self performSegueWithIdentifier:@"toPickerView" sender:self];

            break;
        default:
            [[[UIAlertView alloc] initWithTitle:@"Required Data Unavailable" message:@"Could not retrieve the date required for this action" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
            break;
    }
    
    
    
    
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

- (IBAction)btnCancelClick:(id)sender {
    
    [self dismissModalViewControllerAnimated:YES];
    
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"toLookUpTableView"])
    {
        

        
        //set the required values for the look up view controller
        lookUpTableViewController *lookUpTableViewController = segue.destinationViewController;
        lookUpTableViewController.delegate = self; //set self as the delegate
        lookUpTableViewController.item = item; // set the selected item
        lookUpTableViewController.itemArray = itemArray; // set the array of items
        lookUpTableViewController.sourceCellIdentifier = sourceCellIdentifier;
        
        //pass information about where the look up was called from in order to ensure the returned data can be handles correctly
        //lookUpTableViewController.sourceIdentifier = self.tableView.indexPathForSelectedRow;
        
        
    }
    else if ([segue.identifier isEqualToString:@"toDateTimePicker"])
    {
        
        
        
        //set the required values for the look up view controller
        dateTimePickerViewController *dateTimePickerViewController = segue.destinationViewController;
        dateTimePickerViewController.delegate = self; //set self as the delegate
        
        NSDateFormatter *dfToDate = [[NSDateFormatter alloc] init];
        [dfToDate setDateStyle:NSDateFormatterShortStyle];
        if ([item isEqualToString:@"All"])
            dateTimePickerViewController.dateTime = [NSDate date];
        else
            dateTimePickerViewController.dateTime = [dfToDate dateFromString:item];
        dateTimePickerViewController.sourceCellIdentifier = sourceCellIdentifier;
        dateTimePickerViewController.mode = UIDatePickerModeDate;
        
        //pass information about where the look up was called from in order to ensure the returned data can be handles correctly
        //lookUpTableViewController.sourceIdentifier = self.tableView.indexPathForSelectedRow;
        
        
    }
    else if ([segue.identifier isEqualToString:@"toPickerView"])
    {
        //set the required values for the look up view controller
        pickerViewController *pickerViewController = segue.destinationViewController;
        pickerViewController.delegate = self; //set self as the delegate
        
        pickerViewController.item = item;
        pickerViewController.itemArray = itemArray;
        pickerViewController.sourceCellIdentifier = sourceCellIdentifier;
    }
    else if ([segue.identifier isEqualToString:@"toEventsList"])
    {
        

        NSDateFormatter *dfToDate = [[NSDateFormatter alloc] init];
        [dfToDate setDateStyle:NSDateFormatterShortStyle];
        NSDateFormatter *dfToString = [[NSDateFormatter alloc] init];
        [dfToString setDateFormat:@"yyyy-MM-dd"];
        
        //set to default value
        NSString *dueDateFrom = @"All";
        NSString *dueDateTo = @"All";
        NSString *createdDateFrom = @"All";
        NSString *createdDateTo = @"All";
        
        //check the labels to find the true value, if other than "All" set it
        if (![cellDueDateFrom.detailTextLabel.text isEqualToString:@"All"]) 
            dueDateFrom = [dfToString stringFromDate:[dfToDate dateFromString:cellDueDateFrom.detailTextLabel.text]];
        if (![cellDueDateTo.detailTextLabel.text isEqualToString:@"All"]) 
            dueDateTo = [dfToString stringFromDate:[dfToDate dateFromString:cellDueDateTo.detailTextLabel.text]];
        if (![cellCreatedDateFrom.detailTextLabel.text isEqualToString:@"All"]) 
            createdDateFrom = [dfToString stringFromDate:[dfToDate dateFromString:cellCreatedDateFrom.detailTextLabel.text]];
        if (![cellCreatedDateTo.detailTextLabel.text isEqualToString:@"All"]) 
            createdDateTo = [dfToString stringFromDate:[dfToDate dateFromString:cellCreatedDateTo.detailTextLabel.text]];
        
        
        
        eventsListTableViewController *eventListViewController = segue.destinationViewController;
        //pass through the advanced search URL;
        
        if (segOrderBy.selectedSegmentIndex == 1)
            eventListViewController.orderByCreatedDate = YES;
        
        eventListViewController.company = company;
        
        eventListViewController.advancedURL = [appURL stringByAppendingFormat:@"/service1.asmx/advancedEventSearchABL?companySiteID=%@&contactID=%@&eventType=%@&eventType2=%@&dueDateFrom=%@&dueDateTo=%@&createdDateFrom=%@&createdDateTo=%@&status=%d&title=%@&comments=%@&internalContactID=%@&noOfRecords=%@&orderBy=%d",
                                                                             companySiteID,
                                                                             contactID,
                                                                             eventTypeID,
                                                                             eventType2ID,
                                                                             dueDateFrom,
                                                                             dueDateTo,
                                                                             createdDateFrom,
                                                                             createdDateTo,
                                                                             segStatus.selectedSegmentIndex,
                                                                             txtTitle.text,txtComments.text,
                                                                             internalContactID,
                                                                             cellNoOfRecords.textLabel.text,
                                                                             segOrderBy.selectedSegmentIndex];
        NSLog(@"the url:%@", eventListViewController.advancedURL);
    }
    
    
}


- (void) lookUpTableViewController: (lookUpTableViewController  *) controller didSelectItem:(NSInteger *)returnedRow withSourceCellIdentifier:(NSString *)returnedSourceCellIdentifier
{

    NSString *itemToSet;
    
    //set the value to the correct cell using the source identifier
    //if 0 it is "ALL" else find the corresponding contact 
    // remember to subtract 1 as there is no "All" option int the contact array
    itemToSet = [itemArray objectAtIndex:((int)returnedRow)];
    

        
    [self setValue:itemToSet forKeyPath:returnedSourceCellIdentifier];
    
    if ([returnedSourceCellIdentifier isEqualToString:@"cellContact.detailTextLabel.text"])
    {
        if (returnedRow == 0)
            contactID = @"All";
        else
            contactID = [(ContactSearch *)[contactArray objectAtIndex:((int)returnedRow - 1)] contactID];
    }
    
    
    // when the type 2 cell is changed
    if ([returnedSourceCellIdentifier isEqualToString:@"cellType1.detailTextLabel.text"])
    {
        if (returnedRow == 0)
            eventTypeID = @"All";
        else
            eventTypeID = [[eventTypeArray objectAtIndex:((int)returnedRow - 1)] objectForKey:[itemArray objectAtIndex:((int)returnedRow)]];
        
        //check to see if its been set to something other than "All"
        if (![cellType1.detailTextLabel.text isEqualToString:@"All"])
        {
            //if yes enable the type 2 cell and reset it's value to All (incase it had previously been set)
            cellType2.userInteractionEnabled = YES;

        }
        else
            // if it has been set back to all disable
            cellType2.userInteractionEnabled = NO;
        //whenever type 1 is changed, reset type 2 (as its possible values are dependant on type 1)
        cellType2.detailTextLabel.text = @"All";
        eventType2ID = @"All";
    }
    else if ([returnedSourceCellIdentifier isEqualToString:@"cellType2.detailTextLabel.text"])
    {
        if (returnedRow == 0)
            eventType2ID = @"All";
        else
            eventType2ID = [[eventType2Array objectAtIndex:((int)returnedRow - 1)] objectForKey:[itemArray objectAtIndex:((int)returnedRow)]];
    }
    else if([returnedSourceCellIdentifier isEqualToString:@"cellInternalContact.textLabel.text"])
    {
        if (returnedRow == 0)
            internalContactID = @"All";
        else
            internalContactID = [(ContactSearch *)[contactArray objectAtIndex:((int)returnedRow - 1)] contactID];
    }
    /*
    else if ([returnedSourceCellIdentifier isEqualToString:@"cellContact.detailTextLabel.text"])
    {   //depending upon the contact returned, set the contact id or internal contact ID
        contactID = [[contactArray objectAtIndex:[contactNameArray indexOfObject:cellContact.detailTextLabel.text]] contactID];
        [contactArray removeAllObjects];
        [contactNameArray removeAllObjects];
    }
    else if ([returnedSourceCellIdentifier isEqualToString:@"cellContact.detailTextLabel.text"])
    {
        internalContactID = [[contactArray objectAtIndex:[contactNameArray indexOfObject:cellInternalContact.detailTextLabel.text]] contactID]; 
        [contactArray removeAllObjects];
        [contactNameArray removeAllObjects];
    }*/

    
        
    //[self setValue:@"HI" forKey:@"cellType1"];

    /*switch (sourceIdentifier.section) {
        case 0:
            //
            break;
        case 1:
            if (sourceIdentifier.row == 0)
            {
                [self performSelector:("@setCellType1
                cellType1.detailTextLabel.text = returnedItem;
            }
            break;
        default:
            break;
    }*/
    
}







- (void) dateTimePickerViewController: (dateTimePickerViewController *)controller didSelectDateTime:(NSDate *)returnedDate withSourceCellIdentifier:(NSString *)returnedSourceCellIdentifier withSender:(id)sender
{
    
    NSDateFormatter *dfToString = [[NSDateFormatter alloc] init];
    [dfToString setDateStyle:NSDateFormatterShortStyle];
    NSString *dateString = [dfToString stringFromDate:returnedDate];
    
    //set the value to the correct cell using the source identifier
    [self setValue:dateString forKeyPath:returnedSourceCellIdentifier];
    

    
}


-(void)pickerViewController:(pickerViewController *)controller
                      didSelectItem: (NSString *)returnedItem withSourceCellIdentifier:(NSString *)returnedSourceCellIdentifier{
    
    //set the value to the correct cell using the source identifier
    [self setValue:returnedItem forKeyPath:returnedSourceCellIdentifier];
}


- (BOOL)fetchContacts:(NSString *)searchCompanySiteID{
    
    
    //get the data from the server
    NSError* error = nil;    
    //url will depend on the query
    NSURL *url;
    url = [[NSURL alloc] initWithString:[appURL stringByAppendingFormat:@"/service1.asmx/searchContactsByCompanyABL?searchCompanySiteID=%@",searchCompanySiteID]];

    
    NSString *xmlString = [[NSString alloc] initWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    //remove xmlns from the xml file 
    xmlString = [xmlString stringByReplacingOccurrencesOfString:@"xmlns" withString:@"noNSxml"];
    //NSLog(@"xml string: %@",xmlString);
    NSData *xmlData = [xmlString dataUsingEncoding:NSUTF8StringEncoding];
    DDXMLDocument *eventsDocument = [[DDXMLDocument alloc] initWithData:xmlData options:0 error:&error];
    if (error)
        return NO;
    
    NSArray* nodes = nil;
    nodes = [[eventsDocument rootElement] children];
    
    [contactArray removeAllObjects];
    contactArray = [[NSMutableArray alloc] init];

    
    //add the item all to the item array
    [itemArray addObject:@"All"];
    
    for (DDXMLElement *element in nodes)
    { 
        ContactSearch *contactToSave = [[ContactSearch alloc] init];
        DDXMLElement *_contactID = [[element nodesForXPath:@"contactID" error:nil] objectAtIndex:0];
        contactToSave.contactID = _contactID.stringValue;
        DDXMLElement *conTitle = [[element nodesForXPath:@"conTitle" error:nil] objectAtIndex:0];
        contactToSave.conTitle = conTitle.stringValue;
        DDXMLElement *conFirstName = [[element nodesForXPath:@"conFirstName" error:nil] objectAtIndex:0];
        contactToSave.conFirstName = conFirstName.stringValue;
        DDXMLElement *conMiddleName = [[element nodesForXPath:@"conMiddleName" error:nil] objectAtIndex:0];
        contactToSave.conMiddleName = conMiddleName.stringValue;
        DDXMLElement *conSurname = [[element nodesForXPath:@"conSurname" error:nil] objectAtIndex:0];
        contactToSave.conSurname = conSurname.stringValue;
        contactToSave.companySiteID = searchCompanySiteID;
        DDXMLElement *cosDescription = [[element nodesForXPath:@"cosDescription" error:nil] objectAtIndex:0];
        contactToSave.cosDescription = cosDescription.stringValue;
        DDXMLElement *_CosSiteName = [[element nodesForXPath:@"cosSiteName" error:nil] objectAtIndex:0];
        contactToSave.cosSiteName = _CosSiteName.stringValue;
        
        //TODO will we need this array?
        [contactArray addObject:contactToSave];
        
        NSMutableArray *nameArray = [NSMutableArray arrayWithObjects:contactToSave.conTitle,contactToSave.conFirstName, contactToSave.conMiddleName, contactToSave.conSurname, nil];
        [nameArray removeObject:@""];
        fullName = [nameArray componentsJoinedByString:@"\n"];
        
        [itemArray addObject:fullName];

    }
    
    //place the names array inside itemArray
    //[itemArray addObjectsFromArray:contactNameArray];
    
    //NSLog(@"array count: %d", [itemArray count]);
    return YES;
}

- (BOOL)fetchEventTypes{
    
    
    //get the data from the server
    NSError* error = nil;    
    //url will depend on the query
    NSURL *url;
    url = [[NSURL alloc] initWithString:[appURL stringByAppendingString:@"/service1.asmx/getEventTypesABL"]];
    
    
    NSString *xmlString = [[NSString alloc] initWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    //remove xmlns from the xml file 
    xmlString = [xmlString stringByReplacingOccurrencesOfString:@"xmlns" withString:@"noNSxml"];
    //NSLog(@"xml string: %@",xmlString);
    NSData *xmlData = [xmlString dataUsingEncoding:NSUTF8StringEncoding];
    DDXMLDocument *eventsDocument = [[DDXMLDocument alloc] initWithData:xmlData options:0 error:&error];
    if (error)
        return NO;
    
    NSArray* nodes = nil;
    nodes = [[eventsDocument rootElement] children];

    //ensure that the eventTypeArray is empty.
    [eventTypeArray removeAllObjects];
    
    //add the item all to the item array
    [itemArray addObject:@"All"];
    
    for (DDXMLElement *element in nodes)
    { 
        //create a dictionary to hold the description and id
        NSDictionary *eventTypeDict = [[NSDictionary alloc] init];
      
        DDXMLElement *tempEventTypeID = [[element nodesForXPath:@"eventTypeID" error:nil]objectAtIndex:0];
        DDXMLElement *evtDescription = [[element nodesForXPath:@"evtDescription" error:nil]objectAtIndex:0];
        
        eventTypeDict = [NSDictionary dictionaryWithObject:tempEventTypeID.stringValue forKey:evtDescription.stringValue];

        //add the dictionary to the eventType array
        [eventTypeArray addObject:eventTypeDict];
        //add the descriptions to the item array for the look up table view
        [itemArray addObject:evtDescription.stringValue];
    }
    
    //NSLog(@"array count: %d", [itemArray count]);
    return YES;
}

- (BOOL)fetchEventType2s{
    
    NSString *selectedEventTypeID;
    //get the id of the selected eventType
    for (NSDictionary *tempEventDict in eventTypeArray)
    {   
        if ([tempEventDict objectForKey:cellType1.detailTextLabel.text])
            selectedEventTypeID = [tempEventDict objectForKey:cellType1.detailTextLabel.text];
    }
    
    if (selectedEventTypeID == nil)
        return NO;
    
    //get the data from the server
    NSError* error = nil;    
    //url will depend on the query
    NSURL *url;
    url = [[NSURL alloc] initWithString:[appURL stringByAppendingFormat:@"/service1.asmx/getEventTypeTwosABL?eventTypeID=%@", selectedEventTypeID]];
    
    
    NSString *xmlString = [[NSString alloc] initWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    //remove xmlns from the xml file 
    xmlString = [xmlString stringByReplacingOccurrencesOfString:@"xmlns" withString:@"noNSxml"];
    //NSLog(@"xml string: %@",xmlString);
    NSData *xmlData = [xmlString dataUsingEncoding:NSUTF8StringEncoding];
    DDXMLDocument *eventsDocument = [[DDXMLDocument alloc] initWithData:xmlData options:0 error:&error];
    if (error)
        return NO;
    
    NSArray* nodes = nil;
    nodes = [[eventsDocument rootElement] children];
    
    //ensure that the eventTypeArray is empty.
    [eventType2Array removeAllObjects];
    
    //add the item all to the item array
    [itemArray addObject:@"All"];
    
    for (DDXMLElement *element in nodes)
    { 
        //create a dictionary to hold the description and id
        NSDictionary *eventType2Dict = [[NSDictionary alloc] init];
        
        DDXMLElement *currentEventType2ID = [[element nodesForXPath:@"eventTypeID" error:nil]objectAtIndex:0];
        DDXMLElement *evtDescription = [[element nodesForXPath:@"evtDescription" error:nil]objectAtIndex:0];
        
        eventType2Dict = [NSDictionary dictionaryWithObject:currentEventType2ID.stringValue forKey:evtDescription.stringValue];
        
        //add the dictionary to the eventType array
        [eventType2Array addObject:eventType2Dict];
        //add the descriptions to the item array for the look up table view
        [itemArray addObject:evtDescription.stringValue];
    }
    
    //NSLog(@"array type 2 count: %d", [itemArray count]);
    return YES;
}


- (IBAction)clickSearch:(id)sender {
    
    //set up the date formatters
    NSDateFormatter *dfToDate = [[NSDateFormatter alloc] init];
    [dfToDate setDateStyle:NSDateFormatterShortStyle];
    NSDateFormatter *dfToString = [[NSDateFormatter alloc] init];
    [dfToString setDateFormat:@"yyyy-MM-dd"];
    
    //if both due date boundaries are set, check one the 'from' value is earlier than the 'to' value
    if (![cellDueDateFrom.detailTextLabel.text isEqualToString:@"All"] && ![cellDueDateTo.detailTextLabel.text isEqualToString:@"All"]) 
    {
        if([[dfToDate dateFromString:cellDueDateFrom.detailTextLabel.text] compare: [dfToDate dateFromString:cellDueDateTo.detailTextLabel.text]] == NSOrderedDescending)
        {
            [[[UIAlertView alloc] initWithTitle:@"Incorrect Due Date Boundaries" message:@"Due date 'from' must be earlier than due date 'to'" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2] atScrollPosition:UITableViewScrollPositionTop animated:YES];
            return;
        }
    }
    
    if (![cellCreatedDateFrom.detailTextLabel.text isEqualToString:@"All"] && ![cellCreatedDateTo.detailTextLabel.text isEqualToString:@"All"]) 
    {
        if([[dfToDate dateFromString:cellCreatedDateFrom.detailTextLabel.text] compare: [dfToDate dateFromString:cellCreatedDateTo.detailTextLabel.text]] == NSOrderedDescending)
        {
            [[[UIAlertView alloc] initWithTitle:@"Incorrect Created Date Boundaries" message:@"Created date 'from' must be earlier than created date 'to'" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3] atScrollPosition:UITableViewScrollPositionTop animated:YES];
            return;
        }
    }
    
        [self performSegueWithIdentifier:@"toEventsList" sender:self];

}

//hide the keyboard when the user clicks done
-(IBAction) textFieldDoneEditing:(id)sender{
    [sender resignFirstResponder];
}


@end
