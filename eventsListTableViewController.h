//
//  eventsListTableViewController.h
//  SBS CRM
//
//  Created by Tom Couchman on 15/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DDXML.h"
#import "EventSearch.h"
#import "CompanySearch.h"
#import "ContactSearch.h"
#import "EventsCellData.h"
#import "AppDelegate.h"

@interface eventsListTableViewController : UITableViewController{
    NSMutableArray *orderedEventsArray;
}

@property (strong, nonatomic) CompanySearch *company;
@property (strong, nonatomic) ContactSearch *contact;
@property (nonatomic) BOOL orderByCreatedDate;

@property (strong, nonatomic) NSString *advancedURL;

@end
