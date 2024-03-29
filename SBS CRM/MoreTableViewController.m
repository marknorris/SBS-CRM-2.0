//
//  moreTableViewController.m
//  SBS CRM
//
//  Created by Tom Couchman on 09/02/2012.
//  Copyright (c) 2012 Shuttleworth Business Systems Limited. All rights reserved.
//

#import "MoreTableViewController.h"
#import "AppDelegate.h"
#import "DateTimePickerViewController.h"

@implementation MoreTableViewController

@synthesize logOutCell = _logOutCell;
@synthesize cellDefaultAlert = _cellDefaultAlert;
@synthesize logOut = _logOut;
@synthesize dfToString = _dfToString;

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
    
    self.dfToString = [[NSDateFormatter alloc] init];
    [self.dfToString setDateFormat:@"HH:mm"];
    self.cellDefaultAlert.detailTextLabel.text = [self.dfToString stringFromDate:appDefaultAlertTime];
}

- (void)viewDidUnload
{
    [self setLogOut:nil];
    [self setLogOutCell:nil];
    [self setCellDefaultAlert:nil];
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
    return YES;
}

- (IBAction)logOutAction:(id)sender
{
    appUserID = 0;
    //send notification to delete the userid etc.
    [[NSNotificationCenter defaultCenter] postNotificationName:@"deleteUserData" object:self];
    
    //TODO: is dismissing the tabbarcontroller the right thing to do? else are the other views not being dismissed?
    //[self.parentViewController.navigationController popViewControllerAnimated:YES];
    [self.tabBarController dismissViewControllerAnimated:YES completion:nil];
    //[self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //if the segue is to the date time picker
    if ([segue.identifier isEqualToString:@"toDateTimePicker"]) {
        //set the required values for the look up view controller
        DateTimePickerViewController *dateTimePickerViewController = segue.destinationViewController;
        dateTimePickerViewController.delegate = self; //set self as the delegate
        
        NSDateFormatter *dfToDate = [[NSDateFormatter alloc] init];
        [dfToDate setDateFormat:@"HH:mm"];
        //set the datetime pickers date to the currently set date:
        dateTimePickerViewController.dateTime = [dfToDate dateFromString:self.cellDefaultAlert.detailTextLabel.text];
        dateTimePickerViewController.sourceCellIdentifier = @"cellDefaultAlert.detailTextLabel.text";
        dateTimePickerViewController.mode = UIDatePickerModeTime;
        
    }
}

- (void) dateTimePickerViewController: (DateTimePickerViewController *)controller didSelectDateTime:(NSDate *)returnedDate withSourceCellIdentifier:(NSString *)returnedSourceCellIdentifier withSender:(id)sender
{
    //gets the date returned from the datetimepicker and puts into userdefaults, appdefaultalerttime gloabal variable and displays in cell.
    
    //close the date time picker.
    [self dismissModalViewControllerAnimated:YES];
    
    NSString *newTime = [self.dfToString stringFromDate:returnedDate];
    
    //if the date has changed:
    if (![self.cellDefaultAlert.detailTextLabel.text isEqualToString:newTime]) {
        //set the default due time into the cell.
        self.cellDefaultAlert.detailTextLabel.text = newTime;
        appDefaultAlertTime = returnedDate;
        
        // set the default alert time into userdefaults, so it is not lost when the app is closed.
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:returnedDate forKey:@"defaultAlertTime"];
        [defaults synchronize];
        
        [[[UIAlertView alloc] initWithTitle:@"Default Due Time" message:@"Changes will be made on next sync" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }
    
}

@end
