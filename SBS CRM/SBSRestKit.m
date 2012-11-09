//
//  RestKit.m
//  SBS CRM 2.0
//
//  Created by Mark Norris on 01/11/2012.
//  Copyright (c) 2012 Shuttleworth Business Systems Limited. All rights reserved.
//

#import "SBSRestKit.h"
#import "Event2+RestKit.h"

//#define appBaseURL @"http://192.168.0.3/crm"
#define appBaseURL @"http://172.16.4.5/crm"
#define appObjectStore @"SBS_CRM2.sqlite"

@implementation SBSRestKit

static SBSRestKit *sharedSBSRestKit = nil;

+ (SBSRestKit *)sharedSBSRestKit
{
    if (sharedSBSRestKit == nil) {
        sharedSBSRestKit = [[super allocWithZone:NULL] init];
    }
    
    return sharedSBSRestKit;
}

+ (void)configureRestKit
{
    // Initialize our RestKit singleton
    NSURL *baseURL = [NSURL URLWithString:appBaseURL];
    
    // Initialize for Object mapping
    RKObjectManager* objectManager = [RKObjectManager objectManagerWithBaseURL:baseURL];
    objectManager.objectStore = [RKManagedObjectStore objectStoreWithStoreFilename:appObjectStore];
    [Event2 configureEntity];
}

+ (RKManagedObjectMapping *)configureEntityForClass:(Class)class keyPath:(NSString *)keyPath primaryKey:(NSString *)primaryKey defaultRoute:(NSString *)defaultRoute deleteRoute:(NSString *)deleteRoute getRoute:(NSString *)getRoute postRoute:(NSString *)postRoute putRoute:(NSString *)putRoute
{
    // Get a reference to the shared object manager
    RKObjectManager *objectManager = [RKObjectManager sharedManager];

    // Get a reference to the object store
    RKManagedObjectStore *objectStore = [[RKObjectManager sharedManager] objectStore];
    
    // Get a the reference to the router from the object manager
    RKObjectRouter *objectRouter = [objectManager router];
    
    // Define a default route
    [objectRouter routeClass:class 
        toResourcePath:defaultRoute];
    
    // Define a resource path for specified HTTP verbs
    [objectRouter routeClass:class 
        toResourcePath:deleteRoute
             forMethod:RKRequestMethodDELETE];
    [objectRouter routeClass:class 
        toResourcePath:getRoute
             forMethod:RKRequestMethodGET];
    [objectRouter routeClass:class 
        toResourcePath:postRoute
             forMethod:RKRequestMethodPOST];
    [objectRouter routeClass:class 
        toResourcePath:putRoute
             forMethod:RKRequestMethodPUT];
    
    // Object mapping
    RKManagedObjectMapping *objectMapping = [RKManagedObjectMapping mappingForClass:class 
                                                               inManagedObjectStore:objectStore];

    // Primary key is required for Core Data
    objectMapping.primaryKeyAttribute = primaryKey;
    
    // Automatic mapping of attributes to properties
    NSDictionary *objectProperties = [[RKObjectPropertyInspector sharedInspector] propertyNamesAndTypesForClass:class];
    [objectMapping mapAttributesFromSet:[NSSet setWithArray:[objectProperties allKeys]]];
    return objectMapping;
}

+ (void)setEntityObjectMapping:(RKManagedObjectMapping *)objectMapping forKeyPath:(NSString *)keyPath
{
    // Get a reference to the shared object manager
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    // Set the mapping
    [[objectManager mappingProvider] setMapping:objectMapping 
                                     forKeyPath:keyPath];
}

@end
