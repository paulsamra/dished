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
        _username  = nilOrJSONObjectForKey( data, @"username" );
        _img_thumb = nilOrJSONObjectForKey( data, @"img_thumb" );
        
        _isFollowed = [data[@"caller_follows"] boolValue];
        _user_id    = [data[@"id"] integerValue];
    }
    
    return self;
}

@end