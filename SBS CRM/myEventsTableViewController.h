//
//  myEventsTableViewController.h
//  SBS CRM
//
//  Created by Tom Couchman on 09/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EventsCellData.h"

@interface myEventsTableViewController : UITableViewController
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
    
    //Search:
    IBOutlet UISearchDisplayController *searchDisplayController;
    IBOutlet UISearchBar *searchBar;
    NSMutableArray *searchResults;
    BOOL isSearching;
    NSMutableArray *allEventsArray;
}


//search
@property (nonatomic, retain) IBOutlet UISearchDisplayController *searchDisplayController;
@property (nonatomic, retain) IBOutlet UISearchBar *searchBar;
@property (nonatomic, copy) NSMutableArray *searchResults;




@property (nonatomic, retain) NSManagedObjectContext *context;

@property (nonatomic, retain) UIView *refreshHeaderView;
@property (nonatomic, retain) UILabel *refreshLabel;
@property (nonatomic, retain) UIImageView *refreshArrow;
@property (nonatomic, retain) UIActivityIndicatorView *refreshSpinner;
@property (nonatomic, copy) NSString *textPull;
@property (nonatomic, copy) NSString *textRelease;
@property (nonatomic, copy) NSString *textLoading;


//search
- (void)filterContentForSearchText:(NSString*)searchText 
                             scope:(NSString*)scope;

- (void)setupStrings;
- (void)addPullToRefreshHeader;
- (void)startLoading;
- (void)stopLoading;



- (void)reloadCoreData;
- (void)refreshTableView;

@end
