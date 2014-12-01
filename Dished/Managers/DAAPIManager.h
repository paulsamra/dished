//
//  DAAPIManager.h
//  Dished
//
//  Created by Ryan Khalili on 6/7/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "AFHTTPSessionManager.h"
#import "DANewReview.h"

#define kNetworkUnreachableKey @"network_unreachable"
#define kNetworkReachableKey   @"network_reachable"

typedef enum
{
    eErrorTypeDataNonexists,
    eErrorTypeEmailExists,
    eErrorTypePhoneExists,
    eErrorTypeContentPrivate,
    eErrorTypeTimeout,
    eErrorTypeRequestCancelled,
    eErrorTypeExpiredAccessToken,
    eErrorTypeInvalidRefreshToken,
    eErrorTypeParamsInvalid,
    eErrorTypeUnknown
} eErrorType;


@interface DAAPIManager : AFHTTPSessionManager

+ (DAAPIManager *)sharedManager;
+ (eErrorType)errorTypeForError:(NSError *)error;
+ (NSString *)errorResponseKey;

- (BOOL)networkIsReachable;
- (BOOL)isLoggedIn;
- (NSDictionary *)authenticatedParametersWithParameters:(NSDictionary *)parameters;

/*
 * Refreshes authentication tokens with Dished server.
 */
- (void)refreshAuthenticationWithCompletion:( void(^)( BOOL success ) )completion;

/*
 * Register new Dished user account.
 */
- (void)registerUserWithUsername:(NSString *)username password:(NSString *)password firstName:(NSString *)firstName lastName:(NSString *)lastName email:(NSString *)email phoneNumber:(NSString *)phoneNumber birthday:(NSDate *)birthday completion:(void(^)( BOOL registered, BOOL loggedIn ) )completion;

/*
 * User login.
 */
- (void)loginWithUser:(NSString *)user password:(NSString *)password completion:(void(^)( BOOL success, BOOL wrongUser, BOOL wrongPass ) )completion;

/*
 * User logout.
 */
- (void)logout;

/*
 * Request password reset verification code.
 */
- (void)requestPasswordResetCodeWithPhoneNumber:(NSString *)phoneNumber completion:(void(^)( BOOL success ) )completion;

/*
 * Submit password reset to new password with verification pin.
 */
- (void)submitPasswordResetWithPin:(NSString *)pin phoneNumber:(NSString *)phoneNumber newPassword:(NSString *)password completion:(void(^)( BOOL pinValid, BOOL success ) )completion;

/*
 * Posts a new dish review to the server.
 */
- (void)postNewReview:(DANewReview *)review withImage:(UIImage *)image completion:( void(^)( BOOL success, NSString *imageURL ) )completion;

/*
 * Search task for when it is unknown
 * when user is searching for dishes or locations.
 */
- (NSURLSessionTask *)exploreDishAndLocationSuggestionsTaskWithQuery:(NSString *)query longitude:(double)longitude latitude:(double)latitude radius:(double)radius completion:( void(^)( id response, NSError *error ) )completion;

/*
 * Retrieve data for user's feed view.
 */
- (void)getFeedActivityWithLongitude:(double)longitude latitude:(double)latitude radius:(double)radius offset:(NSInteger)offset limit:(NSInteger)limit completion:( void(^)( id response, NSError *error ) )completion;

@end