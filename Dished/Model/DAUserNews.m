//
//  DANewsItem.m
//  Dished
//
//  Created by Ryan Khalili on 9/17/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DAUserNews.h"

typedef enum
{
    eUserNewsNotificationTypeFollow,
    eUserNewsNotificationTypeYum,
    eUserNewsNotificationTypeComment,
    eUserNewsNotificationTypeCommentMention,
    eUserNewsNotificationTypeUnknown
} eUserNewsNotificationType;


@interface DAUserNews()

@property (nonatomic) eUserNewsNotificationType notificationType;

@end


@implementation DAUserNews

+ (DAUserNews *)userNewsWithData:(id)data
{
    return [[DAUserNews alloc] initWithData:data];
}

- (id)initWithData:(id)data
{
    if( self = [super initWithData:data] )
    {
        _comment  = nilOrJSONObjectForKey( data, @"comment" );
        _username = nilOrJSONObjectForKey( data, @"username" );
        
        _review_id = [data[@"review_id"] integerValue];
        
        _notificationType = [self notificationTypeForTypeString:nilOrJSONObjectForKey( data, @"type" )];
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
            
        case eUserNewsNotificationTypeComment:
            string = [NSString stringWithFormat:@"@%@ left a comment on your review: %@", self.username, self.comment];
            break;
            
        case eUserNewsNotificationTypeCommentMention:
            string = [NSString stringWithFormat:@"@%@ mentioned you in a review: %@", self.username, self.comment];
            break;
            
        case eUserNewsNotificationTypeUnknown:
            break;
    }
    
    return string;
}

@end