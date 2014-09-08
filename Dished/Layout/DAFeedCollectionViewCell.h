//
//  DAFeedCollectionViewCell.h
//  Dished
//
//  Created by Ryan Khalili on 8/20/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DAFeedCollectionViewCell;


@protocol DAFeedCollectionViewCellDelegate <NSObject>

- (void)commentButtonTappedOnFeedCollectionViewCell:(DAFeedCollectionViewCell *)cell;
- (void)titleButtonTappedOnFeedCollectionViewCell:(DAFeedCollectionViewCell *)cell;
- (void)imageDoubleTappedOnFeedCollectionViewCell:(DAFeedCollectionViewCell *)cell;
- (void)yumButtonTappedOnFeedCollectionViewCell:(DAFeedCollectionViewCell *)cell;
- (void)imageTappedOnFeedCollectionViewCell:(DAFeedCollectionViewCell *)cell;

@end


@interface DAFeedCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel     *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel     *gradeLabel;
@property (weak, nonatomic) IBOutlet UIButton    *titleButton;
@property (weak, nonatomic) IBOutlet UIButton    *creatorButton;
@property (weak, nonatomic) IBOutlet UIButton    *locationButton;
@property (weak, nonatomic) IBOutlet UIButton    *commentsButton;
@property (weak, nonatomic) IBOutlet UIButton    *yumButton;
@property (weak, nonatomic) IBOutlet UIImageView *dishImageView;
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;

@property (weak, nonatomic) id<DAFeedCollectionViewCellDelegate> delegate;

@end