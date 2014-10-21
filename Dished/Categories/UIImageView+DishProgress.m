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
        self.progressView = [[DAProgressView alloc] init];
        [self updateProgressViewFrame];
        self.progressView.backgroundColor = [UIColor clearColor];
    }
    
    dispatch_async( dispatch_get_main_queue(), ^
    {
        [self addSubview:self.progressView];
        self.progressView.percentage = 0;
    });
}

- (void)updateProgressViewFrame
{
    if( self.progressView )
    {
        CGRect progressViewBounds = self.progressView.bounds;
        
        float x = ( self.frame.size.width  - progressViewBounds.size.width )  / 2;
        float y = ( self.frame.size.height - progressViewBounds.size.height ) / 2;
        
        self.progressView.frame = CGRectMake( x, y, progressViewBounds.size.width, progressViewBounds.size.height);
    }
}

- (void)removeProgressView
{
    if( self.progressView )
    {
        [self.progressView removeFromSuperview];
        self.progressView = nil;
    }
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    [self updateProgressViewFrame];
}

- (void)setImageUsingProgressViewWithURL:(NSURL *)url
{
    [self setImageUsingProgressViewWithURL:url placeholderImage:nil options:0 completion:nil];
}

- (void)setImageUsingProgressViewWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder
{
    [self setImageUsingProgressViewWithURL:url placeholderImage:placeholder options:0 completion:nil];
}

- (void)setImageUsingProgressViewWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder completion:(SDWebImageCompletionBlock)completion
{
    [self setImageUsingProgressViewWithURL:url placeholderImage:nil options:0 completion:completion];
}

- (void)setImageUsingProgressViewWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options completion:(SDWebImageCompletionBlock)completion
{
    [self addProgressView];
    
    __weak typeof(self) weakSelf = self;
    
//    [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:url options:options
//    progress:^( NSInteger receivedSize, NSInteger expectedSize )
//    {
//        CGFloat percentage = (CGFloat)receivedSize / (CGFloat)expectedSize;
//        weakSelf.progressView.percentage = percentage;
//    }
//    completed:^( UIImage *image, NSData *data, NSError *error, BOOL finished )
//    {
//        if( finished && completion )
//        {
//            completion( image, error, url );
//        }
//        
//        [weakSelf removeProgressView];
//    }];
    
    [self sd_setImageWithURL:url placeholderImage:placeholder options:options
    progress:^( NSInteger receivedSize, NSInteger expectedSize )
    {
        CGFloat percentage = (CGFloat)receivedSize / (CGFloat)expectedSize;
        weakSelf.progressView.percentage = percentage;
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

@end