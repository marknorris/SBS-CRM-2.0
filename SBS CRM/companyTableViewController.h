//
//  companyTableViewController.h
//  SBS CRM
//
//  Created by Tom Couchman on 13/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DDXML.h"
#import "companyDetailsTableViewController.h"

@interface companyTableViewController : UITableViewController
{
    NSMutableArray *companyArray;
    
    //Search:
    IBOutlet UISearchDisplayController *searchDisplayController;
    IBOutlet UISearchBar *searchBar;
    NSMutableArray *searchResults;
    BOOL isSearching;
    NSMutableArray *allEventsArray;
    BOOL cancelled;
    
    //XML parsing
    DDXMLDocument *companiesDocument;    
    NSURL *url;
    NSString *xmlString;
    NSData *xmlData;
}

//search
@property (nonatomic, retain) IBOutlet UISearchDisplayController *searchDisplayController;
@property (nonatomic, retain) IBOutlet UISearchBar *searchBar;
@property (nonatomic, copy) NSMutableArray *searchResults;


@property (nonatomic, retain) NSManagedObjectContext *context;

- (void)reloadCoreData;
- (void)refreshTableView;

//search
- (void)filterContentForSearchText:(NSString*)searchText 
                             scope:(NSString*)scope;
- (BOOL)getCompanyResults:(NSString *)searchText;


@end
