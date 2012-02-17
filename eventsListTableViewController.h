//
//  eventsListTableViewController.h
//  SBS CRM
//
//  Created by Tom Couchman on 15/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DDXML.h"
#import "eventSearch.h"
#import "CompanySearch.h"
#import "contactSearch.h"
#import "EventsCellData.h"

@interface eventsListTableViewController : UITableViewController{
    //NSMutableArray *eventsArray;
    NSMutableArray *orderedEventsArray;
}

@property (strong, nonatomic) CompanySearch *company;
@property (strong, nonatomic) contactSearch *contact;

//@property (strong, nonatomic) NSString *companySiteID;
//@property (strong, nonatomic) NSString *contactID;

@property (strong, nonatomic) NSString *viewTitle;
- (BOOL)getDataFromServer;

@end
