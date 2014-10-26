//
//  DAConstants.h
//  Dished
//
//  Created by Ryan Khalili on 7/11/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#define IS_IPHONE5      (([[UIScreen mainScreen] bounds].size.height-568)?NO:YES)
#define IS_IPHONE4      (([[UIScreen mainScreen] bounds].size.height-480)?NO:YES)
#define IS_IPHONE6      (([[UIScreen mainScreen] bounds].size.height-667)?NO:YES)
#define IS_IPHONE6_PLUS (([[UIScreen mainScreen] bounds].size.height-1104)?NO:YES)

#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

#define IS_IOS8 (([[[UIDevice currentDevice] systemVersion] floatValue]>=8.0)?YES:NO)

#define nilOrJSONObjectForKey(JSON_, KEY_) [[JSON_ objectForKey:KEY_] isKindOfClass:[NSNull class]] ? nil : [JSON_ objectForKey:KEY_]

extern NSString *const kProjectName;

extern NSString *const kFirstLaunchKey;
extern NSString *const kWelcomeScreenImageNameFormat;
extern NSString *const kWelcomeScreenDotsImageNameFormat;

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

extern NSString *const kUsersURL;
extern NSString *const kLogoutURL;
extern NSString *const kHashtagsURL;
extern NSString *const kUserImageURL;
extern NSString *const kFollowUserURL;
extern NSString *const kDishSearchURL;
extern NSString *const kUserProfileURL;
extern NSString *const kEditProfileURL;
extern NSString *const kUnfollowUserURL;
extern NSString *const kUserSettingsURL;
extern NSString *const kUserFollowersURL;
extern NSString *const kUserFollowingURL;
extern NSString *const kExploreLocationsURL;
extern NSString *const kRestaurantProfileURL;
extern NSString *const kEmailAvailabilityURL;
extern NSString *const kPhoneAvailabilityURL;

extern NSString *const kIDKey;
extern NSString *const kDataKey;
extern NSString *const kTypeKey;
extern NSString *const kNameKey;
extern NSString *const kQueryKey;
extern NSString *const kPriceKey;
extern NSString *const kGradeKey;
extern NSString *const kEmailKey;
extern NSString *const kPhoneKey;
extern NSString *const kPublicKey;
extern NSString *const kPushYumKey;
extern NSString *const kDistanceKey;
extern NSString *const kDishTypeKey;
extern NSString *const kUsernameKey;
extern NSString *const kGoogleIDKey;
extern NSString *const kImgThumbKey;
extern NSString *const kLatitudeKey;
extern NSString *const kLastNameKey;
extern NSString *const kFirstNameKey;
extern NSString *const kLongitudeKey;
extern NSString *const kSavePhotoKey;
extern NSString *const kLocationIDKey;
extern NSString *const kPushReviewKey;
extern NSString *const kDateOfBirthKey;
extern NSString *const kHashtagTypeKey;
extern NSString *const kDescriptionKey;
extern NSString *const kPushCommentKey;
extern NSString *const kLocationNameKey;

extern NSString *const kErrorKey;
extern NSString *const kEmailExistsError;
extern NSString *const kPhoneExistsError;
extern NSString *const kDataNonexistsError;

extern NSString *const kAll;
extern NSString *const kNone;
extern NSString *const kFollow;
extern NSString *const kPositiveHashtags;
extern NSString *const kNegativeHashtags;