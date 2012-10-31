//
//  editTableViewConrtoller.m
//  SBS CRM 2.0
//
//  Created by Tom Couchman on 17/05/2012.
//  Copyright (c) 2012 Shuttleworth Business Systems Limited. All rights reserved.
//

#import "EditTableViewController.h"
#import "Format.h"
#import "AppDelegate.h"
#import "XMLParser.h"
#import "ContactSearch.h"
#import "CompanySearch.h"
#import "NSManagedObject+CoreDataManager.h"
#import "LoadingSavingView.h"

@interface EditTableViewController ()

// Keyboard toolbar
@property (strong, nonatomic) UIToolbar *keyboardToolBar;

//fetchXMLs
@property (nonatomic, strong) FetchXML *getContacts;
@property (nonatomic, strong) FetchXML *getOurContacts;
@property (nonatomic, strong) FetchXML *saveEvent;

// activity indicatory
@property (strong, nonatomic) UIActivityIndicatorView *refreshSpinner;

@property (strong, nonatomic) LoadingSavingView *savingView;

// arrays to store items for use with the look up table.
@property (nonatomic, strong) NSMutableArray *lookUpItems;
@property (nonatomic, strong) NSArray *ContactArray;

@property (nonatomic, strong) UIAlertView *fetchXMLFailedAlert;

@property (nonatomic) float scrollPosition;

- (void)fillCells;

@end

@implementation EditTableViewController

// ---- Synthesize -----

