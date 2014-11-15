//
//  DAFeedHeaderCollectionReusableView.m
//  Dished
//
//  Created by Ryan Khalili on 9/15/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DAFeedHeaderCollectionReusableView.h"


@implementation DAFeedHeaderCollectionReusableView

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.titleButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.titleButton.titleLabel.minimumScaleFactor = 0.75;
    
    [self.titleButton addTarget:self action:@selector(titleButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    
    self.opaque = YES;
}

- (void)titleButtonTapped
{
    if( [self.delegate respondsToSelector:@selector(titleButtonTappedOnFeedHeaderCollectionReusableView:)] )
    {
        [self.delegate titleButtonTappedOnFeedHeaderCollectionReusableView:self];
    }
}

@end