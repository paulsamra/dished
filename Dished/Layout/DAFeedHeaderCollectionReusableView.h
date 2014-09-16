//
//  DAFeedHeaderCollectionReusableView.h
//  Dished
//
//  Created by Ryan Khalili on 9/15/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DAFeedHeaderCollectionReusableView;


@protocol DAFeedHeaderCollectionReusableViewDelegate <NSObject>

@optional
- (void)titleButtonTappedOnFeedHeaderCollectionReusableView:(DAFeedHeaderCollectionReusableView *)header;

@end


@interface DAFeedHeaderCollectionReusableView : UICollectionReusableView

@property (weak,   nonatomic) IBOutlet UIButton *titleButton;
@property (weak,   nonatomic) IBOutlet UILabel  *timeLabel;
@property (strong, nonatomic) NSIndexPath       *indexPath;

@property (weak, nonatomic) id<DAFeedHeaderCollectionReusableViewDelegate> delegate;

@end