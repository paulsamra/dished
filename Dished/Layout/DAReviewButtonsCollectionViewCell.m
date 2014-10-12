//
//  DAReviewButtonsCollectionViewCell.m
//  Dished
//
//  Created by Ryan Khalili on 10/11/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DAReviewButtonsCollectionViewCell.h"


@implementation DAReviewButtonsCollectionViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.yumButton.layer.cornerRadius         = 3;
    self.commentsButton.layer.cornerRadius    = 3;
    self.moreReviewsButton.layer.cornerRadius = 3;

    self.yumButton.layer.masksToBounds         = YES;
    self.commentsButton.layer.masksToBounds    = YES;
    self.moreReviewsButton.layer.masksToBounds = YES;
    
    [self.yumButton addTarget:self action:@selector(yumButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.commentsButton addTarget:self action:@selector(commentsButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.moreReviewsButton addTarget:self action:@selector(moreReviewsButtonTapped) forControlEvents:UIControlEventTouchUpInside];
}

- (void)yumButtonTapped
{
    if( [self.delegate respondsToSelector:@selector(yumButtonTappedOnReviewButtonsCollectionViewCell:)] )
    {
        [self.delegate yumButtonTappedOnReviewButtonsCollectionViewCell:self];
    }
}

- (void)commentsButtonTapped
{
    if( [self.delegate respondsToSelector:@selector(commentsButtonTappedOnReviewButtonsCollectionViewCell:)] )
    {
        [self.delegate commentsButtonTappedOnReviewButtonsCollectionViewCell:self];
    }
}

- (void)moreReviewsButtonTapped
{
    if( [self.delegate respondsToSelector:@selector(moreReviewsButtonTappedOnReviewButtonsCollectionViewCell:)] )
    {
        [self.delegate moreReviewsButtonTappedOnReviewButtonsCollectionViewCell:self];
    }
}

@end