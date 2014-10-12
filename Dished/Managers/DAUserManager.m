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
    NSDictionary *parameters = [[DAAPIManager sharedManager] authenticatedParametersWithParameters:nil];
    
    [[DAAPIManager sharedManager] GET:kUserSettingsURL parameters:parameters
    success:^( NSURLSessionDataTask *task, id responseObject )
    {
        NSDictionary *settings = nilOrJSONObjectForKey( responseObject, kDataKey );
        
        self.publicProfile  = [nilOrJSONObjectForKey( settings, kPublicKey )    boolValue];
        self.savesDishPhoto = [nilOrJSONObjectForKey( settings, kSavePhotoKey ) boolValue];
        
        self.receivesYumPushNotifications     = [self pushSettingForSetting:nilOrJSONObjectForKey( settings, kPushYumKey )];
        self.receivesReviewPushNotifications  = [self pushSettingForSetting:nilOrJSONObjectForKey( settings, kPushReviewKey )];
        self.receivesCommentPushNotifications = [self pushSettingForSetting:nilOrJSONObjectForKey( settings, kPushCommentKey )];
    }
    failure:^( NSURLSessionDataTask *task, NSError *error )
    {
        
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

- (void)restoreProfile
{
    
}

- (void)saveProfile
{
    
}

@end