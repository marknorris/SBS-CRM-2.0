//
//  contactListTableViewController.h
//  SBS CRM
//
//  Created by Tom Couchman on 16/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CompanySearch.h"

@interface contactListTableViewController : UITableViewController

@property (strong, nonatomic) NSString *companySiteID;
@property (strong, nonatomic) CompanySearch *company;


@end
