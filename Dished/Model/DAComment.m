//
//  DAComment.m
//  Dished
//
//  Created by Ryan Khalili on 8/28/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DAComment.h"


@implementation DAComment

+ (DAComment *)commentWithData:(id)data
{
    DAComment *comment = [[DAComment alloc] init];
    
    NSTimeInterval timeInterval = [data[@"created"] doubleValue];
    
    comment.created          = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    comment.comment_id       = [data[@"id"] integerValue];
    comment.creator_id       = [data[@"creator_id"] integerValue];
    comment.comment          = data[@"comment"];
    comment.img_thumb        = nilOrJSONObjectForKey( data, @"img_thumb" );
    comment.creator_type     = data[@"creator_type"];
    comment.creator_username = data[@"creator_username"];
    
    return comment;
}

@end