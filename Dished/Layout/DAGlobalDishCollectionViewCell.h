//
//  DAGlobalDishCollectionViewCell.h
//  Dished
//
//  Created by Ryan Khalili on 9/11/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DAGlobalDishCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel      *gradeLabel;
@property (weak, nonatomic) IBOutlet UILabel      *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel      *priceLabel;
@property (weak, nonatomic) IBOutlet UIButton     *yumsNumberButton;
@property (weak, nonatomic) IBOutlet UIButton     *locationButton;
@property (weak, nonatomic) IBOutlet UITextView   *descriptionTextView;
@property (weak, nonatomic) IBOutlet UIScrollView *pagedImageView;
@property (weak, nonatomic) IBOutlet UIButton *photosNumberButton;

+ (NSDictionary *)descriptionTextAttributes;

- (void)setPagedImages:(NSArray *)images;

@end