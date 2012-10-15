//
//  EventSearch.m
//  SBS CRM
//
//  Created by Tom Couchman on 15/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EventSearch.h"
#import "Event.h"

@implementation EventSearch

@synthesize eveNumber;
@synthesize eveStatus;
@synthesize eveTitle;
@synthesize ourContactID;
@synthesize eventType;
@synthesize eventType2;
@synthesize eventPriority;
@synthesize companySiteID;
@synthesize eventID;
@synthesize contactID;
@synthesize eveComments;
@synthesize eveCreatedDate;
@synthesize eveCreatedTime;
@synthesize eveDueDate;
@synthesize eveDueTime;
@synthesize eveEndDate;
@synthesize eveEndTime;
@synthesize eveCreatedBy;
@synthesize readEvent;
@synthesize watched;

-(id)copy{    
    return [self copyWithZone:nil];
}

-(id)copyWithZone:(NSZone *)zone
{
    // We'll ignore the zone for now
    EventSearch *copiedEvent = [[EventSearch alloc] init];
    
    copiedEvent.eventID = [eventID copyWithZone:zone];
    copiedEvent.eveDueDate = [eveDueDate copyWithZone: zone];
    copiedEvent.eveDueTime = [eveDueTime copyWithZone: zone];
    copiedEvent.eveEndDate = [eveEndDate copyWithZone: zone];
    copiedEvent.eveEndTime = [eveEndTime copyWithZone: zone];
    copiedEvent.eveTitle = [eveTitle copyWithZone: zone];
    copiedEvent.companySiteID = [companySiteID copyWithZone: zone];
    copiedEvent.ourContactID = [ourContactID copyWithZone: zone];
    copiedEvent.contactID = [contactID copyWithZone: zone];
    copiedEvent.eveNumber = [eveNumber copyWithZone: zone];
    copiedEvent.eveStatus = [eveStatus copyWithZone: zone];
    copiedEvent.eventType = [eventType copyWithZone: zone];
    copiedEvent.eventType2 = [eventType2 copyWithZone: zone];
    copiedEvent.eventPriority = [eventPriority copyWithZone: zone];
    copiedEvent.eveComments = [eveComments copyWithZone: zone];
    copiedEvent.eveCreatedDate = [eveCreatedDate copyWithZone: zone];
    copiedEvent.eveCreatedTime = [eveCreatedTime copyWithZone: zone];
    copiedEvent.eveCreatedBy = [eveCreatedBy copyWithZone: zone];
    copiedEvent.readEvent = readEvent; // value type
    copiedEvent.watched = watched; // value type
    
    return copiedEvent;
}

@end
