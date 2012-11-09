//
//  RestKit.h
//  SBS CRM 2.0
//
//  Created by Mark Norris on 01/11/2012.
//  Copyright (c) 2012 Shuttleworth Business Systems Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>

@protocol SBSRestKit <NSObject>

@required
+ (RKManagedObjectMapping *)configureEntity;
+ (void)setEntityObjectMapping:(RKManagedObjectMapping *)objectMapping;
+ (void)loadObjectsWithDelegate:(id)delegate;

@end

@interface SBSRestKit : NSObject

+ (SBSRestKit *)sharedSBSRestKit;
+ (void)configureRestKit;
+ (RKManagedObjectMapping *)configureEntityForClass:(Class)class keyPath:(NSString *)keyPath primaryKey:(NSString *)primaryKey defaultRoute:(NSString *)defaultRoute deleteRoute:(NSString *)deleteRoute getRoute:(NSString *)getRoute postRoute:(NSString *)postRoute putRoute:(NSString *)putRoute;
+ (void)setEntityObjectMapping:(RKManagedObjectMapping *)objectMapping forKeyPath:(NSString *)keyPath;

@end
