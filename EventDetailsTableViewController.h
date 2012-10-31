//
//  eventDetailsTableViewController.h
//  SBS CRM
//
//  Created by Tom Couchman on 15/02/2012.
//  Copyright (c) 2012 Shuttleworth Business Systems Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EventSearch.h"
#import "CompanySearch.h"
#import "ContactSearch.h"
#import "FetchXML.h"
#import "EditTableViewController.h"

@interface EventDetailsTableViewController : UITableViewController <UIActionSheetDelegate, FetchXMLDelegate, EditTableViewControllerDelegate>

@property (nonatomic) BOOL isCoreData;
@property (strong, nonatomic) EventSearch *eventDetails;
@property (strong, nonatomic) CompanySearch *company;
@property (strong, nonatomic) ContactSearch *contact;
@property (strong, nonatomic) ContactSearch *ourContact;

//cell and label outlets:
@property (strong, nonatomic) IBOutlet UILabel *lblTitle;
@property (strong, nonatomic) IBOutlet UILabel *lblType;
@property (strong, nonatomic) IBOutlet UILabel *lblCustomer;
@property (strong, nonatomic) IBOutlet UILabel *lblDueDateTime;
@property (strong, nonatomic) IBOutlet UILabel *lblEndDateTime;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellLblSite;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellLblContact;
@property (strong, nonatomic) IBOutlet UITextView *txtComments;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellLblCreateByName;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellLblCreateByDateTime;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellLblOurContact;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellComments;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellCommentLink;
@property (strong, nonatomic) IBOutlet UIView *viewEventDetail;

- (IBAction)btnActions_Click:(id)sender;
-(void) checkNetworkStatus:(NSNotification *)notice;

@end
