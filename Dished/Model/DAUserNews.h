//
//  DANewsItem.h
//  Dished
//
//  Created by Ryan Khalili on 9/17/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DANews.h"

typedef enum
{
    eUserNewsNotificationTypeFollow,
    eUserNewsNotificationTypeYum,
    eUserNewsNotificationTypeReviewMention,
    eUserNewsNotificationTypeComment,
    eUserNewsNotificationTypeCommentMention,
    eUserNewsNotificationTypeUnknown
} eUserNewsNotificationType;


@interface DAUserNews : DANews

@property (copy, nonatomic) NSString *comment;
@property (copy, nonatomic) NSString *username;
@property (copy, nonatomic) NSString *user_type;
@property (copy, nonatomic) NSString *review_img_thumb;

@property (nonatomic) eUserNewsNotificationType notificationType;


+ (DAUserNews *)userNewsWithData:(id)data;

@end