//
//  eventDetailsTableViewController.m
//  SBS CRM
//
//  Created by Tom Couchman on 15/02/2012.
//  Copyright (c) 2012 Shuttleworth Business Systems Limited. All rights reserved.
//

#import "eventDetailsTableViewController.h"
#import "textViewController.h"
#import "companyDetailsTableViewController.h"
#import "contactDetailsTableViewController.h"
#import "AppDelegate.h"
#import "Attachment.h"
#import "DDXML.h"
#import "documentViewController.h"

#import "XMLParser.h"
#import "Event.h"

#import "format.h"
#import "CoreDataManager.h"
#import "convert.h"

#import "Reachability.h"

#import "loadingSavingView.h"


//private interface:
@interface eventDetailsTableViewController()
{
    

}
- (void)getCoreData;
- (void)getDataFromServer;
- (void)refreshTableView;
- (void)markAsReadUnread:(BOOL)currentState;
- (void)setStatus:(int)currentStatus;



@property (nonatomic, retain) UIActivityIndicatorView *refreshSpinner;
@property (nonatomic, retain) loadingSavingView *loadingView;


//declare the fetchXMLs, to allow canceling and identification
@property (nonatomic, retain) fetchXML *getEventsDom;
@property (nonatomic, retain) fetchXML *getContactsDom;
@property (nonatomic, retain) fetchXML *getOurContactsDom;
@property (nonatomic, retain) fetchXML *getAttachmentsDom;
@property (nonatomic, retain) fetchXML *getCompanyDoc;
@property (nonatomic, retain) fetchXML *setReadUnread;
@property (nonatomic, retain) fetchXML *setStatus;

@end

@implementation eventDetailsTableViewController
@synthesize viewEventDetail;

//event stored in core?
@synthesize isCoreData;

//event data:
@synthesize eventDetails;
@synthesize company;
@synthesize contact;
@synthesize ourContact;

//cells outlets:
@synthesize lblTitle;
@synthesize lblType;
@synthesize lblCustomer;
@synthesize lblDueDateTime;
@synthesize lblEndDateTime;
@synthesize cellLblSite;
@synthesize cellLblContact;
@synthesize txtComments;
@synthesize cellLblCreateByName;
@synthesize cellLblCreateByDateTime;
@synthesize cellLblOurContact;
@synthesize cellComments;
@synthesize cellCommentLink;

//refresh spinners
@synthesize refreshSpinner;
@synthesize loadingView;

//fetchXMLs
@synthesize getEventsDom, getContactsDom, getOurContactsDom, getAttachmentsDom, getCompanyDoc, setReadUnread, setStatus;

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

