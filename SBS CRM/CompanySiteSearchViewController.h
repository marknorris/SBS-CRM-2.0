//
//  companySiteSearchViewController.h
//  SBS CRM 2.0
//
//  Created by Tom Couchman on 01/06/2012.
//  Copyright (c) 2012 Shuttleworth Business Systems Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FetchXML.h"
#import "CompanySearch.h"

@class CompanySiteSearchViewController;

@protocol CompanySiteSearchViewControllerDelegate <NSObject>

-(void)companySiteSearchViewController:(CompanySiteSearchViewController *)controller didSelectCompany:(CompanySearch *)selectedCompany;

@end

@interface CompanySiteSearchViewController : UITableViewController <FetchXMLDelegate>

- (IBAction)btnCancel_Click:(id)sender;

@property (nonatomic, strong) IBOutlet UISearchBar *searchBarOutlet;
@property (nonatomic, weak) id<CompanySiteSearchViewControllerDelegate> delegate;

@end
