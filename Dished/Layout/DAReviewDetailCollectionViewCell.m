//
//  DAReviewDetailCommentCollectionViewCell.m
//  Dished
//
//  Created by POST on 9/8/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DAReviewDetailCollectionViewCell.h"


@interface DAReviewDetailCollectionViewCell() <DALinkedTextViewDelegate>

@end


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
    
    self.textView.scrollsToTop = NO;
    self.textView.textContainerInset = UIEdgeInsetsZero;
    self.textView.tapDelegate = self;
    
    self.opaque = YES;
}

- (void)linkedTextView:(DALinkedTextView *)textView tappedOnText:(NSString *)text withLinkedTextType:(eLinkedTextType)textType
{
    if( [self.delegate respondsToSelector:@selector(textViewTappedOnText:withTextType:inCell:)] )
    {
        [self.delegate textViewTappedOnText:text withTextType:textType inCell:self];
    }
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.iconImageView.hidden = NO;
    self.iconImageView.image = nil;
    self.textView.text = nil;
    self.textView.attributedText = nil;
}

@end