//
//  syncData.h
//  SBS CRM
//
//  Created by Tom Couchman on 09/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Events.h"
#import "Communication.h"
#import "Contact.h"
#import "Company.h"
#import "Attachment.h"
#import "DDXML.h"
#import "AppDelegate.h"


@interface syncData : NSObject <UIApplicationDelegate>{
    DDXMLDocument *eventsDocument;
    DDXMLDocument *contactsDocument;
    DDXMLDocument *companiesDocument;
    DDXMLDocument *communicationDocument;
    DDXMLDocument *attachmentsDocument;
    
    NSURL *url;
    NSString *xmlString;
    NSData *xmlData;
    
}

@property (nonatomic, retain) AppDelegate *appDelegate;

- (NSDate *)formatDate:(NSString *)date;

- (BOOL)doSync;
- (BOOL)getDom;
- (BOOL)reloadEvents;
- (BOOL)reloadCompanies;
- (BOOL)reloadContacts;
- (BOOL)reloadCommunication;
- (BOOL)reloadAttachments;
//- (BOOL)reloadEntity:(NSString *)entity:(DDXMLDocument *)currentDocument;

@end
