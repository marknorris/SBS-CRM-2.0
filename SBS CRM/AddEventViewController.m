//
//  addEventViewCotroller.m
//  SBS CRM 2.0
//
//  Created by Tom Couchman on 30/05/2012.
//  Copyright (c) 2012 Shuttleworth Business Systems Limited. All rights reserved.
//

#import "AddEventViewController.h"
#import "EventSearch.h"
#import "Format.h"
#import "AppDelegate.h"
#import "XMLParser.h"
#import "ContactSearch.h"
#import "CompanySearch.h"
#import "LoadingSavingView.h"

@interface AddEventViewController ()

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
@property (nonatomic, strong) FetchXML *getEventTypes;
@property (nonatomic, strong) FetchXML *getEventTypeTwos;
@property (nonatomic, strong) FetchXML *getContacts;
@property (nonatomic, strong) FetchXML *getOurContacts;
@property (nonatomic, strong) FetchXML *saveEvent;

// activity indicatory
@property (strong, nonatomic) UIActivityIndicatorView *refreshSpinner;

@property (strong, nonatomic) LoadingSavingView *savingView;

// arrays to store items for use with the look up table.
@property (nonatomic, strong) NSMutableArray *lookUpItems;
@property (nonatomic, strong) NSArray *contactArray;
@property (nonatomic, strong) NSArray *eventType1Array;
@property (nonatomic, strong) NSArray *eventType2Array;

@property (nonatomic, strong) UIAlertView *fetchXMLFailedAlert;

@property (nonatomic) float scrollPosition;

- (NSString *)getEventType;
- (NSString *)getEventTypeTwo;

@end

@implementation AddEventViewController

// ---- Synthesize -----

