//
//  Contact.h
//  SBS CRM
//
//  Created by Tom Couchman on 13/02/2012.
//  Copyright (c) 2012 Shuttleworth Business Systems Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Contact : NSManagedObject

@property (nonatomic, retain) NSString * conFirstName;
@property (nonatomic, retain) NSString * conMiddleName;
@property (nonatomic, retain) NSString * conSurname;
@property (nonatomic, retain) NSString * contactID;
@property (nonatomic, retain) NSString * conTitle;
@property (nonatomic, retain) NSString * companySiteID;
@property (nonatomic, retain) NSString * cosDescription;
@property (nonatomic, retain) NSString * cosSiteName;

@end
