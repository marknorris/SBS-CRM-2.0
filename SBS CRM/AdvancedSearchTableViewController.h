//
//  advancedSearchTableViewController.h
//  SBS CRM
//
//  Created by Tom Couchman on 24/02/2012.
//  Copyright (c) 2012 Shuttleworth Business Systems Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "lookUpTableViewController.h"
#import "dateTimePickerViewController.h"
#import "pickerViewController.h"
#import "CompanySearch.h"
#import "ContactSearch.h"

@interface advancedSearchTableViewController : UITableViewController <lookUpTableViewControllerDelegate, dateTimePickerViewControllerDelegate, pickerViewControllerDelegate>

- (IBAction)btnCancelClick:(id)sender;


// passed from the previous view.
@property (strong, nonatomic) NSString *companySiteID;
@property (strong, nonatomic) NSString *cosSiteName;

//could be set by contact details view sometimes;
@property (strong, nonatomic) NSString *fullName;
@property (strong, nonatomic) NSString *contactID;

@property (strong, nonatomic) CompanySearch *company;

@property (strong, nonatomic) IBOutlet UITableViewCell *cellCompanySite;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellContact;
@property (strong, nonatomic) IBOutlet UILabel *lblType1CellDetail;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellType1;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellType2;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellDueDateFrom;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellDueDateTo;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellCreatedDateFrom;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellCreatedDateTo;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segStatus;
@property (strong, nonatomic) IBOutlet UITextField *txtTitle;
@property (strong, nonatomic) IBOutlet UITextField *txtComments;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellInternalContact;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellNoOfRecords;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segOrderBy;

- (IBAction)clickSearch:(id)sender;

- (IBAction) textFieldDoneEditing:(id)sender;

@end
