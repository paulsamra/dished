//
//  DAUserManager.h
//  Dished
//
//  Created by Ryan Khalili on 10/12/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kUserProfileUpdatedNotification @"user_updated"

typedef enum
{
    ePushSettingOff,
    ePushSettingFollowed,
    ePushSettingEveryone,
} ePushSetting;


@interface DAUserManager : NSObject

@property (copy, nonatomic, readonly) NSDate   *dateOfBirth;
@property (copy, nonatomic, readonly) NSString *desc;
@property (copy, nonatomic, readonly) NSString *email;
@property (copy, nonatomic, readonly) NSString *username;
@property (copy, nonatomic, readonly) NSString *userType;
@property (copy, nonatomic, readonly) NSString *lastName;
@property (copy, nonatomic, readonly) NSString *firstName;
@property (copy, nonatomic, readonly) NSString *img_thumb;
@property (copy, nonatomic, readonly) NSString *phoneNumber;

@property (nonatomic, readonly) BOOL         savesDishPhoto;
@property (nonatomic, readonly) BOOL         publicProfile;
@property (nonatomic, readonly) BOOL         isFacebookUser;
@property (nonatomic, readonly) NSInteger    user_id;
@property (nonatomic, readonly) ePushSetting receivesYumPushNotifications;
@property (nonatomic, readonly) ePushSetting receivesCommentPushNotifications;


+ (DAUserManager *)sharedManager;

- (void)loadUserInfoWithCompletion:( void(^)( BOOL success ) )completion;
- (void)saveDishPhotoSetting:(BOOL)dishPhotoSetting completion:( void(^)( BOOL success ) )completion;
- (void)savePrivacySetting:(BOOL)privacySetting completion:( void(^)( BOOL success ) )completion;
- (void)setYumPushNotificationSetting:(ePushSetting)pushSetting completion:( void(^)( BOOL success ) )completion;
- (void)setCommentPushNotificationSetting:(ePushSetting)pushSetting completion:( void(^)( BOOL success ) )completion;
- (void)logout;

@end