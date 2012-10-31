//
//  addEventViewCotroller.m
//  SBS CRM 2.0
//
//  Created by Tom Couchman on 30/05/2012.
//  Copyright (c) 2012 Shuttleworth Business Systems Limited. All rights reserved.
//

#import "addEventViewCotroller.h"
#import "EventSearch.h"
#import "format.h"
#import "AppDelegate.h"
#import "XMLParser.h"
#import "ContactSearch.h"
#import "CompanySearch.h"

#import "loadingSavingView.h"

@interface addEventViewCotroller ()

// Keyboard toolbar
@property (strong, nonatomic) UIToolbar *keyboardToolBar;

// EventSearch proerty to hold event to be added
@property (nonatomic, strong) EventSearch *eventToAdd;
@property (nonatomic, strong) NSString *contactName;
@property (nonatomic, strong) NSString *internalContactName;
@property (nonatomic, strong) CompanySearch *company;
@property (nonatomic, strong) NSString *eventType1Description;
@property (nonatomic, strong) NSString *eventType2Description;

//fetchXMLs
@property (nonatomic, strong) fetchXML *getEventTypes;
@property (nonatomic, strong) fetchXML *getEventTypeTwos;
@property (nonatomic, strong) fetchXML *getContacts;
@property (nonatomic, strong) fetchXML *getOurContacts;
@property (nonatomic, strong) fetchXML *saveEvent;

// activity indicatory
@property (strong, nonatomic) UIActivityIndicatorView *refreshSpinner;

@property (strong, nonatomic) loadingSavingView *savingView;

// arrays to store items for use with the look up table.
@property (nonatomic, strong) NSMutableArray *lookUpItems;
@property (nonatomic, strong) NSArray *ContactArray;
@property (nonatomic, strong) NSArray *eventType1Array;
@property (nonatomic, strong) NSArray *eventType2Array;

@property (nonatomic, strong) UIAlertView *fetchXMLFailedAlert;

@property (nonatomic) float scrollPosition;

- (NSString *)getEventType;
- (NSString *)getEventTypeTwo;
@end

@implementation addEventViewCotroller

// ---- Synthesize -----

// cell / txt Outlets
@synthesize btnCancel_Outlet;
@synthesize btnSave_Outlet;
@synthesize cellEventType1;
@synthesize cellEventType2;
@synthesize cellCompanySite;
@synthesize cellDueDate;
@synthesize cellDueTime;
@synthesize cellEndDate;
@synthesize cellEndTime;
@synthesize txtComment;
@synthesize txtTitle, cellContact, cellInternalContact;
// EventSearch proerty to hold event to be added
@synthesize eventToAdd, contactName, internalContactName, company, eventType1Description, eventType2Description;
// Keyboard toolbar
@synthesize keyboardToolBar;
//fetchXMLs
@synthesize getEventTypes, getEventTypeTwos, getContacts, getOurContacts, saveEvent;
// arrays to store items for use with the look up table.
@synthesize lookUpItems, ContactArray, eventType1Array, eventType2Array;
// activity indicatory
@synthesize refreshSpinner,savingView;
// alert view for failed fetchXML;
@synthesize fetchXMLFailedAlert;
// save scroll position to reset when screen returns from lookup / picker views.
@synthesize scrollPosition;

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
    txtComment.inputAccessoryView = keyboardToolBar;
    
    // prep refresh spinner
    refreshSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    refreshSpinner.frame = CGRectMake(self.view.bounds.size.width / 2 - 10, cellContact.bounds.size.height / 2 - 10, 20, 20);
    refreshSpinner.hidesWhenStopped = YES;
    
    // create stadard error connection alert, to be reused by all fetchXMLs.
    fetchXMLFailedAlert = [[UIAlertView alloc] initWithTitle:@"Connection Error" message:@"Could not connect to the server" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];

    eventToAdd = [[EventSearch alloc] init];
    
    scrollPosition = 0;
    
    [self fillCells];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //reset the view to the scroll position it was currently at - this seems to be forgotten after modal segues.
    [self.tableView setContentOffset:CGPointMake(0, scrollPosition)];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    //store the scrolled position of the tableview - so it can be remembered after modal segues.
    scrollPosition = self.tableView.contentOffset.y;
}

