//
//  lookUpTableViewController.h
//  SBS CRM
//
//  Created by Tom Couchman on 24/02/2012.
//  Copyright (c) 2012 Shuttleworth Business Systems Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LookUpTableViewController;

@protocol LookUpTableViewControllerDelegate <NSObject>
-(void)lookUpTableViewController:(LookUpTableViewController *)controller
                   didSelectItem: (NSInteger *)row withSourceCellIdentifier:(NSString *)sourceCellIdentifier;
@end

@interface LookUpTableViewController : UITableViewController
{
    NSInteger selectedIndex;
}

@property (nonatomic, weak) id <LookUpTableViewControllerDelegate> delegate;
@property (nonatomic, strong) NSString *item;
@property (nonatomic, strong) NSArray *itemArray;
@property (nonatomic, strong) NSString *sourceCellIdentifier;
- (IBAction)btnCancelClick:(id)sender;

@end
