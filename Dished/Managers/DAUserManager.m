//
//  DAUserManager.m
//  Dished
//
//  Created by Ryan Khalili on 10/12/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DAUserManager.h"

#define kSavedProfileKey @"userManager-profile"


@interface DAUserManager()

@property (copy, nonatomic, readwrite) NSDate   *dateOfBirth;
@property (copy, nonatomic, readwrite) NSString *desc;
@property (copy, nonatomic, readwrite) NSString *email;
@property (copy, nonatomic, readwrite) NSString *lastName;
@property (copy, nonatomic, readwrite) NSString *username;
@property (copy, nonatomic, readwrite) NSString *userType;
@property (copy, nonatomic, readwrite) NSString *firstName;
@property (copy, nonatomic, readwrite) NSString *img_thumb;
@property (copy, nonatomic, readwrite) NSString *phoneNumber;

@property (strong, nonatomic) NSURLSessionTask *yumPushTask;
@property (strong, nonatomic) NSURLSessionTask *userImageTask;
@property (strong, nonatomic) NSURLSessionTask *reviewPushTask;
@property (strong, nonatomic) NSURLSessionTask *loadProfileTask;
@property (strong, nonatomic) NSURLSessionTask *commentPushTask;
@property (strong, nonatomic) NSURLSessionTask *loadSettingsTask;
@property (strong, nonatomic) NSURLSessionTask *dishPhotoTask;
@property (strong, nonatomic) NSURLSessionTask *profilePrivacyTask;

@property (nonatomic, readwrite) BOOL         userProfileSuccessfullySaved;
@property (nonatomic, readwrite) BOOL         savesDishPhoto;
@property (nonatomic, readwrite) BOOL         publicProfile;
@property (nonatomic, readwrite) NSInteger    user_id;
@property (nonatomic, readwrite) ePushSetting receivesYumPushNotifications;
@property (nonatomic, readwrite) ePushSetting receivesCommentPushNotifications;
@property (nonatomic, readwrite) ePushSetting receivesReviewPushNotifications;

@end


@implementation DAUserManager

+ (DAUserManager *)sharedManager
{
    static DAUserManager *manager = nil;
    
    static dispatch_once_t singleton;
    
    dispatch_once(&singleton, ^{
        manager = [[DAUserManager alloc] init];
    });
    
    return manager;
}

- (id)init
{
    if( self = [super init] )
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshUserData) name:UIApplicationDidFinishLaunchingNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNeedsRefresh) name:UIApplicationWillEnterForegroundNotification object:nil];
        
        _userProfileSuccessfullySaved = NO;
        
        [self restoreProfile];
    }
    
    return self;
}

- (void)refreshUserData
{
    if( [[DAAPIManager sharedManager] isLoggedIn] )
    {
        [self loadUserInfoWithCompletion:nil];
    }
}

- (void)checkNeedsRefresh
{
    if( !self.userProfileSuccessfullySaved )
    {
        [self refreshUserData];
    }
}

- (void)loadUserInfoWithCompletion:( void (^)( BOOL success ) )completion
{
    dispatch_group_t group = dispatch_group_create();
    
    __block BOOL successful = YES;
    
    dispatch_group_enter( group );

    [self loadUserSettingsWithCompletion:^( BOOL success )
    {
        successful &= success;
        
        dispatch_group_leave( group );
    }];
    
    dispatch_group_enter( group );
    
    [self loadUserProfileWithCompletion:^( BOOL success )
    {
        successful &= success;
        
        dispatch_group_leave( group );
    }];
        
    dispatch_group_notify( group, dispatch_get_main_queue(), ^
    {
        [self saveProfile];
            
        self.userProfileSuccessfullySaved = successful;
            
        if( completion )
        {
            completion( successful );
        }
    });
}

- (void)loadUserSettingsWithCompletion:( void(^)( BOOL success ) )completion
{
    [self.loadSettingsTask cancel];
    
    self.loadSettingsTask = [[DAAPIManager sharedManager] GETRequest:kUserSettingsURL withParameters:nil
    success:^( id response )
    {
        NSDictionary *settings = nilOrJSONObjectForKey( response, kDataKey );
        [self setSettingsWithSettingsData:settings];
        
        if( completion )
        {
            completion( YES );
        }
    }
    failure:^( NSError *error, BOOL shouldRetry )
    {
        if( shouldRetry )
        {
            [self loadUserSettingsWithCompletion:completion];
        }
        else
        {
            if( completion )
            {
                completion( NO );
            }
        }
    }];
}

