//
//  UIViewController+DishSegues.h
//  Dished
//
//  Created by Ryan Khalili on 11/10/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DAUserProfileViewController.h"
#import "DAReviewDetailsViewController.h"
#import "DACommentsViewController.h"
#import "DASettingsViewController.h"
#import "DAGlobalDishDetailViewController.h"

@class DAFeedItem;


@interface UIViewController (DishSegues)

- (void)pushRestaurantProfileWithLocationID:(NSInteger)locationID username:(NSString *)username;
- (void)pushrestaurantProfileWithUserID:(NSInteger)userID username:(NSString *)username;
- (void)pushUserProfileWithUsername:(NSString *)username;
- (void)pushUserProfileWithUserID:(NSInteger)userID;

- (void)pushReviewDetailsWithReviewID:(NSInteger)reviewID;
- (void)pushGlobalDishWithDishID:(NSInteger)dishID;

- (void)pushCommentsViewWithFeedItem:(DAFeedItem *)feedItem showKeyboard:(BOOL)showKeyboard;
- (void)pushCommentsViewWithReviewID:(NSInteger)reviewID showKeyboard:(BOOL)showKeyboard;

- (void)pushSettingsView;

@end