// cell / txt Outlets
@synthesize btnCancel = _btnCancel;
@synthesize btnSave = _btnSave;
@synthesize txtTitle = _txtTitle;
@synthesize cellDueDate = _cellDueDate;
@synthesize cellDueTime = _cellDueTime;
@synthesize cellEndDate = _cellEndDate;
@synthesize cellEndTime = _cellEndTime;
@synthesize cellContact = _cellContact;
@synthesize cellInternalContact = _cellInternalContact;
// EventSearch proerty to hold event to be added
@synthesize eventToEdit = _eventToEdit;
@synthesize contact = _contact;
@synthesize internalContact = _internalContact;
@synthesize contactName = _contactName;
@synthesize internalContactName = _internalContactName;
// Keyboard toolbar
@synthesize keyboardToolBar = _keyboardToolBar;
//fetchXMLs
@synthesize saveEvent = _saveEvent;
@synthesize getContacts = _getContacts;
@synthesize getOurContacts = _getOurContacts;
// arrays to store items for use with the look up table.
@synthesize lookUpItems = _lookUpItems;
@synthesize ContactArray = _ContactArray;
// activity indicatory
@synthesize refreshSpinner = _refreshSpinner;
@synthesize savingView = _savingView;
// alert view for failed fetchXML;
@synthesize fetchXMLFailedAlert = _fetchXMLFailedAlert;
// save scroll position to reset when screen returns from lookup / picker views.
@synthesize scrollPosition = _scrollPosition;

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
    
    // Create toolbar for keyboard
    self.keyboardToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,0,self.view.bounds.size.width, 44)];
    self.keyboardToolBar.tintColor = [UIColor blackColor];
    UIBarButtonItem *extraSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(resignKeyboard:)];
    doneButton.style = UIBarButtonItemStyleDone;
    [self.keyboardToolBar setItems:[[NSArray alloc] initWithObjects:extraSpace,doneButton,nil]];
    // add keyboard to text field
    self.txtTitle.inputAccessoryView = self.keyboardToolBar;
    
    // prep refresh spinner
    self.refreshSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.refreshSpinner.frame = CGRectMake(self.view.bounds.size.width / 2 - 10, self.cellContact.bounds.size.height / 2 - 10, 20, 20);
    self.refreshSpinner.hidesWhenStopped = YES;
    
    self.fetchXMLFailedAlert = [[UIAlertView alloc] initWithTitle:@"Connection Error" message:@"Could not connect to the server" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    
    self.scrollPosition = 0;
    
    self.txtTitle.text = self.eventToEdit.eveTitle;
    [self fillCells];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView setContentOffset:CGPointMake(0, self.scrollPosition)];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.scrollPosition = self.tableView.contentOffset.y;
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
- (void)resignKeyboard:(id)sender
{
    [self.txtTitle resignFirstResponder];
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
            if ([self.eventToEdit.companySiteID length] > 0) {
                //prep fetchXML.
                self.getContacts = [[FetchXML alloc] initWithUrl:[NSURL URLWithString:[appURL stringByAppendingFormat:@"/service1.asmx/searchContactsByCompanyABL?searchCompanySiteID=%@", self.eventToEdit.companySiteID]] delegate:self className:@"ContactSearch"];
                
                if (![self.getContacts fetchXML]) //if get dom fails at this point, display error
                    [self.fetchXMLFailedAlert show];
                else // else show network activity (in selected cell);
                    [self.cellContact addSubview:self.refreshSpinner]; [self.refreshSpinner startAnimating];
            }
            else 
                [[[UIAlertView alloc] initWithTitle:@"Please select a company" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
            break;
        case 4: // End date / time
            if (appCompanySiteID > 0) {
                //prep fetchXML
                self.getOurContacts = [[FetchXML alloc] initWithUrl:[NSURL URLWithString:[appURL stringByAppendingFormat:@"/service1.asmx/searchContactsByCompanyABL?searchCompanySiteID=%d", appCompanySiteID]] delegate:self className:@"ContactSearch"];
                
                if (![self.getOurContacts fetchXML]) //if get dom fails at this point, display error
                    [self.fetchXMLFailedAlert show]; 
                else // else show network activity (in selected cell);
                    [self.cellInternalContact addSubview:self.refreshSpinner]; [self.refreshSpinner startAnimating];
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
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{    
    NSIndexPath* indexPath = (NSIndexPath *)sender;
    
    if ([segue.identifier isEqualToString:@"toDateTimePicker"]) {
        DateTimePickerViewController *dtpvc = segue.destinationViewController;
        dtpvc.delegate = self;
        dtpvc.sender = sender;
        
        switch (indexPath.section) {
            case 1: // due
                //customise based on the sender - set mode and currently selected date / time.
                if(indexPath.row == 0) { // due date
                    dtpvc.dateTime = self.eventToEdit.eveDueDate;
                    dtpvc.mode = UIDatePickerModeDate;
                }
                else { // due time
                    dtpvc.dateTime = [Format dateFromSecondsSinceMidnight:[self.eventToEdit.eveDueTime integerValue]];
                    dtpvc.mode = UIDatePickerModeTime;
                }
                break;
            case 2: // end
                //customise based on the sender
                if(indexPath.row == 0) { // end date
                    dtpvc.dateTime = self.eventToEdit.eveEndDate;
                    dtpvc.mode = UIDatePickerModeDate;
                }
                else { // end time.
                    dtpvc.dateTime = [Format dateFromSecondsSinceMidnight:[self.eventToEdit.eveEndTime integerValue]];
                    dtpvc.mode = UIDatePickerModeTime;
                }
                break;
        }
        
    }
    else if ([segue.identifier isEqualToString:@"toLookUpTableView"]) {
        //set the required values for the look up view controller
        LookUpTableViewController *lutvc = segue.destinationViewController;
        lutvc.delegate = self; //set self as the delegate
        lutvc.itemArray = self.lookUpItems; // set the array of items
        
        switch (indexPath.section) {
            case 3: // contact
                lutvc.sourceCellIdentifier = [NSString stringWithFormat:@"%d%02d",indexPath.section, indexPath.row]; // identify by section
                lutvc.item = self.contactName;
                break;
            case 4: // internal contact
                lutvc.sourceCellIdentifier = [NSString stringWithFormat:@"%d%02d",indexPath.section, indexPath.row]; // identify by section
                lutvc.item = self.internalContactName;
                break;
        }
    }
    
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
- (IBAction)btnSave_Click:(id)sender {
    self.btnSave.enabled = false;
    self.btnCancel.enabled = false;
    [self saveEventToDatabase];
}

- (void)saveEventToDatabase{
    self.savingView = [[LoadingSavingView alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 60, self.view.frame.size.height / 2 - 50, 120, 30) withMessage:@"Saving..."];
    [self.tableView addSubview:self.savingView];
    
    UIAlertView *domGetFailed = [[UIAlertView alloc] initWithTitle:@"Connection Error" message:@"Event Not Saved" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    
    self.eventToEdit.eveTitle = self.txtTitle.text;
    
    NSString *title = [self.eventToEdit.eveTitle stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSDateFormatter *dfToString = [[NSDateFormatter alloc] init];
    [dfToString setDateFormat:@"dd/MM/YYYY"];
    NSString *formattedDueDate = [dfToString stringFromDate:self.eventToEdit.eveDueDate];
    
    NSString *endDate;
    
    if (!self.eventToEdit.eveEndDate)
        endDate = @"";
    else 
        endDate = [dfToString stringFromDate:self.eventToEdit.eveEndDate];
    
    self.saveEvent = [[FetchXML alloc] initWithUrl:[NSURL URLWithString:[appURL stringByAppendingFormat:@"/Service1.asmx/editEvent?eventId=%d&eveTitlestring=%@&dueDateString=%@&dueTime=%@&endDateString=%@&endTime=%@&contactID=%@&ourContactID=%@&userID=%d", [self.eventToEdit.eventID integerValue], title ?: @"", formattedDueDate ?: @"", self.eventToEdit.eveDueTime ?: @"-1",endDate ?: @"", self.eventToEdit.eveEndTime ?: @"-1", self.eventToEdit.contactID ?: @"", self.eventToEdit.ourContactID ?: @"", appUserID]] delegate:self className:@"NSNumber"];
    
    if (![self.saveEvent fetchXML]) {
        [domGetFailed show];
        return;
    }
    
}

//------------------------------------------------------------------------
//          Handle the data returned from the dateTimePickerView
//------------------------------------------------------------------------
- (void)dateTimePickerViewController: (DateTimePickerViewController *)controller didSelectDateTime:(NSDate *)returnedDate withSourceCellIdentifier:(NSString *)returnedSourceCellIdentifier withSender:(id)cellIndex 
{
    NSIndexPath *indexPath = (NSIndexPath *)cellIndex;
    
    //determine where to store the returned data, using the indexpath stored in the sender.
    switch (indexPath.section) {
        case 1:
            if (indexPath.row == 0)
                self.eventToEdit.eveDueDate = returnedDate;
            else
                self.eventToEdit.eveDueTime = [Format secondsSinceMidnightFromDate:returnedDate];
            break;
        case 2:
            if (indexPath.row == 0)
                self.eventToEdit.eveEndDate = returnedDate;
            else
                self.eventToEdit.eveEndTime = [Format secondsSinceMidnightFromDate:returnedDate];
            break;
    }
    
    // refill the cells with the updated information.
    [self fillCells];
}

- (void)lookUpTableViewController:(LookUpTableViewController *)controller didSelectItem:(NSInteger *)row withSourceCellIdentifier:(NSString *)sourceIdentifier
{
    
    NSLog(@"ident: %@ indent-int:%d",sourceIdentifier,[sourceIdentifier intValue]);
    // determine which cell called the lookUpTableView.
    switch ([sourceIdentifier intValue]) {
        case 300:
        {
            //retrieved the contact in the contact array that has been selected (by returned index)
            self.contact = [self.ContactArray objectAtIndex:(int)row];
            NSString *fullName = [Format nameFromComponents:[NSMutableArray arrayWithObjects:self.contact.conTitle, self.contact.conFirstName, self.contact.conMiddleName, self.contact.conSurname, nil]];
            self.contactName = fullName;
            self.eventToEdit.contactID = [self.contact contactID];
            self.ContactArray = nil; // contacts no longer needed.
            break;
        }
        case 400:
        {
            self.internalContact = [self.ContactArray objectAtIndex:(int)row];
            NSString *fullName = [Format nameFromComponents:[NSMutableArray arrayWithObjects:self.internalContact.conTitle, self.internalContact.conFirstName, self.internalContact.conMiddleName, self.internalContact.conSurname, nil]];
            self.internalContactName = fullName;
            self.eventToEdit.ourContactID = [self.internalContact contactID];
            self.ContactArray = nil; // contacts no longer needed.
            break;
        }
    }
    
    [self fillCells];
}

//------------------------------------------------------------------------
//             Handle the data returned from the server
//------------------------------------------------------------------------
- (void)docRecieved:(NSDictionary *)doc :(id)sender 
{
    // network activity has ended so stop refreshspinner
    [self.refreshSpinner stopAnimating];
    
    //retrieve the class key
    NSString *classKey = [doc objectForKey:@"ClassName"];
    //send it through to the xml parser to be places in classe indicated by class key.
    NSArray *Array = [[[XMLParser alloc] init]parseXMLDoc:[doc objectForKey:@"Document"] toClass:NSClassFromString(classKey)];
    self.lookUpItems = [[NSMutableArray alloc] init];
    
    if (sender == self.getContacts) {
        // store returned contacts in array
        self.ContactArray = [[NSArray alloc] initWithArray:Array];
        
        for (ContactSearch *con in Array) { // loop through contact and concatenate name, add name to lookUpItems array (to be sent to look up view)
            NSString *fullName = [Format nameFromComponents:[NSMutableArray arrayWithObjects:con.conTitle,con.conFirstName, con.conMiddleName, con.conSurname, nil]];
            [self.lookUpItems addObject:fullName];
        }
        
        //segue to the look up view.
        [self performSegueWithIdentifier:@"toLookUpTableView" sender:[NSIndexPath indexPathForRow:0 inSection:3]];
        self.getContacts = nil;
    }
    else if (sender == self.getOurContacts) {
        // store returned contacts in array
        self.ContactArray = [[NSArray alloc] initWithArray:Array];
        
        for (ContactSearch *con in Array) { // loop through contact and concatenate name, add name to lookUpItems array (to be sent to look up view)
            NSString *fullName = [Format nameFromComponents:[NSMutableArray arrayWithObjects:con.conTitle,con.conFirstName, con.conMiddleName, con.conSurname, nil]];
            [self.lookUpItems addObject:fullName];
        }
        
        //segue to the look up view.
        [self performSegueWithIdentifier:@"toLookUpTableView" sender:[NSIndexPath indexPathForRow:0 inSection:4]];
        self.getOurContacts = nil;
    }
    else if (sender == self.saveEvent) {
        [self.savingView removeFromSuperview];
        //if data recieved place it into
        int errorResponse = [(([Array count] > 0)? [Array objectAtIndex:0] : @"6") integerValue];
        
        if (errorResponse == 0) { //if save successful
            // set event to read via webservice
            NSURL *url = [NSURL URLWithString:[appURL stringByAppendingFormat:@"/Service1.asmx/setReadUnreadABL?readUnread=%@&eventID=%@&userID=%d",@"True", self.eventToEdit.eventID, appUserID]];
            
            FetchXML* setReadUnread = [[FetchXML alloc] initWithUrl:url delegate:self className:@"NSNumber"];
            
            if (![setReadUnread fetchXML])
                [[[UIAlertView alloc] initWithTitle:@"Connection Error" message:@"Could not connect to the server" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];   
            
            [self updateCoreDataEvent:self.eventToEdit];
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
            self.btnSave.enabled = true; //re-enable done button
            self.btnCancel.enabled = true;
        }
        
    }
}

- (void)fetchXMLError:(NSString *)errorResponse :(id)sender
{
    
    if (sender == self.getContacts){
        self.getContacts = nil;
        [[[UIAlertView alloc] initWithTitle:@"Error Fetching Data" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }
    else if (sender == self.getOurContacts) {
        self.getOurContacts = nil;
        [[[UIAlertView alloc] initWithTitle:@"Error Fetching Data" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }
    else if (sender == self.saveEvent) {
        [self.savingView removeFromSuperview];
        self.btnSave.enabled = false;
        self.btnCancel.enabled = false;
        self.saveEvent = nil;
        [[[UIAlertView alloc] initWithTitle:@"Error Saving Data" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }
    
    [self.refreshSpinner stopAnimating];
}

//------------------------------------------------------------------------
//             Fill cells with their respective event data
//------------------------------------------------------------------------
- (void)fillCells
{    
    NSDateFormatter *dfToString;   
    dfToString = [[NSDateFormatter alloc] init];
    
    //check if properties exist - if yes, place in cell, else enter placeholder text.
    [dfToString setDateFormat:@"HH:mm"];
    // if time string is not null or empty string, then convert to date (from seconds since midnight) and then convert to formatted string for display
    self.cellEndTime.detailTextLabel.text = [self.eventToEdit.eveEndTime length] > 0 ? [dfToString stringFromDate:[Format dateFromSecondsSinceMidnight:[self.eventToEdit.eveEndTime integerValue]]] : @"No End Time";
    self.cellDueTime.detailTextLabel.text = [self.eventToEdit.eveDueTime length] > 0 ? [dfToString stringFromDate:[Format dateFromSecondsSinceMidnight:[self.eventToEdit.eveDueTime integerValue]]] : @"No Due Time";
    
    [dfToString setDateStyle:NSDateFormatterMediumStyle];
    self.cellEndDate.detailTextLabel.text = self.eventToEdit.eveEndDate != NULL ? [dfToString stringFromDate:self.eventToEdit.eveEndDate] : @"No End Date";
    self.cellDueDate.detailTextLabel.text = self.eventToEdit.eveDueDate != NULL ? [dfToString stringFromDate:self.eventToEdit.eveDueDate] : @"No Due Date";
    
    self.cellContact.textLabel.text = [self.contactName length] > 0 ? self.contactName : @"No Contact";
    self.cellInternalContact.textLabel.text = [self.internalContactName length] > 0 ? self.internalContactName : @"No Contact";
}

- (BOOL)updateCoreDataEvent:(EventSearch *)EventToSave
{
    // set a predicate to find the event that needs to be updated.
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"eventID == %@", self.eventToEdit.eventID];
    
    BOOL saved = [NSManagedObject updateCoreDataObject:EventToSave forEntityName:@"Event" withPredicate:predicate];
    
    [self.delegate getCoreData];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadCoreData" object:nil];
    
    //[delegate getCoreData];
    
    return saved;
}

@end
