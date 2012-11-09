//
//  Version.h
//  SBS CRM 2.0
//
//  Created by Mark Norris on 06/11/2012.
//  Copyright (c) 2012 Shuttleworth Business Systems Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Version : NSObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * version;

+ (void)configureEntity;
+ (void)loadObjectsWithDelegate:(id)delegate;

@end
