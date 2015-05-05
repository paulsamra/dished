//
//  DANewsItem.m
//  Dished
//
//  Created by Ryan Khalili on 9/17/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DAUserNews.h"


@implementation DAUserNews

+ (DAUserNews *)userNewsWithData:(id)data
{
    return [[DAUserNews alloc] initWithData:data];
}

- (id)initWithData:(id)data
{
    if( self = [super initWithData:data] )
    {
        _comment  = nilOrJSONObjectForKey( data, kCommentKey );
        _username = nilOrJSONObjectForKey( data, kUsernameKey );
        _user_type = nilOrJSONObjectForKey( data, @"source_user_type" );
        
        NSDictionary *images = nilOrJSONObjectForKey( data, kImagesKey );
        if( images )
        {
            NSArray *reviewImages = nilOrJSONObjectForKey( images, kReviewsKey );
            if( reviewImages )
            {
                _review_img_thumb = [reviewImages objectAtIndex:0];
            }
        }
                
        _notificationType = [self notificationTypeForTypeString:nilOrJSONObjectForKey( data, kTypeKey )];
    }
    
    return self;
}

- (eUserNewsNotificationType)notificationTypeForTypeString:(NSString *)string
{
    eUserNewsNotificationType type = eUserNewsNotificationTypeUnknown;
    
    if( [string isEqualToString:kUserNewsFollowNotification] )
    {
        type = eUserNewsNotificationTypeFollow;
    }
    else if( [string isEqualToString:kUserNewsReviewYumNotification] )
    {
        type = eUserNewsNotificationTypeYum;
    }
    else if( [string isEqualToString:kUserNewsReviewMentionNotification] )
    {
        type = eUserNewsNotificationTypeReviewMention;
    }
    else if( [string isEqualToString:kUserNewsReviewCommentNotification] )
    {
        type = eUserNewsNotificationTypeComment;
    }
    else if( [string isEqualToString:kUserNewsReviewCommentMentionNotification] )
    {
        type = eUserNewsNotificationTypeCommentMention;
    }
    
    return type;
}

- (NSString *)formattedString
{
    NSString *string = [super formattedString];
    
    switch( self.notificationType )
    {
        case eUserNewsNotificationTypeFollow:
            string = [NSString stringWithFormat:@"@%@ just started following you!", self.username];
            break;
            
        case eUserNewsNotificationTypeYum:
            string = [NSString stringWithFormat:@"@%@ YUMMED your review.", self.username];
            break;
            
        case eUserNewsNotificationTypeReviewMention:
            string = [NSString stringWithFormat:@"@%@ mentioned you in a review.", self.username];
            break;
            
        case eUserNewsNotificationTypeComment:
            string = [NSString stringWithFormat:@"@%@ left a comment on your review: %@", self.username, self.comment];
            break;
            
        case eUserNewsNotificationTypeCommentMention:
            string = [NSString stringWithFormat:@"@%@ mentioned you in a comment: %@", self.username, self.comment];
            break;
            
        case eUserNewsNotificationTypeUnknown:
            break;
    }
    
    return string;
}

@end