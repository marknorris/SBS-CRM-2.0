//
//  CompanySearch.h
//  SBS CRM
//
//  Created by Tom Couchman on 13/02/2012.
//  Copyright (c) 2012 Shuttleworth Business Systems Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CompanySearch : NSObject

@property (nonatomic, strong) NSString *companySiteID;
@property (nonatomic, strong) NSString *coaCompanyName;
@property (nonatomic, strong) NSString *cosDescription;
@property (nonatomic, strong) NSString *cosSiteName;
@property (nonatomic, strong) NSString *addStreetAddress;
@property (nonatomic, strong) NSString *addStreetAddress2;
@property (nonatomic, strong) NSString *addStreetAddress3;
@property (nonatomic, strong) NSString *addTown;
@property (nonatomic, strong) NSString *addCounty;
@property (nonatomic, strong) NSString *addPostCode;
@property (nonatomic, strong) NSString *couCountryName;

@end
