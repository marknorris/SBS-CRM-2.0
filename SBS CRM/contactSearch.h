//
//  contactSearch.h
//  SBS CRM
//
//  Created by Tom Couchman on 13/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface contactSearch : NSObject

@property (nonatomic, strong) NSString * conFirstName;
@property (nonatomic, strong) NSString * conMiddleName;
@property (nonatomic, strong) NSString * conSurname;
@property (nonatomic, strong) NSString * contactID;
@property (nonatomic, strong) NSString * conTitle;
@property (nonatomic, strong) NSString * companySiteID;
@property (nonatomic, strong) NSString * cosDescription;
@property (nonatomic, strong) NSString * cosSiteName;

@end
