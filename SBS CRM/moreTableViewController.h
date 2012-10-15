//
//  moreTableViewController.h
//  SBS CRM
//
//  Created by Tom Couchman on 09/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "dateTimePickerViewController.h"

@interface moreTableViewController : UITableViewController <dateTimePickerViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UIButton *logOut;
@property (strong, nonatomic) IBOutlet UITableViewCell *logOutCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellDefaultAlert;
@property (strong, nonatomic) NSDateFormatter *dfToString;

- (IBAction)logOutAction:(id)sender;

@end
