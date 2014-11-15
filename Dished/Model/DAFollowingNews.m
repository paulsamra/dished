//
//  DAFollowingNews.m
//  Dished
//
//  Created by Ryan Khalili on 9/22/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DAFollowingNews.h"


@interface DAFollowingNews()

@end


@implementation DAFollowingNews

+ (DAFollowingNews *)followingNewsWithData:(id)data
{
    return [[DAFollowingNews alloc] initWithData:data];
}

- (id)initWithData:(id)data
{
    if( self = [super initWithData:data] )
    {
        _username = nilOrJSONObjectForKey( data, kUsernameKey );
        _users    = nilOrJSONObjectForKey( data, @"users" );
        _review_creator = nilOrJSONObjectForKey( data, @"review_creator" );
        
        _yum_count    = [nilOrJSONObjectForKey( data, @"yum_count" )    integerValue];
        _friend_count = [nilOrJSONObjectForKey( data, @"friend_count" ) integerValue];
        _review_count = [nilOrJSONObjectForKey( data, @"review_count" ) integerValue];
        
        NSDictionary *images = nilOrJSONObjectForKey( data, kImagesKey );
        if( images )
        {
            NSArray *reviewsImageArray = nilOrJSONObjectForKey( images, kReviewsKey );
            if( reviewsImageArray )
            {
                _review_image = [reviewsImageArray objectAtIndex:0];
            }
        }
        
        NSDictionary *userData = nilOrJSONObjectForKey( data, @"followed" );
        if( userData )
        {
            DAUsername *username = [[DAUsername alloc] init];
            username.user_id = [nilOrJSONObjectForKey( userData, @"idUser" ) integerValue];
            username.username = nilOrJSONObjectForKey( userData, kUsernameKey );
            
            _followed = username;
        }
        
        NSArray *reviews = nilOrJSONObjectForKey( data, kReviewsKey );
        if( reviews )
        {
            NSMutableArray *review_images = [NSMutableArray array];
            NSMutableArray *reviewIDs = [NSMutableArray array];
            
            for( NSDictionary *review in reviews )
            {
                NSString *imageURL = nilOrJSONObjectForKey( review, kImgThumbKey );
                
                if( imageURL )
                {
                    [reviewIDs addObject:nilOrJSONObjectForKey( review, kIDKey )];
                    [review_images addObject:imageURL];
                }
            }
            
            _review_images = review_images;
            _reviewIDs = reviewIDs;
        }
        
        _notificationType    = [self notificationTypeForTypeString:nilOrJSONObjectForKey( data, kTypeKey )];
        _notificationSubtype = [self notificationSubtypeForSubtypeString:nilOrJSONObjectForKey( data, @"subtype" )];
    }
    
    return self;
}

- (eFollowingNewsNotificationType)notificationTypeForTypeString:(NSString *)string
{
    eFollowingNewsNotificationType type = eFollowingNewsNotificationTypeUnknown;
    
    if( [string isEqualToString:kFollowingReviewCreateNotification] )
    {
        type = eFollowingNewsNotificationTypeCreateReview;
    }
    else if( [string isEqualToString:kFollowingUserFollowNotification] )
    {
        type = eFollowingNewsNotificationTypeFollow;
    }
    else if( [string isEqualToString:kFollowingReviewYumNotification] )
    {
        type = eFollowingNewsNotificationTypeYum;
    }
    
    return type;
}

- (eFollowingNewsYumNotificationSubtype)notificationSubtypeForSubtypeString:(NSString *)string
{
    eFollowingNewsYumNotificationSubtype subtype = eFollowingNewsYumNotificationSubtypeUnknown;
    
    if( [string isEqualToString:kFollowingSubtypeSingleUserSingleYum] )
    {
        subtype = eFollowingNewsYumNotificationSubtypeSingleUserSingleYum;
    }
    else if( [string isEqualToString:kFollowingSubtypeSingleUserMultiYum] )
    {
        subtype = eFollowingNewsYumNotificationSubtypeSingleUserMultiYum;
    }
    else if( [string isEqualToString:kFollowingSubtypeMultiUserYum] )
    {
        subtype = eFollowingNewsYumNotificationSubtypeMultiUserYum;
    }
    else if( [string isEqualToString:kFollowingSubtypeTwoUserYum] )
    {
        subtype = eFollowingNewsYumNotificationSubtypeTwoUserYum;
    }
    
    return subtype;
}

- (NSString *)formattedString
{
    NSString *string = [super formattedString];
    
    switch( self.notificationType )
    {
        case eFollowingNewsNotificationTypeCreateReview:
            string = [NSString stringWithFormat:@"@%@ added %d reviews.", self.username, (int)self.review_count];
            break;
            
        case eFollowingNewsNotificationTypeFollow:
            string = [NSString stringWithFormat:@"@%@ followed @%@.", self.username, self.followed.username];
            break;
            
        case eFollowingNewsNotificationTypeYum:
            string = [self formattedStringForYumNotificationSubtype:self.notificationSubtype];
            break;
            
        case eFollowingNewsNotificationTypeUnknown:
            break;
    }
    
    return string;
}

- (NSString *)formattedStringForYumNotificationSubtype:(eFollowingNewsYumNotificationSubtype)subtype
{
    NSString *string = [super formattedString];
    
    switch( subtype )
    {
        case eFollowingNewsYumNotificationSubtypeSingleUserSingleYum:
            string = [NSString stringWithFormat:@"@%@ YUMMED @%@'s review.", self.username, self.review_creator];
            break;
            
        case eFollowingNewsYumNotificationSubtypeSingleUserMultiYum:
            string = [NSString stringWithFormat:@"@%@ YUMMED %d reviews.", [self.users objectAtIndex:0], (int)self.yum_count];
            break;
            
        case eFollowingNewsYumNotificationSubtypeMultiUserYum:
            string = [NSString stringWithFormat:@"%d of your friends YUMMED @%@'s review.", (int)self.friend_count, self.username];
            break;
            
        case eFollowingNewsYumNotificationSubtypeTwoUserYum:
            string = [NSString stringWithFormat:@"@%@ and @%@ YUMMED @%@'s review.", self.users[0], self.users[1], self.review_creator];
            break;
            
        case eFollowingNewsYumNotificationSubtypeUnknown:
            break;
    }
    
    return string;
}

@end