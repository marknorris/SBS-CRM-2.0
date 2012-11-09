//
//  EventComment+RestKit.m
//  SBS CRM 2.0
//
//  Created by Mark Norris on 02/11/2012.
//  Copyright (c) 2012 Shuttleworth Business Systems Limited. All rights reserved.
//

#import "EventComment+RestKit.h"

// Core Data requires a primary key
#define entityPrimaryKey @"eventCommentID"
// The path to this entity in the JSON returned from the web service
#define entityKeyPath @"ttEventComment"
// The default route for getting all entities
#define entityRouteDefault @"/events"
// The route for getting a single entity
#define entityRouteForMethodGet @"/event/:entityID"
// The route for deleting an entity
#define entityRouteForMethodDelete @"/event/:entityID"
// The route for posting an entity
#define entityRouteForMethodPost @"/event/:entityID"
// The route for putting (creating) an entity
#define entityRouteForMethodPut @"/event/:entityID"

@implementation EventComment (RestKit)

+ (RKManagedObjectMapping *)configureEntity
{
    NSLog(@"%s", __FUNCTION__);
    RKManagedObjectMapping *objectMapping = [SBSRestKit configureEntityForClass:[self class] keyPath:entityKeyPath primaryKey:entityPrimaryKey defaultRoute:entityRouteDefault deleteRoute:entityRouteForMethodDelete getRoute:entityRouteForMethodGet postRoute:entityRouteForMethodPost putRoute:entityRouteForMethodPut];
    // Get object mapping for Event2 class
    RKObjectMapping *eventMapping = [RKManagedObjectMapping mappingForClass:[Event2 class] inManagedObjectStore:[[RKObjectManager sharedManager] objectStore]];
    // Re-define mapping for event property in EventComment class
    [objectMapping removeMappingForKeyPath:@"event"];
    [objectMapping mapRelationship:@"event" withMapping:eventMapping];
    [objectMapping connectRelationship:@"event" withObjectForPrimaryKeyAttribute:@"eventID"];
    [self setEntityObjectMapping:objectMapping];
    return objectMapping;
}

+ (void)setEntityObjectMapping:(RKManagedObjectMapping *)objectMapping
{
    [SBSRestKit setEntityObjectMapping:objectMapping forKeyPath:entityKeyPath];
}

+ (void)loadObjectsWithDelegate:(id)delegate
{
    NSLog(@"%s", __FUNCTION__);
    [[RKObjectManager sharedManager] loadObjectsAtResourcePath:entityRouteDefault delegate:delegate];
}

@end
