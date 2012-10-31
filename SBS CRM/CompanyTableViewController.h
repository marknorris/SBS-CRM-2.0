//
//  companyTableViewController.h
//  SBS CRM
//
//  Created by Tom Couchman on 13/02/2012.
//  Copyright (c) 2012 Shuttleworth Business Systems Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CompanyDetailsTableViewController.h"
#import "FetchXML.h"

@interface CompanyTableViewController : UITableViewController <FetchXMLDelegate>

//search
@property (nonatomic, retain) IBOutlet UISearchDisplayController *searchDisplayController;
@property (nonatomic, retain) IBOutlet UISearchBar *searchBar;
@property (nonatomic, copy) NSMutableArray *searchResults;
@property (nonatomic) BOOL isSearching;
@property (nonatomic) BOOL fetchingSearchResults;

- (void)refreshTableView;
//search
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope;

@end
