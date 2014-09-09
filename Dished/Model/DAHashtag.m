//
//  DAHashtag.m
//  Dished
//
//  Created by Ryan Khalili on 7/11/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DAHashtag.h"

@implementation DAHashtag

- (BOOL)isEqual:(id)object
{
    if( self == object )
    {
        return YES;
    }
    
    if( ![object isKindOfClass:[DAHashtag class]] )
    {
        return NO;
    }
    
    return [self isEqualToHashtag:(DAHashtag *)object];
}

- (BOOL)isEqualToHashtag:(DAHashtag *)object
{
    return [self.hashtagID isEqualToString:object.hashtagID];
}

- (NSUInteger)hash
{
    return [self.hashtagID hash] ^ [self.name hash];
}

+ (DAHashtag *)hashtagWithData:(id)data
{
    DAHashtag *hashtag = [[DAHashtag alloc] init];
    
    hashtag.name      = data[@"name"];
    hashtag.hashtagID = data[@"id"];
    
    return hashtag;
}

@end