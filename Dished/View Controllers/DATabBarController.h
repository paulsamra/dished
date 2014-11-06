//
//  DATabBarController.h
//  Dished
//
//  Created by Ryan Khalili on 6/29/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DADishProfile;
@class DAReview;


@interface DATabBarController : UITabBarController

- (void)showShareViewWithDish:(DADishProfile *)dishProfile;
- (void)showShareViewWithReview:(DAReview *)review;
- (void)startAddReviewProcessWithDishProfile:(DADishProfile *)dishProfile;

@end