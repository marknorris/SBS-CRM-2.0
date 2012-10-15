//
//  getDom.h
//  SBS CRM 2.0
//
//  Created by Tom Couchman on 26/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDXML.h"

@protocol getDomDelegate <NSObject>
@required
-(void)getDomError:(NSString *)errorResponse:(id)sender;
-(void)docRecieved:(NSDictionary *)doc:(id)sender;
@end

@interface getDom : NSObject{
    id <getDomDelegate> delegate;
    
}


- (id) initWithUrl:(NSURL *)url delegate:(id)Delegate className:(NSString *)ClassName;
- (BOOL)getDom;

@property (nonatomic, strong) id delegate;
@property (nonatomic, strong) NSString* className;
@property (nonatomic, strong) NSURL *url;

- (BOOL)getDom:(NSString *)URLString;
- (void)cancel;
@end
