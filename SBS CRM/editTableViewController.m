//
//  editTableViewConrtoller.m
//  SBS CRM 2.0
//
//  Created by Tom Couchman on 17/05/2012.
//  Copyright (c) 2012 Shuttleworth Business Systems Limited. All rights reserved.
//

#import "editTableViewController.h"
#import "format.h"
#import "AppDelegate.h"
#import "XMLParser.h"
#import "ContactSearch.h"
#import "CompanySearch.h"
#import "NSManagedObject+CoreDataManager.h"

#import "loadingSavingView.h"

@interface editTableViewController ()


// Keyboard toolbar
@property (strong, nonatomic) UIToolbar *keyboardToolBar;

//fetchXMLs
@property (nonatomic, strong) fetchXML *getContacts;
@property (nonatomic, strong) fetchXML *getOurContacts;
@property (nonatomic, strong) fetchXML *saveEvent;

// activity indicatory
@property (strong, nonatomic) UIActivityIndicatorView *refreshSpinner;

@property (strong, nonatomic) loadingSavingView *savingView;

// arrays to store items for use with the look up table.
@property (nonatomic, strong) NSMutableArray *lookUpItems;
@property (nonatomic, strong) NSArray *ContactArray;

@property (nonatomic, strong) UIAlertView *fetchXMLFailedAlert;

@property (nonatomic) float scrollPosition;


- (void)fillCells;

@end

@implementation editTableViewController

// ---- Synthesize -----

// cell / txt Outlets
@synthesize btnCancel;
@synthesize btnSave;
@synthesize txtTitle, cellDueDate, cellDueTime, cellEndDate, cellEndTime, cellContact, cellInternalContact;
// EventSearch proerty to hold event to be added
@synthesize eventToEdit, contact, internalContact, contactName, internalContactName;
// Keyboard toolbar
@synthesize keyboardToolBar;
//fetchXMLs
@synthesize saveEvent, getContacts, getOurContacts;
// arrays to store items for use with the look up table.
@synthesize lookUpItems, ContactArray;
// activity indicatory
@synthesize refreshSpinner, savingView;
// alert view for failed fetchXML;
@synthesize fetchXMLFailedAlert;
// save scroll position to reset when screen returns from lookup / picker views.
@synthesize scrollPosition;

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
    
    // Create toolbar for keyboard
    keyboardToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,0,self.view.bounds.size.width, 44)];
    keyboardToolBar.tintColor = [UIColor blackColor];
    UIBarButtonItem *extraSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(resignKeyboard:)];
    doneButton.style = UIBarButtonItemStyleDone;
    [keyboardToolBar setItems:[[NSArray alloc] initWithObjects:extraSpace,doneButton,nil]];
    // add keyboard to text field
    txtTitle.inputAccessoryView = keyboardToolBar;
    
    
    // prep refresh spinner
    refreshSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    refreshSpinner.frame = CGRectMake(self.view.bounds.size.width / 2 - 10, cellContact.bounds.size.height / 2 - 10, 20, 20);
    refreshSpinner.hidesWhenStopped = YES;
    
    fetchXMLFailedAlert = [[UIAlertView alloc] initWithTitle:@"Connection Error" message:@"Could not connect to the server" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    
    scrollPosition = 0;
    
    txtTitle.text = eventToEdit.eveTitle;
    [self fillCells];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tableView setContentOffset:CGPointMake(0, scrollPosition)];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    scrollPosition = self.tableView.contentOffset.y;
}

