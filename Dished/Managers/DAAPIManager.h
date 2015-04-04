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
#define kForcedLogoutNotificationKey @"forced_logout"

typedef enum
{
    eErrorTypeDataNonexists,
    eErrorTypeDataExists,
    eErrorTypeEmailExists,
    eErrorTypePhoneExists,
    eErrorTypeUsernameExists,
    eErrorTypeInvalidUsername,
    eErrorTypeContentPrivate,
    eErrorTypeTimeout,
    eErrorTypeConnection,
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

- (BOOL)networkIsReachable;
- (BOOL)isLoggedIn;

- (NSURLSessionTask *)GETRequest:(NSString *)url
                  withParameters:(NSDictionary *)parameters
                         success:(RequestSuccessBlock)success
                         failure:(RequestFailureBlock)failure;

- (NSURLSessionTask *)POSTRequest:(NSString *)url
                   withParameters:(NSDictionary *)parameters
                          success:(RequestSuccessBlock)success
                          failure:(RequestFailureBlock)failure;

- (NSURLSessionTask *)POSTRequest:(NSString *)url
                   withParameters:(NSDictionary *)parameters
        constructingBodyWithBlock:(void (^)( id <AFMultipartFormData> formData ) )block
                          success:(RequestSuccessBlock)success
                          failure:(RequestFailureBlock)failure;

/*
 * Register new Dished user account.
 */
- (void)registerUserWithUsername:(NSString *)username password:(NSString *)password firstName:(NSString *)firstName
                        lastName:(NSString *)lastName email:(NSString *)email phoneNumber:(NSString *)phoneNumber
                        birthday:(NSDate *)birthday completion:(void(^)( BOOL registered, BOOL loggedIn ) )completion;

/*
 * User login.
 */
- (void)loginWithUser:(NSString *)user password:(NSString *)password completion:(void(^)( BOOL success, BOOL wrongUser, BOOL wrongPass ) )completion;

/*
 * Facebook user login.
 */
- (void)loginWithFacebookUserID:(NSString *)facebookID completion:( void(^)( BOOL success, BOOL accountExists ) )completion;

/*
 * Register new Dished account with Facebook Login
 */
- (void)registerFacebookUserWithUserID:(NSString *)facebookID Username:(NSString *)username
                             firstName:(NSString *)firstName lastName:(NSString *)lastName email:(NSString *)email
                           phoneNumber:(NSString *)phoneNumber birthday:(NSDate *)birthday imageURL:(NSString *)imageURL
                            completion:( void(^)( BOOL registered, BOOL loggedIn ) )completion;

/*
 * User logout.
 */
- (void)logoutWithCompletion:( void(^)( BOOL success ) )completion;

/*
 * Logs out user without notifying Dished API. Use carefully.
 */
- (void)forceUserLogout;

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

+ (void)followUserID:(NSInteger)userID;
+ (void)unfollowUserID:(NSInteger)userID;

@end