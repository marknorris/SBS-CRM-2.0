//
//  EventSearch.h
//  SBS CRM
//
//  Created by Tom Couchman on 15/02/2012.
//  Copyright (c) 2012 Shuttleworth Business Systems Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EventSearch : NSObject <NSCopying>

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
@property (nonatomic, retain) NSDate * eveCreatedDate;
@property (nonatomic, retain) NSString * eveCreatedTime;
@property (nonatomic, retain) NSDate * eveDueDate;
@property (nonatomic, retain) NSString * eveDueTime;
@property (nonatomic, retain) NSDate * eveEndDate;
@property (nonatomic, retain) NSString * eveEndTime;
@property (nonatomic, retain) NSString * eveCreatedBy;
@property (nonatomic) NSInteger readEvent;
@property (nonatomic) NSInteger watched;

-(id)copy;
-(id)copyWithZone:(NSZone *)zone;

@end
