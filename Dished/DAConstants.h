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

extern NSString *const kPrivacyPolicy;
extern NSString *const kTermsAndConditions;

extern NSString *const kHelveticaNeueLightFont;

extern NSString *const kFirstLaunchKey;
extern NSString *const kWelcomeScreenImageNameFormat;
extern NSString *const kWelcomeScreenDotsImageNameFormat;

extern NSString *const kBasicUserType;
extern NSString *const kAdminUserType;
extern NSString *const kRestaurantUserType;
extern NSString *const kInfluencerUserType;

extern NSString *const kFood;
extern NSString *const kWine;
extern NSString *const kCocktail;

extern NSString *const kUserNewsFollowNotification;
extern NSString *const kUserNewsReviewYumNotification;
extern NSString *const kUserNewsReviewMentionNotification;
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
extern NSString *const kAuthAddURL;
extern NSString *const kCommentsURL;
extern NSString *const kHashtagsURL;
extern NSString *const kUsersNewsURL;
extern NSString *const kUserImageURL;
extern NSString *const kYumReviewURL;
extern NSString *const kAuthTokenURL;
extern NSString *const kFollowUserURL;
extern NSString *const kDishSearchURL;
extern NSString *const kUserUpdateURL;
extern NSString *const kReportUserURL;
extern NSString *const kReviewYumsURL;
extern NSString *const kReportDishURL;
extern NSString *const kPopularNowURL;
extern NSString *const kUnyumReviewURL;
extern NSString *const kFlagCommentURL;
extern NSString *const kUserProfileURL;
extern NSString *const kEditProfileURL;
extern NSString *const kEditorsPicksURL;
extern NSString *const kReportReviewURL;
extern NSString *const kUnfollowUserURL;
extern NSString *const kUserSettingsURL;
extern NSString *const kReviewDeleteURL;
extern NSString *const kExploreDishesURL;
extern NSString *const kDeleteCommentURL;
extern NSString *const kReviewProfileURL;
extern NSString *const kUserFollowersURL;
extern NSString *const kUserFollowingURL;
extern NSString *const kExploreHashtagsURL;
extern NSString *const kHashtagsExploreURL;
extern NSString *const kUserImageDeleteURL;
extern NSString *const kExploreUsernamesURL;
extern NSString *const kExploreLocationsURL;
extern NSString *const kRestaurantProfileURL;
extern NSString *const kEmailAvailabilityURL;
extern NSString *const kPhoneAvailabilityURL;
extern NSString *const kUserProfileReviewsURL;
extern NSString *const kRestaurantProfileDishesURL;

extern NSString *const kIDKey;
extern NSString *const kImgKey;
extern NSString *const kDataKey;
extern NSString *const kTypeKey;
extern NSString *const kNameKey;
extern NSString *const kUserKey;
extern NSString *const kQueryKey;
extern NSString *const kPriceKey;
extern NSString *const kGradeKey;
extern NSString *const kEmailKey;
extern NSString *const kPhoneKey;
extern NSString *const kViewedKey;
extern NSString *const kImagesKey;
extern NSString *const kPublicKey;
extern NSString *const kRadiusKey;
extern NSString *const kReviewsKey;
extern NSString *const kCreatedKey;
extern NSString *const kCommentKey;
extern NSString *const kPushYumKey;
extern NSString *const kHashtagKey;
extern NSString *const kPasswordKey;
extern NSString *const kRowLimitKey;
extern NSString *const kReviewIDKey;
extern NSString *const kRelationKey;
extern NSString *const kDistanceKey;
extern NSString *const kDishTypeKey;
extern NSString *const kUsernameKey;
extern NSString *const kGoogleIDKey;
extern NSString *const kImgThumbKey;
extern NSString *const kLatitudeKey;
extern NSString *const kLocationKey;
extern NSString *const kLastNameKey;
extern NSString *const kRowOffsetKey;
extern NSString *const kFirstNameKey;
extern NSString *const kLongitudeKey;
extern NSString *const kSavePhotoKey;
extern NSString *const kLocationIDKey;
extern NSString *const kPushReviewKey;
extern NSString *const kNumCommentsKey;
extern NSString *const kDateOfBirthKey;
extern NSString *const kHashtagTypeKey;
extern NSString *const kDescriptionKey;
extern NSString *const kPushCommentKey;
extern NSString *const kLocationNameKey;

extern NSString *const kErrorKey;
extern NSString *const kEmailExistsError;
extern NSString *const kPhoneExistsError;
extern NSString *const kParamsInvalidError;
extern NSString *const kDataNonexistsError;
extern NSString *const kContentPrivateError;

extern NSString *const kAll;
extern NSString *const kNone;
extern NSString *const kFollow;
extern NSString *const kFollowing;
extern NSString *const kPositiveHashtags;
extern NSString *const kNegativeHashtags;

extern NSString *const kReviewListID;
extern NSString *const kGlobalDishID;
extern NSString *const kUserProfileID;
extern NSString *const kCommentsViewID;
extern NSString *const kSettingsViewID;
extern NSString *const kReviewDetailsID;