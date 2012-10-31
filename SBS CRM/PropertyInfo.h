//
//  propertyInfo.h
//  SBS CRM 2.0
//
//  Created by Tom Couchman on 27/07/2012.
//  Copyright (c) 2012 Shuttleworth Business Systems Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <objc/message.h>

@interface PropertyInfo : NSObject

+(NSString *) getPropertyType:(objc_property_t) property;

@end
