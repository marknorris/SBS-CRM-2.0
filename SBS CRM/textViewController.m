//
//  textViewController.m
//  SBS CRM
//
//  Created by Tom Couchman on 15/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "textViewController.h"
#import "addCommentViewController.h"
@implementation textViewController
@synthesize btnAdd;
@synthesize text;
@synthesize txtText;
@synthesize eventId;

@synthesize editable;

- (IBAction)clickDone:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

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


- (void)viewDidLoad
{
    [super viewDidLoad];
    txtText.text = text;
    if (editable == NO) // if comments cannot be added to, remove the add button.
        btnAdd.enabled = false;
        
    
}


- (void)viewDidUnload
{
    [self setTxtText:nil];
    [self setBtnAdd:nil];
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

-(void)commentUpdated:(NSString *)comment
{
    txtText.text = comment;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([segue.identifier isEqualToString:@"toAddComment"])
    {
        addCommentViewController *acvc = segue.destinationViewController;
        acvc.delegate = self;
        acvc.eventId = eventId; // pass through the eventId to the add comment view controller.
    }
    
}

@end
