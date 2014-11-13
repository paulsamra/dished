//
//  DAUsername.m
//  Dished
//
//  Created by Ryan Khalili on 9/8/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DAUsername.h"


@implementation DAUsername

+ (DAUsername *)usernameWithData:(id)data
{
    return [[DAUsername alloc] initWithData:data];
}

- (id)initWithData:(id)data
{
    if( self = [super init] )
    {
        _type      = nilOrJSONObjectForKey( data, kTypeKey );
        _username  = nilOrJSONObjectForKey( data, kUsernameKey );
        _img_thumb = nilOrJSONObjectForKey( data, kImgThumbKey );
        
        _user_id    = [nilOrJSONObjectForKey( data, kIDKey ) integerValue];
        _isFollowed = [nilOrJSONObjectForKey( data, @"caller_follows" ) boolValue];
    }
    
    return self;
}

@end