//
//  

//  SBS CRM 2.0
//
//  Created by Tom Couchman on 31/05/2012.
//  Copyright (c) 2012 Shuttleworth Business Systems Limited. All rights reserved.
//

//------------------------------------------------------------------------
//
//  Extend the functionality of the NSManagedObject Class to include
//  convinience methods for access and deletion.
//
//------------------------------------------------------------------------

#import <CoreData/CoreData.h>

@interface NSManagedObject (CoreDataManager)

//------------------------------------------------------------------------
// Request objects by entity name - with predicate and sort descriptors
//------------------------------------------------------------------------
+ (NSArray *)fetchObjectsForEntityName:(NSString *)entityName withPredicate:(NSPredicate *)predicate withSortDescriptors:(NSArray *)SortDescriptors;

//------------------------------------------------------------------------
// Request _all_ objects with entity name 
//------------------------------------------------------------------------
+ (NSArray *)fetchObjectsForEntityName:(NSString *)entityName;

//------------------------------------------------------------------------
// delete objects for entityName With predicate
//------------------------------------------------------------------------
+ (BOOL)deleteObjectsForEntityName:(NSString *)entityName withPredicate:(NSPredicate *)predicate;

//------------------------------------------------------------------------
// delete _all_ objects with entity name 
//------------------------------------------------------------------------
+ (BOOL)deleteAllObjectsForEntityName:(NSString *)entityName;

//------------------------------------------------------------------------
// Save array to core data for entityName
//------------------------------------------------------------------------
+ (BOOL)storeInCoreData:(NSArray *)classArray forEntityName:(NSString *)entityName;

//------------------------------------------------------------------------
// Update object in core data
//------------------------------------------------------------------------
+ (BOOL)updateCoreDataObject:(NSObject *)object forEntityName:(NSString *)entityName withPredicate:(NSPredicate *)predicate;
    
@end
