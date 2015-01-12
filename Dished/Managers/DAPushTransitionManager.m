//
//  DAPushTransitionManager.m
//  Dished
//
//  Created by Ryan Khalili on 1/7/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

#import "DAPushTransitionManager.h"


@implementation DAPushTransitionManager

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.3;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIView *container = [transitionContext containerView];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    if( self.pushing )
    {
        [container addSubview:fromViewController.view];
        [container addSubview:toViewController.view];
    }
    else
    {
        [container addSubview:toViewController.view];
        [container addSubview:fromViewController.view];
    }
    
    CGAffineTransform transform = CGAffineTransformMakeTranslation( container.frame.size.width, 0 );
    
    fromViewController.view.transform = CGAffineTransformIdentity;

    if( self.pushing )
    {
        toViewController.view.transform = transform;
    }
    else
    {
        toViewController.view.transform = CGAffineTransformIdentity;
    }
    
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    
    [UIView animateWithDuration:duration delay:0 options:0 animations:^
    {
        if( self.pushing )
        {
            toViewController.view.transform = CGAffineTransformIdentity;
        }
        else
        {
            fromViewController.view.transform = transform;
        }
    }
    completion:^( BOOL finished )
    {
        [transitionContext completeTransition:YES];
    }];
}

@end