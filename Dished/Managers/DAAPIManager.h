//
//  DAAPIManager.h
//  Dished
//
//  Created by Ryan Khalili on 6/7/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "AFHTTPSessionManager.h"
#import "DAHashtag.h"


@interface DAAPIManager : AFHTTPSessionManager

+ (DAAPIManager *)sharedManager;

- (NSString *)errorResponseKey;

/*
 * Check if another user is already signed up with a given email address.
 */
- (void)checkAvailabilityOfEmail:(NSString *)email completion:(void(^)( BOOL available, NSError *error ) )completion;

/*
 * Check if another user is already signed up with a given phone number.
 */
- (void)checkAvailabilityOfPhoneNumber:(NSString *)phoneNumber completion:(void(^)( BOOL available, NSError *error ) )completion;

/*
 * Register new Dished user account.
 */
- (void)registerUserWithUsername:(NSString *)username password:(NSString *)password firstName:(NSString *)firstName lastName:(NSString *)lastName email:(NSString *)email phoneNumber:(NSString *)phoneNumber birthday:(NSDate *)birthday completion:(void(^)( BOOL registered, BOOL loggedIn ) )completion;

/*
 * User login.
 */
- (void)loginWithUser:(NSString *)user password:(NSString *)password completion:(void(^)( BOOL success, BOOL wrongUser, BOOL wrongPass ) )completion;

/*
 * Request password reset verification code.
 */
- (void)requestPasswordResetCodeWithPhoneNumber:(NSString *)phoneNumber completion:(void(^)( BOOL success ) )completion;

/*
 * Submit password reset to new password with verification pin.
 */
- (void)submitPasswordResetWithPin:(NSString *)pin phoneNumber:(NSString *)phoneNumber newPassword:(NSString *)password completion:(void(^)( BOOL pinValid, BOOL success ) )completion;

/*
 * Get up-to-date list of positive hashtags from server.
 * Completion handler returns array of DAHashtag objects.
 * Returns nil array or error object if error occured.
 */
- (void)getPositiveHashtagsForDishType:(NSString *)dishType completion:( void(^)( NSArray *hashtags, NSError *error ) )completion;

/*
 * Get up-to-date list of negative hashtags from server.
 * Completion handler returns array of DAHashtag objects.
 * Returns nil array or error object if error occured.
 */
- (void)getNegativeHashtagsForDishType:(NSString *)dishType completion:( void(^)( NSArray *hashtags, NSError *error ) )completion;

@end