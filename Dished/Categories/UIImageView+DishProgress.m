//
//  UIImageView+DishProgress.m
//  Dished
//
//  Created by Ryan Khalili on 9/11/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "UIImageView+DishProgress.h"
#import <objc/runtime.h>

static char TAG_ACTIVITY_INDICATOR;


@implementation UIImageView (DishProgress)

@dynamic progressView;

- (DAProgressView *)progressView
{
    return (DAProgressView *)objc_getAssociatedObject(self, &TAG_ACTIVITY_INDICATOR);
}

- (void)setProgressView:(DAProgressView *)progressView
{
    objc_setAssociatedObject(self, &TAG_ACTIVITY_INDICATOR, progressView, OBJC_ASSOCIATION_RETAIN);
}

- (void)addProgressView
{
    if( !self.progressView )
    {
        CGRect frame = CGRectMake( 0, 0, self.frame.size.width, self.frame.size.height );
        self.progressView = [[DAProgressView alloc] initWithFrame:frame];
        self.progressView.backgroundColor = [UIColor clearColor];
    }
    
    dispatch_async( dispatch_get_main_queue(), ^
    {
        [self addSubview:self.progressView];
    });
}

- (void)removeProgressView
{
    if( self.progressView )
    {
        [self.progressView removeFromSuperview];
        self.progressView = nil;
    }
}

- (void)setImageUsingProgressViewWithURL:(NSURL *)url
{
    [self setImageUsingProgressViewWithURL:url completion:nil];
}

- (void)setImageUsingProgressViewWithURL:(NSURL *)url completion:(SDWebImageCompletionBlock)completion
{
    [self addProgressView];
    
    __weak typeof(self) weakSelf = self;
    
    [self sd_setImageWithURL:url placeholderImage:nil options:0
    progress:^( NSInteger receivedSize, NSInteger expectedSize )
    {
        CGFloat percentage = (CGFloat)receivedSize / (CGFloat)expectedSize;
        [weakSelf.progressView animateToPercentage:percentage];
    }
    completed:^( UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL )
    {
        if( completion )
        {
            completion( image, error, cacheType, imageURL );
        }
         
        [weakSelf removeProgressView];
    }];
}

- (void)loadImageUsingProgressViewWithURL:(NSURL *)url completion:(SDWebImageCompletionBlock)completion
{
    [self addProgressView];
    
    __weak typeof(self) weakSelf = self;
    
    [[SDWebImageManager sharedManager] downloadImageWithURL:url options:0
    progress:^( NSInteger receivedSize, NSInteger expectedSize )
    {
        CGFloat percentage = (CGFloat)receivedSize / (CGFloat)expectedSize;
        [weakSelf.progressView animateToPercentage:percentage];
    }
    completed:^( UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL )
    {        
        if( finished && completion )
        {
            completion( image, error, cacheType, imageURL );
        }
        
        [weakSelf removeProgressView];
    }];
}

@end