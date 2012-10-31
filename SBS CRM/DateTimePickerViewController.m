//
//  dateTimePickerViewController.m
//  SBS CRM
//
//  Created by Tom Couchman on 22/02/2012.
//  Copyright (c) 2012 Shuttleworth Business Systems Limited. All rights reserved.
//

#import "DateTimePickerViewController.h"
#import "AppDelegate.h"

@implementation DateTimePickerViewController

@synthesize delegate;

@synthesize dateTimePicker;
@synthesize dateTime;
@synthesize mode;
@synthesize sourceCellIdentifier;
@synthesize sender;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
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

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];

    if (mode)
        dateTimePicker.datePickerMode = mode;
    if (dateTime)
        dateTimePicker.date = dateTime;
}


- (void)viewDidUnload
{
    [self setDateTimePicker:nil];
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

- (IBAction)clickDone:(id)btnSender {
    
    //save the new time to user defaults
    // Store the data
    
    //dateTimePicker.date;
    
    [self.delegate dateTimePickerViewController:self didSelectDateTime:dateTimePicker.date  withSourceCellIdentifier:sourceCellIdentifier withSender:sender];
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)clickCancel:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}
@end
