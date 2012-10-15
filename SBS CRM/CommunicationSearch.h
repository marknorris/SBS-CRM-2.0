//
//  CommunicationSearch.h
//  SBS CRM
//
//  Created by Tom Couchman on 17/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommunicationSearch : NSObject

@property (nonatomic, retain) NSString * contactID;
@property (nonatomic, retain) NSString * communicationNumberID;
@property (nonatomic, retain) NSString * cmnEmail;
@property (nonatomic, retain) NSString * cmnInternationalCode;
@property (nonatomic, retain) NSString * cmnAreaCode;
@property (nonatomic, retain) NSString * cmnNumber;
@property (nonatomic, retain) NSString * cotDescription;

@end
