//
//  lookUpTableViewController.h
//  SBS CRM
//
//  Created by Tom Couchman on 24/02/2012.
//  Copyright (c) 2012 Shuttleworth Business Systems Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

@class lookUpTableViewController;

@protocol lookUpTableViewControllerDelegate <NSObject>
-(void)lookUpTableViewController:(lookUpTableViewController *)controller
                   didSelectItem: (NSInteger *)row withSourceCellIdentifier:(NSString *)sourceCellIdentifier;
@end

@interface lookUpTableViewController : UITableViewController
{
    NSInteger selectedIndex;
}

@property (nonatomic, weak) id <lookUpTableViewControllerDelegate> delegate;
@property (nonatomic, strong) NSString *item;
@property (nonatomic, strong) NSArray *itemArray;
@property (nonatomic, strong) NSString *sourceCellIdentifier;
- (IBAction)btnCancelClick:(id)sender;

@end
