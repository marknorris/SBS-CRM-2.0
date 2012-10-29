//
//  syncData.m
//  SBS CRM
//
//  Created by Tom Couchman on 09/02/2012.
//  Copyright (c) 2012 Shuttleworth Business Systems Limited. All rights reserved.
//
/*
#import "syncData.h"

@interface syncData() {
    NSInteger overDueCount;
}
    - (void)setAlertAndBadge:(NSDate *)dueDate:(NSString *)dueTime:(NSString *)eveTitle:(NSString *)eventID;
@end

@implementation syncData

@synthesize appDelegate;


- (NSArray *)parseXMLDoc:(DDXMLDocument *)Doc:(NSString *)className{
    
    NSMutableArray* elementArray = [[NSMutableArray alloc] init];
    
    //create an array of nodes.
    NSArray* nodes = nil;
    //fill it with the children of the documents root element.
    nodes = [[Doc rootElement] children];
    
    // loop through each element
    for (DDXMLElement *element in nodes)
    { 
        NSObject *currentItem;
        currentItem = [[NSClassFromString(className) alloc] init];

        NSArray* children = [element children];
        for (DDXMLElement *child in children)
        {

            if (child != NULL && child!= nil) 
            {
                //NSLog(@"Name: %@    Value: %@", child.name, child.stringValue);
                
                if ([className isEqualToString:@"EventSearch"] && ([child.name isEqualToString:@"eveCreatedDate"] || [child.name isEqualToString:@"eveDueDate"]))
                    [currentItem setValue:[self formatDate:child.stringValue] forKey:child.name];
                else
                    [currentItem setValue:child.stringValue forKey:child.name]; //if the entity contains a value set that value into the attribute of the same name.

                //NSLog(@"class Value: %@", [currentItem eveCreatedDate]);
            }
                else [currentItem setValue:@"" forKey:child.name];  
        }
        [elementArray addObject:currentItem];
    }
    return elementArray;
}





- (BOOL)storeInCoreData:(NSArray *)classArray:(NSString *)entityName{
    
    appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSError *error;    
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    // fetch saved events from coredata and delete them
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    
    
    NSArray *items = [context executeFetchRequest:fetchRequest error:&error];
    
    for (NSManagedObject *managedObject in items){
        [context deleteObject:managedObject];
    }    
    
    //if fails, return no.
    if (![context save:&error]) return NO;
    
    
    for (int i = 0; i < [classArray count]; i++)
    {
        NSObject *eve;
        //eve = [[NSClassFromString(@"EventSearch") alloc] init];
        eve = [classArray objectAtIndex:i];
        
        id entityToSave = [NSClassFromString(entityName) alloc];
        entityToSave = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:context]; 
        
        NSDictionary *attributes = [[NSEntityDescription
                                     entityForName:entityName
                                     inManagedObjectContext:context] attributesByName];
        
        for (NSString *attr in attributes) {
            [entityToSave setValue:[eve valueForKey:attr] forKey:attr];
        }
    }
    if (![context save:&error]) return NO;

    
    //if successful return yes
    return YES;
}


                                                              



//TODO: this stuff needs to be sorted into classes!


- (void)setAlertAndBadge:(NSDate *)dueDate:(NSString *)dueTime:(NSString *)eveTitle:(NSString *)eventID{

    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    //get the date components from due date
    NSDateComponents *components = [gregorian components:(NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit) fromDate:dueDate];
    // convert the due time into the correct format and add as components.
    [components setHour:([dueTime integerValue]  / 3600)]; 
    [components setMinute:(([dueTime integerValue] / 60) % 60)];
    //create a date from the components
    NSDate *dueDateTime = [gregorian dateFromComponents:components];

    //
    //if the time is set to midnight:
    if (components.hour == 0 && components.minute == 0)
    {
        NSLog(@"No due time - %@",dueDateTime);
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *defaultComponents = [gregorian components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:appDefaultAlertTime];
        NSLog(@"default hours: %d", defaultComponents.hour);
        //NSDateFormatter *hourFormat = [[NSDateFormatter alloc] init];
        //[hourFormat setDateFormat:@"HH"];
        [components setHour:defaultComponents.hour]; // TODO! this is done using 12 hour format so isnt working
        [components setMinute:defaultComponents.minute];
        dueDateTime = [gregorian dateFromComponents:components];
        NSLog(@"default due time - %@",dueDateTime);
    }
    

    // check to see if the date is before now, if yes increase the overdue count on the application badge
    if([dueDateTime compare:[NSDate date]] == NSOrderedAscending)
    {
            overDueCount++;
    }
    else //if the event is not yet overdue, create an alert for that event.
    {
        UILocalNotification *localNotif = [[UILocalNotification alloc] init];
        if (localNotif == nil) return;
        localNotif.fireDate = dueDateTime; //set date for the alert to fire
        localNotif.alertBody = eveTitle; // use event title as the message for the alert.
        NSDictionary *userinfo = [NSDictionary dictionaryWithObject:eventID forKey:eveTitle]; //store the eventID in userinfo.
        localNotif.userInfo = userinfo;
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
    }
    //set the badge number to the calculated count of overdue events.
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:overDueCount];
}



- (NSDate *)formatDate:(NSString *)date{
    //if no date is set, set it to 01/01/9999, so that it can be interpretted as 'no due date' later
    if ([date isEqualToString:@""])
        date = @"01/01/9999 00:00:00";
    //set up date formatter
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"dd/MM/yyyy HH:mm:ss"];
    //return the foratted date.
    return [df dateFromString:date];
}


- (NSString *)setDefaultTime:(NSString *)dueTime{
    //the time is set to zero, or not set at all and so needs to be changed to the default time
    //create components for the hour and minute of default time
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *defaultComponents = [gregorian components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:appDefaultAlertTime];
    
    //convert the hours and minutes to seconds since midnight and return it
    return [NSString stringWithFormat:@"%d",((defaultComponents.hour * 3600) + (defaultComponents.minute * 60))];
}



@end
*/
