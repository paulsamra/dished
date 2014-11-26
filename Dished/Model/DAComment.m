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
    
    NSTimeInterval timeInterval = [nilOrJSONObjectForKey( data, kCreatedKey ) doubleValue];
    
    comment.created          = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    comment.comment_id       = [nilOrJSONObjectForKey( data, kIDKey ) integerValue];
    comment.creator_id       = [nilOrJSONObjectForKey( data, @"creator_id" ) integerValue];
    comment.comment          = nilOrJSONObjectForKey( data, kCommentKey );
    comment.img_thumb        = nilOrJSONObjectForKey( data, kImgThumbKey );
    comment.creator_type     = nilOrJSONObjectForKey( data, @"creator_type" );
    comment.creator_username = nilOrJSONObjectForKey( data, @"creator_username" );
    comment.usernameMentions = nilOrJSONObjectForKey( data, @"usernames" );
    
    if( !comment.usernameMentions )
    {
        comment.usernameMentions = @[ ];
    }
    
    return comment;
}

@end