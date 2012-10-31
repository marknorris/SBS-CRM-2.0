//
//  convert.m
//  SBS CRM 2.0
//
//  Created by Tom Couchman on 08/06/2012.
//  Copyright (c) 2012 Shuttleworth Business Systems Limited. All rights reserved.
//

#import "convert.h"

@implementation convert


//------------------------------------------------------------------------
// convert ManagedObject to search class
//------------------------------------------------------------------------
+ (void)searchClass:(id)searchObject FromManagedObject:(NSManagedObject *)object{
    
    //loop through each attribute in the managed objects entity
    for (NSString *attribute in [[[object entity] attributesByName] allKeys])
    {
        //for each key place the value from event into EventSearch
        [searchObject setValue:[object valueForKey:attribute] forKey:attribute];
    }
}


//------------------------------------------------------------------------
// Class specific methods to call converter method
//------------------------------------------------------------------------
+ (EventSearch *)EventSearchFromEvent:(Event *)event{
    EventSearch *convertedEvent = [[EventSearch alloc] init];
    
    [self searchClass:convertedEvent FromManagedObject:event];
    
    return convertedEvent;
}

+ (ContactSearch *)ContactSearchFromConact:(Contact *)contact{
    ContactSearch *convertedConact;
    
    [self searchClass:convertedConact FromManagedObject:contact];
    
    return convertedConact;
}

+ (CommunicationSearch *)CommunicationSearchFromCommunication:(Communication *)communication{
    CommunicationSearch *convertedCommunication;
    
    [self searchClass:convertedCommunication FromManagedObject:communication];
    
    return convertedCommunication;
}

+ (CompanySearch *)CompanySearchFromCompany:(Company *)company{
    CompanySearch *convertedCompany;
    
    [self searchClass:convertedCompany FromManagedObject:company];
    
    return convertedCompany;
}

+ (AttachmentSearch *)AttachmentSearchFromAttachment:(Attachment *)attachment{
    AttachmentSearch *convertedAttachment;
    
    [self searchClass:convertedAttachment FromManagedObject:attachment];
    
    return convertedAttachment;
}

@end
