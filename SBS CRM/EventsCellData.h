//
//  EventsCellData.h
//  SBS CRM
//
//  Created by Tom Couchman on 10/02/2012.
//  Copyright (c) 2012 Shuttleworth Business Systems Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EventsCellData : NSObject

@property (readwrite, nonatomic) NSInteger eventID;
@property (strong, nonatomic) NSString *eventTitle;
@property (strong, nonatomic) NSString *siteNameDesc;
@property (strong, nonatomic) NSString *eventTypeType2;
@property (strong, nonatomic) NSString *eventComments;
@property (strong, nonatomic) NSString *eventDueTime;

@end
