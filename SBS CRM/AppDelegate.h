//
//  AppDelegate.h
//  SBS CRM
//
//  Created by Tom Couchman on 08/02/2012.
//  Copyright (c) 2012 Shuttleworth Business Systems Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TestFlight.h"
#import "UserDetails.h"
#import <RestKit/RestKit.h>

extern NSInteger appUserID;
extern NSInteger appContactID;
extern NSInteger appCompanySiteID;
extern NSString *appURL;
extern NSString *appEventID;
extern NSDate *appDefaultAlertTime;

// TODO get this from initial user ID fetch
//extern NSString *internalCompanySiteID;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
