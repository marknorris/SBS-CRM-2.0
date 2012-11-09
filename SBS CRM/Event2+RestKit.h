//
//  Event2+RestKit.h
//  SBS CRM 2.0
//
//  Created by Mark Norris on 01/11/2012.
//  Copyright (c) 2012 Shuttleworth Business Systems Limited. All rights reserved.
//

#import "Event2.h"
#import "EventComment+RestKit.h"
#import "SBSRestKit.h"
#import "Company2+RestKit.h"

@interface Event2 (RestKit) <SBSRestKit>

- (EventComment *)firstEventComment;

@end
