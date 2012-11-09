//
//  Version.m
//  SBS CRM 2.0
//
//  Created by Mark Norris on 06/11/2012.
//  Copyright (c) 2012 Shuttleworth Business Systems Limited. All rights reserved.
//

#import "Version.h"
#import <RestKit/RestKit.h>

@implementation Version

@synthesize name;
@synthesize version;

+ (void)configureEntity
{
    NSLog(@"%s", __FUNCTION__);

    RKObjectMapping *objectMapping = [[[RKObjectManager sharedManager] mappingProvider] objectMappingForClass:[self class]];
    
    if (!objectMapping) {
        objectMapping = [RKObjectMapping mappingForClass:[self class]];    
        [objectMapping mapKeyPath:@"name" toAttribute:@"name"];
        [objectMapping mapKeyPath:@"version" toAttribute:@"version"];
        // Set the mapping
        [[[RKObjectManager sharedManager] mappingProvider] setMapping:objectMapping 
                                                           forKeyPath:@""];
    }
    
}

+ (void)loadObjectsWithDelegate:(id)delegate
{
    NSLog(@"%s", __FUNCTION__);
    [[RKObjectManager sharedManager] loadObjectsAtResourcePath:@"/version" delegate:delegate];
}

@end
