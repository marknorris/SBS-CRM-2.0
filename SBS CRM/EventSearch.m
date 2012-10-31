//
//  EventSearch.m
//  SBS CRM
//
//  Created by Tom Couchman on 15/02/2012.
//  Copyright (c) 2012 Shuttleworth Business Systems Limited. All rights reserved.
//

#import "EventSearch.h"
#import "Event.h"

@implementation EventSearch

@synthesize eveNumber = _eveNumber;
@synthesize eveStatus = _eveStatus;
@synthesize eveTitle = _eveTitle;
@synthesize ourContactID = _ourContactID;
@synthesize eventType = _eventType;
@synthesize eventType2 = _eventType2;
@synthesize eventPriority = _eventPriority;
@synthesize companySiteID = _companySiteID;
@synthesize eventID = _eventID;
@synthesize contactID = _contactID;
@synthesize eveComments = _eveComments;
@synthesize eveCreatedDate = _eveCreatedDate;
@synthesize eveCreatedTime = _eveCreatedTime;
@synthesize eveDueDate = _eveDueDate;
@synthesize eveDueTime = _eveDueTime;
@synthesize eveEndDate = _eveEndDate;
@synthesize eveEndTime = _eveEndTime;
@synthesize eveCreatedBy = _eveCreatedBy;
@synthesize readEvent = _readEvent;
@synthesize watched = _watched;

- (id)copy
{    
    return [self copyWithZone:nil];
}

- (id)copyWithZone:(NSZone *)zone
{
    // We'll ignore the zone for now
    EventSearch *copiedEvent = [[EventSearch alloc] init];
    
    copiedEvent.eventID = [self.eventID copyWithZone:zone];
    copiedEvent.eveDueDate = [self.eveDueDate copyWithZone: zone];
    copiedEvent.eveDueTime = [self.eveDueTime copyWithZone: zone];
    copiedEvent.eveEndDate = [self.eveEndDate copyWithZone: zone];
    copiedEvent.eveEndTime = [self.eveEndTime copyWithZone: zone];
    copiedEvent.eveTitle = [self.eveTitle copyWithZone: zone];
    copiedEvent.companySiteID = [self.companySiteID copyWithZone: zone];
    copiedEvent.ourContactID = [self.ourContactID copyWithZone: zone];
    copiedEvent.contactID = [self.contactID copyWithZone: zone];
    copiedEvent.eveNumber = [self.eveNumber copyWithZone: zone];
    copiedEvent.eveStatus = [self.eveStatus copyWithZone: zone];
    copiedEvent.eventType = [self.eventType copyWithZone: zone];
    copiedEvent.eventType2 = [self.eventType2 copyWithZone: zone];
    copiedEvent.eventPriority = [self.eventPriority copyWithZone: zone];
    copiedEvent.eveComments = [self.eveComments copyWithZone: zone];
    copiedEvent.eveCreatedDate = [self.eveCreatedDate copyWithZone: zone];
    copiedEvent.eveCreatedTime = [self.eveCreatedTime copyWithZone: zone];
    copiedEvent.eveCreatedBy = [self.eveCreatedBy copyWithZone: zone];
    copiedEvent.readEvent = self.readEvent; // value type
    copiedEvent.watched = self.watched; // value type
    
    return copiedEvent;
}

@end
