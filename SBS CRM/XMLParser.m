//
//  XMLParser.m
//  SBS CRM 2.0
//
//  Created by Tom Couchman on 28/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <objc/runtime.h>
#import <objc/message.h>
#import "XMLParser.h"
#import "Format.h"
#import "EventSearch.h"
#import "ContactSearch.h"
#import "CompanySearch.h"
#import "CommunicationSearch.h"
#import "AttachmentSearch.h"
#import "Event.h"
#import "Communication.h"
#import "Contact.h"
#import "Company.h"
#import "Attachment.h"
#import "UserDetails.h"
#import "NSManagedObject+CoreDataManager.h"
#import "AppDelegate.h"
#import "PropertyInfo.h"

@implementation XMLParser

- (NSArray *)parseXMLDoc:(DDXMLDocument *)doc toClass:(Class)outputClass
{
    
    NSLog(@"class name = %@", NSStringFromClass(outputClass));
    
    NSMutableArray* elementArray = [[NSMutableArray alloc] init];
    
    //create an array of nodes and fill it with the children of the documents root element.
    NSArray* nodes;
    
    if (outputClass == [UserDetails class])
        nodes = [NSArray arrayWithObject:[doc rootElement]]; 
    else
        nodes = [[doc rootElement] children];
    
    // loop through each element
    for (DDXMLElement *element in nodes)
    { 
        // creat an instance of the output class.
        NSObject *currentItem = [[outputClass alloc] init];
        
        NSLog(@"property name = %@", element.name);
        
        if ([[element children] count]) {
            NSArray* children = [element children];
            
            for (DDXMLElement *child in children) {
                
                if (child != NULL && child!= nil && ![child.stringValue isEqualToString:@""]) {

                    if (outputClass == [NSDictionary class] || outputClass == [NSMutableDictionary class]) {
                        [currentItem setValue:child.stringValue forKey:child.name];  
                    }
                    else {
                        objc_property_t property = class_getProperty(outputClass, [child.name cStringUsingEncoding:NSUTF8StringEncoding]);
                        id convertedValue = [self convertFromString:child.stringValue toTypeFromTypeString:[PropertyInfo getPropertyType:property]];
                        [currentItem setValue:convertedValue forKey:child.name];  
                    }
                    
                }
                else [currentItem setValue:@"" forKey:child.name];
                
            }
            
        }
        else currentItem = [self convertFromString:element.stringValue toTypeFromTypeString:NSStringFromClass(outputClass)];
        
        if (currentItem) [elementArray addObject:currentItem];
    }
    
    return elementArray;
}

- (id)convertFromString:(NSString *)valueString toTypeFromTypeString:(NSString *)typeString
{    
    if ([typeString isEqualToString:@"NSString"])
        return valueString;
    else if ([typeString isEqualToString:@"NSDate"]) {
        return [Format formatDate:valueString];
    }
    else if ([typeString isEqualToString:@"i"] || [typeString isEqualToString:@"int"]) {
        return [NSNumber numberWithInt:[valueString integerValue]];
    }
    else {
        return valueString;
    }
}

@end

/*AppDelegate *appDelegate;
 NSManagedObjectContext *context;
 NSEntityDescription *entity;
 BOOL customClass;
 */


// if is a coredata class:
/*
 //TODO - change following if to the line below: - not implemented yet, as needs to be tested.
 if ([NSClassFromString(className) isSubclassOfClass:[NSManagedObject class]])
 {
 
 //class_getName([NSString class]);
 //determine the search class from the entityname.
 NSString *SearchClass = [className stringByAppendingString:@"Search"];
 currentItem = [[NSClassFromString(SearchClass) alloc] init];
 appDelegate = [[UIApplication sharedApplication] delegate];
 context = [appDelegate managedObjectContext];
 entity = [NSEntityDescription entityForName:className inManagedObjectContext:context];
 customClass = YES;
 }
 else { 
 currentItem = [[NSClassFromString(className) alloc] init];    
 customClass = NO;
 }
 */