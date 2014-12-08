//
//  DAPushManager.h
//  Dished
//
//  Created by Ryan Khalili on 12/4/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DAPushManager : NSObject

+ (void)handlePushNotification:(NSDictionary *)notification;

@end