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
        
        NSDictionary *images = nilOrJSONObjectForKey( data, @"images" );
        _user_img_thumb = nilOrJSONObjectForKey( images, @"user" );
        
        _review_id = [nilOrJSONObjectForKey( data, @"review_id" ) integerValue];
        
        _viewed    = [nilOrJSONObjectForKey( data, @"viewed" )       boolValue];
        _item_id   = [nilOrJSONObjectForKey( data, kIDKey )       integerValue];
    }
    
    return self;
}

- (NSString *)formattedString
{
    return @"";
}

@end