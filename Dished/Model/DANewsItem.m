//
//  DANewsItem.m
//  Dished
//
//  Created by Ryan Khalili on 9/17/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DANewsItem.h"


@implementation DANewsItem

+ (DANewsItem *)newsItemWithData:(id)data
{
    return [[DANewsItem alloc] initWithData:data];
}

- (id)initWithData:(id)data
{
    if( self = [super init] )
    {
        NSTimeInterval timeInterval = [data[@"created"] doubleValue];
        _created = [NSDate dateWithTimeIntervalSince1970:timeInterval];
        
        _type = nilOrJSONObjectForKey( data, @"type" );
        
        _item_id = [data[@"id"] integerValue];
    }
    
    return self;
}

@end