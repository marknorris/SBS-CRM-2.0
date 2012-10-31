//
//  format.m
//  SBS CRM 2.0
//
//  Created by Tom Couchman on 28/03/2012.
//  Copyright (c) 2012 Shuttleworth Business Systems Limited. All rights reserved.
//

#import "Format.h"
#import "AppDelegate.h"

@implementation Format

+ (NSString *)nameFromComponents:(NSMutableArray *)nameArray
{
    //remove empty items
    [nameArray removeObject:@""];
    //return concatented array with spaces between components.
    return [nameArray componentsJoinedByString:@" "];
}

+ (NSString *)secondsSinceMidnightFromDate:(NSDate *)date
{
    // get the hour and minute components from the date
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *defaultComponents = [gregorian components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:date];
    
    //convert the hours and minutes components to seconds since midnight and return result
    return [NSString stringWithFormat:@"%d",((defaultComponents.hour * 3600) + (defaultComponents.minute * 60))];
}

+ (NSDate *)dateFromSecondsSinceMidnight:(int)seconds
{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregorian components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:[NSDate date]];
    
    // calculate the hours and minutes from the seconds and place in components
    [components setHour:(seconds  / 3600)]; 
    [components setMinute:((seconds / 60) % 60)];
    
          NSDate *dateFromComonents = [gregorian dateFromComponents:components];
    NSLog(@"date from seconds since midnight: %@", dateFromComonents);
    //create a date from the components and return
    return dateFromComonents;
}

+ (NSString *)timeStringFromSecondsSinceMidnight:(int)seconds
{
    // calculate the hours and minutes from the seconds and place in components
    int hours = (seconds  / 3600); 
    int minutes = ((seconds / 60) % 60);
    return [NSString stringWithFormat:@"%02d:%02d",hours,minutes];
}

+ (NSDate *)formatDate:(NSString *)date
{
    //if no date is set, set it to 01/01/9999, so that it can be interpretted as 'no due date' later
    if ([date isEqualToString:@""]) {
        date = NULL;
        return NULL;
    }
    
    //set up date formatter
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"dd/MM/yyyy HH:mm:ss"];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [df setTimeZone:timeZone];
    //return the foratted date.
    return [df dateFromString:date];
}

+ (NSString *)setDefaultTime:(NSString *)dueTime
{
    //create calandar and datecompnents to access hour and minute of appDefaultAlertTime
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *defaultComponents = [gregorian components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:appDefaultAlertTime];
    //convert the hours and minutes to seconds since midnight and return it
    return [NSString stringWithFormat:@"%d",((defaultComponents.hour * 3600) + (defaultComponents.minute * 60))];
}

@end
