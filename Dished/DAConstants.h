//
//  DAConstants.h
//  Dished
//
//  Created by Ryan Khalili on 7/11/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#define IS_IPHONE5 (([[UIScreen mainScreen] bounds].size.height-568)?NO:YES)

#define nilOrJSONObjectForKey(JSON_, KEY_) [[JSON_ objectForKey:KEY_] isKindOfClass:[NSNull class]] ? nil : [JSON_ objectForKey:KEY_]

extern NSString *const kProjectName;

extern NSString *const kFood;
extern NSString *const kWine;
extern NSString *const kCocktail;

extern NSString *const kUserNewsFollowNotification;
extern NSString *const kUserNewsReviewYumNotification;
extern NSString *const kUserNewsReviewCommentNotification;
extern NSString *const kUserNewsReviewCommentMentionNotification;

extern NSString *const kFollowingReviewCreateNotification;
extern NSString *const kFollowingUserFollowNotification;
extern NSString *const kFollowingReviewYumNotification;
extern NSString *const kFollowingSubtypeSingleUserSingleYum;
extern NSString *const kFollowingSubtypeSingleUserMultiYum;
extern NSString *const kFollowingSubtypeMultiUserYum;
extern NSString *const kFollowingSubtypeTwoUserYum;