//
//  eventDetailsTableViewController.h
//  SBS CRM
//
//  Created by Tom Couchman on 15/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "eventSearch.h"
#import "CompanySearch.h"
#import "contactSearch.h"

@interface eventDetailsTableViewController : UITableViewController{
    NSMutableArray *attachmentArray;
}

@property (nonatomic) BOOL isCoreData;

@property (strong, nonatomic) eventSearch *eventDetails;
@property (strong, nonatomic) CompanySearch *company;
@property (strong, nonatomic) contactSearch *contact;
@property (strong, nonatomic) contactSearch *ourContact;

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

@property (nonatomic, retain) NSManagedObjectContext *context;


@end