- (void)viewDidUnload
{
    [self setCellContact:nil];
    [self setCellInternalContact:nil];
    [self setTxtTitle:nil];
    [self setCellEventType1:nil];
    [self setCellEventType2:nil];
    [self setCellCompanySite:nil];
    [self setBtnCancel_Outlet:nil];
    [self setBtnSave_Outlet:nil];
    [self setCellDueDate:nil];
    [self setCellDueTime:nil];
    [self setCellEndDate:nil];
    [self setCellEndTime:nil];
    [self setTxtComment:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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
        case 0:
        {
            if (indexPath.row == 0) // Event Type
            {
                //prep fetchXML.
                getEventTypes = [[fetchXML alloc] initWithUrl:[NSURL URLWithString:[appURL stringByAppendingString:@"/service1.asmx/getEventTypesABL"]] delegate:self className:@"NSMutableDictionary"];
                
                if (![getEventTypes fetchXML]) //if get dom fails at this point, display error
                    [fetchXMLFailedAlert show];
                else // else show network activity (in selected cell);
                {
                    [cellEventType1 addSubview:refreshSpinner]; 
                    [refreshSpinner startAnimating];
                }
            }
            else // Event Type 2
            {
                if ([eventToAdd.eventType length] > 0)
                {
                    getEventTypeTwos = [[fetchXML alloc] initWithUrl:[NSURL URLWithString:[appURL stringByAppendingFormat:@"/service1.asmx/getEventTypeTwosABL?eventTypeID=%@", eventToAdd.eventType]] delegate:self className:@"NSMutableDictionary"];
                    
                    if (![getEventTypeTwos fetchXML]) //if get dom fails at this point, display error
                        [fetchXMLFailedAlert show];
                    else // else show network activity (in selected cell);
                    {
                        [cellEventType2 addSubview:refreshSpinner]; 
                        [refreshSpinner startAnimating];
                    }
                }
                else {
                    [[[UIAlertView alloc] initWithTitle:@"Event Type Not Found" message:@"Please Select an Event Type" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
                }
            }
            break;
        }
        case 3: // End date / time
        {
            //if there is a company site ID search for contacts:
            if ([company.companySiteID length] > 0)
            {
                //prep fetchXML.
                getContacts = [[fetchXML alloc] initWithUrl:[NSURL URLWithString:[appURL stringByAppendingFormat:@"/service1.asmx/searchContactsByCompanyABL?searchCompanySiteID=%@",company.companySiteID]] delegate:self className:@"ContactSearch"];
                
                if (![getContacts fetchXML]) //if get dom fails at this point, display error
                    [fetchXMLFailedAlert show];
                else // else show network activity (in selected cell);
                    [cellContact addSubview:refreshSpinner]; [refreshSpinner startAnimating];
            }
            else 
                [[[UIAlertView alloc] initWithTitle:@"Please select a company" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
            break;
        }
        case 4: // End date / time
        {

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
        }
        case 5: // End date / time
        {
            if (indexPath.row == 0)
            {
                [self performSegueWithIdentifier:@"toDateTimePicker" sender:cellDueDate]; 
            }
            else {
                [self performSegueWithIdentifier:@"toDateTimePicker" sender:cellDueTime]; 
            }
            break;
        }
        case 6: // End date / time
        {
            if (indexPath.row == 0)
            {
                [self performSegueWithIdentifier:@"toDateTimePicker" sender:cellEndDate]; 
            }
            else {
                [self performSegueWithIdentifier:@"toDateTimePicker" sender:cellEndTime]; 
            }
            break;
        }
    }
    
    
}

//------------------------------------------------------------------------
//            Pass values to the destination view controller
//------------------------------------------------------------------------
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    NSIndexPath* indexPath = (NSIndexPath *)sender;
    
    if ([segue.identifier isEqualToString:@"toLookUpTableView"]){
        
        //set the required values for the look up view controller
        lookUpTableViewController *lutvc = segue.destinationViewController;
        lutvc.delegate = self; //set self as the delegate
        lutvc.itemArray = lookUpItems; // set the array of items
        
        switch (indexPath.section) {
            case 0: // internal contact
            {
                lutvc.sourceCellIdentifier = [NSString stringWithFormat:@"%d%02d",indexPath.section, indexPath.row]; // identify by section
                if (indexPath.row == 0)
                    lutvc.item = eventType1Description;
                else 
                    lutvc.item = eventType2Description;
                break;
            }
            case 3: // contact
            {
                lutvc.sourceCellIdentifier = [NSString stringWithFormat:@"%d%02d",indexPath.section, indexPath.row]; // identify by section
                lutvc.item = contactName;
                break;
            }
            case 4: // internal contact
            {
                lutvc.sourceCellIdentifier = [NSString stringWithFormat:@"%d%02d",indexPath.section, indexPath.row]; // identify by section
                lutvc.item = internalContactName;
                break;
            }
        }
    }
    else if([segue.identifier isEqualToString:@"toCompanySearch"])
    {  
        companySiteSearchViewController *cssvc = segue.destinationViewController;
        cssvc.delegate = self;
    }
    else if([segue.identifier isEqualToString:@"toDateTimePicker"])
    {  
        dateTimePickerViewController *dtpvc = segue.destinationViewController;
        dtpvc.delegate = self;
        
        if (sender == cellDueDate)
        {
            dtpvc.dateTime = eventToAdd.eveDueDate;
            dtpvc.mode = UIDatePickerModeDate;
            dtpvc.sourceCellIdentifier = @"DueDate";
        }
        else if (sender == cellDueTime)
        {
            dtpvc.dateTime = [format dateFromSecondsSinceMidnight:[eventToAdd.eveDueTime intValue]];
            dtpvc.mode = UIDatePickerModeTime;
            dtpvc.sourceCellIdentifier = @"DueTime";
        }
        else if (sender == cellEndDate)
        {
            dtpvc.dateTime = eventToAdd.eveEndDate;
            dtpvc.mode = UIDatePickerModeDate;
            dtpvc.sourceCellIdentifier = @"EndDate";
        }
        else if (sender == cellEndTime)
        {
            dtpvc.dateTime = [format dateFromSecondsSinceMidnight:[eventToAdd.eveEndTime intValue]];
            dtpvc.mode = UIDatePickerModeTime;
            dtpvc.sourceCellIdentifier = @"EndTime";
        }

        
    }
}

// get data from lookup views
- (NSString *)getEventType{ return NULL; }


- (NSString *)getEventTypeTwo{ return NULL; }



// dismiss the view
- (IBAction)btnCancel_Click:(id)sender {
    //dismiss the view, does not cancel any fetchXML's as I don't want to interrupt events that are being saved. Also once, data is sent, the event is updated elsewhere, so cancelling would likely only stop confirmation or failure notification coming back.
    [self dismissModalViewControllerAnimated:YES];
}



//------------------------------------------------------------------------
//                      Save the event to database
//------------------------------------------------------------------------
- (IBAction)btnSave_Click:(id)sender {
    //Check the data the required information as been provided:
    //TODO: check required event details are present.
    
    UIAlertView *alertMissingData = [[UIAlertView alloc] initWithTitle:@"Required Values Missing" message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    
    

    
    if (eventToAdd.eventType == NULL)
    {
        alertMissingData.title = @"Please select an event type";
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:0 animated:YES];
        [alertMissingData show];
        return;
    } 
    else if (eventToAdd.eventType2 == NULL)
    {
        alertMissingData.title = @"Please enter an event type two";
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] atScrollPosition:0 animated:YES];
        [alertMissingData show];
        return;
    } 
    else if ([txtTitle.text isEqualToString:@""])
    {
        alertMissingData.title = @"Please enter a title";
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] atScrollPosition:0 animated:YES];
        [alertMissingData show];
        return;
    } 
    else if (eventToAdd.companySiteID == NULL)
    {
        alertMissingData.title = @"Please select a company site";
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2] atScrollPosition:0 animated:YES];
        [alertMissingData show];
        return;
    }
    else if (eventToAdd.contactID == NULL)
    {
        alertMissingData.title = @"Please select a contact";
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3] atScrollPosition:0 animated:YES];
        [alertMissingData show];
        return;
    }
    else if (eventToAdd.ourContactID == NULL)
    {
        alertMissingData.title = @"Please select an internal contact";
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:4] atScrollPosition:0 animated:YES];
        [alertMissingData show];
        return;
    }
    else if (eventToAdd.eveDueDate == NULL)
    {
        alertMissingData.title = @"Please select a due date";
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:5] atScrollPosition:0 animated:YES];
        [alertMissingData show];
        return;
    }
    else if (eventToAdd.eveDueTime == NULL)
    {
        alertMissingData.title = @"Please select a due time";
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:5] atScrollPosition:0 animated:YES];
        [alertMissingData show];
        return;
    }
        
    
    btnCancel_Outlet.enabled = false;
    btnSave_Outlet.enabled = false;
    
    NSDateFormatter *dfToString = [[NSDateFormatter alloc] init];
    [dfToString setDateFormat:@"dd/MM/YYYY"];
    NSString *formattedDueDate;
    if (!eventToAdd.eveDueDate)
        formattedDueDate = @"";
    else 
        formattedDueDate = [dfToString stringFromDate:eventToAdd.eveDueDate];
    
    NSString *formattedEndDate;
    if (!eventToAdd.eveEndDate)
        formattedEndDate = @"";
    else formattedEndDate = [dfToString stringFromDate:eventToAdd.eveEndDate];
    
    
    
    
    NSURL *url = [NSURL URLWithString:[[appURL stringByAppendingFormat:@"/service1.asmx/addEvent?companySiteID=%@&internalContactID=%@&eventTypeID=%@&eventTypeTwoID=%@&title=%@&comments=%@&dueDateString=%@&dueTime=%d&endDateString=%@&endTime=%d&createdByLoginUserID=%d&externalContactID=%@",company.companySiteID,eventToAdd.ourContactID,eventToAdd.eventType,eventToAdd.eventType2,txtTitle.text, txtComment.text, formattedDueDate, [eventToAdd.eveDueTime intValue] ?: -1, formattedEndDate, [eventToAdd.eveEndTime intValue]?: -1, appUserID, eventToAdd.contactID] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSLog(@"add event: %@",url);
    
    saveEvent = [[fetchXML alloc] initWithUrl:url delegate:self className:@"NSNumber"];
    
    if (![saveEvent fetchXML]) //if get dom fails at this point, display error
        [fetchXMLFailedAlert show];
    else // else show network activity (in selected cell);
    {     savingView = [[loadingSavingView alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 60, self.view.frame.size.height / 2 - 50, 120, 30) withMessage:@"Saving..."];
        
        [self.tableView addSubview:savingView];
    }
    
}

// hide keyboard
- (void)resignKeyboard:(id)sender  {
    [txtTitle resignFirstResponder];
    [txtComment resignFirstResponder];
}


//------------------------------------------------------------------------
//        Handle the data returned from the look up table view
//------------------------------------------------------------------------
- (void)lookUpTableViewController:(lookUpTableViewController *)controller didSelectItem:(NSInteger *)row withSourceCellIdentifier:(NSString *)sourceIdentifier
{
    
    //TODO: NEED A BETTER WAY TO IDENTIFY CELLS - this is not right.
        // should be identified by IndexPath, but the lookuptable takes a string, so for now this is using a string to represent section and cell index
    
    //NSLog(@"ident: %@ indent-int:%d",sourceIdentifier,[sourceIdentifier intValue]);
    // determine which cell called the lookUpTableView.
    switch ([sourceIdentifier intValue]) {
        case 0:
        {
            //retrieved the contact in the contact array that has been selected (by returned index)
            NSMutableDictionary *selectedDic = [eventType1Array objectAtIndex:(int)row];
            eventType1Description = [selectedDic valueForKey:@"evtDescription"];
            eventToAdd.eventType = [selectedDic valueForKey:@"eventTypeID"];
            eventType2Description = NULL; // reset event type 2 data is it is dependent on type 1
            eventToAdd.eventType2 = NULL;
            eventType1Array = nil; // empty event type 1 array
            break;
        }
        case 1:
        {
            //retrieved the contact in the contact array that has been selected (by returned index)
            NSMutableDictionary *selectedDic = [eventType2Array objectAtIndex:(int)row];
            eventType2Description = [selectedDic valueForKey:@"evtDescription"];
            eventToAdd.eventType2 = [selectedDic valueForKey:@"eventTypeID"];
            eventType2Array = nil; // empty event type 2 array.
            break;
        }
        case 300:
        {
            //retrieved the contact in the contact array that has been selected (by returned index)
            ContactSearch *selectedContact = [ContactArray objectAtIndex:(int)row];
            NSString *fullName = [format nameFromComponents:[NSMutableArray arrayWithObjects:selectedContact.conTitle,selectedContact.conFirstName, selectedContact.conMiddleName, selectedContact.conSurname, nil]];
            contactName = fullName;
            eventToAdd.contactID = [selectedContact contactID];
            ContactArray = nil; // empty contacts array
            break;
        }
        case 400:
        {
            ContactSearch *selectedContact = [ContactArray objectAtIndex:(int)row];
            NSString *fullName = [format nameFromComponents:[NSMutableArray arrayWithObjects:selectedContact.conTitle,selectedContact.conFirstName, selectedContact.conMiddleName, selectedContact.conSurname, nil]];
            internalContactName = fullName;
            eventToAdd.ourContactID = [selectedContact contactID];
            ContactArray = nil; // empty contacts array
            break;
        }
    }
    
    
    [self fillCells];
}


//------------------------------------------------------------------------
//     Handle the data returned from the date time picker view
//------------------------------------------------------------------------

- (void) dateTimePickerViewController: (dateTimePickerViewController *)controller didSelectDateTime:(NSDate *)returnedDate withSourceCellIdentifier:(NSString *)returnedSourceCellIdentifier withSender:(id)cellIndex 
{
    
    if ([returnedSourceCellIdentifier isEqualToString:@"DueDate"])
    {
        eventToAdd.eveDueDate = returnedDate;
    }
    else if ([returnedSourceCellIdentifier isEqualToString:@"DueTime"])
    {
        eventToAdd.eveDueTime = [format secondsSinceMidnightFromDate:returnedDate];
    }
    else if ([returnedSourceCellIdentifier isEqualToString:@"EndDate"])
    {
        eventToAdd.eveEndDate = returnedDate;
        
    }
    else if ([returnedSourceCellIdentifier isEqualToString:@"EndTime"])
    {
        eventToAdd.eveEndTime = [format secondsSinceMidnightFromDate:returnedDate];
    }
    
    // refill the cells with the updated information.
    [self fillCells];
}


//------------------------------------------------------------------------
//     Handle the data returned from the company site search view
//------------------------------------------------------------------------
-(void)companySiteSearchViewController:(companySiteSearchViewController *)controller
                      didSelectCompany: (CompanySearch *)selectedCompany{
    
    //store the selected company
    company = selectedCompany;
    
    //reset external contact;
    eventToAdd.contactID = NULL;
    contactName = @"";
    
    eventToAdd.companySiteID = company.companySiteID;
    
    //refill the cells with the updated informtion.
    [self fillCells];
}


//------------------------------------------------------------------------
//             Handle the data returned from the server
//------------------------------------------------------------------------
- (void)docRecieved:(NSDictionary *)doc :(id)sender {
    btnCancel_Outlet.enabled = true;
    btnSave_Outlet.enabled = true;
    
    // network activity has ended so stop refreshspinner
    [refreshSpinner stopAnimating];
    
    //retrieve the class key
    NSString *classKey = [doc objectForKey:@"ClassName"];
    //send it through to the xml parser to be places in classe indicated by class key.
    NSArray *Array = [[[XMLParser alloc] init]parseXMLDoc:[doc objectForKey:@"Document"] toClass:NSClassFromString(classKey)];
    lookUpItems = [[NSMutableArray alloc] init];
    
    if (sender == getContacts)
    {
        
        //create array of sort descriptors to order names contacts:
        NSArray *sortDescriptors = [NSArray arrayWithObjects:[[NSSortDescriptor alloc] initWithKey:@"conFirstName" ascending:YES],[[NSSortDescriptor alloc] initWithKey:@"conMiddleName" ascending:YES],[[NSSortDescriptor alloc] initWithKey:@"conSurname" ascending:YES], nil];
        //fill contactArray with ordered contacts
        ContactArray = [[NSArray alloc] initWithArray:[Array sortedArrayUsingDescriptors:sortDescriptors]];
        
        for (ContactSearch *con in ContactArray) // loop through contact and concatenate name, add name to lookUpItems array (to be sent to look up view)
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

        //create array of sort descriptors to order names contacts:
        NSArray *sortDescriptors = [NSArray arrayWithObjects:[[NSSortDescriptor alloc] initWithKey:@"conFirstName" ascending:YES],[[NSSortDescriptor alloc] initWithKey:@"conMiddleName" ascending:YES],[[NSSortDescriptor alloc] initWithKey:@"conSurname" ascending:YES], nil];
        //fill contactArray with ordered contacts
        ContactArray = [[NSArray alloc] initWithArray:[Array sortedArrayUsingDescriptors:sortDescriptors]];

        for (ContactSearch *con in ContactArray) // loop through contact and concatenate name, add name to lookUpItems array (to be sent to look up view)
        {
            NSString *fullName = [format nameFromComponents:[NSMutableArray arrayWithObjects:con.conTitle,con.conFirstName, con.conMiddleName, con.conSurname, nil]];
            [lookUpItems addObject:fullName];
        }
        //segue to the look up view.
        [self performSegueWithIdentifier:@"toLookUpTableView" sender:[NSIndexPath indexPathForRow:0 inSection:4]];
        getOurContacts = nil;
    }
    else if (sender == getEventTypes) 
    {
        // store returned event types in array
        eventType1Array = [[NSArray alloc] initWithArray:Array];
        for (NSMutableDictionary *dic in Array) // loop through event types and add descriptions to lookUpItems array.
        {
            [lookUpItems addObject:[dic valueForKey:@"evtDescription"]];
        }
        //segue to the look up view.
        [self performSegueWithIdentifier:@"toLookUpTableView" sender:[NSIndexPath indexPathForRow:0 inSection:0]];
        getEventTypes = nil;
    }
    else if (sender == getEventTypeTwos) 
    {
        // store returned event type 2s in array
        eventType2Array = [[NSArray alloc] initWithArray:Array];
        for (NSMutableDictionary *dic in Array) // loop through event types and add descriptions to lookUpItems array.
        {
            [lookUpItems addObject:[dic valueForKey:@"evtDescription"]];
        }
        //segue to the look up view.
        [self performSegueWithIdentifier:@"toLookUpTableView" sender:[NSIndexPath indexPathForRow:1 inSection:0]];
        getEventTypeTwos = nil;
    }
    else if (sender == saveEvent)
    {
        [savingView removeFromSuperview];
        
        saveEvent = nil;
        // if array not empty id of new event has been returned.
        if ([Array count] > 0 && [[Array objectAtIndex:0] integerValue] != 0) 
        {
            NSNumber *eventID = [Array objectAtIndex:0];
            
            //create a local notification containing id in a userinfo dictionary.
            NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObject:eventID forKey:@"id"];
            [userInfo setValue:@"0" forKey:@"core"];
            //tell the myEvents view to load the event.
            [[NSNotificationCenter defaultCenter] postNotificationName:@"openEventFromNotification" object:self userInfo:userInfo];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"getCoreData" object:self userInfo:userInfo];
            
            
            [self dismissModalViewControllerAnimated:YES];
        }
        else
        {
            [[[UIAlertView alloc] initWithTitle:@"Event Save Failed" message:@"Event could not be saved to the database." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
            btnSave_Outlet.enabled = YES;
            btnCancel_Outlet.enabled = YES;
        }
    }
}

- (void)fetchXMLError:(NSString *)errorResponse :(id)sender {
    
    [refreshSpinner stopAnimating];
    [savingView removeFromSuperview];
    
    if (sender == getContacts) getContacts = nil;
    else if (sender == getOurContacts) getOurContacts = nil;
    else if (sender == getEventTypes) getEventTypes = nil;
    else if (sender == getEventTypeTwos) getEventTypeTwos = nil;
    
    
    if (sender == saveEvent)
    {
        // show alert explaining event save failed.
        [[[UIAlertView alloc] initWithTitle:@"Event Save Failed" message:@"Event could not be saved to the database" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        btnSave_Outlet.enabled = YES;
        btnCancel_Outlet.enabled = YES;
    }
    else // show standard alert to explain error.
    {
        [[[UIAlertView alloc] initWithTitle:@"Error Fetching Data" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        
    }
    
}

//------------------------------------------------------------------------
//             Fill cells with their respective event data
//------------------------------------------------------------------------
- (void)fillCells {
    
    cellContact.textLabel.text = [contactName length] > 0 ? contactName : @"No Contact";
    cellInternalContact.textLabel.text = [internalContactName length] > 0 ? internalContactName : @"No Contact";
    cellEventType1.detailTextLabel.text = [eventToAdd.eventType length] > 0 ? eventType1Description : @"No Event Type";
    cellEventType2.detailTextLabel.text = [eventToAdd.eventType2 length] > 0 ? eventType2Description : @"No Event Type";
    cellCompanySite.textLabel.text = company.cosSiteName;
    
    NSDateFormatter *dfToString = [[NSDateFormatter alloc] init];
    [dfToString setDateStyle:NSDateFormatterMediumStyle];
    NSLog(@"due date: %@",eventToAdd.eveDueDate);
    
    cellDueDate.detailTextLabel.text = eventToAdd.eveDueDate != NULL ? [dfToString stringFromDate:eventToAdd.eveDueDate] : @"No Due Date";

    
    cellDueTime.detailTextLabel.text = [eventToAdd.eveDueTime length] > 0 ? [format timeStringFromSecondsSinceMidnight:[eventToAdd.eveDueTime intValue]] : @"No Due Time";
    
    cellEndDate.detailTextLabel.text =  eventToAdd.eveEndDate != NULL ? [dfToString stringFromDate:eventToAdd.eveEndDate] : @"No End Date";
    
    cellEndTime.detailTextLabel.text = [eventToAdd.eveEndTime length] > 0 ? [format timeStringFromSecondsSinceMidnight:[eventToAdd.eveEndTime intValue]] : @"No End Time";   
}



@end