// cell / txt Outlets
@synthesize btnCancel_Outlet = _btnCancel_Outlet;
@synthesize btnSave_Outlet = _btnSave_Outlet;
@synthesize cellEventType1 = _cellEventType1;
@synthesize cellEventType2 = _cellEventType2;
@synthesize cellCompanySite = _cellCompanySite;
@synthesize cellDueDate = _cellDueDate;
@synthesize cellDueTime = _cellDueTime;
@synthesize cellEndDate = _cellEndDate;
@synthesize cellEndTime = _cellEndTime;
@synthesize txtComment = _txtComment;
@synthesize txtTitle = _txtTitle;
@synthesize cellContact = _cellContact;
@synthesize cellInternalContact = _cellInternalContact;
// EventSearch proerty to hold event to be added
@synthesize eventToAdd = _eventToAdd;
@synthesize contactName = _contactName;
@synthesize internalContactName = _internalContactName;
@synthesize company = _company;
@synthesize eventType1Description = _eventType1Description;
@synthesize eventType2Description = _eventType2Description;
// Keyboard toolbar
@synthesize keyboardToolBar = _keyboardToolBar;
//fetchXMLs
@synthesize getEventTypes = _getEventTypes;
@synthesize getEventTypeTwos = _getEventTypeTwos;
@synthesize getContacts = _getContacts;
@synthesize getOurContacts = _getOurContacts;
@synthesize saveEvent = _saveEvent;
// arrays to store items for use with the look up table.
@synthesize lookUpItems = _lookUpItems;
@synthesize contactArray = _contactArray;
@synthesize eventType1Array = _eventType1Array;
@synthesize eventType2Array = _eventType2Array;
// activity indicatory
@synthesize refreshSpinner = _refreshSpinner;
@synthesize savingView = _savingView;
// alert view for failed fetchXML;
@synthesize fetchXMLFailedAlert = _fetchXMLFailedAlert;
// save scroll position to reset when screen returns from lookup / picker views.
@synthesize scrollPosition = _scrollPosition;

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
    self.keyboardToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,0,self.view.bounds.size.width, 44)];
    self.keyboardToolBar.tintColor = [UIColor blackColor];
    UIBarButtonItem *extraSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(resignKeyboard:)];
    doneButton.style = UIBarButtonItemStyleDone;
    [self.keyboardToolBar setItems:[[NSArray alloc] initWithObjects:extraSpace,doneButton,nil]];
    
    // add keyboard to text field
    self.txtTitle.inputAccessoryView = self.keyboardToolBar;
    self.txtComment.inputAccessoryView = self.keyboardToolBar;
    
    // prep refresh spinner
    self.refreshSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.refreshSpinner.frame = CGRectMake(self.view.bounds.size.width / 2 - 10, self.cellContact.bounds.size.height / 2 - 10, 20, 20);
    self.refreshSpinner.hidesWhenStopped = YES;
    
    // create stadard error connection alert, to be reused by all fetchXMLs.
    self.fetchXMLFailedAlert = [[UIAlertView alloc] initWithTitle:@"Connection Error" message:@"Could not connect to the server" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];

    self.eventToAdd = [[EventSearch alloc] init];
    self.scrollPosition = 0;
    [self fillCells];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //reset the view to the scroll position it was currently at - this seems to be forgotten after modal segues.
    [self.tableView setContentOffset:CGPointMake(0, self.scrollPosition)];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    //store the scrolled position of the tableview - so it can be remembered after modal segues.
    self.scrollPosition = self.tableView.contentOffset.y;
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
            if (indexPath.row == 0) { // Event Type
                //prep fetchXML.
                self.getEventTypes = [[FetchXML alloc] initWithUrl:[NSURL URLWithString:[appURL stringByAppendingString:@"/service1.asmx/getEventTypesABL"]] delegate:self className:@"NSMutableDictionary"];
                
                if (![self.getEventTypes fetchXML]) //if get dom fails at this point, display error
                    [self.fetchXMLFailedAlert show];
                else // else show network activity (in selected cell);
                {
                    [self.cellEventType1 addSubview:self.refreshSpinner]; 
                    [self.refreshSpinner startAnimating];
                }
            }
            else { // Event Type 2
                if ([self.eventToAdd.eventType length] > 0) {
                    self.getEventTypeTwos = [[FetchXML alloc] initWithUrl:[NSURL URLWithString:[appURL stringByAppendingFormat:@"/service1.asmx/getEventTypeTwosABL?eventTypeID=%@", self.eventToAdd.eventType]] delegate:self className:@"NSMutableDictionary"];
                    
                    if (![self.getEventTypeTwos fetchXML]) //if get dom fails at this point, display error
                        [self.fetchXMLFailedAlert show];
                    else { // else show network activity (in selected cell);
                        [self.cellEventType2 addSubview:self.refreshSpinner]; 
                        [self.refreshSpinner startAnimating];
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
            if ([self.company.companySiteID length] > 0) {
                //prep fetchXML.
                self.getContacts = [[FetchXML alloc] initWithUrl:[NSURL URLWithString:[appURL stringByAppendingFormat:@"/service1.asmx/searchContactsByCompanyABL?searchCompanySiteID=%@",self.company.companySiteID]] delegate:self className:@"ContactSearch"];
                
                if (![self.getContacts fetchXML]) //if get dom fails at this point, display error
                    [self.fetchXMLFailedAlert show];
                else // else show network activity (in selected cell);
                    [self.cellContact addSubview:self.refreshSpinner]; [self.refreshSpinner startAnimating];
            }
            else 
                [[[UIAlertView alloc] initWithTitle:@"Please select a company" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
            break;
        }
        case 4: // End date / time
        {

            if (appCompanySiteID > 0) {
                //prep fetchXML
                self.getOurContacts = [[FetchXML alloc] initWithUrl:[NSURL URLWithString:[appURL stringByAppendingFormat:@"/service1.asmx/searchContactsByCompanyABL?searchCompanySiteID=%d",appCompanySiteID]] delegate:self className:@"ContactSearch"];
                
                if (![self.getOurContacts fetchXML]) //if get dom fails at this point, display error
                    [self.fetchXMLFailedAlert show]; 
                else // else show network activity (in selected cell);
                    [self.cellInternalContact addSubview:self.refreshSpinner]; [self.refreshSpinner startAnimating];
            }
            else 
                [[[UIAlertView alloc] initWithTitle:@"Internal Company not found" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
            break;
        }
        case 5: // End date / time
        {
            if (indexPath.row == 0) {
                [self performSegueWithIdentifier:@"toDateTimePicker" sender:self.cellDueDate]; 
            }
            else {
                [self performSegueWithIdentifier:@"toDateTimePicker" sender:self.cellDueTime]; 
            }
            break;
        }
        case 6: // End date / time
        {
            if (indexPath.row == 0) {
                [self performSegueWithIdentifier:@"toDateTimePicker" sender:self.cellEndDate]; 
            }
            else {
                [self performSegueWithIdentifier:@"toDateTimePicker" sender:self.cellEndTime]; 
            }
            break;
        }
    }
    
}

//------------------------------------------------------------------------
//            Pass values to the destination view controller
//------------------------------------------------------------------------
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender 
{
    
    NSIndexPath* indexPath = (NSIndexPath *)sender;
    
    if ([segue.identifier isEqualToString:@"toLookUpTableView"]) {
        //set the required values for the look up view controller
        LookUpTableViewController *lutvc = segue.destinationViewController;
        lutvc.delegate = self; //set self as the delegate
        lutvc.itemArray = self.lookUpItems; // set the array of items
        
        switch (indexPath.section) {
            case 0: // internal contact
            {
                lutvc.sourceCellIdentifier = [NSString stringWithFormat:@"%d%02d",indexPath.section, indexPath.row]; // identify by section
                if (indexPath.row == 0)
                    lutvc.item = self.eventType1Description;
                else 
                    lutvc.item = self.eventType2Description;
                break;
            }
            case 3: // contact
            {
                lutvc.sourceCellIdentifier = [NSString stringWithFormat:@"%d%02d",indexPath.section, indexPath.row]; // identify by section
                lutvc.item = self.contactName;
                break;
            }
            case 4: // internal contact
            {
                lutvc.sourceCellIdentifier = [NSString stringWithFormat:@"%d%02d",indexPath.section, indexPath.row]; // identify by section
                lutvc.item = self.internalContactName;
                break;
            }
        }
    }
    else if ([segue.identifier isEqualToString:@"toCompanySearch"]) {  
        CompanySiteSearchViewController *cssvc = segue.destinationViewController;
        cssvc.delegate = self;
    }
    else if ([segue.identifier isEqualToString:@"toDateTimePicker"]) {  
        DateTimePickerViewController *dtpvc = segue.destinationViewController;
        dtpvc.delegate = self;
        
        if (sender == self.cellDueDate) {
            dtpvc.dateTime = self.eventToAdd.eveDueDate;
            dtpvc.mode = UIDatePickerModeDate;
            dtpvc.sourceCellIdentifier = @"DueDate";
        }
        else if (sender == self.cellDueTime) {
            dtpvc.dateTime = [Format dateFromSecondsSinceMidnight:[self.eventToAdd.eveDueTime intValue]];
            dtpvc.mode = UIDatePickerModeTime;
            dtpvc.sourceCellIdentifier = @"DueTime";
        }
        else if (sender == self.cellEndDate) {
            dtpvc.dateTime = self.eventToAdd.eveEndDate;
            dtpvc.mode = UIDatePickerModeDate;
            dtpvc.sourceCellIdentifier = @"EndDate";
        }
        else if (sender == self.cellEndTime) {
            dtpvc.dateTime = [Format dateFromSecondsSinceMidnight:[self.eventToAdd.eveEndTime intValue]];
            dtpvc.mode = UIDatePickerModeTime;
            dtpvc.sourceCellIdentifier = @"EndTime";
        }

    }
}

// get data from lookup views
- (NSString *)getEventType
{ 
    return NULL; 
}

- (NSString *)getEventTypeTwo
{ 
    return NULL; 
}

// dismiss the view
- (IBAction)btnCancel_Click:(id)sender
{
    //dismiss the view, does not cancel any fetchXML's as I don't want to interrupt events that are being saved. Also once, data is sent, the event is updated elsewhere, so cancelling would likely only stop confirmation or failure notification coming back.
    [self dismissModalViewControllerAnimated:YES];
}

//------------------------------------------------------------------------
//                      Save the event to database
//------------------------------------------------------------------------
- (IBAction)btnSave_Click:(id)sender 
{
    //Check the data the required information as been provided:
    //TODO: check required event details are present.
    
    UIAlertView *alertMissingData = [[UIAlertView alloc] initWithTitle:@"Required Values Missing" message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    
    if (self.eventToAdd.eventType == NULL) {
        alertMissingData.title = @"Please select an event type";
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:0 animated:YES];
        [alertMissingData show];
        return;
    } 
    else if (self.eventToAdd.eventType2 == NULL) {
        alertMissingData.title = @"Please enter an event type two";
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] atScrollPosition:0 animated:YES];
        [alertMissingData show];
        return;
    } 
    else if ([self.txtTitle.text isEqualToString:@""]) {
        alertMissingData.title = @"Please enter a title";
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] atScrollPosition:0 animated:YES];
        [alertMissingData show];
        return;
    } 
    else if (self.eventToAdd.companySiteID == NULL) {
        alertMissingData.title = @"Please select a company site";
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2] atScrollPosition:0 animated:YES];
        [alertMissingData show];
        return;
    }
    else if (self.eventToAdd.contactID == NULL) {
        alertMissingData.title = @"Please select a contact";
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3] atScrollPosition:0 animated:YES];
        [alertMissingData show];
        return;
    }
    else if (self.eventToAdd.ourContactID == NULL) {
        alertMissingData.title = @"Please select an internal contact";
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:4] atScrollPosition:0 animated:YES];
        [alertMissingData show];
        return;
    }
    else if (self.eventToAdd.eveDueDate == NULL) {
        alertMissingData.title = @"Please select a due date";
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:5] atScrollPosition:0 animated:YES];
        [alertMissingData show];
        return;
    }
    else if (self.eventToAdd.eveDueTime == NULL) {
        alertMissingData.title = @"Please select a due time";
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:5] atScrollPosition:0 animated:YES];
        [alertMissingData show];
        return;
    }
        
    self.btnCancel_Outlet.enabled = false;
    self.btnSave_Outlet.enabled = false;
    
    NSDateFormatter *dfToString = [[NSDateFormatter alloc] init];
    [dfToString setDateFormat:@"dd/MM/YYYY"];
    NSString *formattedDueDate;
    
    if (!self.eventToAdd.eveDueDate)
        formattedDueDate = @"";
    else 
        formattedDueDate = [dfToString stringFromDate:self.eventToAdd.eveDueDate];
    
    NSString *formattedEndDate;
    if (!self.eventToAdd.eveEndDate)
        formattedEndDate = @"";
    else 
        formattedEndDate = [dfToString stringFromDate:self.eventToAdd.eveEndDate];
    
    NSURL *url = [NSURL URLWithString:[[appURL stringByAppendingFormat:@"/service1.asmx/addEvent?companySiteID=%@&internalContactID=%@&eventTypeID=%@&eventTypeTwoID=%@&title=%@&comments=%@&dueDateString=%@&dueTime=%d&endDateString=%@&endTime=%d&createdByLoginUserID=%d&externalContactID=%@", self.company.companySiteID, self.eventToAdd.ourContactID, self.eventToAdd.eventType, self.eventToAdd.eventType2, self.txtTitle.text, self.txtComment.text, formattedDueDate, [self.eventToAdd.eveDueTime intValue] ?: -1, formattedEndDate, [self.eventToAdd.eveEndTime intValue]?: -1, appUserID, self.eventToAdd.contactID] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSLog(@"add event: %@",url);
    
    self.saveEvent = [[FetchXML alloc] initWithUrl:url delegate:self className:@"NSNumber"];
    
    if (![self.saveEvent fetchXML]) //if get dom fails at this point, display error
        [self.fetchXMLFailedAlert show];
    else { // else show network activity (in selected cell);
        self.savingView = [[LoadingSavingView alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 60, self.view.frame.size.height / 2 - 50, 120, 30) withMessage:@"Saving..."];
        
        [self.tableView addSubview:self.savingView];
    }
    
}

// hide keyboard
- (void)resignKeyboard:(id)sender
{
    [self.txtTitle resignFirstResponder];
    [self.txtComment resignFirstResponder];
}

//------------------------------------------------------------------------
//        Handle the data returned from the look up table view
//------------------------------------------------------------------------
- (void)lookUpTableViewController:(LookUpTableViewController *)controller didSelectItem:(NSInteger *)row withSourceCellIdentifier:(NSString *)sourceIdentifier
{
    
    //TODO: NEED A BETTER WAY TO IDENTIFY CELLS - this is not right.
        // should be identified by IndexPath, but the lookuptable takes a string, so for now this is using a string to represent section and cell index
    
    //NSLog(@"ident: %@ indent-int:%d",sourceIdentifier,[sourceIdentifier intValue]);
    // determine which cell called the lookUpTableView.
    switch ([sourceIdentifier intValue]) {
        case 0:
        {
            //retrieved the contact in the contact array that has been selected (by returned index)
            NSMutableDictionary *selectedDic = [self.eventType1Array objectAtIndex:(int)row];
            self.eventType1Description = [selectedDic valueForKey:@"evtDescription"];
            self.eventToAdd.eventType = [selectedDic valueForKey:@"eventTypeID"];
            self.eventType2Description = NULL; // reset event type 2 data is it is dependent on type 1
            self.eventToAdd.eventType2 = NULL;
            self.eventType1Array = nil; // empty event type 1 array
            break;
        }
        case 1:
        {
            //retrieved the contact in the contact array that has been selected (by returned index)
            NSMutableDictionary *selectedDic = [self.eventType2Array objectAtIndex:(int)row];
            self.eventType2Description = [selectedDic valueForKey:@"evtDescription"];
            self.eventToAdd.eventType2 = [selectedDic valueForKey:@"eventTypeID"];
            self.eventType2Array = nil; // empty event type 2 array.
            break;
        }
        case 300:
        {
            //retrieved the contact in the contact array that has been selected (by returned index)
            ContactSearch *selectedContact = [self.contactArray objectAtIndex:(int)row];
            NSString *fullName = [Format nameFromComponents:[NSMutableArray arrayWithObjects:selectedContact.conTitle,selectedContact.conFirstName, selectedContact.conMiddleName, selectedContact.conSurname, nil]];
            self.contactName = fullName;
            self.eventToAdd.contactID = [selectedContact contactID];
            self.ContactArray = nil; // empty contacts array
            break;
        }
        case 400:
        {
            ContactSearch *selectedContact = [self.contactArray objectAtIndex:(int)row];
            NSString *fullName = [Format nameFromComponents:[NSMutableArray arrayWithObjects:selectedContact.conTitle,selectedContact.conFirstName, selectedContact.conMiddleName, selectedContact.conSurname, nil]];
            self.internalContactName = fullName;
            self.eventToAdd.ourContactID = [selectedContact contactID];
            self.ContactArray = nil; // empty contacts array
            break;
        }
    }
    
    [self fillCells];
}

//------------------------------------------------------------------------
//     Handle the data returned from the date time picker view
//------------------------------------------------------------------------

- (void) dateTimePickerViewController: (DateTimePickerViewController *)controller didSelectDateTime:(NSDate *)returnedDate withSourceCellIdentifier:(NSString *)returnedSourceCellIdentifier withSender:(id)cellIndex 
{
    
    if ([returnedSourceCellIdentifier isEqualToString:@"DueDate"]) {
        self.eventToAdd.eveDueDate = returnedDate;
    }
    else if ([returnedSourceCellIdentifier isEqualToString:@"DueTime"]) {
        self.eventToAdd.eveDueTime = [Format secondsSinceMidnightFromDate:returnedDate];
    }
    else if ([returnedSourceCellIdentifier isEqualToString:@"EndDate"]) {
        self.eventToAdd.eveEndDate = returnedDate;
        
    }
    else if ([returnedSourceCellIdentifier isEqualToString:@"EndTime"]) {
        self.eventToAdd.eveEndTime = [Format secondsSinceMidnightFromDate:returnedDate];
    }
    
    // refill the cells with the updated information.
    [self fillCells];
}

//------------------------------------------------------------------------
//     Handle the data returned from the company site search view
//------------------------------------------------------------------------
-(void)companySiteSearchViewController:(CompanySiteSearchViewController *)controller didSelectCompany: (CompanySearch *)selectedCompany{
    
    //store the selected company
    self.company = selectedCompany;
    
    //reset external contact;
    self.eventToAdd.contactID = NULL;
    self.contactName = @"";
    
    self.eventToAdd.companySiteID = self.company.companySiteID;
    
    //refill the cells with the updated informtion.
    [self fillCells];
}

//------------------------------------------------------------------------
//             Handle the data returned from the server
//------------------------------------------------------------------------
- (void)docRecieved:(NSDictionary *)doc :(id)sender 
{
    self.btnCancel_Outlet.enabled = true;
    self.btnSave_Outlet.enabled = true;
    
    // network activity has ended so stop refreshspinner
    [self.refreshSpinner stopAnimating];
    
    //retrieve the class key
    NSString *classKey = [doc objectForKey:@"ClassName"];
    //send it through to the xml parser to be places in classe indicated by class key.
    NSArray *Array = [[[XMLParser alloc] init]parseXMLDoc:[doc objectForKey:@"Document"] toClass:NSClassFromString(classKey)];
    self.lookUpItems = [[NSMutableArray alloc] init];
    
    if (sender == self.getContacts) {
        //create array of sort descriptors to order names contacts:
        NSArray *sortDescriptors = [NSArray arrayWithObjects:[[NSSortDescriptor alloc] initWithKey:@"conFirstName" ascending:YES],[[NSSortDescriptor alloc] initWithKey:@"conMiddleName" ascending:YES],[[NSSortDescriptor alloc] initWithKey:@"conSurname" ascending:YES], nil];
        //fill contactArray with ordered contacts
        self.ContactArray = [[NSArray alloc] initWithArray:[Array sortedArrayUsingDescriptors:sortDescriptors]];
        
        for (ContactSearch *con in self.contactArray) { // loop through contact and concatenate name, add name to lookUpItems array (to be sent to look up view)
            NSString *fullName = [Format nameFromComponents:[NSMutableArray arrayWithObjects:con.conTitle,con.conFirstName, con.conMiddleName, con.conSurname, nil]];
            [self.lookUpItems addObject:fullName];
        }

        //segue to the look up view.
        [self performSegueWithIdentifier:@"toLookUpTableView" sender:[NSIndexPath indexPathForRow:0 inSection:3]];
        self.getContacts = nil;
    } 
    else if (sender == self.getOurContacts) {
        //create array of sort descriptors to order names contacts:
        NSArray *sortDescriptors = [NSArray arrayWithObjects:[[NSSortDescriptor alloc] initWithKey:@"conFirstName" ascending:YES],[[NSSortDescriptor alloc] initWithKey:@"conMiddleName" ascending:YES],[[NSSortDescriptor alloc] initWithKey:@"conSurname" ascending:YES], nil];
        //fill contactArray with ordered contacts
        self.ContactArray = [[NSArray alloc] initWithArray:[Array sortedArrayUsingDescriptors:sortDescriptors]];

        for (ContactSearch *con in self.contactArray) { // loop through contact and concatenate name, add name to lookUpItems array (to be sent to look up view)
            NSString *fullName = [Format nameFromComponents:[NSMutableArray arrayWithObjects:con.conTitle,con.conFirstName, con.conMiddleName, con.conSurname, nil]];
            [self.lookUpItems addObject:fullName];
        }
        
        //segue to the look up view.
        [self performSegueWithIdentifier:@"toLookUpTableView" sender:[NSIndexPath indexPathForRow:0 inSection:4]];
        self.getOurContacts = nil;
    }
    else if (sender == self.getEventTypes) {
        // store returned event types in array
        self.eventType1Array = [[NSArray alloc] initWithArray:Array];

        for (NSMutableDictionary *dic in Array) { // loop through event types and add descriptions to lookUpItems array.
            [self.lookUpItems addObject:[dic valueForKey:@"evtDescription"]];
        }

        //segue to the look up view.
        [self performSegueWithIdentifier:@"toLookUpTableView" sender:[NSIndexPath indexPathForRow:0 inSection:0]];
        self.getEventTypes = nil;
    }
    else if (sender == self.getEventTypeTwos) {
        // store returned event type 2s in array
        self.eventType2Array = [[NSArray alloc] initWithArray:Array];

        for (NSMutableDictionary *dic in Array) { // loop through event types and add descriptions to lookUpItems array.
            [self.lookUpItems addObject:[dic valueForKey:@"evtDescription"]];
        }
        //segue to the look up view.
        [self performSegueWithIdentifier:@"toLookUpTableView" sender:[NSIndexPath indexPathForRow:1 inSection:0]];
        self.getEventTypeTwos = nil;
    }
    else if (sender == self.saveEvent) {
        [self.savingView removeFromSuperview];
        
        self.saveEvent = nil;
        // if array not empty id of new event has been returned.
        if ([Array count] > 0 && [[Array objectAtIndex:0] integerValue] != 0) {
            NSNumber *eventID = [Array objectAtIndex:0];
            
            //create a local notification containing id in a userinfo dictionary.
            NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObject:eventID forKey:@"id"];
            [userInfo setValue:@"0" forKey:@"core"];
            //tell the myEvents view to load the event.
            [[NSNotificationCenter defaultCenter] postNotificationName:@"openEventFromNotification" object:self userInfo:userInfo];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"getCoreData" object:self userInfo:userInfo];
            
            [self dismissModalViewControllerAnimated:YES];
        }
        else {
            [[[UIAlertView alloc] initWithTitle:@"Event Save Failed" message:@"Event could not be saved to the database." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
            self.btnSave_Outlet.enabled = YES;
            self.btnCancel_Outlet.enabled = YES;
        }
    }
}

- (void)fetchXMLError:(NSString *)errorResponse :(id)sender 
{    
    [self.refreshSpinner stopAnimating];
    [self.savingView removeFromSuperview];
    
    if (sender == self.getContacts) 
        self.getContacts = nil;
    else if (sender == self.getOurContacts) 
        self.getOurContacts = nil;
    else if (sender == self.getEventTypes) 
        self.getEventTypes = nil;
    else if (sender == self.getEventTypeTwos) 
        self.getEventTypeTwos = nil;
    
    if (sender == self.saveEvent) {
        // show alert explaining event save failed.
        [[[UIAlertView alloc] initWithTitle:@"Event Save Failed" message:@"Event could not be saved to the database" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        self.btnSave_Outlet.enabled = YES;
        self.btnCancel_Outlet.enabled = YES;
    }
    else { // show standard alert to explain error.
        [[[UIAlertView alloc] initWithTitle:@"Error Fetching Data" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        
    }
    
}

//------------------------------------------------------------------------
//             Fill cells with their respective event data
//------------------------------------------------------------------------
- (void)fillCells 
{    
    self.cellContact.textLabel.text = [self.contactName length] > 0 ? self.contactName : @"No Contact";
    self.cellInternalContact.textLabel.text = [self.internalContactName length] > 0 ? self.internalContactName : @"No Contact";
    self.cellEventType1.detailTextLabel.text = [self.eventToAdd.eventType length] > 0 ? self.eventType1Description : @"No Event Type";
    self.cellEventType2.detailTextLabel.text = [self.eventToAdd.eventType2 length] > 0 ? self.eventType2Description : @"No Event Type";
    self.cellCompanySite.textLabel.text = self.company.cosSiteName;
    
    NSDateFormatter *dfToString = [[NSDateFormatter alloc] init];
    [dfToString setDateStyle:NSDateFormatterMediumStyle];
    NSLog(@"due date: %@",self.eventToAdd.eveDueDate);
    
    self.cellDueDate.detailTextLabel.text = self.eventToAdd.eveDueDate != NULL ? [dfToString stringFromDate:self.eventToAdd.eveDueDate] : @"No Due Date";
    self.cellDueTime.detailTextLabel.text = [self.eventToAdd.eveDueTime length] > 0 ? [Format timeStringFromSecondsSinceMidnight:[self.eventToAdd.eveDueTime intValue]] : @"No Due Time";
    self.cellEndDate.detailTextLabel.text =  self.eventToAdd.eveEndDate != NULL ? [dfToString stringFromDate:self.eventToAdd.eveEndDate] : @"No End Date";
    self.cellEndTime.detailTextLabel.text = [self.eventToAdd.eveEndTime length] > 0 ? [Format timeStringFromSecondsSinceMidnight:[self.eventToAdd.eveEndTime intValue]] : @"No End Time";   
}

@end
