//
//  DATwitterManager.h
//  Dished
//
//  Created by Ryan Khalili on 7/28/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kTwitterLoginNotificationKey @"login_complete"
#define kTwitterCallbackURL  @"dishedapp://twitterCallback"


typedef void ( ^DATwitterSuccessBlock )( BOOL );

@interface DATwitterManager : NSObject

+ (DATwitterManager *)sharedManager;

- (BOOL)isLoggedIn;
- (NSString *)currentUser;
- (void)loginWithCompletion:( void(^)( BOOL success ) )completion;
- (void)logout;
- (void)processURL:(NSURL *)url;
- (void)postDishTweetWithMessage:(NSString *)message imageURL:(NSString *)imageURL completion:(DATwitterSuccessBlock)completion;

@end