- (void)loadUserProfileWithCompletion:( void(^)( BOOL success ) )completion
{
    [self.loadProfileTask cancel];
    
    self.loadProfileTask = [[DAAPIManager sharedManager] GETRequest:kUsersURL withParameters:nil
    success:^( id response )
    {
        NSDictionary *profile = nilOrJSONObjectForKey( response, kDataKey );
        [self setProfileWithProfileData:profile];
        
        if( completion )
        {
            completion( YES );
        }
    }
    failure:^( NSError *error, BOOL shouldRetry )
    {
        if( shouldRetry )
        {
            [self loadUserProfileWithCompletion:completion];
        }
        else
        {
            if( completion )
            {
                completion( NO );
            }
        }
    }];
}

- (void)setSettingsWithSettingsData:(id)settings
{
    self.publicProfile  = [nilOrJSONObjectForKey( settings, kPublicKey    ) boolValue];
    self.savesDishPhoto = [nilOrJSONObjectForKey( settings, kSavePhotoKey ) boolValue];
    
    self.receivesYumPushNotifications     = [self pushSettingForSettingString:nilOrJSONObjectForKey( settings, kPushYumKey )];
    self.receivesReviewPushNotifications  = [self pushSettingForSettingString:nilOrJSONObjectForKey( settings, kPushReviewKey )];
    self.receivesCommentPushNotifications = [self pushSettingForSettingString:nilOrJSONObjectForKey( settings, kPushCommentKey )];
}

- (void)setProfileWithProfileData:(id)profile
{
    if( [profile[kDateOfBirthKey] isKindOfClass:[NSDate class]] )
    {
        self.dateOfBirth = profile[kDateOfBirthKey];
    }
    else
    {
        NSTimeInterval dateOfBirthTimestamp = [nilOrJSONObjectForKey( profile, kDateOfBirthKey ) doubleValue];
        self.dateOfBirth = [NSDate dateWithTimeIntervalSince1970:dateOfBirthTimestamp];
    }
    
    self.desc        = nilOrJSONObjectForKey( profile, kDescriptionKey );
    self.email       = nilOrJSONObjectForKey( profile, kEmailKey       );
    self.userType    = nilOrJSONObjectForKey( profile, kTypeKey        );
    self.lastName    = nilOrJSONObjectForKey( profile, kLastNameKey    );
    self.username    = nilOrJSONObjectForKey( profile, kUsernameKey    );
    self.firstName   = nilOrJSONObjectForKey( profile, kFirstNameKey   );
    self.img_thumb   = nilOrJSONObjectForKey( profile, kImgThumbKey    );
    self.phoneNumber = nilOrJSONObjectForKey( profile, kPhoneKey       );
    
    self.user_id     = [nilOrJSONObjectForKey( profile, kIDKey ) integerValue];
}

- (ePushSetting)pushSettingForSettingString:(NSString *)setting
{
    ePushSetting pushSetting = ePushSettingOff;
    
    if( [setting isEqualToString:kNone] )
    {
        pushSetting = ePushSettingOff;
    }
    else if( [setting isEqualToString:kAll] )
    {
        pushSetting = ePushSettingEveryone;
    }
    else if( [setting isEqualToString:kFollow] )
    {
        pushSetting = ePushSettingFollowed;
    }
    
    return pushSetting;
}

- (void)saveDishPhotoSetting:(BOOL)dishPhotoSetting completion:( void(^)( BOOL success ) )completion
{
    NSDictionary *parameters = @{ kSavePhotoKey : @(dishPhotoSetting) };
    [self saveSettingsToServerWithParameters:parameters completion:completion];
}

- (void)savePrivacySetting:(BOOL)privacySetting completion:( void(^)( BOOL success ) )completion
{
    NSDictionary *parameters = @{ kPublicKey : @(privacySetting) };
    [self saveSettingsToServerWithParameters:parameters completion:completion];
}

- (void)setYumPushNotificationSetting:(ePushSetting)pushSetting completion:( void(^)( BOOL success ) )completion
{
    NSDictionary *parameters = @{ kPushYumKey : [self pushSettingStringForPushSetting:pushSetting] };
    [self saveSettingsToServerWithParameters:parameters completion:completion];
}

- (void)setCommentPushNotificationSetting:(ePushSetting)pushSetting completion:( void(^)( BOOL success ) )completion
{
    NSDictionary *parameters = @{ kPushCommentKey : [self pushSettingStringForPushSetting:pushSetting] };
    [self saveSettingsToServerWithParameters:parameters completion:completion];
}

- (void)setReviewPushNotificationSetting:(ePushSetting)pushSetting completion:( void(^)( BOOL success ) )completion
{
    NSDictionary *parameters = @{ kPushReviewKey : [self pushSettingStringForPushSetting:pushSetting] };
    [self saveSettingsToServerWithParameters:parameters completion:completion];
}

