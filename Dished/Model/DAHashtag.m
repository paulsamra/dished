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
    return self.hashtag_id == object.hashtag_id && [self.name isEqualToString:object.name];
}

- (NSUInteger)hash
{
    return self.hashtag_id ^ [self.name hash];
}

+ (DAHashtag *)hashtagWithData:(id)data
{
    DAHashtag *hashtag = [[DAHashtag alloc] init];
    
    hashtag.name       = data[kNameKey];
    hashtag.hashtag_id = [data[kIDKey] integerValue];
    
    return hashtag;
}

@end