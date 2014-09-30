//
//  DARefreshControl.m
//  Dished
//
//  Created by Ryan Khalili on 8/24/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DARefreshControl.h"

#define kDefaultHeight 40


@interface DARefreshControl()

@property (strong, nonatomic) CALayer      *maskLayer;
@property (strong, nonatomic) CALayer      *blueDishLayer;
@property (strong, nonatomic) CALayer      *grayDishLayer;
@property (weak,   nonatomic) UIScrollView *scrollView;

@property (nonatomic) BOOL isRefreshing;

@end


@implementation DARefreshControl

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if( self )
    {
        _isRefreshing = NO;
        [self setupImageLayer];
    }
    
    return self;
}

- (id)initWithScrollView:(UIScrollView *)scrollView
{
    self = [super init];
    
    if( self )
    {
        _scrollView = scrollView;
        [self calculateFrame];
        [self setupImageLayer];
    }
    
    return self;
}

- (void)calculateFrame
{
    CGFloat height = kDefaultHeight;
    CGFloat width  = self.scrollView.bounds.size.width;
    CGRect  frame  = CGRectMake( 0, -height, width, height );
    
    self.frame = frame;
}

- (void)setupImageLayer
{
    self.grayDishLayer = [CALayer layer];
    self.grayDishLayer.masksToBounds = YES;
    UIImage *dishImage = [UIImage imageNamed:@"refresh_gray"];
    CGFloat x = ( self.frame.size.width  / 2 ) - ( dishImage.size.width  / 2 );
    CGFloat y = ( self.frame.size.height / 2 ) - ( dishImage.size.height / 2 );
    self.grayDishLayer.frame = CGRectMake( x, y, dishImage.size.width, dishImage.size.height );
    self.grayDishLayer.backgroundColor = [UIColor clearColor].CGColor;
    self.grayDishLayer.contents = (id)dishImage.CGImage;
    [self.layer addSublayer:self.grayDishLayer];
    
    self.blueDishLayer = [CALayer layer];
    self.blueDishLayer.frame = self.grayDishLayer.frame;
    self.blueDishLayer.backgroundColor = [UIColor clearColor].CGColor;
    self.blueDishLayer.contents = (id)[UIImage imageNamed:@"refresh_blue"].CGImage;
    [self.layer addSublayer:self.blueDishLayer];
    
    self.maskLayer = [CALayer layer];
    self.maskLayer.anchorPoint = CGPointZero;
    self.maskLayer.frame = CGRectMake( 0, 0, 0, self.blueDishLayer.frame.size.height );
    self.maskLayer.backgroundColor = [UIColor blackColor].CGColor;
    self.blueDishLayer.mask = self.maskLayer;
}

- (void)containingScrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat scrollPosition = scrollView.contentOffset.y + scrollView.contentInset.top;
    
    if( scrollPosition > 0 || self.isRefreshing )
    {
        return;
    }
    
    CGFloat percentWidth = fabs( scrollPosition ) / self.frame.size.height / 2.5;
    
    CGRect maskFrame = self.maskLayer.frame;
    maskFrame.size.width = self.blueDishLayer.frame.size.width * percentWidth;

    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    self.maskLayer.frame = maskFrame;
    [CATransaction commit];

}

- (void)containingScrollViewDidEndDragging:(UIScrollView *)scrollView
{
    if( self.maskLayer.frame.size.width >= self.blueDishLayer.frame.size.width && !self.isRefreshing )
    {
        self.isRefreshing = YES;
        [self setLoadingScrollViewInsets:scrollView];
        [self startAnimation];
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

- (void)shouldRestartAnimation
{
    if( self.isRefreshing )
    {
        [self.maskLayer removeAllAnimations];
        [self startAnimation];
    }
}

- (void)startAnimation
{
    self.maskLayer.frame = CGRectMake( 0, 0, self.blueDishLayer.frame.size.width, self.blueDishLayer.frame.size.height );
    
    [CATransaction begin];
    CABasicAnimation *firstAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
    
    CGPoint toPoint = CGPointZero;
    toPoint.x += self.blueDishLayer.frame.size.width;
    firstAnimation.fromValue = [self.maskLayer valueForKey:@"position"];
    firstAnimation.toValue   = [NSValue valueWithCGPoint:toPoint];
    firstAnimation.duration  = 0.5;
    self.maskLayer.position = toPoint;
    
    [CATransaction setCompletionBlock:^
    {
        [self.maskLayer removeAllAnimations];
        [self repeatAnimation];
    }];
    
    [self.maskLayer addAnimation:firstAnimation forKey:@"first"];
    [CATransaction commit];
}

- (void)repeatAnimation
{
    if( !self.isRefreshing )
    {
        return;
    }
    
    CABasicAnimation *repeatAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
    
    CGPoint startPoint = CGPointZero;
    startPoint.x = -self.blueDishLayer.frame.size.width;
    repeatAnimation.fromValue = [NSValue valueWithCGPoint:startPoint];
    CGPoint endPoint = CGPointZero;
    endPoint.x = self.blueDishLayer.frame.size.width;
    repeatAnimation.toValue = [NSValue valueWithCGPoint:endPoint];
    repeatAnimation.duration = 1;
    repeatAnimation.repeatCount = 1000000;
    self.maskLayer.position = endPoint;
    
    [self.maskLayer addAnimation:repeatAnimation forKey:@"repeat"];
}

- (void)endRefreshing
{
    if( !self.isRefreshing )
    {
        return;
    }
    
    [self.maskLayer removeAllAnimations];
    self.maskLayer.frame = CGRectMake( 0, 0, 0, self.blueDishLayer.frame.size.height );
    self.isRefreshing = NO;
    
    if( self.scrollView )
    {
        [self resetScrollViewInsets:self.scrollView];
    }
    else
    {
        UIView *superView = [self superview];
        
        if( [superView isKindOfClass:[UIScrollView class]] )
        {
            [self resetScrollViewInsets:(UIScrollView *)superView];
        }
    }
}

- (BOOL)isRefreshing
{
    return _isRefreshing;
}

- (void)setLoadingScrollViewInsets:(UIScrollView *)scrollView
{
    UIEdgeInsets loadingInset = scrollView.contentInset;
    loadingInset.top += self.frame.size.height;

    scrollView.contentInset = loadingInset;
    scrollView.contentOffset = CGPointZero;
}

- (void)resetScrollViewInsets:(UIScrollView *)scrollView
{
    UIEdgeInsets loadingInset = scrollView.contentInset;
    loadingInset.top -= self.frame.size.height;

    UIViewAnimationOptions options = UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState;
    
    [UIView animateWithDuration:0.2 delay:0 options:options animations:^
    {
        scrollView.contentInset = loadingInset;
    }
    completion:nil];
}

@end