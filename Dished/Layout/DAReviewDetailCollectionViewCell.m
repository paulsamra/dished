//
//  DAReviewDetailCommentCollectionViewCell.m
//  Dished
//
//  Created by POST on 9/8/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DAReviewDetailCollectionViewCell.h"


@implementation DAReviewDetailCollectionViewCell

+ (DAReviewDetailCollectionViewCell *)sizingCell
{
    NSString *nibName = NSStringFromClass( [DAReviewDetailCollectionViewCell class] );
    DAReviewDetailCollectionViewCell *sizeCell = [[[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil] lastObject];

    return sizeCell;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.textView.textContainerInset = UIEdgeInsetsZero;
    self.detailTextView.textContainerInset = UIEdgeInsetsZero;
}

- (void)setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    
    self.contentView.frame = bounds;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.iconImageView.hidden = NO;
    self.iconImageView.image = nil;
    self.textView.text = nil;
    self.textView.attributedText = nil;
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