//
//  UIViewController+ShareView.h
//  Dished
//
//  Created by Ryan Khalili on 11/8/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DASocialCollectionViewController.h"

@class DAReview;
@class DADishProfile;


@interface UIViewController (ShareView) <DASocialCollectionViewControllerDelegate>

- (void)showShareViewWithDish:(DADishProfile *)dishProfile;
- (void)showShareViewWithReview:(DAReview *)review;
- (void)dismissShareView;

@end