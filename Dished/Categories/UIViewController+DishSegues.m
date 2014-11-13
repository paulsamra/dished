//
//  UIViewController+DishSegues.m
//  Dished
//
//  Created by Ryan Khalili on 11/10/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "UIViewController+DishSegues.h"

@implementation UIViewController (DishSegues)

- (void)pushRestaurantProfileWithLocationID:(NSInteger)locationID username:(NSString *)username
{
    DAUserProfileViewController *restaurantProfileViewController = [self viewControllerWithStoryboardID:kUserProfileID];
    
    restaurantProfileViewController.isRestaurant = YES;
    restaurantProfileViewController.username = username;
    restaurantProfileViewController.loc_id  = locationID;
    
    [self.navigationController pushViewController:restaurantProfileViewController animated:YES];
}

- (void)pushrestaurantProfileWithUserID:(NSInteger)userID username:(NSString *)username
{
    DAUserProfileViewController *restaurantProfileViewController = [self viewControllerWithStoryboardID:kUserProfileID];
    
    restaurantProfileViewController.isRestaurant = YES;
    restaurantProfileViewController.username = username;
    restaurantProfileViewController.user_id  = userID;
    
    [self.navigationController pushViewController:restaurantProfileViewController animated:YES];
}

- (void)pushUserProfileWithUserID:(NSInteger)userID
{
    DAUserProfileViewController *userProfileViewController = [self viewControllerWithStoryboardID:kUserProfileID];
    
    userProfileViewController.isRestaurant = NO;
    userProfileViewController.user_id = userID;
    
    [self.navigationController pushViewController:userProfileViewController animated:YES];
}

- (void)pushUserProfileWithUsername:(NSString *)username
{
    DAUserProfileViewController *userProfileViewController = [self viewControllerWithStoryboardID:kUserProfileID];
    
    userProfileViewController.isRestaurant = NO;
    userProfileViewController.username = username;
    
    [self.navigationController pushViewController:userProfileViewController animated:YES];
}

- (void)pushReviewDetailsWithReviewID:(NSInteger)reviewID
{
    DAReviewDetailsViewController *reviewDetailsViewController = [self viewControllerWithStoryboardID:kReviewDetailsID];
    
    reviewDetailsViewController.reviewID = reviewID;
    
    [self.navigationController pushViewController:reviewDetailsViewController animated:YES];
}

- (void)pushGlobalDishWithDishID:(NSInteger)dishID
{
    DAGlobalDishDetailViewController *globalDishViewController = [self viewControllerWithStoryboardID:kGlobalDishID];
    
    globalDishViewController.dishID = dishID;
    
    [self.navigationController pushViewController:globalDishViewController animated:YES];
}

- (void)pushCommentsViewWithFeedItem:(DAFeedItem *)feedItem showKeyboard:(BOOL)showKeyboard
{
    DACommentsViewController *commentsViewController = [self viewControllerWithStoryboardID:kCommentsViewID];
    
    commentsViewController.feedItem = feedItem;
    commentsViewController.shouldShowKeyboard = showKeyboard;
    
    [self.navigationController pushViewController:commentsViewController animated:YES];
}

- (void)pushCommentsViewWithReviewID:(NSInteger)reviewID showKeyboard:(BOOL)showKeyboard
{
    DACommentsViewController *commentsViewController = [self viewControllerWithStoryboardID:kCommentsViewID];
    
    commentsViewController.reviewID = reviewID;
    commentsViewController.shouldShowKeyboard = showKeyboard;
    
    [self.navigationController pushViewController:commentsViewController animated:YES];
}

- (void)pushSettingsView
{
    DASettingsViewController *settingsViewController = [self viewControllerWithStoryboardID:kSettingsViewID];
    
    [self.navigationController pushViewController:settingsViewController animated:YES];
}

- (id)viewControllerWithStoryboardID:(NSString *)storyboardID
{
    return [self.storyboard instantiateViewControllerWithIdentifier:storyboardID];
}

@end