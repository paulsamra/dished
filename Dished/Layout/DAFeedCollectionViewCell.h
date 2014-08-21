//
//  DAFeedCollectionViewCell.h
//  Dished
//
//  Created by Ryan Khalili on 8/20/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import <UIKit/UIKit.h>


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

@end