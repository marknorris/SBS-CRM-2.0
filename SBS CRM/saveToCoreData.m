//
//  saveToCoreData.m
//  SBS CRM 2.0
//
//  Created by Tom Couchman on 28/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "saveToCoreData.h"

//import the search classes and core data managed object clases
#import "Event.h"
#import "Communication.h"
#import "Contact.h"
#import "Company.h"
#import "Attachment.h"

#import "EventSearch.h"
#import "ContactSearch.h"
#import "CompanySearch.h"
#import "CommunicationSearch.h"
#import "AttachmentSearch.h"

@implementation saveToCoreData

@synthesize appDelegate;

- (BOOL)storeInCoreData:(NSArray *)classArray:(NSString *)entityName{
    
    appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSError *error;    
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
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
        NSObject *eve;
        eve = [classArray objectAtIndex:i];
        
        
        
        id entityToSave = [NSClassFromString(entityName) alloc];
        entityToSave = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:context]; 
        

        
        
        NSDictionary *attributes = [[NSEntityDescription
                                     entityForName:entityName
                                     inManagedObjectContext:context] attributesByName];
        
        for (NSString *attr in attributes) {
            [entityToSave setValue:[eve valueForKey:attr] forKey:attr];
        }
        

    }
    if (![context save:&error]) return NO;
    
    
    //if successful return yes
    return YES;
}

@end
