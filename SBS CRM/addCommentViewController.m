//
//  addCommentViewController.m
//  SBS CRM 2.0
//
//  Created by Tom Couchman on 10/05/2012.
//  Copyright (c) 2012 Shuttleworth Business Systems Limited. All rights reserved.
//

#import "addCommentViewController.h"
#import "AppDelegate.h"
#import "XMLParser.h"
#import "Event.h"

#import "loadingSavingView.h"

#import "CoreDataManager.h"

@interface addCommentViewController ()
@property (strong, nonatomic) fetchXML *saveComment;
@property (strong, nonatomic) loadingSavingView *savingView;
@property (nonatomic) int keyboardHeight;
@end

@implementation addCommentViewController
@synthesize btnDone;
@synthesize btnCancel;

@synthesize txtComment;

@synthesize delegate,eventId;

@synthesize savingView,saveComment,keyboardHeight;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    txtComment.delegate = self;
    
    //listen out for keyboardwillshow notification, to get the height of the keyboard when available.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidUnload
{
    [self setTxtComment:nil];
    [self setBtnDone:nil];
    [self setBtnCancel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (IBAction)btnCancelClick:(id)sender {
    [saveComment cancel]; // if there is a download taking place, cancel it.
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)btnDoneClick:(id)sender {
    
    if ([txtComment.text length] == 0)
    {
        [[[UIAlertView alloc] initWithTitle:@"Please Enter a Comment" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil]show];
        return;
    }
    else if ([txtComment.text length] > 2000)
    {
        [[[UIAlertView alloc] initWithTitle:@"Comment is too long" message:[NSString stringWithFormat:@"Comment is currently %d characters long, please reduce it to within 2000 characters",[txtComment.text length]]  delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil]show];
        return;
    }
    
    
    //don't allow user to click the button again while the data is being sent and recieved.
    btnDone.enabled = false;
    btnCancel.enabled = false; // can't cancel as data is sent immediately, delays are most likely due to waiting for the confirmation response
    txtComment.editable = false;
    
    NSURL *url = [NSURL URLWithString:[appURL stringByAppendingFormat:@"/service1.asmx/addComment?eventID=%@&userID=%d&comment=%@",eventId,appUserID,[txtComment.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    
    saveComment = [[fetchXML alloc] initWithUrl:url delegate:self className:@"NSNumber"];

    if (![saveComment fetchXML])
    {
        //Show alert
        [[[UIAlertView alloc] initWithTitle:@"Connection Error" message:@"Could not connect to the server" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil]show];
        return;
    }
    

    savingView = [[loadingSavingView alloc] initWithFrame:CGRectMake(txtComment.frame.size.width / 2 - 60, txtComment.frame.size.height / 2 - 50, 120, 30) withMessage:@"Saving..."];
    
    
    [txtComment addSubview:savingView];
}


-(void)fetchXMLError:(NSString *)errorResponse:(id)sender{
    

    
    if (self.view.window) // don't display if this view is not active. TODO:make sure this method is never event called!
    {
        // If error recieved, display alert.
        [[[UIAlertView alloc] initWithTitle:@"Error saving comment" message:errorResponse delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }
    
    btnDone.enabled = true; //re-enable done button
    btnCancel.enabled = true;
    txtComment.editable = true;
    [savingView removeFromSuperview];
}

-(void)docRecieved:(NSDictionary *)docDic:(id)sender{
    
    //[NSThread sleepForTimeInterval:5.0];
    
    [savingView removeFromSuperview];

    //parse the data, idenifying it's type using the returned class key:
    NSString *classKey = [docDic objectForKey:@"ClassName"];
    NSArray *Array = [[[XMLParser alloc] init]parseXMLDoc:[docDic objectForKey:@"Document"] toClass:NSClassFromString(classKey)];

    if ([Array count] > 0 && ![[Array objectAtIndex:0] isEqualToString:@"-1"]) //if something returned and not error indicator:
    {
        //
        
        NSString *comment = [Array objectAtIndex:0];
        [delegate commentUpdated:comment]; //send the comment through to the previous screen (as it does not access core data)
        [self saveCommentToCoreData:comment];
        [self dismissModalViewControllerAnimated:YES];
    }
    else // if nothing returned, or error indicator returned. 
    {
        [[[UIAlertView alloc] initWithTitle:@"Error saving comment" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil]show];
        btnDone.enabled = true; //re-enable done button
        btnCancel.enabled = true;
        txtComment.editable = true;
    }
}

- (void)saveCommentToCoreData:(NSString *)comment{
    
    //find the event where the event ID matches that of the current event.
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"eventID == %@", eventId];
    NSArray *ResultsArray = [NSManagedObject fetchObjectsForEntityName:@"Event" withPredicate:predicate withSortDescriptors:nil];
    
    // if the event is found, then the event is core data and should be updated. else, just call for the event to be refreshed.
    if ([ResultsArray count] > 0)
    {
        Event* eveToUpdate = [ResultsArray objectAtIndex:0];
        
        // update the comments
        eveToUpdate.eveComments = comment;
        NSLog(@" comment : %@", comment);
        
        //save the updated event back to core data
        [NSManagedObject updateCoreDataObject:eveToUpdate forEntityName:@"Event" withPredicate:predicate];
    }
    

    
    //create a user info dictionary to store the evenId
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObject:eventId forKey:@"eventId"];
    //send notification to refresh the tableview on myevents screen.
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadEvent" object:nil userInfo:userInfo];
    //update myEventsView
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadCoreData" object:nil userInfo:userInfo];
}


-(void)keyboardWasShown:(NSNotification*)aNotification{
    NSDictionary* info = aNotification.userInfo;
    keyboardHeight = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;
    [self animateTextField:txtComment up: YES byDistance:keyboardHeight];
}

-(void)keyboardWillBeHidden:(NSNotification*)aNotification{
    //put the text field back to it's original height.
    [self animateTextField:txtComment up: NO byDistance:keyboardHeight];
}

- (void) animateTextField:(UITextView*)textField up:(BOOL)up byDistance:(int)distance
{
    const float movementDuration = 0.3f; // tweak as needed
    
    //add padding, to create space between text and keyboard.
    int padding = 5;
    distance += padding;
    
    int change = (up ? -distance : distance);
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    txtComment.frame = CGRectMake(txtComment.frame.origin.x,txtComment.frame.origin.y,txtComment.frame.size.width, txtComment.frame.size.height + change);
    [UIView commitAnimations];
}



@end
