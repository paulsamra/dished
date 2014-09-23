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
 * Get up-to-date list of positive hashtags from server.
 * Returns nil or error object if error occured.
 * Dish type options: "food", "wine", "cocktail"
 * Returns task identifier that can be used to cancel
 * the data task.
 */
- (void)getPositiveHashtagsForDishType:(NSString *)dishType completion:( void(^)( id response, NSError *error ) )completion;

/*
 * Get up-to-date list of negative hashtags from server.
 * Returns nil or error object if error occured.
 * Dish type options: "food", "wine", "cocktail"
 * Returns task identifier that can be used to cancel
 * the data task.
 */
- (void)getNegativeHashtagsForDishType:(NSString *)dishType completion:( void(^)( id response, NSError *error ) )completion;

/*
 * Returns an NSURLSessionTask object for retrieving
 * dish suggestions based on a search string.
 */
- (NSURLSessionTask *)getDishTitleSuggestionsWithQuery:(NSString *)query dishType:(NSString *)dishType completion:( void(^)( id response, NSError *error ) )completion;

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
 * Get content for main screen on explore tab incl.
 * hashtags and images.
 */
- (void)getExploreTabContentWithCompletion:( void(^)( id response, NSError *error ) )completion;

/*
 * Search task for usernames given a search string.
 * Completion returns array of usernames.
 */
- (NSURLSessionTask *)exploreUsernameSearchTaskWithQuery:(NSString *)query competion:( void(^)( id response, NSError *error ) )completion;

/*
 * Search task for dishes given a hashtag.
 * Completion returns array of dishes.
 */
- (NSURLSessionTask *)exploreDishesWithHashtagSearchTaskWithQuery:(NSString *)query longitude:(double)longitude latitude:(double)latitude radius:(double)radius completion:( void(^)( id response, NSError *error ) )completion;

/*
 * Search task for when it is unknown
 * when user is searching for dishes or locations.
 */
- (NSURLSessionTask *)exploreDishAndLocationSuggestionsTaskWithQuery:(NSString *)query longitude:(double)longitude latitude:(double)latitude radius:(double)radius completion:( void(^)( id response, NSError *error ) )completion;

/*
 * Get Editor's Picks dishes.
 * Completion returns array of dishes.
 */
- (void)getEditorsPicksDishesWithLongitude:(double)longitude latitude:(double)latitude radius:(double)radius completion:( void(^)( id response, NSError *error ) )completion;

/*
 * Get popular and trending dishes.
 * Completion returns array of dishes.
 */
- (void)getPopularDishesWithLongitude:(double)longitude latitude:(double)latitude radius:(double)radius completion:( void(^)( id response, NSError *error ) )completion;

/*
 * Search task for getting hashtag suggestions when
 * user is typing in a hashtag.
 */
- (NSURLSessionTask *)exploreHashtagSuggestionsTaskWithQuery:(NSString *)query completion:( void(^)( id response, NSError *error ) )completion;

/*
 * Search for dishes given a search term.
 */
- (void)exploreDishesWithQuery:(NSString *)query longitude:(double)longitude latitude:(double)latitude radius:(double)radius completion:( void(^)( id response, NSError *error ) )completion;

/*
 * Retrieve data for user's feed view.
 */
- (void)getFeedActivityWithLongitude:(double)longitude latitude:(double)latitude radius:(double)radius offset:(NSInteger)offset limit:(NSInteger)limit completion:( void(^)( id response, NSError *error ) )completion;

/*
 * Get list of comments left on a review.
 */
- (void)getCommentsForReviewID:(NSInteger)reviewID completion:( void(^)( id response, NSError *error ) )completion;

/*
 * Delete a review comment.
 */
- (void)deleteCommentWithID:(NSInteger)commentID completion:( void(^)( BOOL success ) )completion;

/*
 * Flag a review comment.
 */
- (void)flagCommentWithID:(NSInteger)commentID completion:( void(^)( BOOL success ) )completion;

/*
 * Create comment on a review.
 */
- (void)createComment:(NSString *)comment forReviewID:(NSInteger)reviewID completion:( void(^)( BOOL success ) )completion;

/*
 * Yum a review.
 */
- (void)yumReviewID:(NSInteger)reviewID completion:( void(^)( BOOL success ) )completion;

/*
 * Unyum a review.
 */
- (void)unyumReviewID:(NSInteger)reviewID completion:( void(^)( BOOL success ) )completion;

/*
 * Get review details.
 */
- (void)getProfileForReviewID:(NSInteger)reviewID completion:( void(^)( id response, NSError *error ) )completion;

/*
 * Get global dish info.
 */
- (void)getGlobalDishInfoForDishID:(NSInteger)dishID completion:( void(^)( id response, NSError *error ) )completion;

/*
 * Get a user's news notifications.
 */
- (void)getNewsNotificationsWithCompletion:( void(^)( id response, NSError *error ) )completion;

/*
 * Get a user's following notifications.
 */
- (void)getFollowingNotificationsWithCompletion:( void(^)( id response, NSError *error ) )completion;

@end