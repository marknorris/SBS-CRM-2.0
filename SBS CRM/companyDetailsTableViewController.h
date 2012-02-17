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

@interface companyDetailsTableViewController : UITableViewController{
    NSString *fullAddress;
}
@property (strong, nonatomic) IBOutlet UITextView *txtAddress;
@property (strong, nonatomic) IBOutlet UILabel *lblSiteName;
@property (strong, nonatomic) IBOutlet UILabel *lblDescription;

@property (strong, nonatomic) CompanySearch *companyDetail;

@end
