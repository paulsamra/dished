//
//  DAGlobalReviewCollectionViewCell.h
//  Dished
//
//  Created by Ryan Khalili on 9/9/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DAGlobalReviewCollectionViewCell;


@protocol DAGlobalReviewCollectionViewCellDelegate <NSObject>

@optional
- (void)usernameButtonTappedOnGlobalReviewCollectionViewCell:(DAGlobalReviewCollectionViewCell *)cell;
- (void)commentTappedOnGlobalReviewCollectionViewCell:(DAGlobalReviewCollectionViewCell *)cell;

@end


@interface DAGlobalReviewCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIView      *gradeView;
@property (weak, nonatomic) IBOutlet UILabel     *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel     *gradeLabel;
@property (weak, nonatomic) IBOutlet UIButton    *usernameButton;
@property (weak, nonatomic) IBOutlet UITextView  *commentTextView;
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;

@property (weak, nonatomic) id<DAGlobalReviewCollectionViewCellDelegate> delegate;


+ (NSDictionary *)commentTextAttributes;

@end