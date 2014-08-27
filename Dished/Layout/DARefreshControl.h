//
//  DARefreshControl.h
//  Dished
//
//  Created by Ryan Khalili on 8/24/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DARefreshControl : UIControl

- (id)initWithScrollView:(UIScrollView *)scrollView;

- (void)containingScrollViewDidScroll:(UIScrollView *)scrollView;
- (void)containingScrollViewDidEndDragging:(UIScrollView *)scrollView;

- (void)endRefreshing;

@end