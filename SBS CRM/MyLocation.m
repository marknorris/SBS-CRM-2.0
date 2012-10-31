//
//  myLocation.m
//  SBS CRM
//
//  Created by Tom Couchman on 08/03/2012.
//  Copyright (c) 2012 Shuttleworth Business Systems Limited. All rights reserved.
//

#import "myLocation.h"


@implementation myLocation 

@synthesize name = _name;
@synthesize address = _address;
@synthesize coordinate = _coordinate;

-(id)initWithName:(NSString *)name address:(NSString *)address coordinate:(CLLocationCoordinate2D)coordinate
{
    
    
    if ((self = [super init])){
        _name = [name copy];
        _address = [address copy];
        _coordinate = coordinate;
    }
    
    
    return self;
    
}


-(NSString *)title{
    return _name;
}


-(NSString *)subtitle{
    return _address;
}

-(void)dealloc{
    _name = nil;
    _address = nil;
}


@end