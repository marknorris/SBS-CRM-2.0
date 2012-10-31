//
//  addEventViewCotroller.h
//  SBS CRM 2.0
//
//  Created by Tom Couchman on 30/05/2012.
//  Copyright (c) 2012 Shuttleworth Business Systems Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DateTimePickerViewController.h"
#import "LookUpTableViewController.h"
#import "FetchXML.h"
#import "CompanySiteSearchViewController.h"

@interface AddEventViewController : UITableViewController <LookUpTableViewControllerDelegate, FetchXMLDelegate, CompanySiteSearchViewControllerDelegate, DateTimePickerViewControllerDelegate>

- (IBAction)btnCancel_Click:(id)sender;
- (IBAction)btnSave_Click:(id)sender;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnCancel_Outlet;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnSave_Outlet;

//cell outlets:
@property (strong, nonatomic) IBOutlet UITableViewCell *cellContact;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellInternalContact;
@property (strong, nonatomic) IBOutlet UITextField *txtTitle;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellEventType1;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellEventType2;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellCompanySite;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellDueDate;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellDueTime;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellEndDate;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellEndTime;
@property (strong, nonatomic) IBOutlet UITextView *txtComment;

@end
