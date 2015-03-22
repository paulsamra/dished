//
//  UIImageView+DishProgress.h
//  Dished
//
//  Created by Ryan Khalili on 9/11/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"
#import "SDImageCache.h"


@interface UIImageView (DishProgress)

@property (strong, nonatomic) DAProgressView *progressView;

- (void)setImageUsingProgressViewWithURL:(NSURL *)url;
- (void)setImageUsingProgressViewWithURL:(NSURL *)url  completion:(SDWebImageCompletionBlock)completion;
- (void)loadImageUsingProgressViewWithURL:(NSURL *)url completion:(SDWebImageCompletionBlock)completion;

- (void)removeProgressView;

@end