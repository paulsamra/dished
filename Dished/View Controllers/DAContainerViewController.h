//
//  DAContainerViewController.h
//  Dished
//
//  Created by Ryan Khalili on 10/19/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DAContainerViewController : UIViewController

- (void)moveToTabBar;
- (void)slideOutMenu;
- (void)moveToMenu;
- (BOOL)menuShowing;

- (void)handleUserNotificationWithUserID:(NSInteger)userID isRestaurant:(BOOL)isRestaurant;
- (void)handleReviewNotificationWithReviewID:(NSInteger)reviewID;

- (void)openReviewWithReviewID:(NSInteger)reviewID;
- (void)openDishWithDishID:(NSInteger)dishID;

@end


@interface UIViewController(DAContainerViewController)

- (DAContainerViewController *)containerViewController;

@end