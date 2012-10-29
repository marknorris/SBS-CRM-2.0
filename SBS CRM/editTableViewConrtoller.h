//
//  editTableViewConrtoller.h
//  SBS CRM 2.0
//
//  Created by Tom Couchman on 17/05/2012.
//  Copyright (c) 2012 Shuttleworth Business Systems Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "dateTimePickerViewController.h"
#import "lookUpTableViewController.h"
#import "fetchXML.h"
#import "EventSearch.h"
#import "ContactSearch.h"

@protocol editEventDelegate <NSObject> 
@required
-(void)getCoreData;
@end

@interface editTableViewConrtoller : UITableViewController <lookUpTableViewControllerDelegate, dateTimePickerViewControllerDelegate, fetchXMLDelegate, UITextFieldDelegate>
- (IBAction)btnCancel_Click:(id)sender;
- (IBAction)btnSave_Click:(id)sender;

//cell outlets:
@property (strong, nonatomic) IBOutlet UITableViewCell *cellDueDate;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellDueTime;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellEndDate;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellEndTime;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellContact;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellInternalContact;
@property (strong, nonatomic) IBOutlet UITextField *txtTitle;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnCancel;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnSave;

@property (nonatomic, strong) id delegate;

// EventSearch proerty to hold event to be edited
@property (nonatomic, strong) EventSearch *eventToEdit;
// ContactSearch Property to hold the contact and internal contact (in case these are not alrelady in core data
@property (nonatomic, strong) ContactSearch *contact, *internalContact;

@property (nonatomic, strong) NSString *contactName;
@property (nonatomic, strong) NSString *internalContactName;

@end