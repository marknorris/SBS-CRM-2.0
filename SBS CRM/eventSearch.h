//
//  eventSearch.h
//  SBS CRM
//
//  Created by Tom Couchman on 15/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface eventSearch : NSObject

@property (nonatomic, retain) NSString * eveNumber;
@property (nonatomic, retain) NSString * eveStatus;
@property (nonatomic, retain) NSString * eveTitle;
@property (nonatomic, retain) NSString * ourContactID;
@property (nonatomic, retain) NSString * eventType;
@property (nonatomic, retain) NSString * eventType2;
@property (nonatomic, retain) NSString * eventPriority;
@property (nonatomic, retain) NSString * companySiteID;
@property (nonatomic, retain) NSString * eventID;
@property (nonatomic, retain) NSString * contactID;
@property (nonatomic, retain) NSString * eveComments;
@property (nonatomic, retain) NSString * eveCreatedDate;
@property (nonatomic, retain) NSString * eveCreatedTime;
@property (nonatomic, retain) NSDate * eveDueDate;
@property (nonatomic, retain) NSString * eveDueTime;
@property (nonatomic, retain) NSString * eveEndDate;
@property (nonatomic, retain) NSString * eveEndTime;
@property (nonatomic, retain) NSString * eveCreatedBy;

@end
