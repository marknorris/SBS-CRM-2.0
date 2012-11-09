//
//  AppDelegate.m
//  SBS CRM
//
//  Created by Tom Couchman on 08/02/2012.
//  Copyright (c) 2012 Shuttleworth Business Systems Limited. All rights reserved.
//

#import "AppDelegate.h"
#import "Event.h"
#import "Event2.h"
#import "Communication.h"
#import "Contact.h"
#import "Company.h"
#import "Attachment.h"
#import "EventsTableViewController.h"
#import "NSManagedObject+CoreDataManager.h"

NSInteger appUserID = 0;
NSInteger appContactID = 0;
NSInteger appCompanySiteID = 0;
NSString *appURL = @"";
NSString *appEventID = @"";
NSDate *appDefaultAlertTime;
//TODO: get this with userID
//NSString * internalCompanySiteID = @"6487576";

@implementation AppDelegate

@synthesize window = _window;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSLog(@"Documents Directory: %@", self.applicationDocumentsDirectory);
    //reset user defaults for the initial view incase they were not correctly reset previosly.
    [[NSUserDefaults standardUserDefaults]  setValue:@"" forKey:@"initialID"];
    [[NSUserDefaults standardUserDefaults]  setValue:@"" forKey:@"initialView"];
    [[NSUserDefaults standardUserDefaults]  setValue:@"" forKey:@"initialCore"];
    
