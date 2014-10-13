//
//  DAUserManager.h
//  Dished
//
//  Created by Ryan Khalili on 10/12/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    ePushSettingOff,
    ePushSettingFollowed,
    ePushSettingEveryone,
} ePushSetting;


@interface DAUserManager : NSObject

@property (copy, nonatomic, readonly) NSDate   *dateOfBirth;
@property (copy, nonatomic, readonly) NSString *firstName;
@property (copy, nonatomic, readonly) NSString *lastName;
@property (copy, nonatomic, readonly) NSString *username;
@property (copy, nonatomic, readonly) NSString *desc;
@property (copy, nonatomic, readonly) NSString *email;
@property (copy, nonatomic, readonly) NSString *img_thumb;
@property (copy, nonatomic, readonly) NSString *userType;

@property (nonatomic, readonly) BOOL         savesDishPhoto;
@property (nonatomic, readonly) BOOL         publicProfile;
@property (nonatomic, readonly) BOOL         user_id;
@property (nonatomic, readonly) ePushSetting receivesYumPushNotifications;
@property (nonatomic, readonly) ePushSetting receivesCommentPushNotifications;
@property (nonatomic, readonly) ePushSetting receivesReviewPushNotifications;


+ (DAUserManager *)sharedManager;

- (void)loadUserInfoWithCompletion:( void(^)( BOOL success ) )completion;
- (void)saveDishPhotoSetting:(BOOL)dishPhotoSetting completion:( void(^)( BOOL success ) )completion;
- (void)savePrivacySetting:(BOOL)privacySetting completion:( void(^)( BOOL success ) )completion;
- (void)setUserProfileImage:(UIImage *)image completion:( void(^)( BOOL success ) )completion;
- (void)deleteLocalUserSettings;

@end