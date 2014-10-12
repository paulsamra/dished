//
//  DANews.m
//  Dished
//
//  Created by Ryan Khalili on 9/22/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DANews.h"


@implementation DANews

- (id)initWithData:(id)data
{
    if( self = [super init] )
    {
        NSTimeInterval timeInterval = [data[@"created"] doubleValue];
        _created   = [NSDate dateWithTimeIntervalSince1970:timeInterval];
        _img = nilOrJSONObjectForKey( data, @"img" );
        
        _viewed    = [nilOrJSONObjectForKey( data, @"viewed" )       boolValue];
        _item_id   = [nilOrJSONObjectForKey( data, kIDKey )       integerValue];
        _review_id = [nilOrJSONObjectForKey( data, @"review_id" ) integerValue];
    }
    
    return self;
}

- (NSString *)formattedString
{
    return @"";
}

@end