//
//  fetchXML.h
//  SBS CRM 2.0
//
//  Created by Tom Couchman on 26/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDXML.h"

@protocol fetchXMLDelegate <NSObject>
@required
-(void)fetchXMLError:(NSString *)errorResponse:(id)sender;
-(void)docRecieved:(NSDictionary *)doc:(id)sender;
@end

@interface fetchXML : NSObject{
    id <fetchXMLDelegate> delegate;
    
}


- (id) initWithUrl:(NSURL *)url delegate:(id)Delegate className:(NSString *)ClassName;
- (BOOL)fetchXML;

@property (nonatomic, strong) id delegate;
@property (nonatomic, strong) NSString* className;
@property (nonatomic, strong) NSURL *url;

- (BOOL)fetchXMLWithURL:(NSString *)URLString;
- (void)cancel;
@end
