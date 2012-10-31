//
//  pickerViewController.m
//  SBS CRM
//
//  Created by Tom Couchman on 27/02/2012.
//  Copyright (c) 2012 Shuttleworth Business Systems Limited. All rights reserved.
//

#import "PickerViewController.h"

@interface PickerViewController()
{
    NSInteger selectedIndex;
}

@end

@implementation PickerViewController

@synthesize delegate = _delegate;
@synthesize sourceCellIdentifier = _sourceCellIdentifier;
@synthesize itemArray = _itemArray;
@synthesize picker = _picker;
@synthesize item = _item;

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

    [self.picker selectRow:[self.itemArray indexOfObject:self.item] inComponent:0 animated:NO];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView;
{
    return 1;
}

/*
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    something =    [arrayNo objectAtIndex:row];
}
*/

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component;
{
    return [self.itemArray count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component;
{
    //NSLog(@"current item: %@", [itemArray objectAtIndex:row]);
    //NSLog(@"item: %@", item);

    return [self.itemArray objectAtIndex:row];
}

- (void)viewDidUnload
{
    self.picker = nil;
    [self setPicker:nil];
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

- (IBAction)clickDone:(id)sender
{    
    [self.delegate pickerViewController:self didSelectItem:[self.itemArray objectAtIndex:[self.picker selectedRowInComponent:0]]  withSourceCellIdentifier:self.sourceCellIdentifier];
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)clickCancel:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

@end
