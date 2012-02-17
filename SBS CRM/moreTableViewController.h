//
//  moreTableViewController.h
//  SBS CRM
//
//  Created by Tom Couchman on 09/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface moreTableViewController : UITableViewController



@property (strong, nonatomic) IBOutlet UIButton *logOut;
- (IBAction)logOutAction:(id)sender;
@property (strong, nonatomic) IBOutlet UITableViewCell *logOutCell;

@end