- (NSURLSessionTask *)getTaskWithParameters:(NSDictionary *)parameters
{
    NSURLSessionTask *task = nil;
    
    for( NSString *key in parameters )
    {
        if( [key isEqualToString:kPushYumKey] )
        {
            task = self.yumPushTask;
        }
        else if( [key isEqualToString:kPushCommentKey] )
        {
            task = self.commentPushTask;
        }
        else if( [key isEqualToString:kPushReviewKey] )
        {
            task = self.reviewPushTask;
        }
        else if( [key isEqualToString:kPublicKey] )
        {
            task = self.profilePrivacyTask;
        }
        else if( [key isEqualToString:kSavePhotoKey] )
        {
            task = self.dishPhotoTask;
        }
    }
    
    return task;
}

- (void)setTask:(NSURLSessionTask *)task withParameters:(NSDictionary *)parameters
{
    for( NSString *key in parameters )
    {
        if( [key isEqualToString:kPushYumKey] )
        {
            self.yumPushTask = task;
        }
        else if( [key isEqualToString:kPushCommentKey] )
        {
            self.commentPushTask = task;
        }
        else if( [key isEqualToString:kPushReviewKey] )
        {
            self.reviewPushTask = task;
        }
        else if( [key isEqualToString:kPublicKey] )
        {
            self.profilePrivacyTask = task;
        }
        else if( [key isEqualToString:kSavePhotoKey] )
        {
            self.dishPhotoTask = task;
        }
    }
}

- (void)saveSettingsToServerWithParameters:(NSDictionary *)parameters completion:( void(^)( BOOL success ) )completion
{    
    [[self getTaskWithParameters:parameters] cancel];
    
    NSURLSessionTask *task = [[DAAPIManager sharedManager] POSTRequest:kUserSettingsURL withParameters:parameters
    success:^( id response )
    {
        NSDictionary *settings = nilOrJSONObjectForKey( response, kDataKey );
        [self setSettingsWithSettingsData:settings];
        [self saveProfile];
        
        if( completion )
        {
            completion( YES );
        }
    }
    failure:^( NSError *error, BOOL shouldRetry )
    {
        eErrorType errorType = [DAAPIManager errorTypeForError:error];
        
        if( shouldRetry )
        {
            [self saveSettingsToServerWithParameters:parameters completion:completion];
        }
        else if( errorType != eErrorTypeRequestCancelled )
        {
            if( completion )
            {
                completion( NO );
            }
        }
    }];
    
    [self setTask:task withParameters:parameters];
}

- (NSString *)pushSettingStringForPushSetting:(ePushSetting)pushSetting
{
    NSString *pushSettingString = kNone;
    
    switch( pushSetting )
    {
        case ePushSettingOff:      pushSettingString = kNone;   break;
        case ePushSettingEveryone: pushSettingString = kAll;    break;
        case ePushSettingFollowed: pushSettingString = kFollow; break;
    }
    
    return pushSettingString;
}

- (void)deleteLocalUserSettings
{
    self.dateOfBirth = nil;
    self.firstName = nil;
    self.lastName = nil;
    self.email = nil;
    self.desc = nil;
    self.phoneNumber = nil;
    self.username = nil;
    self.userType = nil;
    self.img_thumb = nil;
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kSavedProfileKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)restoreProfile
{
    NSDictionary *userProfile = [[NSUserDefaults standardUserDefaults] objectForKey:kSavedProfileKey];
    
    if( !userProfile )
    {
        return;
    }
    
    [self setSettingsWithSettingsData:userProfile];
    [self setProfileWithProfileData:userProfile];
}

- (void)saveProfile
{
    NSMutableDictionary *userProfile = [NSMutableDictionary dictionary];
    
    userProfile[kIDKey]          = @(self.user_id);
    userProfile[kTypeKey]        = self.userType;
    userProfile[kPhoneKey]       = self.phoneNumber ? self.phoneNumber : @"";
    userProfile[kEmailKey]       = self.email;
    userProfile[kUsernameKey]    = self.username;
    userProfile[kImgThumbKey]    = self.img_thumb ? self.img_thumb : @"";
    userProfile[kLastNameKey]    = self.lastName;
    userProfile[kFirstNameKey]   = self.firstName;
    userProfile[kDateOfBirthKey] = self.dateOfBirth;
    userProfile[kDescriptionKey] = self.desc ? self.desc : @"";
    
    userProfile[kPublicKey]    = @(self.publicProfile);
    userProfile[kSavePhotoKey] = @(self.savesDishPhoto);
    
    userProfile[kPushYumKey]     = [NSString stringWithFormat:@"%d", (int)self.receivesYumPushNotifications];
    userProfile[kPushReviewKey]  = [NSString stringWithFormat:@"%d", (int)self.receivesReviewPushNotifications];
    userProfile[kPushCommentKey] = [NSString stringWithFormat:@"%d", (int)self.receivesCommentPushNotifications];
    
    [[NSUserDefaults standardUserDefaults] setObject:userProfile forKey:kSavedProfileKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kUserProfileUpdatedNotification object:nil];
}

@end