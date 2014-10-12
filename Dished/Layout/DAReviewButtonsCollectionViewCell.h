//
//  DAReviewButtonsCollectionViewCell.h
//  Dished
//
//  Created by Ryan Khalili on 10/11/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import <UIKit/UIKit.h>


@class DAReviewButtonsCollectionViewCell;

@protocol DAReviewButtonsCollectionViewCellDelegate <NSObject>

@optional
- (void)commentsButtonTappedOnReviewButtonsCollectionViewCell:(DAReviewButtonsCollectionViewCell *)cell;
- (void)yumButtonTappedOnReviewButtonsCollectionViewCell:(DAReviewButtonsCollectionViewCell *)cell;
- (void)moreReviewsButtonTappedOnReviewButtonsCollectionViewCell:(DAReviewButtonsCollectionViewCell *)cell;

@end


@interface DAReviewButtonsCollectionViewCell : UICollectionViewCell

@property (weak ,nonatomic) id<DAReviewButtonsCollectionViewCellDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIButton *yumButton;
@property (weak, nonatomic) IBOutlet UIButton *commentsButton;
@property (weak, nonatomic) IBOutlet UIButton *moreReviewsButton;

@end