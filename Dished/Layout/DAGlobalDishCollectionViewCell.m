//
//  DAGlobalDishCollectionViewCell.m
//  Dished
//
//  Created by Ryan Khalili on 9/11/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DAGlobalDishCollectionViewCell.h"
#import "UIImageView+DishProgress.h"


@interface DAGlobalDishCollectionViewCell()

@property (strong, nonatomic) NSArray        *images;
@property (strong, nonatomic) NSMutableArray *scrollViewImageViews;

@end


@implementation DAGlobalDishCollectionViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self.locationButton addTarget:self action:@selector(locationButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.addReviewButton addTarget:self action:@selector(addReviewTapped) forControlEvents:UIControlEventTouchUpInside];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.descriptionTextView.textContainerInset = UIEdgeInsetsZero;
}

- (void)setPagedImages:(NSArray *)images
{
    _images = images;
    
    [self updateScrollViewImages];
}

- (void)updateScrollViewImages
{
    if( !self.scrollViewImageViews )
    {
        self.scrollViewImageViews = [NSMutableArray array];
    }
    
    for( UIImageView *imageView in self.scrollViewImageViews )
    {
        [imageView removeFromSuperview];
    }
    
    [self.scrollViewImageViews removeAllObjects];
    
    for( int i = 0; i < self.images.count; i++ )
    {
        CGRect frame = CGRectZero;
        frame.origin.x = self.frame.size.width * i;
        frame.origin.y = 0;
        frame.size.height = self.pagedImageView.frame.size.height;
        frame.size.width = self.frame.size.width;
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.layer.masksToBounds = YES;
        imageView.clipsToBounds = YES;
        [imageView setImageUsingProgressViewWithURL:self.images[i]];
        [self.pagedImageView addSubview:imageView];
        [self.scrollViewImageViews addObject:imageView];
    }
    
    self.pagedImageView.contentSize = CGSizeMake( self.frame.size.width * self.images.count, self.pagedImageView.frame.size.height );
}

- (void)setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    
    self.contentView.frame = bounds;
}

+ (NSDictionary *)descriptionTextAttributes
{
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16];
    UIColor *color = [UIColor colorWithRed:0.4 green:0.43 blue:0.47 alpha:1];
    
    return @{ NSFontAttributeName : font, NSForegroundColorAttributeName : color };
}

- (void)locationButtonTapped
{
    if( [self.delegate respondsToSelector:@selector(locationButtonTappedOnGlobalDishCollectionViewCell:)] )
    {
        [self.delegate locationButtonTappedOnGlobalDishCollectionViewCell:self];
    }
}

- (void)addReviewTapped
{
    if( [self.delegate respondsToSelector:@selector(addReviewButtonTappedOnGlobalDishCollectionViewCell:)] )
    {
        [self.delegate addReviewButtonTappedOnGlobalDishCollectionViewCell:self];
    }
}

@end