//
//  DAGlobalReviewCollectionViewCell.m
//  Dished
//
//  Created by Ryan Khalili on 9/9/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DAGlobalReviewCollectionViewCell.h"


@implementation DAGlobalReviewCollectionViewCell

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.gradeView.layer.cornerRadius = self.gradeView.frame.size.width / 2;
    self.userImageView.layer.cornerRadius = self.userImageView.frame.size.width / 2;
    
    self.commentTextView.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15];
    self.commentTextView.textContainerInset = UIEdgeInsetsZero;
}

@end