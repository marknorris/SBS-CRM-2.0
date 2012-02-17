//
//  contactDetailsTableViewController.h
//  SBS CRM
//
//  Created by Tom Couchman on 14/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "contactSearch.h"
#import "contactsTableViewController.h"
#import "CompanySearch.h"

@interface contactDetailsTableViewController : UITableViewController{
    NSString *fullAddress;
    NSMutableArray *communicationArray;
    NSString *fullName;
    
}
//@property (strong, nonatomic) IBOutlet UITableViewCell *emailCell;

@property (nonatomic, retain) NSManagedObjectContext *context;

@property (strong, nonatomic) contactSearch *contactDetail;
@property (strong, nonatomic) CompanySearch *company;

@property (nonatomic) BOOL isCoreData;

@property (strong, nonatomic) IBOutlet UILabel *contactNameOutlet;
@property (strong, nonatomic) IBOutlet UILabel *siteNameDescriptionOutlet;
@property (strong, nonatomic) IBOutlet UITextView *addressOutlet;
@property (strong, nonatomic) IBOutlet UITableViewCell *eventsOutlet;
@property (strong, nonatomic) IBOutlet UITableViewCell *addressCell;

@end