- (void)viewDidUnload
{
    [self setCellDueDate:nil];
    [self setCellDueTime:nil];
    [self setCellEndDate:nil];
    [self setCellEndTime:nil];
    [self setCellContact:nil];
    [self setCellInternalContact:nil];
    [self setTxtTitle:nil];
    [self setBtnCancel:nil];
    [self setBtnSave:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


// hide keyboard
- (void)resignKeyboard:(id)sender  {
    [txtTitle resignFirstResponder];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}


#pragma mark - Table view delegate


//------------------------------------------------------------------------
//                  Determine actions by selected cell
//------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 1: // Due date / time
            [self performSegueWithIdentifier:@"toDateTimePicker" sender:indexPath]; 
            break;
        case 2: // End date / time
            [self performSegueWithIdentifier:@"toDateTimePicker" sender:indexPath]; 
            break;
        case 3: // End date / time
            //if there is a company site ID search for contacts:
            if ([eventToEdit.companySiteID length] > 0)
            {
                //prep fetchXML.
                getContacts = [[fetchXML alloc] initWithUrl:[NSURL URLWithString:[appURL stringByAppendingFormat:@"/service1.asmx/searchContactsByCompanyABL?searchCompanySiteID=%@",eventToEdit.companySiteID]] delegate:self className:@"ContactSearch"];
                
                if (![getContacts fetchXML]) //if get dom fails at this point, display error
                    [fetchXMLFailedAlert show];
                else // else show network activity (in selected cell);
                    [cellContact addSubview:refreshSpinner]; [refreshSpinner startAnimating];
            }
            else 
                [[[UIAlertView alloc] initWithTitle:@"Please select a company" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
            break;
        case 4: // End date / time
            if (appCompanySiteID > 0)
            {
                //prep fetchXML
                getOurContacts = [[fetchXML alloc] initWithUrl:[NSURL URLWithString:[appURL stringByAppendingFormat:@"/service1.asmx/searchContactsByCompanyABL?searchCompanySiteID=%d",appCompanySiteID]] delegate:self className:@"ContactSearch"];
                
                if (![getOurContacts fetchXML]) //if get dom fails at this point, display error
                    [fetchXMLFailedAlert show]; 
                else // else show network activity (in selected cell);
                    [cellInternalContact addSubview:refreshSpinner]; [refreshSpinner startAnimating];
            }
            else 
                [[[UIAlertView alloc] initWithTitle:@"Internal Company not found" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
            break;
        default:
            break;
    }
    
}

//------------------------------------------------------------------------
//            Pass values to the destination view controller
//------------------------------------------------------------------------
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    NSIndexPath* indexPath = (NSIndexPath *)sender;
    
    if ([segue.identifier isEqualToString:@"toDateTimePicker"])
    {
        dateTimePickerViewController *dtpvc = segue.destinationViewController;
        dtpvc.delegate = self;
        dtpvc.sender = sender;
        
        switch (indexPath.section) {
            case 1: // due
                //customise based on the sender - set mode and currently selected date / time.
                if(indexPath.row == 0) // due date
                {
                    dtpvc.dateTime = eventToEdit.eveDueDate;
                    dtpvc.mode = UIDatePickerModeDate;
                }
                else { // due time
                    dtpvc.dateTime = [format dateFromSecondsSinceMidnight:[eventToEdit.eveDueTime integerValue]];
                    dtpvc.mode = UIDatePickerModeTime;
                }
                break;
            case 2: // end
                //customise based on the sender
                if(indexPath.row == 0) // end date
                {
                    dtpvc.dateTime = eventToEdit.eveEndDate;
                    dtpvc.mode = UIDatePickerModeDate;
                }
                else { // end time.
                    dtpvc.dateTime = [format dateFromSecondsSinceMidnight:[eventToEdit.eveEndTime integerValue]];
                    dtpvc.mode = UIDatePickerModeTime;
                }
                break;
        }
        
    }
    else if ([segue.identifier isEqualToString:@"toLookUpTableView"]){
        
        //set the required values for the look up view controller
        lookUpTableViewController *lutvc = segue.destinationViewController;
        lutvc.delegate = self; //set self as the delegate
        lutvc.itemArray = lookUpItems; // set the array of items
        
        switch (indexPath.section) {
            case 3: // contact
                lutvc.sourceCellIdentifier = [NSString stringWithFormat:@"%d%02d",indexPath.section, indexPath.row]; // identify by section
                lutvc.item = contactName;
                break;
            case 4: // internal contact
                lutvc.sourceCellIdentifier = [NSString stringWithFormat:@"%d%02d",indexPath.section, indexPath.row]; // identify by section
                lutvc.item = internalContactName;
                break;
        }
    }
    
}


// dismiss the view
- (IBAction)btnCancel_Click:(id)sender {
    //dismiss the view, does not cancel any fetchXML's as I don't want to interrupt events that are being saved. Also once, data is sent, the event is updated elsewhere, so cancelling would likely only stop confirmation or failure notification coming back.
    [self dismissModalViewControllerAnimated:YES];
}



//------------------------------------------------------------------------
//                      Save the event to database
//------------------------------------------------------------------------
- (IBAction)btnSave_Click:(id)sender {
    btnSave.enabled = false;
    btnCancel.enabled = false;

    [self saveEventToDatabase];
}

- (void)saveEventToDatabase{
     savingView = [[loadingSavingView alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 60, self.view.frame.size.height / 2 - 50, 120, 30) withMessage:@"Saving..."];
    
    [self.tableView addSubview:savingView];
    
    
    
    UIAlertView *domGetFailed = [[UIAlertView alloc] initWithTitle:@"Connection Error" message:@"Event Not Saved" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    
    eventToEdit.eveTitle = txtTitle.text;
    
    NSString *title = [eventToEdit.eveTitle stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSDateFormatter *dfToString = [[NSDateFormatter alloc] init];
    [dfToString setDateFormat:@"dd/MM/YYYY"];
    NSString *formattedDueDate = [dfToString stringFromDate:eventToEdit.eveDueDate];
    
    NSString *endDate;
    if (!eventToEdit.eveEndDate)
        endDate = @"";
    else endDate = [dfToString stringFromDate:eventToEdit.eveEndDate];
    
    saveEvent = [[fetchXML alloc] initWithUrl:[NSURL URLWithString:[appURL stringByAppendingFormat:@"/Service1.asmx/editEvent?eventId=%d&eveTitlestring=%@&dueDateString=%@&dueTime=%@&endDateString=%@&endTime=%@&contactID=%@&ourContactID=%@&userID=%d",[eventToEdit.eventID integerValue], title ?: @"", formattedDueDate ?: @"", eventToEdit.eveDueTime ?: @"-1",endDate ?: @"", eventToEdit.eveEndTime ?: @"-1",eventToEdit.contactID ?: @"", eventToEdit.ourContactID ?: @"", appUserID]] delegate:self className:@"NSNumber"];
    
    if (![saveEvent fetchXML])
    {[domGetFailed show]; return;}
}


//------------------------------------------------------------------------
//          Handle the data returned from the dateTimePickerView
//------------------------------------------------------------------------
- (void) dateTimePickerViewController: (dateTimePickerViewController *)controller didSelectDateTime:(NSDate *)returnedDate withSourceCellIdentifier:(NSString *)returnedSourceCellIdentifier withSender:(id)cellIndex 
{
    NSIndexPath *indexPath = (NSIndexPath *)cellIndex;
    
    //determine where to store the returned data, using the indexpath stored in the sender.
    switch (indexPath.section) {
        case 1:
            if (indexPath.row == 0)
                eventToEdit.eveDueDate = returnedDate;
            else
                eventToEdit.eveDueTime = [format secondsSinceMidnightFromDate:returnedDate];
            break;
        case 2:
            if (indexPath.row == 0)
                eventToEdit.eveEndDate = returnedDate;
            else
                eventToEdit.eveEndTime = [format secondsSinceMidnightFromDate:returnedDate];
            break;
    }
    
    
    
    // refill the cells with the updated information.
    [self fillCells];
}


- (void)lookUpTableViewController:(lookUpTableViewController *)controller didSelectItem:(NSInteger *)row withSourceCellIdentifier:(NSString *)sourceIdentifier
{
    
    NSLog(@"ident: %@ indent-int:%d",sourceIdentifier,[sourceIdentifier intValue]);
    // determine which cell called the lookUpTableView.
    switch ([sourceIdentifier intValue]) {
        case 300:
        {
            //retrieved the contact in the contact array that has been selected (by returned index)
            contact = [ContactArray objectAtIndex:(int)row];
            NSString *fullName = [format nameFromComponents:[NSMutableArray arrayWithObjects:contact.conTitle,contact.conFirstName, contact.conMiddleName, contact.conSurname, nil]];
            contactName = fullName;
            eventToEdit.contactID = [contact contactID];
            ContactArray = nil; // contacts no longer needed.
            break;
        }
        case 400:
        {
            internalContact = [ContactArray objectAtIndex:(int)row];
            NSString *fullName = [format nameFromComponents:[NSMutableArray arrayWithObjects:internalContact.conTitle,internalContact.conFirstName, internalContact.conMiddleName, internalContact.conSurname, nil]];
            internalContactName = fullName;
            eventToEdit.ourContactID = [internalContact contactID];
            ContactArray = nil; // contacts no longer needed.
            break;
        }
    }
    
    
    [self fillCells];
}




//------------------------------------------------------------------------
//             Handle the data returned from the server
//------------------------------------------------------------------------
- (void)docRecieved:(NSDictionary *)doc :(id)sender {
    // network activity has ended so stop refreshspinner
    [refreshSpinner stopAnimating];

    
    //retrieve the class key
    NSString *classKey = [doc objectForKey:@"ClassName"];
    //send it through to the xml parser to be places in classe indicated by class key.
    NSArray *Array = [[[XMLParser alloc] init]parseXMLDoc:[doc objectForKey:@"Document"] toClass:NSClassFromString(classKey)];
    lookUpItems = [[NSMutableArray alloc] init];
    
    if (sender == getContacts)
    {
        // store returned contacts in array
        ContactArray = [[NSArray alloc] initWithArray:Array];
        for (ContactSearch *con in Array) // loop through contact and concatenate name, add name to lookUpItems array (to be sent to look up view)
        {
            NSString *fullName = [format nameFromComponents:[NSMutableArray arrayWithObjects:con.conTitle,con.conFirstName, con.conMiddleName, con.conSurname, nil]];
            [lookUpItems addObject:fullName];
        }
        //segue to the look up view.
        [self performSegueWithIdentifier:@"toLookUpTableView" sender:[NSIndexPath indexPathForRow:0 inSection:3]];
        getContacts = nil;
    }
    else if (sender == getOurContacts)
    {
        // store returned contacts in array
        ContactArray = [[NSArray alloc] initWithArray:Array];
        for (ContactSearch *con in Array) // loop through contact and concatenate name, add name to lookUpItems array (to be sent to look up view)
        {
            NSString *fullName = [format nameFromComponents:[NSMutableArray arrayWithObjects:con.conTitle,con.conFirstName, con.conMiddleName, con.conSurname, nil]];
            [lookUpItems addObject:fullName];
        }
        //segue to the look up view.
        [self performSegueWithIdentifier:@"toLookUpTableView" sender:[NSIndexPath indexPathForRow:0 inSection:4]];
        getOurContacts = nil;
    }
    else if (sender == saveEvent)
    {
        [savingView removeFromSuperview];
        //if data recieved place it into
        int errorResponse = [(([Array count] > 0)? [Array objectAtIndex:0] : @"6") integerValue];
        
        if (errorResponse == 0) //if save successful
        {
            // set event to read via webservice
            NSURL *url = [NSURL URLWithString:[appURL stringByAppendingFormat:@"/Service1.asmx/setReadUnreadABL?readUnread=%@&eventID=%@&userID=%d",@"True", eventToEdit.eventID, appUserID]];
            
            fetchXML* setReadUnread = [[fetchXML alloc] initWithUrl:url delegate:self className:@"NSNumber"];
            
            if (![setReadUnread fetchXML])
                [[[UIAlertView alloc] initWithTitle:@"Connection Error" message:@"Could not connect to the server" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];   
            
            
            [self updateCoreDataEvent:eventToEdit];
            [self dismissModalViewControllerAnimated:YES];
        }
        else {
            
            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Error Saving Data" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            
            //set error message:
            switch (errorResponse) {
                case 1:
                    [errorAlert setMessage:@"Event Not Found"];
                    break;
                case 2:
                    [errorAlert setMessage:@"Event Locked"];
                    break;
                case 3:
                    [errorAlert setMessage:@"Event Has Been Altered"];
                    break;
                case 4:
                    [errorAlert setMessage:@"Error Connecting To Database"];
                    break;
                case 5:
                    [errorAlert setMessage:@"Incorrect Parameters"];
                    break;
                case 6:
                    [errorAlert setMessage:@"Error Saving Data"];
                    break;
                default:
                    break;
            }
            
            [errorAlert show];
            btnSave.enabled = true; //re-enable done button
            btnCancel.enabled = true;
        }
        
    }
}

- (void)fetchXMLError:(NSString *)errorResponse :(id)sender {
    
    if (sender == getContacts){
        getContacts = nil;
        [[[UIAlertView alloc] initWithTitle:@"Error Fetching Data" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }
    else if (sender == getOurContacts) {
        
    getOurContacts = nil;
    [[[UIAlertView alloc] initWithTitle:@"Error Fetching Data" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }
    else if (sender == saveEvent) {
        [savingView removeFromSuperview];
        btnSave.enabled = false;
        btnCancel.enabled = false;
        saveEvent = nil;
        [[[UIAlertView alloc] initWithTitle:@"Error Saving Data" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }
    [refreshSpinner stopAnimating];

    
}

//------------------------------------------------------------------------
//             Fill cells with their respective event data
//------------------------------------------------------------------------
- (void)fillCells {
    
    NSDateFormatter *dfToString;   
    dfToString = [[NSDateFormatter alloc] init];
    
    //check if properties exist - if yes, place in cell, else enter placeholder text.
    [dfToString setDateFormat:@"HH:mm"];
    // if time string is not null or empty string, then convert to date (from seconds since midnight) and then convert to formatted string for display
    cellEndTime.detailTextLabel.text = [eventToEdit.eveEndTime length] > 0 ? [dfToString stringFromDate:[format dateFromSecondsSinceMidnight:[eventToEdit.eveEndTime integerValue]]] : @"No End Time";
    cellDueTime.detailTextLabel.text = [eventToEdit.eveDueTime length] > 0 ? [dfToString stringFromDate:[format dateFromSecondsSinceMidnight:[eventToEdit.eveDueTime integerValue]]] : @"No Due Time";
    
    [dfToString setDateStyle:NSDateFormatterMediumStyle];
    cellEndDate.detailTextLabel.text = eventToEdit.eveEndDate != NULL ? [dfToString stringFromDate:eventToEdit.eveEndDate] : @"No End Date";
    cellDueDate.detailTextLabel.text = eventToEdit.eveDueDate != NULL ? [dfToString stringFromDate:eventToEdit.eveDueDate] : @"No Due Date";
    
    cellContact.textLabel.text = [contactName length] > 0 ? contactName : @"No Contact";
    cellInternalContact.textLabel.text = [internalContactName length] > 0 ? internalContactName : @"No Contact";
    
}


































- (BOOL)updateCoreDataEvent:(EventSearch *)EventToSave{
    
    
        
 
    
    // set a predicate to find the event that needs to be updated.
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"eventID == %@", eventToEdit.eventID];
    
    BOOL saved = [NSManagedObject updateCoreDataObject:EventToSave forEntityName:@"Event" withPredicate:predicate];
    
       [delegate getCoreData];
          [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadCoreData" object:nil];
    
    //[delegate getCoreData];
    
    return saved;
    /*
    // set a predicate to find the event that needs to be updated.
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"eventID == %@", eventToEdit.eventID];
    
    EventSearch *eventToUpdate = [[NSManagedObject fetchObjectsForEntityName:@"Event" withPredicate:predicate withSortDescriptors:nil] objectAtIndex:0];
    
    
    eventToUpdate.eveTitle = txtTitle.text;
    eventToUpdate.eveDueDate = EventToSave.eveDueDate;
    eventToUpdate.eveDueTime = EventToSave.eveDueTime;
    eventToUpdate.eveEndDate = EventToSave.eveEndDate;
    eventToUpdate.eveEndTime = EventToSave.eveEndTime;
    eventToUpdate.ourContactID = EventToSave.contactID;
    eventToUpdate.contactID = EventToSave.ourContactID;
    
    
    if (![context save:&error]) //if save fails show error
    {
        [[[UIAlertView alloc] initWithTitle:@"Error saving data to device" message:@"Refresh events table to see updated data" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        return NO;
    }
    
    //if the internal contact ID has changed, check to see if the contact is already saved in core data. If not save them.
    if (![EventToSave.ourContactID isEqualToString:internalContact.contactID])
    {
        entity = [NSEntityDescription entityForName:@"Contact" inManagedObjectContext:context];
        request = [[NSFetchRequest alloc] init];
        [request setEntity:entity];
        
        //find the event where the event ID matches that of the current event.
        predicate = [NSPredicate predicateWithFormat:@"contactID == %@", internalContact.contactID];
        [request setPredicate:predicate];
        NSError *error;
        
        // if the contact was not found, save them.
        if ([[context executeFetchRequest:request error:&error] count] == 0 && !error)
        {
            NSArray *Array = [[NSArray alloc] initWithObjects:internalContact, nil];
            [NSManagedObject storeInCoreData:Array forEntityName:@"Contact"];
        }
    }
    
    //if the external contact has changed, check to see if the contact is already saved in core data. If not save them.
    if (![EventToSave.contactID isEqualToString:contact.contactID])
    {
        entity = [NSEntityDescription entityForName:@"Contact" inManagedObjectContext:context];
        request = [[NSFetchRequest alloc] init];
        [request setEntity:entity];
        
        //find the event where the event ID matches that of the current event.
        predicate = [NSPredicate predicateWithFormat:@"contactID == %@", contact.contactID];
        [request setPredicate:predicate];
        NSError *error;
        
        // if the contact was not found, save them.
        if ([[context executeFetchRequest:request error:&error] count] == 0 && !error)
        {
            NSArray *Array = [[NSArray alloc] initWithObjects:contact, nil];
            [NSManagedObject storeInCoreData:Array forEntityName:@"Contact"];
        }
    }
    
    //if the event was not deleted update the data in the detail view
    [delegate getCoreData];
    
    // if the event is not a watched event and internal contact has changed the delete it,
    if (EventToSave.watched == [NSNumber numberWithInt:0] && ![EventToSave.ourContactID isEqualToString:internalContact.contactID])
    {
        
        [context deleteObject:eveToUpdate];
        
        if (![context save:&error]) //if save fails show error
        {
            [[[UIAlertView alloc] initWithTitle:@"Error loading data from device" message:@"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
            return;
        }
        //refresh the tableview on myevents screen.
        [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadCoreData" object:nil];
        
    }
    */
    
    /*
     //create a user info dictionary to store the evenId
     NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObject:EventToSave.eventID forKey:@"eventId"];
     //send notification to refresh the tableview on myevents screen.
     [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadEvent" object:self userInfo:userInfo];
     */
    
    
    
    
    
}



@end

