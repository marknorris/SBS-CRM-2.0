//
//  Company2.h
//  SBS CRM 2.0
//
//  Created by Mark Norris on 08/11/2012.
//  Copyright (c) 2012 Shuttleworth Business Systems Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Event2;

@interface Company2 : NSManagedObject

@property (nonatomic, retain) NSString * addCounty;
@property (nonatomic, retain) NSString * addPostCode;
@property (nonatomic, retain) NSString * addStreetAddress1;
@property (nonatomic, retain) NSString * addStreetAddress2;
@property (nonatomic, retain) NSString * addStreetAddress3;
@property (nonatomic, retain) NSString * addTown;
@property (nonatomic, retain) NSString * coaCompanyName;
@property (nonatomic, retain) NSNumber * companySiteID;
@property (nonatomic, retain) NSString * cosDescription;
@property (nonatomic, retain) NSString * cosSiteName;
@property (nonatomic, retain) NSString * couCountryName;
@property (nonatomic, retain) Event2 *event;

@end
