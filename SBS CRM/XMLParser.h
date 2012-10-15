//
//  XMLParser.h
//  SBS CRM 2.0
//
//  Created by Tom Couchman on 28/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDXML.h"

@interface XMLParser : NSObject

- (NSArray *)parseXMLDoc:(DDXMLDocument *)Doc toClass:(Class)outputClass;

@end
