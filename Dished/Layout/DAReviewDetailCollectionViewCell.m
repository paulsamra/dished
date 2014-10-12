//
//  DAReviewDetailCommentCollectionViewCell.m
//  Dished
//
//  Created by POST on 9/8/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DAReviewDetailCollectionViewCell.h"


@implementation DAReviewDetailCollectionViewCell

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.detailTextView.textContainerInset = UIEdgeInsetsZero;
}

- (void)setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    
    self.contentView.frame = bounds;
}

+ (NSDictionary *)textAttributes
{
    return @{ NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:14.0f] };
}

+ (NSDictionary *)linkedTextAttributes;
{
    return @{ NSForegroundColorAttributeName : [UIColor dishedColor],
              NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:14.0f] };
}

@end