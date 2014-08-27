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
}

@end