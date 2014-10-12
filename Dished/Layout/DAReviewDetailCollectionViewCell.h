//
//  DAReviewDetailCommentCollectionViewCell.h
//  Dished
//
//  Created by POST on 9/8/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DAReviewDetailCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UITextView  *textView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITextView  *detailTextView;

+ (DAReviewDetailCollectionViewCell *)sizingCell;
+ (NSDictionary *)linkedTextAttributes;
+ (NSDictionary *)textAttributes;

@end