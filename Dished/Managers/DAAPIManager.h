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
- (BOOL)authenticate;

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
 * Returns an NSURLSessionTask object for retrieving
 * dish suggestions based on a search string.
 */
- (NSURLSessionTask *)dishTitleSuggestionTaskWithQuery:(NSString *)query dishType:(NSString *)dishType completion:( void(^)( id responseData, NSError *error ) )completion;

/*
 * Returns an array of locations given a search string.
 * Distances are given in miles.
 */
- (NSURLSessionTask *)locationSearchTaskWithQuery:(NSString *)query longitude:(double)longitude latitude:(double)latitude completion:( void(^)( id responseData, NSError *error ) )completion;

/*
 * Posts a new dish review to the server.
 */
- (void)postNewReview:(DANewReview *)review withImage:(UIImage *)image completion:( void(^)( BOOL success, NSString *imageURL ) )completion;

/*
 * Get content for main screen on explore tab incl.
 * hashtags and images. Completion handler return
 * array of DAHashtag objects and array of image URLs.
 */
- (void)getExploreTabContentWithCompletion:( void(^)( NSArray *hashtags, NSArray *imageURLs, NSError *error ) )completion;

@end