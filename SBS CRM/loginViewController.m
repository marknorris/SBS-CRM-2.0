//
//  loginViewController.m
//  SBS CRM
//
//  Created by Tom Couchman on 08/02/2012.
//  Copyright (c) 2012 Shuttleworth Business Systems Limited. All rights reserved.
//

// TODO - remove webservice calls and xml parsing from this class. 

#import "loginViewController.h"

#import "DDXMLDocument.h"
#import "DDXMLNode.h"
#import "DDXMLElement.h"
#import "DDXML.h"

#import "AppDelegate.h"
#import "Event.h"
#import "Contact.h"
#import "Communication.h"
#import "Company.h"
#import "Attachment.h"
#import "NSManagedObject+CoreDataManager.h"

#import "myEventsTableViewController.h"


#import "UserDetails.h"

#import "XMLParser.h"


//##################################################################
//  login View Controller - Private Interface
//##################################################################
@interface loginViewController(){
    
    KeychainItemWrapper *keychainID;
    KeychainItemWrapper *keychainURL;
    
    //custom keyboard
    UIToolbar *keyboardToolBar;
}

- (void)getUserID;
- (void)deleteUserData;


@property (nonatomic, strong) fetchXML *getUserDetails;

//------ custom keyboard ------
@property (nonatomic, strong) UIToolbar *keyboardToolBar;

- (void)resignKeyboard:(id)sender;
- (void)previousField:(id)sender;
- (void)nextField:(id)sender;
//-----------------------------

@end




//##################################################################
//  login View Controller - Implementation
//##################################################################
@implementation loginViewController


@synthesize getUserDetails;

//-------- User details -------
@synthesize txtUserName;
@synthesize txtPassword;
@synthesize txtURL;
//-----------------------------

//------- remember id? -------- 
@synthesize stayLoggedIn;
//-----------------------------

//------ custom keyboard ------
@synthesize keyboardToolBar;
@synthesize logInButton;
//-----------------------------


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


//------------------------------------------------------------------
//  View Did Load
//------------------------------------------------------------------
- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    //listen to for the 'deleteUserData' notification when the user logs out.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteUserData) name:@"deleteUserData" object:nil];
    
    // retrieve keychain
    keychainID =[[KeychainItemWrapper alloc] initWithIdentifier:@"SBSCRMUserID" accessGroup:nil];
    
    // Fille username and url text fiels with text from keychain
    txtUserName.text = [keychainID objectForKey:(__bridge id)kSecAttrAccount];
    txtURL.text = [keychainID objectForKey:(__bridge id)kSecAttrService];
    
    // if an Id has been stored in the keychain then the user had selected "stay logged in":
    if (![[keychainID objectForKey:(__bridge id)kSecValueData] isEqualToString:@""])
    {
        // Load the values into the global variables // these will be needed for retrieving data.
        appUserID = [[keychainID objectForKey:(__bridge id)kSecValueData] integerValue];
        appURL = [keychainID objectForKey:(__bridge id)kSecAttrService];
        appContactID = [[NSUserDefaults standardUserDefaults] integerForKey:@"contactID"];
        appCompanySiteID = [[NSUserDefaults standardUserDefaults] integerForKey:@"companySiteID"];

        self.view.hidden = YES; // hide view as the user will automatically be taken to the next screen
        
        //as the user should have core data stored already, do not do a refresh on load of myEventsTableViewController
        [[NSUserDefaults standardUserDefaults]  setObject:@"NO" forKey:@"refreshOnLoad"];
    }
    else if (![[keychainID objectForKey:(__bridge id)kSecAttrAccount] isEqualToString:@""])
    {
        // if the user id was not saved but there is a username this means the user selected do not stay logged in on the previous visit so delete previous details:
        // TODO: Why would there still be a username saved?
        [self deleteUserData];
    }
    
    //-------- custom keyboard -------
    
    if (keyboardToolBar == nil)
    {
        keyboardToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,0,self.view.bounds.size.width, 44)];
        keyboardToolBar.tintColor = [UIColor blackColor];
        UIBarButtonItem *previousButton = [[UIBarButtonItem alloc] initWithTitle:@"Previous" style:UIBarButtonItemStyleBordered target:self action:@selector(previousField:)];
        UIBarButtonItem *nextButton = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStyleBordered target:self action:@selector(nextField:)];
        UIBarButtonItem *extraSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(resignKeyboard:)];
        doneButton.style = UIBarButtonItemStyleDone;
        
        [keyboardToolBar setItems:[[NSArray alloc] initWithObjects:previousButton,nextButton,extraSpace,doneButton,nil]];
    }
    
    // add the toolbars to the keyboards of each of the text fields.
    txtUserName.inputAccessoryView = keyboardToolBar;
    txtPassword.inputAccessoryView = keyboardToolBar;
    txtURL.inputAccessoryView = keyboardToolBar;
    
    //------ end custom keyboard ------
}


- (void)viewDidAppear:(BOOL)animated{
    
    if (appUserID != 0) //if the user had selected 'stay logged in' on last login           
        [self performSegueWithIdentifier:@"login" sender:self]; //then go to next screen (this cannot be done before viewDidAppear)
    else //ensusre the login screen is visible
        self.view.hidden = false;
}


