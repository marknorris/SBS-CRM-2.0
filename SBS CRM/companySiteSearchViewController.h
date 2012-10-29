//
//  companySiteSearchViewController.h
//  SBS CRM 2.0
//
//  Created by Tom Couchman on 01/06/2012.
//  Copyright (c) 2012 Shuttleworth Business Systems Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "fetchXML.h"
#import "CompanySearch.h"

@class companySiteSearchViewController;

@protocol companySiteSearchViewControllerDelegate <NSObject>
-(void)companySiteSearchViewController:(companySiteSearchViewController *)controller
                  didSelectCompany: (CompanySearch *)selectedCompany;
@end

@interface companySiteSearchViewController : UITableViewController <fetchXMLDelegate>
- (IBAction)btnCancel_Click:(id)sender;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBarOutlet;


@property (nonatomic, weak) id <companySiteSearchViewControllerDelegate> delegate;

@end
