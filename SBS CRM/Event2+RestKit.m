//
//  Event2+RestKit.m
//  SBS CRM 2.0
//
//  Created by Mark Norris on 01/11/2012.
//  Copyright (c) 2012 Shuttleworth Business Systems Limited. All rights reserved.
//

#import "Event2+RestKit.h"
#import <RestKit/RKObjectMapperError.h>

// Core Data requires a primary key
#define entityPrimaryKey @"eventID"
// The path to this entity in the JSON returned from the web service
#define entityKeyPath @"ttEvent"
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

@implementation Event2 (RestKit)

+ (RKManagedObjectMapping *)configureEntity
{
    NSLog(@"%s", __FUNCTION__);
    RKManagedObjectMapping *objectMapping = [SBSRestKit configureEntityForClass:[self class] keyPath:entityKeyPath primaryKey:entityPrimaryKey defaultRoute:entityRouteDefault deleteRoute:entityRouteForMethodDelete getRoute:entityRouteForMethodGet postRoute:entityRouteForMethodPost putRoute:entityRouteForMethodPut];
    // Configure Company2 entity
    [Company2 configureEntity];
    // Get object mapping for Company2 class
    RKObjectMapping *companyMapping = [RKManagedObjectMapping mappingForClass:[Company2 class] inManagedObjectStore:[[RKObjectManager sharedManager] objectStore]];
    // Re-define mapping for eventCompany property in Event2 class
    [objectMapping removeMappingForKeyPath:@"eventCompany"];
    [objectMapping mapRelationship:@"eventCompany" withMapping:companyMapping];
    [objectMapping connectRelationship:@"eventCompany" withObjectForPrimaryKeyAttribute:@"companySiteID"];
    // Configure EventComment entity
    [EventComment configureEntity];
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

// Override the default getter to set the date for Events where eveDueDateTime is null
- (NSDate *)eveDueDate
{
    [self willAccessValueForKey:@"eveDueDate"];
    NSDate *tmpValue = [self primitiveValueForKey:@"eveDueDate"];
    [self didAccessValueForKey:@"eveDueDate"];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];

    if (!tmpValue) {
        df.dateFormat = @"yyyy-MM-dd";
        tmpValue = [df dateFromString:@"9999-01-01"];
        [self setEveDueDate:tmpValue];
    }

    return tmpValue;
}

- (EventComment *)firstEventComment
{
    NSFetchRequest *fetchRequest = [EventComment fetchRequest];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"eventCommentID"
                                                                   ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"eventID == %@", [self eventID]];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [[EventComment currentContext] executeFetchRequest:fetchRequest error:&error];
    
    if (fetchedObjects == nil) {
        return nil;
    } else {
        
        if ([fetchedObjects count] == 0) {
            return nil;
        } else {
            return [fetchedObjects objectAtIndex:0];
        }
        
    }
    
}

@end
