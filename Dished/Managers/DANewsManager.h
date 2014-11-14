//
//  DANewsManager.h
//  Dished
//
//  Created by Ryan Khalili on 9/24/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DAUserNews.h"
#import "DAFollowingNews.h"

#define kNewsUpdatedNotificationKey      @"news_updated"
#define kFollowingUpdatedNotificationKey @"following_updated"

typedef void (^DANewsManagerCompletionBlock)( BOOL success );


@interface DANewsManager : NSObject

@property (strong, nonatomic, readonly) NSArray *newsNotifications;
@property (strong, nonatomic, readonly) NSArray *followingNotifications;

@property (nonatomic, readonly) BOOL      newsFinishedLoading;
@property (nonatomic, readonly) BOOL      followingFinishedLoading;
@property (nonatomic, readonly) BOOL      hasMoreNewsNotifications;
@property (nonatomic, readonly) BOOL      hasMoreFollowingNotifications;
@property (nonatomic, readonly) NSInteger num_reviews;
@property (nonatomic, readonly) NSInteger num_yums;
@property (nonatomic)           NSInteger loadLimit; //defaults to 25


+ (DANewsManager *)sharedManager;

- (void)updateAllNewsWithCompletion:(DANewsManagerCompletionBlock)completion;

- (void)refreshNewsWithCompletion:(DANewsManagerCompletionBlock)completion;
- (void)refreshFollowingWithCompletion:(DANewsManagerCompletionBlock)completion;

- (void)loadMoreNewsWithCompletion:(DANewsManagerCompletionBlock)completion;
- (void)loadMoreFollowingWithCompletion:(DANewsManagerCompletionBlock)completion;

- (void)deleteAllNews;

@end