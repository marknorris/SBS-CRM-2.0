//
//  contactsTableViewController.h
//  SBS CRM
//
//  Created by Tom Couchman on 13/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "contactDetailsTableViewController.h"
#import "fetchXML.h"

@interface contactsTableViewController : UITableViewController <fetchXMLDelegate>
{
    NSMutableArray *contactsArray;
    
    //Search:
    NSMutableArray *allEventsArray;
    UIActivityIndicatorView *refreshSpinner;
    
}

//search
@property (nonatomic, retain) IBOutlet UISearchDisplayController *searchDisplayController;
@property (nonatomic, retain) IBOutlet UISearchBar *searchBar;
@property (nonatomic, copy) NSMutableArray *searchResults;
@property (nonatomic) BOOL isSearching;
@property (nonatomic) BOOL fetchingSearchResults;


- (void)refreshTableView;

//search
- (void)filterContentForSearchText:(NSString*)searchText 
                             scope:(NSString*)scope;


@end