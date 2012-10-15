//
//  alertsAndBadges.m
//  SBS CRM 2.0
//
//  Created by Tom Couchman on 31/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "alertsAndBadges.h"
#import "EventSearch.h"


@interface alertsAndBadges()

@end

@implementation alertsAndBadges

static NSInteger overDueCount = 0;

+(void)setAlertsAndBadges:(NSArray *)EventArray{
    overDueCount = 0;
    
    //loop through each of the events
    for (EventSearch *eve in EventArray)
    {
        // if needed set the default alert time. As we are currently saving the default alert time to core 
        // data there is no way to update this again without doing a refresh. TODO: consider this.
        //if (eve.eveDueTime == NULL || [eve.eveDueTime isEqualToString:@"0"] || [eve.eveDueTime isEqualToString:@""])
        //{
            //eve.eveDueTime = [format setDefaultTime:eve.eveDueTime];
        //}
        // if the event is watched move onto the next.
        if (eve.watched == 0)
            continue;
        
        NSDate * dueDateTime = [self getDueDateTime:eve.eveDueDate:eve.eveDueTime];
        
        if (dueDateTime == [NSDate distantPast])
            continue;
        
        if ([dueDateTime compare:[NSDate date]] == NSOrderedAscending)
        {
            overDueCount++;
        }
        else {
            UILocalNotification *localNotif = [[UILocalNotification alloc] init];
            if (localNotif == nil) return;
            localNotif.fireDate = dueDateTime; //set date for the alert to fire
            localNotif.alertBody = eve.eveTitle; // use event title as the message for the alert.
            NSDictionary *userinfo = [NSDictionary dictionaryWithObject:eve.eventID forKey:eve.eveTitle]; //store the eventID in userinfo.
            localNotif.userInfo = userinfo;
            [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
        }
    }
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:overDueCount];
}


+ (NSDate *)getDueDateTime:(NSDate *)dueDate:(NSString *)dueTime
{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    //get the date components from due date
    NSDateComponents *components = [gregorian components:(NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit) fromDate:dueDate];
    
    
    // stop the date from being automatically adjusted.
    components.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    
    // convert the due time into the correct format and add as components.
    [components setHour:([dueTime integerValue]  / 3600)]; 
    [components setMinute:(([dueTime integerValue] / 60) % 60)];
    //create a date from the components
    return [gregorian dateFromComponents:components];
}

@end
