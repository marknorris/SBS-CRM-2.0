//
//  InfoTableViewController.h
//  SBS CRM 2.0
//
//  Created by Mark Norris on 04/11/2012.
//  Copyright (c) 2012 Shuttleworth Business Systems Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RestKit/RestKit.h>
#import "Version.h"

@interface InfoTableViewController : UITableViewController <RKObjectLoaderDelegate>

- (IBAction)done:(id)sender;

@end