//------------------------------------------------------------------
//  Login
//------------------------------------------------------------------
- (IBAction)login:(id)sender {
    // edit userdefaults to enable refresh on load of myEventTableViewController.
    [[NSUserDefaults standardUserDefaults]  setObject:@"YES" forKey:@"refreshOnLoad"];
    
    [self resetTextFieldColors];

    
    //if data has been inputted into all the required fields
    if([self validateTextFields])
    {
        //save username and url to keychain
        [keychainID setObject:txtUserName.text forKey:(__bridge id)kSecAttrAccount];
        [keychainID setObject:txtURL.text forKey:(__bridge id)kSecAttrService];
        
        // enable the network activity indicator
        UIApplication *app = [UIApplication sharedApplication];  
        //[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        [app setNetworkActivityIndicatorVisible:YES]; 
        
        //disable the login button
        logInButton.enabled = NO;
        
        ////////(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{  
            //retrieve the ID from the server
            //int currentID = 
            [self getUserID];
            
            ///dispatch_sync(dispatch_get_main_queue(), ^{
                //disable the network activity indicator
                
                //enable the login button
                //logInButton.enabled = YES;
                /*
                switch (currentID) {
                    case -1: //case 1 means the server has denied the request for an ID
                    {
                        UIAlertView *error = [[UIAlertView alloc] initWithTitle:@"Invalid username or password" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                        [error show];
                        break;
                    }
                    case -2: // 0 means the xml could not be parsed - e.g. the file was not returned.
                    {
                        UIAlertView *notConnected = [[UIAlertView alloc] initWithTitle:@"Could not connect to the server" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                        [notConnected show];
                        break;
                    }
                    default: //else success
                    {
                        // once the id has been returned check if the user wished to log in automatically on their next visit
                        if (self.stayLoggedIn.selectedSegmentIndex == 0)
                        {
                            // if yes save the ID to the keychain.
                            [keychainID setObject:[NSString stringWithFormat:@"%d",currentID] forKey:(__bridge id)kSecValueData];
                        }
                        //store details to global variables
                        appUserID = currentID;
                        appURL = txtURL.text;
                        //go to next storyboard segment
                        [self performSegueWithIdentifier:@"login" sender:self];
                        break;
                    }
              }*/
            ///});
        ///});
        
    }

}







