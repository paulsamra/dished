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
    eErrorTypeParamsInvalid,
    eErrorTypeUnknown
} eErrorType;


@interface DAAPIManager : AFHTTPSessionManager

+ (DAAPIManager *)sharedManager;
+ (eErrorType)errorTypeForError:(NSError *)error;
+ (NSString *)errorResponseKey;

- (BOOL)networkIsReachable;
- (BOOL)isLoggedIn;
- (void)authenticateWithCompletion:( void(^)( BOOL success ) )completion;
- (NSDictionary *)authenticatedParametersWithParameters:(NSDictionary *)parameters;

- (void)refreshAuthenticationWithCompletion:( void(^)() )completion;

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
 * Returns an array of locations given a search string.
 * Distances are given in miles.
 */
- (NSURLSessionTask *)exploreLocationSearchTaskWithQuery:(NSString *)query longitude:(double)longitude latitude:(double)latitude completion:( void(^)( id response, NSError *error ) )completion;

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
 * Search for dishes given a search term.
 */
- (void)exploreDishesWithQuery:(NSString *)query longitude:(double)longitude latitude:(double)latitude radius:(double)radius completion:( void(^)( id response, NSError *error ) )completion;

/*
 * Retrieve data for user's feed view.
 */
- (void)getFeedActivityWithLongitude:(double)longitude latitude:(double)latitude radius:(double)radius offset:(NSInteger)offset limit:(NSInteger)limit completion:( void(^)( id response, NSError *error ) )completion;

/*
 * Get a user's news notifications.
 */
- (void)getNewsNotificationsWithLimit:(NSInteger)limit offset:(NSInteger)offset completion:( void(^)( id response, NSError *error ) )completion;

/*
 * Get a user's following notifications.
 */
- (void)getFollowingNotificationsWithLimit:(NSInteger)limit offset:(NSInteger)offset completion:( void(^)( id response, NSError *error ) )completion;

@end