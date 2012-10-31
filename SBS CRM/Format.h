//
//  format.h
//  SBS CRM 2.0
//
//  Created by Tom Couchman on 28/03/2012.
//  Copyright (c) 2012 Shuttleworth Business Systems Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Format : NSObject

+ (NSString *)nameFromComponents:(NSMutableArray *)nameArray;
+ (NSString *)secondsSinceMidnightFromDate:(NSDate *)date;
+ (NSDate *)dateFromSecondsSinceMidnight:(int)seconds;
+ (NSString *)timeStringFromSecondsSinceMidnight:(int)seconds;
+ (NSDate *)formatDate:(NSString *)date;
+ (NSString *)setDefaultTime:(NSString *)dueTime;

@end
