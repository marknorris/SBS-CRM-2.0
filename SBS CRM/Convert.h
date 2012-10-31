//
//  convert.h
//  SBS CRM 2.0
//
//  Created by Tom Couchman on 08/06/2012.
//  Copyright (c) 2012 Shuttleworth Business Systems Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "EventSearch.h"
#import "ContactSearch.h"
#import "CompanySearch.h"
#import "AttachmentSearch.h"
#import "CommunicationSearch.h"
#import "Event.h"
#import "Contact.h"
#import "Company.h"
#import "Communication.h"
#import "Attachment.h"

@interface Convert : NSObject

+ (EventSearch *)EventSearchFromEvent:(Event *)event;
+ (ContactSearch *)ContactSearchFromConact:(Contact *)contact;
+ (CommunicationSearch *)CommunicationSearchFromCommunication:(Communication *)communication;
+ (CompanySearch *)CompanySearchFromCompany:(Company *)company;
+ (AttachmentSearch *)AttachmentSearchFromAttachment:(Attachment *)attachment;

@end
