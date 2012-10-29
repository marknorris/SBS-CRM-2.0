//
//  Communication.h
//  SBS CRM
//
//  Created by Tom Couchman on 09/02/2012.
//  Copyright (c) 2012 Shuttleworth Business Systems Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Communication : NSManagedObject

@property (nonatomic, retain) NSString * contactID;
@property (nonatomic, retain) NSString * communicationNumberID;
@property (nonatomic, retain) NSString * cmnEmail;
@property (nonatomic, retain) NSString * cmnInternationalCode;
@property (nonatomic, retain) NSString * cmnAreaCode;
@property (nonatomic, retain) NSString * cmnNumber;
@property (nonatomic, retain) NSString * cotDescription;

@end
