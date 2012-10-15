//
//  NSManagedObject+CoreDataManager.m
//  SBS CRM 2.0
//
//  Created by Tom Couchman on 31/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CoreDataManager.h"
#import "AppDelegate.h"

@implementation NSManagedObject (CoreDataManager)

//------------------------------------------------------------------------
// Request objects by entity name - with predicate and sort descriptors
//------------------------------------------------------------------------
+ (NSArray *)fetchObjectsForEntityName:(NSString *)entityName
                       withPredicate:(NSPredicate *)predicate withSortDescriptors:(NSArray *)SortDescriptors;{
    NSManagedObjectContext *context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext]; 
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:entityName inManagedObjectContext:context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    
    if (predicate)
        [request setPredicate:predicate];
    
    if (SortDescriptors)
        [request setSortDescriptors:SortDescriptors];
    
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:request error:&error];
    if (error != nil)
    {
        [NSException raise:NSGenericException format:[error description]];
    }
    
    return results;
}


//------------------------------------------------------------------------
// Request _all_ objects with entity name 
//------------------------------------------------------------------------
+ (NSArray *)fetchObjectsForEntityName:(NSString *)entityName{

    return [self fetchObjectsForEntityName:entityName
                                withPredicate:nil withSortDescriptors:nil];
}

//------------------------------------------------------------------------
// delete objects for entityName With predicate
//------------------------------------------------------------------------
+ (BOOL)deleteObjectsForEntityName:(NSString *)entityName
                     withPredicate:(NSPredicate *)predicate{
    
    
    NSManagedObjectContext *context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext]; 
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    
    if (predicate)
        [request setPredicate:predicate];
    
    NSError *error = nil;
    //get an array of all the objects to delete.
    NSArray *objectsToDeleteArray = [context executeFetchRequest:request error:&error];
    
    //Loop through the returned objects and delete them:
    for (NSManagedObject *objecToDelete in objectsToDeleteArray) {
        [context deleteObject:objecToDelete];
    }
    
    NSError *saveError = nil;
    return [context save:&saveError];
}


//------------------------------------------------------------------------
// delete _all_ objects with entity name 
//------------------------------------------------------------------------
+ (BOOL)deleteAllObjectsForEntityName:(NSString *)entityName{
        return [NSManagedObject deleteObjectsForEntityName:entityName
                                         withPredicate:nil];
}







//------------------------------------------------------------------------
// Save array to core data:
//------------------------------------------------------------------------
+ (BOOL)storeInCoreData:(NSArray *)classArray forEntityName:(NSString *)entityName{

    NSError *error;    
    NSManagedObjectContext *context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext]; 
    
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
        NSManagedObject *object;
        object = [classArray objectAtIndex:i];
        
        id entityToSave = [NSClassFromString(entityName) alloc];
        entityToSave = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:context]; 
        
        NSDictionary *attributes = [[NSEntityDescription
                                     entityForName:entityName
                                     inManagedObjectContext:context] attributesByName];
        
        for (NSString *attr in attributes) {
            [entityToSave setValue:[object valueForKey:attr] forKey:attr];
        }
        
    

        
    }
    if (![context save:&error]) return NO;
    
    
    //if successful return yes
    return YES;
}

//------------------------------------------------------------------------
// Update object in core data
//------------------------------------------------------------------------
+ (BOOL)updateCoreDataObject:(NSObject *)object forEntityName:(NSString *)entityName withPredicate:(NSPredicate *)predicate{
    
    NSError *error;    
    NSManagedObjectContext *context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext]; 
    
    // fetch saved events from coredata and delete them
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    
    
    
    id entityToSave = [[context executeFetchRequest:fetchRequest error:&error] lastObject];
    
    NSDictionary *attributes = [[NSEntityDescription
                                 entityForName:entityName
                                 inManagedObjectContext:context] attributesByName];
    
    for (NSString *attr in attributes) {
        [entityToSave setValue:[object valueForKey:attr] forKey:attr];
    }
    

    if (![context save:&error]) return NO;
    
    
    //if successful return yes
    return YES;
}


@end
