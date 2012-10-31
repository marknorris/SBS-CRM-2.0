//
//  fetchXML.h
//  SBS CRM 2.0
//
//  Created by Tom Couchman on 26/03/2012.
//  Copyright (c) 2012 Shuttleworth Business Systems Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDXML.h"

@protocol FetchXMLDelegate <NSObject>

@required
- (void)fetchXMLError:(NSString *)errorResponse:(id)sender;
- (void)docRecieved:(NSDictionary *)doc:(id)sender;

@end

@interface FetchXML : NSObject

@property (nonatomic, strong) NSURL *url;

- (id)initWithUrl:(NSURL *)url delegate:(id)delegate className:(NSString *)className;
- (BOOL)fetchXML;
- (BOOL)fetchXMLWithURL:(NSString *)urlString;
- (void)cancel;

@end
