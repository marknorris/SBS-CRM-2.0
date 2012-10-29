//
//  saveToCoreData.h
//  SBS CRM 2.0
//
//  Created by Tom Couchman on 28/03/2012.
//  Copyright (c) 2012 Shuttleworth Business Systems Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"

@interface saveToCoreData : NSObject 

@property (nonatomic, retain) AppDelegate *appDelegate;

- (BOOL)storeInCoreData:(NSArray *)eventArray:(NSString *)entityName;

@end
