//
//  DAAPIManager.h
//  Dished
//
//  Created by Ryan Khalili on 6/7/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "AFHTTPSessionManager.h"
#import "DAHashtag.h"
#import "DANewReview.h"


@interface DAAPIManager : AFHTTPSessionManager

+ (DAAPIManager *)sharedManager;

- (BOOL)isLoggedIn;
- (NSString *)accessToken;
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
 * Dish type options: "food", "wine", "cocktail"
 */
- (void)getPositiveHashtagsForDishType:(NSString *)dishType completion:( void(^)( NSArray *hashtags, NSError *error ) )completion;

/*
 * Get up-to-date list of negative hashtags from server.
 * Completion handler returns array of DAHashtag objects.
 * Returns nil array or error object if error occured.
 * Dish type options: "food", "wine", "cocktail"
 */
- (void)getNegativeHashtagsForDishType:(NSString *)dishType completion:( void(^)( NSArray *hashtags, NSError *error ) )completion;

/*
 * Returns an URL session task for retrieving dish
 * suggestions based on a search string.
 */
- (NSURLSessionTask *)dishTitleSuggestionTaskWithQuery:(NSString *)query dishType:(NSString *)dishType completion:( void(^)( id responseData, NSError *error ) )completion;

/*
 * Returns an array of locations and an array of the
 * distances to those locations given a search string.
 * The sizes of the arrays will always be the same.
 * If there is not distance available for a location, 
 * the corresponding distance for that location will
 * be an empty string in the array. The distances are
 * in miles, and represented as strings in the array.
 */
- (void)searchLocationsWithQuery:(NSString *)query completion:( void(^)( NSArray *locations, NSArray *distances, NSError *error ) )completion;

/*
 * Posts a new dish review to the server.
 */
- (void)postNewReview:(DANewReview *)review completion:( void(^)( BOOL success ) )completion;

@end