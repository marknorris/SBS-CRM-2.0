//
//  Event2.h
//  SBS CRM 2.0
//
//  Created by Mark Norris on 09/11/2012.
//  Copyright (c) 2012 Shuttleworth Business Systems Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Company2, EventComment;

@interface Event2 : NSManagedObject

@property (nonatomic, retain) NSNumber * companySiteID;
@property (nonatomic, retain) NSNumber * contactID;
@property (nonatomic, retain) NSString * ettDescription;
@property (nonatomic, retain) NSString * eveComments;
@property (nonatomic, retain) NSDate * eveCreatedDateTime;
@property (nonatomic, retain) NSDate * eveDueDateTime;
@property (nonatomic, retain) NSDate * eveEndDueDateTime;
@property (nonatomic, retain) NSNumber * eventID;
@property (nonatomic, retain) NSNumber * eveNumber;
@property (nonatomic, retain) NSNumber * eveStatus;
@property (nonatomic, retain) NSString * eveTitle;
@property (nonatomic, retain) NSNumber * evoRead;
@property (nonatomic, retain) NSString * evpDescription;
@property (nonatomic, retain) NSString * evtDescription;
@property (nonatomic, retain) NSString * louDescription;
@property (nonatomic, retain) NSNumber * ourContactID;
@property (nonatomic, retain) NSNumber * watched;
@property (nonatomic, retain) NSDate * eveDueDate;
@property (nonatomic, retain) NSSet *eventComments;
@property (nonatomic, retain) Company2 *eventCompany;
@end

@interface Event2 (CoreDataGeneratedAccessors)

- (void)addEventCommentsObject:(EventComment *)value;
- (void)removeEventCommentsObject:(EventComment *)value;
- (void)addEventComments:(NSSet *)values;
- (void)removeEventComments:(NSSet *)values;

@end
