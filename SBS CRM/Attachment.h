//
//  Attachment.h
//  SBS CRM
//
//  Created by Tom Couchman on 09/02/2012.
//  Copyright (c) 2012 Shuttleworth Business Systems Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Attachment : NSManagedObject

@property (nonatomic, retain) NSString * eventID;
@property (nonatomic, retain) NSString * attachmentID;
@property (nonatomic, retain) NSString * attDescription;
@property (nonatomic, retain) NSString * atyMnemonic;
@property (nonatomic, retain) NSString * attOriginalFilename;

@end
