//
//  AttachmentSearch.h
//  SBS CRM 2.0
//
//  Created by Tom Couchman on 27/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AttachmentSearch : NSObject

@property (nonatomic, retain) NSString * eventID;
@property (nonatomic, retain) NSString * attachmentID;
@property (nonatomic, retain) NSString * attDescription;
@property (nonatomic, retain) NSString * atyMnemonic;
@property (nonatomic, retain) NSString * attOriginalFilename;

@end