//    [TestFlight takeOff:@"4162eaa944120d432e6b8e6a3f24aadd_NjQwMjEyMDEyLTAyLTIwIDA4OjAxOjI1Ljc5NzE2OA"];
    //self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    //self.window.backgroundColor = [UIColor whiteColor];
    //[self.window makeKeyAndVisible];
    
    //register with notification center
    [[UIApplication sharedApplication]registerForRemoteNotificationTypes: UIRemoteNotificationTypeBadge | 
     UIRemoteNotificationTypeAlert |
     UIRemoteNotificationTypeSound];

    
    UILocalNotification *localNotif = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (localNotif) {
        [[NSUserDefaults standardUserDefaults] setValue:@"eve" forKey:@"initialView"];
        [[NSUserDefaults standardUserDefaults] setObject:[localNotif.userInfo objectForKey:[[localNotif.userInfo allKeys] objectAtIndex:0]] forKey:@"initialID"];
        [[NSUserDefaults standardUserDefaults] setValue:@"1" forKey:@"initialCore"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    NSURL *recievedURL = [launchOptions objectForKey:UIApplicationLaunchOptionsURLKey];
    if (recievedURL) {
        NSString *entity;
        NSString *entityID;
 
        //get the query string from the url, and break it down into components
        NSArray *URLArray = [[recievedURL query] componentsSeparatedByString:@"&"];
        //break the queries down to get the required values.
        for (int i = 0; i < [URLArray count]; i++)
        {
            NSArray *queryItems = [[URLArray objectAtIndex:i] componentsSeparatedByString:@"="];
            if ([[queryItems objectAtIndex:0] isEqualToString:@"entity"]) { entity = [queryItems objectAtIndex:1]; }
            else if ([[queryItems objectAtIndex:0] isEqualToString:@"id"]) { entityID = [queryItems objectAtIndex:1]; }
        }
        
        //place data in user defaults
        [[NSUserDefaults standardUserDefaults] setObject:entity forKey:@"initialView"];
        [[NSUserDefaults standardUserDefaults] setObject:entityID forKey:@"initialID"];
        [[NSUserDefaults standardUserDefaults] setValue:@"0" forKey:@"initialCore"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    return YES;
}

- (void)application:(UIApplication *)application
didReceiveLocalNotification:(UILocalNotification *)notification
{    
    NSString *title = [[notification.userInfo allKeys] objectAtIndex:0];
    //userInfoForLocalNotification = notification.userInfo;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Event Due: %@",title] message:@"Would you like to view the event?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    [alert show];
    alert.tag = [[notification.userInfo objectForKey:[[notification.userInfo allKeys] objectAtIndex:0]] intValue];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if([title isEqualToString:@"Yes"])
    {
        //create a dictionary using the id stored in the alert view tag
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObject:[NSString stringWithFormat:@"%d",alertView.tag] forKey:@"id"];
        [userInfo setValue:@"1" forKey:@"core"];
        //send notification to the initial view reguarding the view that should be displayed.
        [[NSNotificationCenter defaultCenter] 
         postNotificationName:@"openEventFromNotification" 
         object:self userInfo:userInfo];
    }
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    if (!url) {  return NO; }
    //NSString *entity;
    NSString *entityID;
    
    //get the query string from the url, and break it down into components
    NSArray *URLArray = [[url query] componentsSeparatedByString:@"&"];
    //break the queries down to get the required values.
    for (int i = 0; i < [URLArray count]; i++)
    {
        NSArray *queryItems = [[URLArray objectAtIndex:i] componentsSeparatedByString:@"="];
        //if ([[queryItems objectAtIndex:0] isEqualToString:@"entity"]) { NSString *entity = [queryItems objectAtIndex:1]; }
        if ([[queryItems objectAtIndex:0] isEqualToString:@"id"]) { entityID = [queryItems objectAtIndex:1]; }
    }
    
    //create a local notification containing id in a userinfo dictionary.
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObject:entityID forKey:@"id"];
    [userInfo setValue:@"0" forKey:@"core"];
    [[NSNotificationCenter defaultCenter] 
     postNotificationName:@"openEventFromNotification" 
     object:self userInfo:userInfo];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[NSNotificationCenter defaultCenter] 
     postNotificationName:@"didEnterBackground" 
     object:self userInfo:nil];
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [[NSNotificationCenter defaultCenter] 
     postNotificationName:@"willEnterForeground" 
     object:self userInfo:nil];
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{

    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
//    [self configureRestKit];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
    
    //if (
    
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil)
    {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil)
    {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"SBS_CRM" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return __managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil)
    {
        return __persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"SBS_CRM.sqlite"];
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
    {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return __persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - Custom methods

//- (void)configureRestKit
//{
//    // Initialize RestKit
////    if ([[Settings settingsManager] baseURL] == nil) {
////        return;
////    }
//
//    
////    NSLog(@"baseURL = %@", [[Settings settingsManager] baseURL]);
////    RKURL *baseURL = [RKURL URLWithBaseURLString:[@"http://" stringByAppendingString:[[Settings settingsManager] baseURL]]];
////    RKURL *baseURL = [RKURL URLWithBaseURLString:[@"http://" stringByAppendingString:[[Settings settingsManager] baseURL]]];
//    RKURL *baseURL = [RKURL URLWithString:@"http://192.168.0.3/crm"];
////    RKURL *baseURL = [RKURL URLWithString:@"http://172.16.4.5/crm"];
//    RKObjectManager *objectManager = [RKObjectManager managerWithBaseURL:baseURL];
//    RKLogInfo(@"I am your RKClient singleton %@", [objectManager client]);
//    RKLogInfo(@"Base URL: %@", [baseURL debugDescription]);
//    [objectManager setSerializationMIMEType:RKMIMETypeJSON];
//    NSLog(@"%@", self.applicationDocumentsDirectory);
//    [objectManager setObjectStore:[RKManagedObjectStore objectStoreWithStoreFilename:@"SBS_CRM2.sqlite"]];
//
//    // Send this string with each request
//    [[objectManager client] setValue:@"123-456-789" 
//                  forHTTPHeaderField:@"X-UDID"];
//    
//    // User Basic HTTP Authentication
//    [[objectManager client] setAuthenticationType:RKRequestAuthenticationTypeOAuth1];
//    
//    // Use cached data if offline
//    [[objectManager client] setCachePolicy:RKRequestCachePolicyLoadIfOffline];
//    
//    // Enable automatic network activity indicator management
//    [[[objectManager client] requestQueue] setShowsNetworkActivityIndicatorWhenBusy:YES];
//    
//    // Grab the reference to the router from the manager
//    RKObjectRouter *router = [objectManager router];
//    
//    // Define a resource path for specified HTTP verbs
//    [router routeClass:[Event2 class] 
//        toResourcePath:@"/events" 
//             forMethod:RKRequestMethodGET];
//    [router routeClass:[Event2 class] 
//        toResourcePath:@"/event/:EventID" 
//             forMethod:RKRequestMethodDELETE];
//    [router routeClass:[Event2 class] 
//        toResourcePath:@"/event/:EventID" 
//             forMethod:RKRequestMethodPOST];
//    [router routeClass:[Event2 class] 
//        toResourcePath:@"/event/:EventID" 
//             forMethod:RKRequestMethodPUT];
//    
//    // Event mapping
//    RKManagedObjectMapping* EventMapping = [RKManagedObjectMapping mappingForClass:[Event2 class] 
//                                                              inManagedObjectStore:objectManager.objectStore];
//    // Automatic mapping of attributes
//    NSDictionary *EventDictionary = [[RKObjectPropertyInspector sharedInspector] propertyNamesAndTypesForClass:[Event2 class]];
//    [EventMapping mapAttributesFromSet:[NSSet setWithArray:[EventDictionary allKeys]]];
//    [[objectManager mappingProvider] setSerializationMapping:EventMapping 
//                                                    forClass:[Event2 class]];
//    [[objectManager mappingProvider] setMapping:EventMapping 
//                                     forKeyPath:@"ttEvent"];
//    
////    // Comments mapping
////    RKManagedObjectMapping* CommentsMapping = [RKManagedObjectMapping mappingForClass:[Comments class] inManagedObjectStore:objectManager.objectStore];
////    // Automatic mapping of attributes
////    NSDictionary *CommentsDictionary = [[RKObjectPropertyInspector sharedInspector] propertyNamesAndTypesForClass:[Comments class]];
////    [CommentsMapping mapAttributesFromSet:[NSSet setWithArray:[CommentsDictionary allKeys]]];
////    
////    // EventDetails mapping
////    RKManagedObjectMapping* EventDetailsMapping = [RKManagedObjectMapping mappingForClass:[EventDetails class] inManagedObjectStore:objectManager.objectStore];
////    // KeyPath is the object in the JSON. Relationship is the attribute in dsEventDetails to map to
////    [EventDetailsMapping mapKeyPath:@"Event" 
////                     toRelationship:@"Event" 
////                        withMapping:EventMapping];
////    [EventDetailsMapping mapKeyPath:@"Comments" 
////                     toRelationship:@"Comments" 
////                        withMapping:EventMapping];
////    [[objectManager mappingProvider] setMapping:EventDetailsMapping 
////                                     forKeyPath:@""];
//    
////    RKObjectManager *objectManager = [RKObjectManager sharedManager];
//}

@end
