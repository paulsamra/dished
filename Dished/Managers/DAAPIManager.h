//
//  DAAPIManager.h
//  Dished
//
//  Created by Ryan Khalili on 6/7/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "AFHTTPSessionManager.h"

#define kNetworkUnreachableKey @"network_unreachable"
#define kNetworkReachableKey   @"network_reachable"

typedef enum
{
    eErrorTypeDataNonexists,
    eErrorTypeEmailExists,
    eErrorTypePhoneExists,
    eErrorTypeUsernameExists,
    eErrorTypeInvalidUsername,
    eErrorTypeContentPrivate,
    eErrorTypeTimeout,
    eErrorTypeRequestCancelled,
    eErrorTypeExpiredAccessToken,
    eErrorTypeInvalidRefreshToken,
    eErrorTypeParamsInvalid,
    eErrorTypeUnknown
} eErrorType;

typedef void(^RequestSuccessBlock)( id response );
typedef void(^RequestFailureBlock)( NSError *error, BOOL shouldRetry );


@interface DAAPIManager : AFHTTPSessionManager

+ (DAAPIManager *)sharedManager;
+ (eErrorType)errorTypeForError:(NSError *)error;
+ (NSString *)errorResponseKey;

- (BOOL)networkIsReachable;
- (BOOL)isLoggedIn;
- (NSDictionary *)authenticatedParametersWithParameters:(NSDictionary *)parameters;

- (NSURLSessionTask *)GETRequest:(NSString *)url
                  withParameters:(NSDictionary *)parameters
                         success:(RequestSuccessBlock)success
                         failure:(RequestFailureBlock)failure;

- (NSURLSessionTask *)POSTRequest:(NSString *)url
                   withParameters:(NSDictionary *)parameters
                          success:(RequestSuccessBlock)success
                          failure:(RequestFailureBlock)failure;

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
 * Search task for when it is unknown
 * when user is searching for dishes or locations.
 */
- (NSURLSessionTask *)exploreDishAndLocationSuggestionsTaskWithQuery:(NSString *)query longitude:(double)longitude latitude:(double)latitude radius:(double)radius completion:( void(^)( id response, NSError *error ) )completion;

@end