-(void)fetchXMLError:(NSString *)errorResponse:(id)sender{
    logInButton.enabled = YES;
    if (self.view.window) // don't display if this view is not active. TODO:make sure this method is never even called!
    {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO]; 
        
        // If error recieved, display alert.
        [[[UIAlertView alloc] initWithTitle:@"Error Fetching Data" message:errorResponse delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }
    //fetchingSearchResults = NO;
}

-(void)docRecieved:(NSDictionary *)docDic:(id)sender{
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO]; 
    NSString *classKey = [docDic objectForKey:@"ClassName"];
    NSArray *array = [[NSArray alloc] initWithArray:[[[XMLParser alloc] init]parseXMLDoc:[docDic objectForKey:@"Document"] toClass:NSClassFromString(classKey)]];
    
    if ([array count] > 0)
    {
        logInButton.enabled = YES;
        
        UserDetails *details = [array objectAtIndex:0];
        // once the id has been returned check if the user wished to log in automatically on their next visit
        if (self.stayLoggedIn.selectedSegmentIndex == 0)
        {
            // if yes save the ID to the keychain.
            [keychainID setObject:[NSString stringWithFormat:@"%d",details.userID] forKey:(__bridge id)kSecValueData];
        }
        //store details to global variables
        appUserID = details.userID;
        appURL = txtURL.text;
        appCompanySiteID = details.companySiteID;
        appContactID = details.contactID;
        
        
        [[NSUserDefaults standardUserDefaults] setInteger:appContactID forKey:@"contactID"];
        [[NSUserDefaults standardUserDefaults] setInteger:appCompanySiteID forKey:@"companySiteID"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        //go to next storyboard segment
        [self performSegueWithIdentifier:@"login" sender:self];
    }
    
    
}



//------------------------------------------------------------------
//  get User ID
//------------------------------------------------------------------
- (void)getUserID
{
    
    //create URL, retrieve xml from server, parse xml, get userID
    NSURL *url = [[NSURL alloc] initWithString:[txtURL.text stringByAppendingFormat:@"/service1.asmx/getUserIDABL?userName=%@&password=%@",[txtUserName.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[txtPassword.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    NSLog(@"%@",url);
    
    getUserDetails = [[fetchXML alloc] initWithUrl:url delegate:self className:@"UserDetails"];
    [getUserDetails fetchXML];
    
    return;
    /*
    NSError *fetchError;
    NSString *xmlString = [[NSString alloc] initWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&fetchError];
    
    if (xmlString == NULL && fetchError != NULL)
    {
        
        NSLog(@"%d",[fetchError code] );
    }
    
    //remove xmlns from the xml file to stop the parser errorin
    xmlString = [xmlString stringByReplacingOccurrencesOfString:@"xmlns" withString:@"noNSxml"];
    //NSLog(@"String:%@", xmlString);
    NSData *xmlData = [xmlString dataUsingEncoding:NSUTF8StringEncoding];
    NSError* error = nil;
    DDXMLDocument* xmlDoc = [[DDXMLDocument alloc] initWithData:xmlData options:0 error:&error];
    //NSLog(@"%@", [xmlDoc XMLStringWithOptions:DDXMLNodePrettyPrint]);
    if (error) {
        //if the connection fails return a -2
        return -2;
    }
    else
    {
        NSArray *childElements = [[xmlDoc rootElement] children];
        
        for (DDXMLElement* element in childElements)
        {
            if ([element.name isEqualToString:@"userID"])
                userID = [[element stringValue] intValue];
            else if ([element.name isEqualToString:@"contactID"])
            {
                appContactID = [[element stringValue] intValue];
                [[NSUserDefaults standardUserDefaults] setInteger:appContactID forKey:@"contactID"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            else if ([element.name isEqualToString:@"companySiteID"])
            {
                appCompanySiteID = [[element stringValue] intValue];
                [[NSUserDefaults standardUserDefaults] setInteger:appCompanySiteID forKey:@"companySiteID"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }
    } 
    return userID;*/
}





- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle






- (void)viewDidUnload
{
    [self setStayLoggedIn:nil];
    [self setLogInButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
    return YES;
}


//--------------------------------------------------------------------------
//  text field validation methods
//--------------------------------------------------------------------------

- (BOOL)validateTextFields{
    
    BOOL isValid = true;
    
    //check which fields are empty / invalid and set their bg color to red, also make them the selected field.
    if(txtURL.text.length == 0 || [txtURL.text  isEqualToString:@"http://"])
    {
        txtURL.backgroundColor = [UIColor colorWithRed:255 green:0 blue:0 alpha:0.5 ];
        [txtURL becomeFirstResponder];
        isValid = false;
    }
    if(txtPassword.text.length == 0)
    {
        txtPassword.backgroundColor = [UIColor colorWithRed:255 green:0 blue:0 alpha:0.5 ];
        [txtPassword becomeFirstResponder];
        isValid = false;
    }
    if(txtUserName.text.length == 0)
    {
        [txtUserName becomeFirstResponder];
        txtUserName.backgroundColor = [UIColor colorWithRed:255 green:0 blue:0 alpha:0.5 ];
        isValid = false;
    }
    
    if (!isValid)
    {
        //inform the user
        UIAlertView *alertMissingDetails = [[UIAlertView alloc] initWithTitle:@"Please enter your log in detials" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];    
        [alertMissingDetails show];
    }
    
    return isValid;
}


- (void)resetTextFieldColors
{
    //reset colours of textfields to white incase they had been set to red due to invalid input
    txtURL.backgroundColor = [UIColor whiteColor];
    txtPassword.backgroundColor = [UIColor whiteColor];
    txtUserName.backgroundColor = [UIColor whiteColor];
}
//-------------------- end text field validation methods -------------------






//--------------------------------------------------------------------------
//  custom keyboard methods
//--------------------------------------------------------------------------
- (void)resignKeyboard:(id)sender  {
    [txtUserName resignFirstResponder];
    [txtPassword resignFirstResponder];
    [txtURL resignFirstResponder];
}

- (void)previousField:(id)sender{
    if ([txtUserName isFirstResponder])
        [txtURL becomeFirstResponder];
    else if ([txtPassword isFirstResponder])
        [txtUserName becomeFirstResponder];
    else if ([txtURL isFirstResponder])
        [txtPassword becomeFirstResponder];
}

- (void)nextField:(id)sender{
    if ([txtUserName isFirstResponder])
        [txtPassword becomeFirstResponder];
    else if ([txtPassword isFirstResponder])
        [txtURL becomeFirstResponder];
    else if ([txtURL isFirstResponder])
        [txtUserName becomeFirstResponder];
}
//----------------------- end custom keyboard methods ----------------------


-(BOOL)textFieldShouldReturn:(UITextField *) textField
{
    id sender = sender;
    [self login:sender];
    return YES;
}



//--------------------------------------------------------------------------
//  delete User Data
//--------------------------------------------------------------------------
-(void)deleteUserData{

    self.view.hidden = NO; // ensures the view is not hidden.
    
    //remove badges
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    //remove local notifications
    [[UIApplication sharedApplication] cancelAllLocalNotifications];

    //delete all the keychain values, but resae username and URL.
    [keychainID resetKeychainItem];
    [keychainID setObject:txtUserName.text forKey:(__bridge id)kSecAttrAccount];
    [keychainID setObject:txtURL.text forKey:(__bridge id)kSecAttrService];
    
    //delete core data:
    [NSManagedObject deleteAllObjectsForEntityName:@"Event"];
    [NSManagedObject deleteAllObjectsForEntityName:@"Contact"];
    [NSManagedObject deleteAllObjectsForEntityName:@"Communication"];
    [NSManagedObject deleteAllObjectsForEntityName:@"Company"];
    [NSManagedObject deleteAllObjectsForEntityName:@"Attachment"];

}

@end
