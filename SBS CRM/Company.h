//
//  Company.h
//  SBS CRM
//
//  Created by Tom Couchman on 09/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Company : NSManagedObject

@property (nonatomic, retain) NSString * companySiteID;
@property (nonatomic, retain) NSString * coaCompanyName;
@property (nonatomic, retain) NSString * cosDescription;
@property (nonatomic, retain) NSString * cosSiteName;
@property (nonatomic, retain) NSString * addStreetAddress;
@property (nonatomic, retain) NSString * addStreetAddress2;
@property (nonatomic, retain) NSString * addStreetAddress3;
@property (nonatomic, retain) NSString * addTown;
@property (nonatomic, retain) NSString * addCounty;
@property (nonatomic, retain) NSString * addPostCode;
@property (nonatomic, retain) NSString * couCountryName;

@end
