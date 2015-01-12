//
//  DATransitionManager.m
//  Dished
//
//  Created by Ryan Khalili on 1/7/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

#import "DAModalTransitionManager.h"


@interface DAModalTransitionManager()

@property (nonatomic) BOOL presenting;

@end

@implementation DAModalTransitionManager

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    if( self.presenting )
    {
        return 0.3;
    }
    else
    {
        return 0.3;
    }
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIView *container = [transitionContext containerView];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    if( self.presenting )
    {
        [container addSubview:fromViewController.view];
        [container addSubview:toViewController.view];
    }
    else
    {
        [container addSubview:toViewController.view];
        [container addSubview:fromViewController.view];
    }
    
    CGAffineTransform transform;
    
    switch( self.transitionType )
    {
        case eTransitionTypeUp:
            transform = CGAffineTransformMakeTranslation( 0, container.frame.size.height );
            break;
            
        case eTransitionTypeDown:
            transform = CGAffineTransformMakeTranslation( 0, -container.frame.size.height );
            break;
            
        case eTransitionTypeLeft:
            transform = CGAffineTransformMakeTranslation( container.frame.size.width, 0 );
            break;
            
        case eTransitionTypeRight:
            transform = CGAffineTransformMakeTranslation( -container.frame.size.width, 0 );
            break;
    }
    
    if( self.presenting )
    {
        toViewController.view.transform = transform;
    }
    else
    {
        fromViewController.view.transform = CGAffineTransformIdentity;
    }
    
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    
    [UIView animateWithDuration:duration delay:0 options:0 animations:^
    {
        if( self.presenting )
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

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    self.presenting = YES;
    return self;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    self.presenting = NO;
    return self;
}

@end