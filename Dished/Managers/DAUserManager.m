//
//  DAUserManager.m
//  Dished
//
//  Created by Ryan Khalili on 10/12/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DAUserManager.h"
#import "DAAPIManager.h"


@interface DAUserManager()

@property (copy, nonatomic, readwrite) NSString *firstName;
@property (copy, nonatomic, readwrite) NSString *lastName;
@property (copy, nonatomic, readwrite) NSString *username;
@property (copy, nonatomic, readwrite) NSString *desc;
@property (copy, nonatomic, readwrite) NSString *email;
@property (copy, nonatomic, readwrite) NSString *img_thumb;

@property (strong, nonatomic) NSURLSessionTask *userImageTask;
@property (strong, nonatomic) NSURLSessionTask *loadSettingsTask;
@property (strong, nonatomic) NSURLSessionTask *dishPhotoURLTask;
@property (strong, nonatomic) NSURLSessionTask *profilePrivacyURLTask;

@property (nonatomic, readwrite) BOOL         savesDishPhoto;
@property (nonatomic, readwrite) BOOL         publicProfile;
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

- (void)loadUserInfoWithCompletion:( void (^)( BOOL success ) )completion
{
    [[DAAPIManager sharedManager] authenticateWithCompletion:^( BOOL success )
    {
        NSDictionary *parameters = [[DAAPIManager sharedManager] authenticatedParametersWithParameters:nil];
        
        [self.loadSettingsTask cancel];
        
        self.loadSettingsTask = [[DAAPIManager sharedManager] GET:kUserSettingsURL parameters:parameters
        success:^( NSURLSessionDataTask *task, id responseObject )
        {
            NSDictionary *settings = nilOrJSONObjectForKey( responseObject, kDataKey );
            [self saveSettingsWithSettingsData:settings];
            [self saveProfile];
            
            if( completion )
            {
                completion( YES );
            }
        }
        failure:^( NSURLSessionDataTask *task, NSError *error )
        {
            
        }];
    }];
}

- (void)saveSettingsWithSettingsData:(id)settings
{
    self.publicProfile  = [nilOrJSONObjectForKey( settings, kPublicKey )    boolValue];
    self.savesDishPhoto = [nilOrJSONObjectForKey( settings, kSavePhotoKey ) boolValue];
    
    self.receivesYumPushNotifications     = [self pushSettingForSetting:nilOrJSONObjectForKey( settings, kPushYumKey )];
    self.receivesReviewPushNotifications  = [self pushSettingForSetting:nilOrJSONObjectForKey( settings, kPushReviewKey )];
    self.receivesCommentPushNotifications = [self pushSettingForSetting:nilOrJSONObjectForKey( settings, kPushCommentKey )];
}

- (void)setUserProfileImage:(UIImage *)image completion:( void(^)( BOOL success ) )completion
{
    [[DAAPIManager sharedManager] authenticateWithCompletion:^( BOOL success )
    {
        NSDictionary *parameters = [[DAAPIManager sharedManager] authenticatedParametersWithParameters:nil];
        
        [[DAAPIManager sharedManager] POST:kUserImageURL parameters:parameters
        constructingBodyWithBlock:^( id<AFMultipartFormData> formData )
        {
            if( image )
            {
                float compression = 0.8;
                NSData *imageData = UIImageJPEGRepresentation( image, compression );
                int maxFileSize = 2000000;
                while( [imageData length] > maxFileSize )
                {
                    compression -= 0.1;
                    imageData = UIImageJPEGRepresentation( image, compression );
                }
                 
                [formData appendPartWithFileData:imageData name:@"image" fileName:@"image.jpeg" mimeType:@"image/jpeg"];
            }
        }
        success:^( NSURLSessionDataTask *task, id responseObject )
        {
            completion( YES );
        }
        failure:^( NSURLSessionDataTask *task, NSError *error )
        {
            NSLog(@"failure: %@", error );
            completion( NO );
        }];
    }];
}

- (ePushSetting)pushSettingForSetting:(NSString *)setting
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
    [[DAAPIManager sharedManager] authenticateWithCompletion:^( BOOL success )
    {
        NSDictionary *parameters = @{ kSavePhotoKey : @(dishPhotoSetting) };
        parameters = [[DAAPIManager sharedManager] authenticatedParametersWithParameters:parameters];
        
        [self.dishPhotoURLTask cancel];
        
        self.dishPhotoURLTask = [[DAAPIManager sharedManager] POST:kUserSettingsURL parameters:parameters
        success:^( NSURLSessionDataTask *task, id responseObject )
        {
            NSDictionary *settings = nilOrJSONObjectForKey( responseObject, kDataKey );
            [self saveSettingsWithSettingsData:settings];
            [self saveProfile];
            
            if( completion )
            {
                completion( YES );
            }
        }
        failure:^( NSURLSessionDataTask *task, NSError *error )
        {
            eErrorType errorType = [DAAPIManager errorTypeForError:error];
            
            if( errorType != eErrorTypeRequestCancelled )
            {
                if( completion )
                {
                    completion( NO );
                }
            }
        }];
    }];
}

- (void)savePrivacySetting:(BOOL)privacySetting completion:( void(^)( BOOL success ) )completion
{
    [[DAAPIManager sharedManager] authenticateWithCompletion:^( BOOL success )
    {
        NSDictionary *parameters = @{ kPublicKey : @(privacySetting) };
        parameters = [[DAAPIManager sharedManager] authenticatedParametersWithParameters:parameters];
        
        [self.profilePrivacyURLTask cancel];
        
        self.profilePrivacyURLTask = [[DAAPIManager sharedManager] POST:kUserSettingsURL parameters:parameters
        success:^( NSURLSessionDataTask *task, id responseObject )
        {
            NSDictionary *settings = nilOrJSONObjectForKey( responseObject, kDataKey );
            [self saveSettingsWithSettingsData:settings];
            [self saveProfile];
            
            if( completion )
            {
                completion( YES );
            }
        }
        failure:^( NSURLSessionDataTask *task, NSError *error )
        {
            eErrorType errorType = [DAAPIManager errorTypeForError:error];
            
            if( errorType != eErrorTypeRequestCancelled )
            {
                if( completion )
                {
                    completion( NO );
                }
            }
        }];
    }];
}

- (void)deleteLocalUserSettings
{
    
}

- (void)restoreProfile
{
    
}

- (void)saveProfile
{
    
}

@end