-(void)test{
    
    [[[UIAlertView alloc] initWithTitle:@"test" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
}

- (void)viewDidLoad
{
    

    
    [super viewDidLoad];
    
    //listen for the reloadEvent command when the user logs out.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadUpdatedEvent:) 
                                                 name:@"reloadEvent"
                                               object:nil];
    
    refreshSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    refreshSpinner.frame = CGRectMake(cellLblOurContact.frame.size.width / 2 - 10, cellLblOurContact.frame.size.height / 2 - 10, 20, 20);
    refreshSpinner.hidesWhenStopped = YES;
    
    
    loadingView = [[loadingSavingView alloc] initWithFrame:CGRectMake(viewEventDetail.frame.size.width / 2 - 60, viewEventDetail.frame.size.height / 2, 120, 30) withMessage:@"Loading..."];
    
    
    
    
    attachmentArray = [[NSMutableArray alloc] init];
    

    [self loadEvent];
    
    //if the event had not preiviously been read then, mark it as read.
    if (isCoreData && ![[NSNumber numberWithInt:eventDetails.readEvent] boolValue]) [self markAsReadUnread:![[NSNumber numberWithInt:eventDetails.readEvent] boolValue]];
    
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    //self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
    
-(void)loadEvent{
    
    //Create an alert to display if the data cannot be loaded
    UIAlertView *domGetFailed = [[UIAlertView alloc] initWithTitle:@"Connection Error" message:@"Could not connect to the server" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    
    //if the required event details is stored within core data
    if (isCoreData)
    {
        NSLog(@"event contact: %@",eventDetails.contactID);
        [self getCoreData];
    }
    else // load the data from the web
    {
        self.tableView.canCancelContentTouches = YES;
        
        NSLog(@"company: %@", company.coaCompanyName);
        
        //if the event is nothing more than an event id/number (occurs when the event is linked to from a url or a new event is added etc.)
        // then the event details must be retrieved before any others.
        if (eventDetails.eveCreatedDate == NULL)
        {
            //add a refresh spinner as a subview to indicate network activity.
            [viewEventDetail addSubview:loadingView];
            
            getEventsDom = [[fetchXML alloc] initWithUrl:nil delegate:self className:@"EventSearch"];
            if (eventDetails.eventID != NULL)
            {
                getEventsDom.url = [NSURL URLWithString:[appURL stringByAppendingFormat:@"/service1.asmx/searchEventsByEventIDABL?eventID=%@",eventDetails.eventID]];
                if (![getEventsDom fetchXML]) {[domGetFailed show]; return;}
            }
            else if (eventDetails.eveNumber != NULL)
            {
                getEventsDom.url = [NSURL URLWithString:[appURL stringByAppendingFormat:@"/service1.asmx/searchEventsByEventNumberABL?eventNumberString=%@",eventDetails.eveNumber]];
                if (![getEventsDom fetchXML]) {[domGetFailed show]; return;}
            }
            
        }
        else //get the remaining data:        
            [self getDataFromServer];
        
        
        
        
    }
    

    
}

// get Details
-(void)getDataFromServer{
    
    [viewEventDetail addSubview:loadingView];
    
    UIAlertView *domGetFailed = [[UIAlertView alloc] initWithTitle:@"Connection Error" message:@"Could not connect to the server" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    
    NSURL *url = [NSURL URLWithString:[appURL stringByAppendingFormat:@"/service1.asmx/searchContactsByContactIDABL?searchContactID=%@",eventDetails.contactID]];
    
    getContactsDom = [[fetchXML alloc] initWithUrl:url delegate:self className:@"ContactSearch"];

    if (![getContactsDom fetchXML])
    {[domGetFailed show]; return;}
    
    if (!contact){ //if there is no contact stored, then attachments will also need to be retrieved from the server.   
        
        NSURL *url = [NSURL URLWithString:[appURL stringByAppendingFormat:@"/service1.asmx/searchAttachmentsByEventIDABL?eventID=%@",eventDetails.eventID]];
        
        getAttachmentsDom = [[fetchXML alloc] initWithUrl:url delegate:self className: @"Attachment"];
        if (![getAttachmentsDom fetchXML])
        {[domGetFailed show]; return;}
    }
    
    
    // our contact will need to be retrieved whether the event is core or not - but not if there is no id
    if (eventDetails.ourContactID != NULL)
    {
        
        //add a refresh spinner as a subview to indicate network activity.
        [cellLblOurContact addSubview:refreshSpinner];
        [refreshSpinner startAnimating];
        
        NSURL *url = [NSURL URLWithString:[appURL stringByAppendingFormat:@"/service1.asmx/searchContactsByContactIDABL?searchContactID=%@",eventDetails.ourContactID]];
        
        getOurContactsDom = [[fetchXML alloc] initWithUrl:url delegate:self className:@"ContactSearch"];

        if (![getOurContactsDom fetchXML])
        {[domGetFailed show]; return;}
    }
    
    if (!company)
    {
        //add a refresh spinner as a subview to indicate network activity.
        [cellLblSite addSubview:refreshSpinner];
        [refreshSpinner startAnimating];
        getCompanyDoc = [[fetchXML alloc] initWithUrl:[NSURL URLWithString:[appURL stringByAppendingFormat:@"/service1.asmx/searchCompaniesByCompanySiteIDABL?companySiteID=%@",eventDetails.companySiteID]] delegate:self className:@"CompanySearch"];
        //getCompanyDoc.delegate = self;
        //getCompanyDoc.className = @"CompanySearch";
        if (![getCompanyDoc fetchXML])
        { [domGetFailed show]; return; }
    }
}

- (void)reloadUpdatedEvent:(NSNotification *)notification{
    if ([[notification.userInfo objectForKey:@"eventId"] isEqualToString:eventDetails.eventID]) //potentially more than one event details view, so need to ensure this is the correct one.
    {
        if (isCoreData)
            [self getCoreData];
        else 
        {
            eventDetails.eveCreatedDate = nil;
            [self loadEvent];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.title == @"No event" || alertView.title == @"Core data") //when there is no data and the user clicks ok, dissmiss the view controller.
        [self.navigationController performSelector:@selector(popViewControllerAnimated:) withObject:@"YES" afterDelay:0.2];
}



- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // check for internet connection
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNetworkStatus:) name:kReachabilityChangedNotification object:nil];
    
    internetReachable = [Reachability reachabilityForInternetConnection];
    [internetReachable startNotifier];
    
    NSLog(@"%@", [appURL stringByReplacingOccurrencesOfString:@"http://" withString:@""]);
    // check if a pathway to a random host exists
    hostReachable = [Reachability reachabilityWithHostName: [appURL stringByReplacingOccurrencesOfString:@"http://" withString:@""]];
    [hostReachable startNotifier];

}
    

//###############################################
//#                                             #
//#                                             #
//#              Data Fetching:                 #
//#                                             #
//#                                             #
//###############################################
    
    //#######################################
    //#                                     #
    //#            CORE DATA:               #
    //#                                     #
    //#######################################
    
    
- (void)getCoreData{

        NSError *error = nil;
        
        //####### Get Event from Core Data ######
        
        // set a predicate to return the event that matches the eventID
        NSPredicate *predicate;

        if (eventDetails.eventID != NULL)
            predicate = [NSPredicate predicateWithFormat:@"eventID == %@", eventDetails.eventID];
        else if (eventDetails.eveNumber != NULL)
            predicate = [NSPredicate predicateWithFormat:@"eveNumber == %@", eventDetails.eveNumber];
        else {
            [[[UIAlertView alloc] initWithTitle:@"No event ID or number found" message:@"Cannot display event details" delegate:self cancelButtonTitle:@"No" otherButtonTitles:nil, nil] show];
            return;
        }
    
    // hold the result in an array
    NSArray *eventsArray = [NSManagedObject fetchObjectsForEntityName:@"Event" withPredicate:predicate withSortDescriptors:nil];
        if ([eventsArray count] > 0) //if the search was successful, store the event.
            eventDetails = [convert EventSearchFromEvent:[eventsArray objectAtIndex:0]];
        else { // else inform user the event was not found
            [[[UIAlertView alloc] initWithTitle:@"No event data" message:@"Cannot display event details" delegate:self cancelButtonTitle:@"No" otherButtonTitles:nil, nil] show];
            return;
        }
    
  
        //####### Get Event from Core Data ######
        // set a predicate to return the company that matches the companySiteID of the event.
        predicate = [NSPredicate predicateWithFormat:@"companySiteID == %@", eventDetails.companySiteID];
        
        // hold the result in an array
        NSArray *companyArray = [NSManagedObject fetchObjectsForEntityName:@"Company" withPredicate:predicate withSortDescriptors:nil];
        if ([companyArray count] > 0) // check that there is a company in the array before accessing it
            company = [companyArray objectAtIndex:0];
        else {
            company.cosSiteName = @"No company"; company.cosDescription = @"Can't display details.";
        }
        
        //####### Get Contact from Core Data ######
        // set a predicate to return the contact that matches the contactID of the event.
        predicate = [NSPredicate predicateWithFormat:@"contactID == %@", eventDetails.contactID];
        NSLog(@"predicate con: %@    site: %@", eventDetails.contactID, eventDetails.companySiteID);
        // hold the result in an array
        NSArray *contactArray = [NSManagedObject fetchObjectsForEntityName:@"Contact" withPredicate:predicate withSortDescriptors:nil];
        if ([contactArray count] > 0) // check that there is a contact in the array before accessing it
            contact = [contactArray objectAtIndex:0];
        else
        {
            contact = [[ContactSearch alloc] init];
            contact.conTitle = @"No Contact";
            NSLog(@"contitle: %@", contact.conTitle);
        }
        //####### Get Attachments from Core Data ######       
        predicate = [NSPredicate predicateWithFormat: @"eventID == %@", eventDetails.eventID];
        // hold the result in an array;
        attachmentArray = [NSArray arrayWithArray:[NSManagedObject fetchObjectsForEntityName:@"Attachment" withPredicate:predicate withSortDescriptors:nil]];
        

        //####### Get internal Contact from Core Data ######
        // set a predicate to return the contact that matches the contactID of the event.
        predicate = [NSPredicate predicateWithFormat:@"contactID == %@ AND companySiteID == %d", eventDetails.ourContactID, appCompanySiteID];
        
        // hold the result in an array
        NSArray *OurContactArray = [NSArray arrayWithArray:[NSManagedObject fetchObjectsForEntityName:@"Contact" withPredicate:predicate withSortDescriptors:nil]];
        if ([OurContactArray count] >0) // check that there is a contact in the array before accessing it
             ourContact = [OurContactArray objectAtIndex:0];
        else
        {
            ourContact = [[ContactSearch alloc] init];
            ourContact.conTitle = @"No Contact";
        }

        if (error)
        {
            [[[UIAlertView alloc] initWithTitle:@"Core Data" message:@"Cannot load event from core data" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        }
        NSLog(@"due time: %@", eventDetails.eveDueTime);
    [self refreshTableView];
 

}


//#######################################
//#                                     #
//#            DATA FETCH:              #
//#                                     #
//#######################################


-(void)fetchXMLError:(NSString *)errorResponse:(id)sender{
    
    if (self.view.window) // don't display if this view is not active. TODO:make sure this method is never event called!
    {
        // If error recieved, display alert.
        [[[UIAlertView alloc] initWithTitle:@"Error Fetching Data" message:errorResponse delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }
    
    if (sender == getEventsDom)
    {
        [self dismissModalViewControllerAnimated:YES];
    }
    if (sender == getOurContactsDom)
    {
        ourContact = [[ContactSearch alloc] init]; 
        ourContact.conTitle = @"Unavailable";
        
        cellLblOurContact.userInteractionEnabled = true;
        [self refreshTableView];
    }
    else if (sender == getContactsDom)
    {
        [loadingView removeFromSuperview];
        contact = [[ContactSearch alloc] init]; 
        contact.conTitle = @"No contact";
        [self refreshTableView];
    }
    else if(sender == getCompanyDoc)
    {
        [loadingView removeFromSuperview];
        cellLblSite.textLabel.text = @"Company Site Unavailable";
        [self refreshTableView];
    }
    
    [loadingView removeFromSuperview];
    
}

-(void)docRecieved:(NSDictionary *)docDic:(id)sender{
    //parse the data, idenifying it's type using the returned class key:
    NSString *classKey = [docDic objectForKey:@"ClassName"];
    NSArray *Array = [[[XMLParser alloc] init]parseXMLDoc:[docDic objectForKey:@"Document"] toClass:NSClassFromString(classKey)];
    
    //identify the doc by the sender
    if (sender == getEventsDom)
    {

        [loadingView removeFromSuperview];
        
        if([Array count] > 0)
        {
            eventDetails = [Array objectAtIndex:0];
            [self getDataFromServer];
        }
        else
        {
            
            [[[UIAlertView alloc] initWithTitle:@"Event Not Found" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
            [self dismissModalViewControllerAnimated:YES];
        }  
        
    }
    else if (sender == getOurContactsDom)
    {
        //data load is over so enable cell.
        cellLblOurContact.userInteractionEnabled = true;
        [refreshSpinner removeFromSuperview];
        if([Array count] > 0)
            ourContact = [Array objectAtIndex:0]; // if contact found store in ourContact
        else
        { //if no contact was returned mark contact as unavailable.
            ourContact = [[ContactSearch alloc] init]; 
            ourContact.conTitle = @"Unavailable";   
            [self refreshTableView];
        }
        getOurContactsDom = nil; // no longer
    }
    else if (sender == getContactsDom)
    {
        [loadingView removeFromSuperview];
        if([Array count] > 0)
            contact = [Array objectAtIndex:0];
        else contact.conTitle = @"No contact";
    }
    else if (sender == getAttachmentsDom)
        attachmentArray = [NSMutableArray arrayWithArray:Array];
    else if (sender == setReadUnread && [Array count] > 0)
    {
        if ([[Array objectAtIndex:0] isEqualToString:@"0"]) // if a zero is returned then the update was successful:
        {
            //save the updated details to core data:
            
            //find the event where the event ID matches that of the current event.
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"eventID == %@", eventDetails.eventID];
            /////// [request setPredicate:predicate];
            
            Event* eveToUpdate = [[NSManagedObject fetchObjectsForEntityName:@"Event" withPredicate:predicate withSortDescriptors:nil] lastObject];

            //swap the read value to its opposite, and also update the current event being displayed.
            eveToUpdate.readEvent = (eventDetails.readEvent == 0)? 1 : 0;
            eventDetails.readEvent = eveToUpdate.readEvent;

            if (![NSManagedObject updateCoreDataObject:eveToUpdate forEntityName:@"Event" withPredicate:predicate])
            {
                [[[UIAlertView alloc] initWithTitle:@"Error saving data to device" message:@"Refresh events view to see updated data" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show]; 
            }
            
            //refresh the tableview on myevents screen.
            [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadCoreData" object:nil];
        }
        else
            [[[UIAlertView alloc] initWithTitle:@"Could not update event" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }
    else if (sender == setStatus && [Array count] > 0)
    {
        
        switch ([[Array objectAtIndex:0] intValue]) {
            case 0:
            {
                eventDetails.eveStatus = [NSString stringWithFormat:@"%d", 0];
                
                NSLog(@"%d - %d",appContactID ,[eventDetails.ourContactID intValue]);
                
                //if user is internal contact save the event in core data
                if (appContactID == [eventDetails.ourContactID intValue])
                {
                    //reload data from server to retrieve the event (needed to get company contacts, etc.)
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"getCoreData" object:nil];
                }
                break;
            }
            case 9:
            {
                eventDetails.eveStatus = [NSString stringWithFormat:@"%d", 9];
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"eventID == %@", eventDetails.eventID];            
                if (![NSManagedObject deleteObjectsForEntityName:@"Event" withPredicate:predicate])
                    [[[UIAlertView alloc] initWithTitle:@"Error loading data from device" message:@"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
                
                //refresh the tableview on myevents screen.
                [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadEventData" object:nil];
                
                [self.navigationController popViewControllerAnimated:YES];
                break;
            }
            case -1:
            {
                [[[UIAlertView alloc] initWithTitle:@"Could not update event" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
                break;
            }
        }
         
    }
    else if(sender == getCompanyDoc)
    {
        [refreshSpinner removeFromSuperview];
        if ([Array count] > 0)
            company = [Array objectAtIndex:0];
    }

    [self refreshTableView];
}



- (void)refreshTableView{
    
    //###### put the data into the cells. ######
    
    lblTitle.text = [@"EN" stringByAppendingFormat:[eventDetails.eveNumber stringByAppendingFormat:@" - %@",eventDetails.eveTitle]];
    lblType.text = [eventDetails.eventType stringByAppendingFormat:@" - %@", eventDetails.eventType2];
    
    if (contact.contactID) {
        // concatenate full name from the available components
        NSMutableArray *nameArray = [NSMutableArray arrayWithObjects:contact.conTitle,contact.conFirstName,contact.conMiddleName,contact.conSurname, nil];
        [nameArray removeObject:@""];
        lblCustomer.text = [nameArray componentsJoinedByString:@" "];
    }
    else
        lblCustomer.text = @"No contact";
    
    
    //Format the dates and times
    NSDateFormatter *dfToString = [[NSDateFormatter alloc] init];
    [dfToString setDateStyle:NSDateFormatterMediumStyle];
    NSDateFormatter *dfToDate = [[NSDateFormatter alloc] init];
    [dfToDate setDateFormat:@"dd/MM/yyyy HH:mm:ss"];
    
    //if date is not set to '0' and is not the first of jan 9999 (our default for no date set) then display
    if ([[dfToString stringFromDate:eventDetails.eveDueDate] length] > 1 && ![eventDetails.eveDueDate isEqualToDate:[dfToDate dateFromString:@"01/01/9999 00:00:00"]]) {
        lblDueDateTime.text = [[dfToString stringFromDate:eventDetails.eveDueDate] stringByAppendingFormat:@" - %@",[format timeStringFromSecondsSinceMidnight:[eventDetails.eveDueTime integerValue]]];
    }
    else
        lblDueDateTime.text = @"No Due Date";
    
    // if the end date is present and is not set to '0'
    if ([[dfToString stringFromDate:eventDetails.eveEndDate] length] > 1 ){
        //convert enddate to date and back for formatting.
        lblEndDateTime.text = [[dfToString stringFromDate:eventDetails.eveEndDate] stringByAppendingFormat:@" - %@",[format timeStringFromSecondsSinceMidnight:[eventDetails.eveEndTime intValue]]];
    }
    else
        lblEndDateTime.text = @"No End Date";
    
    
    if ([eventDetails.eveCreatedTime length] > 0)
    {
        // format string to include both date and time. For the date convert it to a date and then convert it back to get the required formatting
        NSString *createdDateString = [dfToString stringFromDate:eventDetails.eveCreatedDate];
        cellLblCreateByDateTime.textLabel.text = [createdDateString stringByAppendingFormat:@" - %@",[format timeStringFromSecondsSinceMidnight:[eventDetails.eveCreatedTime integerValue]]];
    }
    
    cellLblCreateByName.textLabel.text = eventDetails.eveCreatedBy;
    
    cellLblSite.detailTextLabel.text = [company.cosSiteName stringByAppendingFormat:@" - %@",company.cosDescription];
    cellLblContact.detailTextLabel.text = lblCustomer.text;
    
    txtComments.text = eventDetails.eveComments;
    
    //if our contact id exists set the contact name into the cell
    if (eventDetails.ourContactID != NULL)
    {
        //create a name string using all of the name data available for the contact
        NSMutableArray *nameArray = [NSMutableArray arrayWithObjects:ourContact.conTitle,ourContact.conFirstName,ourContact.conMiddleName,ourContact.conSurname, nil];
        [nameArray removeObject:@""];
        NSLog(@"contact: %@", [nameArray componentsJoinedByString:@" "]);
        cellLblOurContact.textLabel.text = [nameArray componentsJoinedByString:@" "]; //display the concatenated name in the cell.
    }
    else {
        cellLblOurContact.textLabel.text = @"No Internal Contact";
    }
    
    [self.tableView reloadData];
}

- (void)viewDidUnload
{
    [self setLblCustomer:nil];
    [self setLblDueDateTime:nil];
    [self setLblEndDateTime:nil];
    [self setCellLblSite:nil];
    [self setCellLblContact:nil];
    [self setTxtComments:nil];
    [self setCellLblCreateByName:nil];
    [self setCellLblCreateByDateTime:nil];
    [self setCellLblOurContact:nil];
    [self setCellComments:nil];
    [self setCellCommentLink:nil];
    [self setViewEventDetail:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([attachmentArray count] > 0)
        return 5;
    else
        return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 2;
            break;
        case 1:
            return 2;
            break;
        case 2:
            return 1;
            break;
        case 3:
            return 2;
            break;
        case 4:
            if ([attachmentArray count] <= 10)
                return [attachmentArray count];
            else
                return 10;
            break;
        default:
            return 1;
            break;
    }
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    switch (indexPath.section)
    {
        case 0:
        {
            if (indexPath.row == 0)
                return cellLblSite;
            else
                return cellLblContact;
            break;
        }
        case 1:
        {
            if (indexPath.row == 0)
                return cellComments;
            else
                return cellCommentLink;
            break;
        }
        case 2:
        {
            return cellLblOurContact;
            break;
        }
        case 3:
        {
            if (indexPath.row == 0)
                return cellLblCreateByName;
            else
                return cellLblCreateByDateTime;
            break;
        }
        case 4:
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            if ([attachmentArray count] >= indexPath.row) // ensure that the attachment exists
            {
                Attachment *attachment = [attachmentArray objectAtIndex:indexPath.row];
                if([attachment.atyMnemonic isEqualToString:@"mis"])
                    cell.imageView.image = [UIImage imageNamed:@"mis.jpg"];
                else if([attachment.atyMnemonic isEqualToString:@"xls"])
                    cell.imageView.image = [UIImage imageNamed:@"xls.gif"];
                else if([attachment.atyMnemonic isEqualToString:@"doc"])
                    cell.imageView.image = [UIImage imageNamed:@"doc.gif"];
                else if([attachment.atyMnemonic isEqualToString:@"pop"])
                    cell.imageView.image = [UIImage imageNamed:@"pop.gif"];
                else if([attachment.atyMnemonic isEqualToString:@"pdf"])
                    cell.imageView.image = [UIImage imageNamed:@"pdf.png"];
                else if([attachment.atyMnemonic isEqualToString:@"txt"])
                    cell.imageView.image = [UIImage imageNamed:@"mis.jpg"];
                cell.textLabel.text = attachment.attDescription;
                return cell;
            }
            else
                return nil;
            break;
        }
        default:
            return cellLblSite;
            break;
    }
    
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    
    //find the cell that has been clicked.
    if (indexPath.section == 0 && indexPath.row == 0)
    {
        if (company.companySiteID)
        [self performSegueWithIdentifier:@"toCompanyDetails" sender:self];
        else
        {
            [[[UIAlertView alloc] initWithTitle:@"No Company" message:@"Company details unavailable" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        }
    }
    else if (indexPath.section == 0 && indexPath.row == 1)
    {
        if (contact.contactID)
            [self performSegueWithIdentifier:@"toContactDetails" sender:self];
        else
        {
            [[[UIAlertView alloc] initWithTitle:@"No Contact" message:@"Contact details unavailable" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        }
    }
    else if (indexPath.section == 2)
    {
        if (eventDetails.ourContactID == NULL)
        {
            [[[UIAlertView alloc] initWithTitle:@"No Contact" message:@"Contact details unavailable" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        }
        else if (ourContact.contactID)
        {
            [self performSegueWithIdentifier:@"toOurContactDetails" sender:self];
        }
    }
    else if (indexPath.section == 4)
    {
        //if (internetActive)
        //{
            if (YES) //if  (internetActive)
                [self performSegueWithIdentifier:@"toDocument" sender:self];
            else {
                UIAlertView *noInternetConnection = [[UIAlertView alloc] initWithTitle:@"Could not connect to server" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [noInternetConnection show];
                [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow]  animated:YES];
            }
        //}
        //else {
        //    UIAlertView *noInternetConnection = [[UIAlertView alloc] initWithTitle:@"No Internet Connection" message:@"Please connect and try again" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            //[noInternetConnection show];
           // [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow]  animated:YES];
        //}
        
    }
    
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //if the segue is to the details screen
    if ([segue.identifier isEqualToString:@"toComments"])
    {
        textViewController *textViewController = segue.destinationViewController;
        textViewController.eventId = eventDetails.eventID; //send through the event id incase the user wishes to edit it.
        textViewController.text= eventDetails.eveComments;
        textViewController.editable = [eventDetails.eveStatus isEqualToString:@"0"] ? YES : NO; // if event is open set editable true, else false
    }
    else if([segue.identifier isEqualToString:@"toCompanyDetails"])
    {
            companyDetailsTableViewController *detailsViewController = segue.destinationViewController;
            detailsViewController.companyDetail = company;
    }
    else if([segue.identifier isEqualToString:@"toContactDetails"])
    {
        contactDetailsTableViewController *detailsViewController = segue.destinationViewController;
        detailsViewController.contactDetail = contact;
        detailsViewController.company = company;
        detailsViewController.isCoreData = isCoreData;
    }
    else if([segue.identifier isEqualToString:@"toOurContactDetails"])
    {
        contactDetailsTableViewController *detailsViewController = segue.destinationViewController;
        detailsViewController.contactDetail = ourContact;
        detailsViewController.isCoreData = isCoreData;
    }
    else if([segue.identifier isEqualToString:@"toDocument"])
    {
        //get the index of the selected attachment
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        documentViewController *documentViewController = segue.destinationViewController;
        documentViewController.eventID = eventDetails.eventID;
        documentViewController.attOriginalFilename = [[attachmentArray objectAtIndex:indexPath.row] attOriginalFilename];
        documentViewController.attachmentID = [[attachmentArray objectAtIndex:indexPath.row] attachmentID];
        documentViewController.atyMnemonic = [[attachmentArray objectAtIndex:indexPath.row] atyMnemonic];
    }
    else if([segue.identifier isEqualToString:@"toEdit"])
    {   
        editTableViewConrtoller *etvc = segue.destinationViewController;
        etvc.delegate = self;
        
        etvc.eventToEdit = [eventDetails copy];
        
        etvc.contact = contact;
        etvc.internalContact = ourContact;
        
        etvc.internalContactName = [format nameFromComponents:[NSMutableArray arrayWithObjects:ourContact.conTitle,ourContact.conFirstName, ourContact.conMiddleName, ourContact.conSurname, nil]];
        etvc.contactName = [format nameFromComponents:[NSMutableArray arrayWithObjects:contact.conTitle,contact.conFirstName, contact.conMiddleName, contact.conSurname, nil]];;
        
    }

}
- (IBAction)btnActions_Click:(id)sender {
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];

    
    if ([eventDetails.eveStatus isEqualToString:@"0"])
        [actionSheet addButtonWithTitle:@"Edit Event"];
    

    
    //TODO: create a list of my events (+read or unread), and my watched events to compare to?
    if (isCoreData)
    {
        //if the event is read:
        if (eventDetails.readEvent == 1)
            [actionSheet addButtonWithTitle:@"Mark as Unread"];
        else //if the event is unread - this will only be the case when the user has previously clicked mark as unread.
            [actionSheet addButtonWithTitle:@"Mark as Read"];
    }

    
    if ([eventDetails.eveStatus isEqualToString:@"0"])
        [actionSheet addButtonWithTitle:@"Close Event"];
    else {
        [actionSheet addButtonWithTitle:@"Open Event"];
    }
    actionSheet.destructiveButtonIndex = actionSheet.numberOfButtons - 1;
    
    [actionSheet addButtonWithTitle:@"Cancel"];
    actionSheet.cancelButtonIndex = actionSheet.numberOfButtons - 1;
    
    
    
    [actionSheet showFromTabBar:self.tabBarController.tabBar];
}




-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    // identifying clicked button by title, because buttons are not always the same and so indexes are not fixed.
    
    NSString *clickedButton = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    if ([clickedButton isEqualToString:@"Mark as Unread"] || [clickedButton isEqualToString:@"Mark as Read"] )
        [self markAsReadUnread:![[NSNumber numberWithInt:eventDetails.readEvent] boolValue]];
    else if ([clickedButton isEqualToString:@"Close Event"] || [clickedButton isEqualToString:@"Open Event"] )
        [self setStatus:[eventDetails.eveStatus intValue] ? 0 : 9];
    else if ([clickedButton isEqualToString:@"Edit Event"])
    {
        [self performSegueWithIdentifier:@"toEdit" sender:self];
    }
    
}


- (void)markAsReadUnread:(BOOL)newStatus{
    NSURL *url = [NSURL URLWithString:[appURL stringByAppendingFormat:@"/Service1.asmx/setReadUnreadABL?readUnread=%@&eventID=%@&userID=%d", newStatus?@"True":@"False", eventDetails.eventID, appUserID]];
    
    setReadUnread = [[fetchXML alloc] initWithUrl:url delegate:self className:@"NSNumber"];
    
    if (![setReadUnread fetchXML])
        [[[UIAlertView alloc] initWithTitle:@"Connection Error" message:@"Could not connect to the server" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];            
}

- (void)setStatus:(int)newStatus{    
    NSURL *url = [NSURL URLWithString:[appURL stringByAppendingFormat:@"/Service1.asmx/setStatus?status=%d&eventID=%@&userID=%d", newStatus, eventDetails.eventID,appUserID]];
    
    setStatus = [[fetchXML alloc] initWithUrl:url delegate:self className:@"NSNumber"];
    
    if (![setStatus fetchXML])
        [[[UIAlertView alloc] initWithTitle:@"Connection Error" message:@"Could not connect to the server" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
}




-(void) checkNetworkStatus:(NSNotification *)notice
{
    // called after network status changes
    NetworkStatus internetStatus = [internetReachable currentReachabilityStatus];
    switch (internetStatus)
    {
        case NotReachable:
        {
            NSLog(@"The internet is down.");
            internetActive = NO;
            
            break;
        }
        case ReachableViaWiFi:
        {
            NSLog(@"The internet is working via WIFI.");
            internetActive = YES;
            
            break;
        }
        case ReachableViaWWAN:
        {
            NSLog(@"The internet is working via WWAN.");
            internetActive = YES;
            
            break;
        }
    }
    
    NetworkStatus hostStatus = [hostReachable currentReachabilityStatus];
    switch (hostStatus)
    {
        case NotReachable:
        {
            NSLog(@"A gateway to the host server is down.");
            hostActive = NO;
            
            break;
        }
        case ReachableViaWiFi:
        {
            NSLog(@"A gateway to the host server is working via WIFI.");
            hostActive = YES;
            
            break;
        }
        case ReachableViaWWAN:
        {
            NSLog(@"A gateway to the host server is working via WWAN.");
            hostActive = YES;
            
            break;
        }
    }
}

@end
