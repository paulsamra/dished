//
//  DATabBarController.h
//  Dished
//
//  Created by Ryan Khalili on 6/29/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DADishProfile;


@interface DATabBarController : UITabBarController

- (void)resetToHomeFeed;
- (void)startAddReviewProcessWithDishProfile:(DADishProfile *)dishProfile;

@end