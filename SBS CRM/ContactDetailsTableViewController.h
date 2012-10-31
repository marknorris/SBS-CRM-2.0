//
//  contactDetailsTableViewController.h
//  SBS CRM
//
//  Created by Tom Couchman on 14/02/2012.
//  Copyright (c) 2012 Shuttleworth Business Systems Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContactSearch.h"
#import "ContactsTableViewController.h"
#import "CompanySearch.h"

@interface ContactDetailsTableViewController : UITableViewController

@property (strong, nonatomic) ContactSearch *contactDetail;
@property (strong, nonatomic) CompanySearch *company;
@property (nonatomic) BOOL isCoreData;
@property (strong, nonatomic) IBOutlet UILabel *contactNameOutlet;
@property (strong, nonatomic) IBOutlet UILabel *siteNameDescriptionOutlet;
@property (strong, nonatomic) IBOutlet UITextView *addressOutlet;
@property (strong, nonatomic) IBOutlet UITableViewCell *eventsOutlet;
@property (strong, nonatomic) IBOutlet UITableViewCell *addressCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellAdvancedEvents;
@property (strong, nonatomic) NSMutableArray *communicationArray;

- (void)checkNetworkStatus:(NSNotification *)notice;

@end
