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
    self.userImageView.layer.masksToBounds = YES;
    
    self.commentTextView.textContainerInset = UIEdgeInsetsZero;
    
    [self.usernameButton addTarget:self action:@selector(usernameButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    
    UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(commentTapped)];
    doubleTapGesture.numberOfTapsRequired = 1;
    [self.commentTextView addGestureRecognizer:doubleTapGesture];
}

- (void)setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    
    self.contentView.frame = bounds;
}

- (void)usernameButtonTapped
{
    if( [self.delegate respondsToSelector:@selector(usernameButtonTappedOnGlobalReviewCollectionViewCell:)] )
    {
        [self.delegate usernameButtonTappedOnGlobalReviewCollectionViewCell:self];
    }
}

- (void)commentTapped
{
    if( [self.delegate respondsToSelector:@selector(commentTappedOnGlobalReviewCollectionViewCell:)] )
    {
        [self.delegate commentTappedOnGlobalReviewCollectionViewCell:self];
    }
}

+ (NSDictionary *)commentTextAttributes
{
    return @{ NSFontAttributeName : [UIFont fontWithName:kHelveticaNeueLightFont size:15] };
}

@end