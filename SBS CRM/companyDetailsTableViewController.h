//
//  companyDetailsTableViewController.h
//  SBS CRM
//
//  Created by Tom Couchman on 14/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CompanySearch.h"
#import "companyTableViewController.h"

@class Reachability;

@interface companyDetailsTableViewController : UITableViewController{
    NSString *fullAddress;
    Reachability* internetReachable;
    Reachability* hostReachable;
    BOOL internetActive;
    BOOL hostActive;
}
@property (strong, nonatomic) IBOutlet UITextView *txtAddress;
@property (strong, nonatomic) IBOutlet UILabel *lblSiteName;
@property (strong, nonatomic) IBOutlet UILabel *lblDescription;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellAddress;

@property (strong, nonatomic) CompanySearch *companyDetail;

-(void) checkNetworkStatus:(NSNotification *)notice;

@end
