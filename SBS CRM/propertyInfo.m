//
//  propertyInfo.m
//  SBS CRM 2.0
//
//  Created by Tom Couchman on 27/07/2012.
//  Copyright (c) 2012 Shuttleworth Business Systems Limited. All rights reserved.
//

#import "propertyInfo.h"

@implementation propertyInfo


+(NSString *) getPropertyType:(objc_property_t) property {
    const char *attributes = property_getAttributes(property);
    printf("attributes=%s\n", attributes);
    char buffer[1 + strlen(attributes)];
    strcpy(buffer, attributes);
    char *state = buffer, *attribute;
    while ((attribute = strsep(&state, ",")) != NULL) {
        if (attribute[0] == 'T' && attribute[1] != '@') {
            // it's a C primitive type:
            /* 
             if you want a list of what will be returned for these primitives, search online for
             "objective-c" "Property Attribute Description Examples"
             apple docs list plenty of examples of what you get for int "i", long "l", unsigned "I", struct, etc.            
             */
            return [NSString stringWithCString:(const char *)[[NSData dataWithBytes:(attribute + 1) length:strlen(attribute) - 1] bytes] encoding:NSUTF8StringEncoding];
        }        
        else if (attribute[0] == 'T' && attribute[1] == '@' && strlen(attribute) == 2) {
            // it's an ObjC id type:
            return @"id";
        }
        else if (attribute[0] == 'T' && attribute[1] == '@') {
            // it's another ObjC object type:
            return [NSString stringWithCString:(const char *)[[NSData dataWithBytes:(attribute + 3) length:strlen(attribute) - 4] bytes] encoding:NSUTF8StringEncoding];
        }
    }
    return @"";
}

@end
