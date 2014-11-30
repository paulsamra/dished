//
//  DAConstants.m
//  Dished
//
//  Created by Ryan Khalili on 7/11/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

NSString *const kProjectName = @"Dished";

NSString *const kPrivacyPolicy      = @"Privacy Policy";
NSString *const kTermsAndConditions = @"Terms & Conditions";

NSString *const kHelveticaNeueLightFont = @"HelveticaNeue-Light";

NSString *const kFirstLaunchKey = @"first_launch";

NSString *const kWelcomeScreenImageNameFormat     = @"welcome_%d_%d";
NSString *const kWelcomeScreenDotsImageNameFormat = @"page_%d_dots";

NSString *const kFood     = @"food";
NSString *const kWine     = @"wine";
NSString *const kCocktail = @"cocktail";

NSString *const kBasicUserType      = @"basic";
NSString *const kAdminUserType      = @"admin";
NSString *const kRestaurantUserType = @"restaurant";
NSString *const kInfluencerUserType = @"influencer";

NSString *const kUserNewsFollowNotification               = @"user_follow";
NSString *const kUserNewsReviewYumNotification            = @"review_yum";
NSString *const kUserNewsReviewMentionNotification        = @"review_mention";
NSString *const kUserNewsReviewCommentNotification        = @"review_comment";
NSString *const kUserNewsReviewCommentMentionNotification = @"review_comment_mention";

NSString *const kFollowingReviewCreateNotification = @"review_create_followers";
NSString *const kFollowingUserFollowNotification   = @"user_follow_followers";
NSString *const kFollowingReviewYumNotification    = @"review_yum_followers";

NSString *const kFollowingSubtypeSingleUserSingleYum  = @"suty";
NSString *const kFollowingSubtypeSingleUserMultiYum   = @"sumy";
NSString *const kFollowingSubtypeMultiUserYum         = @"muty";
NSString *const kFollowingSubtypeTwoUserYum           = @"tuty";

NSString *const kUsersURL                   = @"users";
NSString *const kLogoutURL                  = @"auth/logout";
NSString *const kAuthAddURL                 = @"auth/add";
NSString *const kCommentsURL                = @"comments";
NSString *const kHashtagsURL                = @"hashtags";
NSString *const kUserNewsURL                = @"users/news";
NSString *const kUserImageURL               = @"users/image";
NSString *const kYumReviewURL               = @"reviews/yum";
NSString *const kAuthTokenURL               = @"auth/token";
NSString *const kFollowUserURL              = @"users/follow";
NSString *const kDishSearchURL              = @"dishes/search";
NSString *const kUserUpdateURL              = @"users/update";
NSString *const kReportDishURL              = @"dishes/report";
NSString *const kReportUserURL              = @"users/report";
NSString *const kReviewYumsURL              = @"reviews/yums";
NSString *const kPopularNowURL              = @"explore/dishes/popular";
NSString *const kUnyumReviewURL             = @"reviews/unyum";
NSString *const kFlagCommentURL             = @"comments/report";
NSString *const kUserProfileURL             = @"users/profile";
NSString *const kEditProfileURL             = @"users/update";
NSString *const kEditorsPicksURL            = @"explore/dishes/editors_pick";
NSString *const kReportReviewURL            = @"reviews/report";
NSString *const kUserSettingsURL            = @"users/settings";
NSString *const kReviewDeleteURL            = @"reviews/delete";
NSString *const kUnfollowUserURL            = @"users/unfollow";
NSString *const kExploreDishesURL           = @"explore/dishes";
NSString *const kDeleteCommentURL           = @"comments/delete";
NSString *const kReviewProfileURL           = @"reviews/profile";
NSString *const kUserFollowersURL           = @"users/followers";
NSString *const kUserFollowingURL           = @"users/following";
NSString *const kExploreHashtagsURL         = @"explore/dishes/hashtag";
NSString *const kHashtagsExploreURL         = @"hashtags/explore";
NSString *const kUserImageDeleteURL         = @"users/image/delete";
NSString *const kExploreUsernamesURL        = @"explore/usernames";
NSString *const kExploreLocationsURL        = @"explore/locations";
NSString *const kRestaurantProfileURL       = @"restaurants/profile";
NSString *const kEmailAvailabilityURL       = @"users/availability/email";
NSString *const kPhoneAvailabilityURL       = @"users/availability/phone";
NSString *const kUserProfileReviewsURL      = @"users/profile/reviews";
NSString *const kRestaurantProfileDishesURL = @"restaurants/profile/dishes";

NSString *const kIDKey           = @"id";
NSString *const kImgKey          = @"img";
NSString *const kDataKey         = @"data";
NSString *const kTypeKey         = @"type";
NSString *const kNameKey         = @"name";
NSString *const kUserKey         = @"user";
NSString *const kQueryKey        = @"query";
NSString *const kPriceKey        = @"price";
NSString *const kGradeKey        = @"grade";
NSString *const kEmailKey        = @"email";
NSString *const kPhoneKey        = @"phone";
NSString *const kRadiusKey       = @"radius";
NSString *const kViewedKey       = @"viewed";
NSString *const kImagesKey       = @"images";
NSString *const kPublicKey       = @"public";
NSString *const kCreatedKey      = @"created";
NSString *const kCommentKey      = @"comment";
NSString *const kReviewsKey      = @"reviews";
NSString *const kPushYumKey      = @"push_yum";
NSString *const kHashtagKey      = @"hashtag";
NSString *const kPasswordKey     = @"password";
NSString *const kRowLimitKey     = @"row_limit";
NSString *const kReviewIDKey     = @"review_id";
NSString *const kRelationKey     = @"relation";
NSString *const kDistanceKey     = @"distance";
NSString *const kDishTypeKey     = @"dish_type";
NSString *const kUsernameKey     = @"username";
NSString *const kGoogleIDKey     = @"google_id";
NSString *const kImgThumbKey     = @"img_thumb";
NSString *const kLatitudeKey     = @"latitude";
NSString *const kLocationKey     = @"location";
NSString *const kLastNameKey     = @"lastname";
NSString *const kRowOffsetKey    = @"row_offset";
NSString *const kFirstNameKey    = @"firstname";
NSString *const kLongitudeKey    = @"longitude";
NSString *const kSavePhotoKey    = @"save_photo";
NSString *const kLocationIDKey   = @"loc_id";
NSString *const kPushReviewKey   = @"push_review";
NSString *const kNumCommentsKey  = @"num_comments";
NSString *const kDateOfBirthKey  = @"dob";
NSString *const kDescriptionKey  = @"description";
NSString *const kHashtagTypeKey  = @"tag_type";
NSString *const kPushCommentKey  = @"push_comment";
NSString *const kLocationNameKey = @"loc_name";

NSString *const kErrorKey            = @"error";
NSString *const kEmailExistsError    = @"email_exists";
NSString *const kPhoneExistsError    = @"phone_exists";
NSString *const kParamsInvalidError  = @"params_invalid";
NSString *const kDataNonexistsError  = @"data_nonexists";
NSString *const kContentPrivateError = @"content_private";

NSString *const kAll              = @"all";
NSString *const kNone             = @"none";
NSString *const kFollow           = @"follow";
NSString *const kPositiveHashtags = @"rev_p";
NSString *const kNegativeHashtags = @"rev_n";

NSString *const kReviewListID    = @"reviewList";
NSString *const kGlobalDishID    = @"globalDish";
NSString *const kUserProfileID   = @"userProfile";
NSString *const kCommentsViewID  = @"commentsView";
NSString *const kSettingsViewID  = @"settingsView";
NSString *const kReviewDetailsID = @"reviewDetails";