//
//  UIViewController+ShareView.m
//  Dished
//
//  Created by Ryan Khalili on 11/8/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "UIViewController+ShareView.h"
#import "DAUserManager.h"

#define kDimViewTag   98
#define kShareViewTag 99


@implementation UIViewController (ShareView)

- (void)showShareViewWithDish:(DADishProfile *)dishProfile
{
    DASocialCollectionViewController *socialViewController = [self showShareView];
    socialViewController.dishProfile = dishProfile;
}

- (void)showShareViewWithReview:(DAReview *)review
{
    DAUserManager2 *userManager = [[DAUserManager2 alloc] init];
    DASocialCollectionViewController *socialViewController = [self showShareView];
    socialViewController.review = review;
    
    if( [review.creator_username isEqualToString:userManager.username] )
    {
        socialViewController.isOwnReview = YES;
    }
}

- (void)dismissShareView
{
    UIView *dimView = [self.view viewWithTag:kDimViewTag];
    UIView *shareView = [self.view viewWithTag:kShareViewTag];
    
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^
    {
        dimView.backgroundColor = [UIColor clearColor];
        dimView.alpha = 1.0;
         
        CGRect hiddenRect = shareView.frame;
        hiddenRect.origin.y = self.view.frame.size.height;
        shareView.frame = hiddenRect;
    }
    completion:^( BOOL finished )
    {
        [dimView removeFromSuperview];
        [shareView removeFromSuperview];
    }];
}

- (DASocialCollectionViewController *)showShareView
{
    DASocialCollectionViewController *socialViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"social"];
    socialViewController.isReviewPost = NO;
    socialViewController.view.tag = kShareViewTag;
    socialViewController.view.frame = CGRectMake( 0, self.view.frame.size.height, self.view.bounds.size.width, self.view.bounds.size.height );
    socialViewController.delegate = self;
    [self addChildViewController:socialViewController];
    
    UIView *dimView = [[UIView alloc] initWithFrame:self.view.frame];
    dimView.tag = kDimViewTag;
    dimView.backgroundColor = [UIColor clearColor];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:socialViewController.delegate action:@selector(socialCollectionViewControllerDidFinish:)];
    [dimView addGestureRecognizer:tapGesture];
    
    [self.view addSubview:dimView];
    [self.view addSubview:socialViewController.view];
    socialViewController.view.hidden = NO;
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^
    {
        dimView.backgroundColor = [UIColor blackColor];
        dimView.alpha = 0.4;
         
        CGFloat socialViewHeight = socialViewController.collectionViewLayout.collectionViewContentSize.height;
        CGRect socialViewFrame = socialViewController.view.frame;
        
        if( self.tabBarController )
        {
            socialViewFrame.origin.y = self.tabBarController.tabBar.frame.origin.y - socialViewHeight;
        }
        else
        {
            socialViewFrame.origin.y = self.view.frame.size.height - socialViewHeight;
        }
        
        socialViewController.view.frame = socialViewFrame;
    }
    completion:^( BOOL finished )
    {
        [socialViewController didMoveToParentViewController:self];
    }];
    
    return socialViewController;
}

@end