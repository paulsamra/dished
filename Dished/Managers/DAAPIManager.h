//
//  DAAPIManager.h
//  Dished
//
//  Created by Ryan Khalili on 6/7/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "AFHTTPSessionManager.h"

@interface DAAPIManager : AFHTTPSessionManager

+ (DAAPIManager *)sharedManager;

/*
 * Check if another user is already signed up with a given username.
 */
- (void)checkAvailabilityOfUsername:(NSString *)username completion:(void(^)( BOOL available, NSError *error ))completion;

/*
 * Check if another user is already signed up with a given email address.
 */
- (void)checkAvailabilityOfEmail:(NSString *)email completion:(void(^)( BOOL available, NSError *error ))completion;

/*
 * Register new Dished user account.
 */
- (void)registerUserWithUsername:(NSString *)username password:(NSString *)password firstName:(NSString *)firstName lastName:(NSString *)lastName email:(NSString *)email birthday:(NSDate *)birthday completion:(void(^)( BOOL registered, BOOL loggedIn ))completion;

@end