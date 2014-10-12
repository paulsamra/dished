//
//  DAReviewDetailCommentCollectionViewCell.h
//  Dished
//
//  Created by POST on 9/8/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import <UIKit/UIKit.h>


@class DAReviewDetailCollectionViewCell;

@protocol DAReviewDetailCollectionViewCellDelegate <NSObject>

@optional
- (void)linkedTextTappedWithAttributes:(NSDictionary *)attributes;

@end


@interface DAReviewDetailCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) id<DAReviewDetailCollectionViewCellDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UITextView  *textView;

+ (DAReviewDetailCollectionViewCell *)sizingCell;
+ (NSDictionary *)linkedTextAttributes;
+ (NSDictionary *)textAttributes;

@end