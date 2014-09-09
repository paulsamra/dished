//
//  DAReviewDetailCommentCollectionViewCell.m
//  Dished
//
//  Created by POST on 9/8/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DAReviewDetailCommentCollectionViewCell.h"


@implementation DAReviewDetailCommentCollectionViewCell

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.commentLabel.textContainerInset = UIEdgeInsetsZero;
}

+ (NSDictionary *)textAttributes
{
    return @{ NSForegroundColorAttributeName : [UIColor dishedColor],
              NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:13.0f] };
}

@end