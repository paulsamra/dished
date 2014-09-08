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
    DAUsername *username = [[DAUsername alloc] init];
    
    username.username = data[@"username"];
    username.user_id  = [data[@"id"] integerValue];
    
    return username;
}

@end