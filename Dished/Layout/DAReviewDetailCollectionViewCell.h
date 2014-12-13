//
//  DAReviewDetailCommentCollectionViewCell.h
//  Dished
//
//  Created by POST on 9/8/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DALinkedTextView.h"


@class DAReviewDetailCollectionViewCell;

@protocol DAReviewDetailCollectionViewCellDelegate <NSObject>

@optional
- (void)textViewTappedOnText:(NSString *)text
                      withTextType:(eLinkedTextType)textType
                            inCell:(DAReviewDetailCollectionViewCell *)cell;

@end


@interface DAReviewDetailCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) id<DAReviewDetailCollectionViewCellDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIImageView      *iconImageView;
@property (weak, nonatomic) IBOutlet DALinkedTextView *textView;

+ (DAReviewDetailCollectionViewCell *)sizingCell;

@end