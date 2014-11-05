//
//  DAFollowingNews.h
//  Dished
//
//  Created by Ryan Khalili on 9/22/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DANews.h"
#import "DAUsername.h"
#import "DAGlobalReview.h"

typedef enum
{
    eFollowingNewsNotificationTypeCreateReview,
    eFollowingNewsNotificationTypeFollow,
    eFollowingNewsNotificationTypeYum,
    eFollowingNewsNotificationTypeUnknown
} eFollowingNewsNotificationType;

typedef enum
{
    eFollowingNewsYumNotificationSubtypeSingleUserSingleYum,
    eFollowingNewsYumNotificationSubtypeSingleUserMultiYum,
    eFollowingNewsYumNotificationSubtypeMultiUserYum,
    eFollowingNewsYumNotificationSubtypeTwoUserYum,
    eFollowingNewsYumNotificationSubtypeUnknown
} eFollowingNewsYumNotificationSubtype;


@interface DAFollowingNews : DANews

@property (copy,   nonatomic) NSString   *username;
@property (copy,   nonatomic) NSString   *review_image;
@property (strong, nonatomic) NSArray    *users;
@property (strong, nonatomic) NSArray    *reviews;
@property (strong, nonatomic) NSArray    *review_images;
@property (strong, nonatomic) NSArray    *reviewIDs;
@property (strong, nonatomic) DAUsername *followed;

@property (nonatomic) NSInteger yum_count;
@property (nonatomic) NSInteger friend_count;
@property (nonatomic) NSInteger review_count;
@property (nonatomic) eFollowingNewsNotificationType notificationType;
@property (nonatomic) eFollowingNewsYumNotificationSubtype notificationSubtype;



+ (DAFollowingNews *)followingNewsWithData:(id)data;

@end