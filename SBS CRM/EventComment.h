//
//  EventComment.h
//  SBS CRM 2.0
//
//  Created by Mark Norris on 08/11/2012.
//  Copyright (c) 2012 Shuttleworth Business Systems Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Event2;

@interface EventComment : NSManagedObject

@property (nonatomic, retain) NSString * ecoBy;
@property (nonatomic, retain) NSString * ecoComment;
@property (nonatomic, retain) NSDate * ecoDateTime;
@property (nonatomic, retain) NSNumber * ecoSequence;
@property (nonatomic, retain) NSNumber * eventCommentID;
@property (nonatomic, retain) NSNumber * eventID;
@property (nonatomic, retain) Event2 *event;

@end
