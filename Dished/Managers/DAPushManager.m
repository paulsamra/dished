//
//  DAPushManager.m
//  Dished
//
//  Created by Ryan Khalili on 12/4/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DAPushManager.h"
#import "DAAppDelegate.h"
#import "DANewsManager.h"
#import "DAContainerViewController.h"


@implementation DAPushManager

+ (id)rootViewController
{
    return [UIApplication sharedApplication].delegate.window.rootViewController;
}

+ (void)handlePushNotification:(NSDictionary *)notification
{
    if( [[UIApplication sharedApplication] applicationState] == UIApplicationStateInactive )
    {
        [self handleInactivePushNotification:notification];
    }
    else
    {
        [self handleActivePushNotification:notification];
    }
}

+ (void)handleInactivePushNotification:(NSDictionary *)notification
{
    NSString *notificationType = notification[@"ntf"][@"type"];
    NSInteger typeID = [notification[@"ntf"][@"type_id"] integerValue];
    
    DAContainerViewController *rootViewController = [self rootViewController];
    
    if( [notificationType isEqualToString:@"user"] )
    {
        [rootViewController handleUserNotificationWithUserID:typeID isRestaurant:NO];
    }
    else if( [notificationType isEqualToString:@"restaurant"] )
    {
        [rootViewController handleUserNotificationWithUserID:typeID isRestaurant:YES];
    }
    else if( [notificationType isEqualToString:@"review"] )
    {
        [rootViewController handleReviewNotificationWithReviewID:typeID];
    }
}

+ (void)handleActivePushNotification:(NSDictionary *)notification
{
    [[DANewsManager sharedManager] updateAllNews];
}

@end