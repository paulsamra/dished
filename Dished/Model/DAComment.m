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

- (NSAttributedString *)attributedCommentStringWithFont:(UIFont *)font
{
    NSDictionary *textAttributes = @{ NSFontAttributeName : [UIFont fontWithName:kHelveticaNeueLightFont size:14.0f] };
    NSString *usernameString = [NSString stringWithFormat:@"@%@", self.creator_username];
    NSMutableAttributedString *finalString = [[[NSAttributedString alloc] initWithString:usernameString attributes:textAttributes] mutableCopy];
    
    if( [self.creator_type isEqualToString:kInfluencerUserType] )
    {
        [finalString appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
        NSAttributedString *influencerIconString = [NSAttributedString attributedStringWithAttachment:[[DAInfluencerTextAttachment alloc] init]];
        [finalString appendAttributedString:influencerIconString];
    }
    
    NSAttributedString *commentString = [[NSAttributedString alloc] initWithString:self.comment attributes:textAttributes];
    [finalString appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
    [finalString appendAttributedString:commentString];
    
    return finalString;
}

@end