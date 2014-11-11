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
    
    self.textView.scrollsToTop = NO;
    self.textView.textContainerInset = UIEdgeInsetsZero;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(textViewTapped:)];
    tapGesture.numberOfTapsRequired = 1;
    [self.textView addGestureRecognizer:tapGesture];
}

- (void)textViewTapped:(UITapGestureRecognizer *)recognizer
{
    UITextView *textView = (UITextView *)recognizer.view;
    
    NSLayoutManager *layoutManager = textView.layoutManager;
    CGPoint location = [recognizer locationInView:textView];
    location.x -= textView.textContainerInset.left;
    location.y -= textView.textContainerInset.top;
    
    NSUInteger characterIndex = [layoutManager characterIndexForPoint:location
                                                      inTextContainer:textView.textContainer
                             fractionOfDistanceBetweenInsertionPoints:nil];
    
    if( characterIndex < textView.textStorage.length )
    {
        if( [self.delegate respondsToSelector:@selector(textViewTappedAtCharacterIndex:inCell:)] )
        {
            [self.delegate textViewTappedAtCharacterIndex:characterIndex inCell:self];
        }
    }
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
    return @{ NSFontAttributeName : [UIFont fontWithName:kHelveticaNeueLightFont size:14.0f] };
}

+ (NSDictionary *)linkedTextAttributes;
{
    return @{ NSForegroundColorAttributeName : [UIColor dishedColor],
              NSFontAttributeName : [UIFont fontWithName:kHelveticaNeueLightFont size:14.0f] };
}

@end