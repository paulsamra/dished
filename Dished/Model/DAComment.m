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
    comment.comment_id       = [data[kIDKey] integerValue];
    comment.creator_id       = [data[@"creator_id"] integerValue];
    comment.comment          = nilOrJSONObjectForKey( data, kCommentKey );
    comment.img_thumb        = nilOrJSONObjectForKey( data, kImgThumbKey );
    comment.creator_type     = data[@"creator_type"];
    comment.creator_username = data[@"creator_username"];
    
    return comment;
}

@end