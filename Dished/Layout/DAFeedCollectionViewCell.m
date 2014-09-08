//
//  DAFeedCollectionViewCell.m
//  Dished
//
//  Created by Ryan Khalili on 8/20/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DAFeedCollectionViewCell.h"


@implementation DAFeedCollectionViewCell

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.userImageView.layer.cornerRadius = self.userImageView.frame.size.width / 2;
    self.userImageView.layer.masksToBounds = YES;
    self.userImageView.clipsToBounds = YES;
    
    self.titleButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.commentsButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    
    [self.commentsButton addTarget:self action:@selector(commentButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.titleButton    addTarget:self action:@selector(titleButtonTapped)   forControlEvents:UIControlEventTouchUpInside];
    [self.yumButton      addTarget:self action:@selector(yumButtonTapped)     forControlEvents:UIControlEventTouchUpInside];
}

- (void)commentButtonTapped
{
    if( [self.delegate respondsToSelector:@selector(commentButtonTappedOnFeedCollectionViewCell:)] )
    {
        [self.delegate commentButtonTappedOnFeedCollectionViewCell:self];
    }
}

- (void)titleButtonTapped
{
    if( [self.delegate respondsToSelector:@selector(titleButtonTappedOnFeedCollectionViewCell:)] )
    {
        [self.delegate titleButtonTappedOnFeedCollectionViewCell:self];
    }
}

- (void)yumButtonTapped
{
    if( [self.delegate respondsToSelector:@selector(yumButtonTappedOnFeedCollectionViewCell:)] )
    {
        [self.delegate yumButtonTappedOnFeedCollectionViewCell:self];
    }
}

@end