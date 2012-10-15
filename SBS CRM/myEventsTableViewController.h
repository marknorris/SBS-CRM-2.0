//
//  myEventsTableViewController.h
//  SBS CRM
//
//  Created by Tom Couchman on 09/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EventsCellData.h"
#import "fetchXML.h"

@interface myEventsTableViewController : UITableViewController <fetchXMLDelegate>
{
UIView *refreshHeaderView;
UILabel *refreshLabel;
UIImageView *refreshArrow;
UIActivityIndicatorView *refreshSpinner;
BOOL isDragging;
BOOL isLoading;
NSString *textPull;
NSString *textRelease;
NSString *textLoading;
NSMutableArray *eventIDArray;
    
BOOL isMutatingArray;

}

@property (strong, nonatomic) IBOutlet UISearchBar *_searchBar;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnAdd;

@property (nonatomic, retain) NSManagedObjectContext *context;

@property (nonatomic, retain) UIView *refreshHeaderView;
@property (nonatomic, retain) UILabel *refreshLabel;
@property (nonatomic, retain) UIImageView *refreshArrow;
@property (nonatomic, retain) UIActivityIndicatorView *refreshSpinner;

@property (nonatomic, copy) NSString *textPull;
@property (nonatomic, copy) NSString *textRelease;
@property (nonatomic, copy) NSString *textLoading;

- (IBAction)clickToday:(id)sender;

- (void)setupStrings;
- (void)addPullToRefreshHeader;
- (void)startLoading;
- (void)stopLoading;

- (void)reloadCoreData;
- (void)refreshTableView;

@end
