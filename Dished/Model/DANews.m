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
        NSTimeInterval timeInterval = [nilOrJSONObjectForKey( data, kCreatedKey ) doubleValue];
        _created   = [NSDate dateWithTimeIntervalSince1970:timeInterval];
        
        NSDictionary *images = nilOrJSONObjectForKey( data, kImagesKey );
        if( images )
        {
            _user_img_thumb = nilOrJSONObjectForKey( images, kUserKey );
        }
        
        _viewed    = [nilOrJSONObjectForKey( data, kViewedKey ) boolValue];
        _item_id   = [nilOrJSONObjectForKey( data, kIDKey )    integerValue];
        _review_id = [nilOrJSONObjectForKey( data, kReviewIDKey ) integerValue];
    }
    
    return self;
}

- (NSString *)formattedString
{
    return @"";
}

@end