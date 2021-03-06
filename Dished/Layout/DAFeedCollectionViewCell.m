//
//  DAFeedCollectionViewCell.m
//  Dished
//
//  Created by Ryan Khalili on 8/20/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DAFeedCollectionViewCell.h"


@interface DAFeedCollectionViewCell()

@property (strong, nonatomic) UIImageView *heartImageView;

@end


@implementation DAFeedCollectionViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.userImageView.layer.cornerRadius = self.userImageView.frame.size.width / 2;
    self.userImageView.layer.masksToBounds = YES;
    
    [self.locationButton addTarget:self action:@selector(locationButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.creatorButton  addTarget:self action:@selector(creatorButtonTapped)  forControlEvents:UIControlEventTouchUpInside];
    
    self.dishImageView.clipsToBounds = YES;
    
    self.dishImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dishImageDoubleTapped)];
    doubleTapGesture.numberOfTapsRequired = 2;
    [self.dishImageView addGestureRecognizer:doubleTapGesture];
    
    self.userImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc ] initWithTarget:self action:@selector(userImageTapped)];
    tapGesture.numberOfTapsRequired = 1;
    [self.userImageView addGestureRecognizer:tapGesture];
    
    self.opaque = YES;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    if( self )
    {
        self.userImageView.image = nil;
        self.dishImageView.image = nil;
        [self.locationButton setTitle:nil forState:UIControlStateNormal];
        [self.creatorButton  setImage:nil forState:UIControlStateNormal];
        self.timeLabel.text = nil;
        self.tag = -1;
    }
}

- (void)dishImageDoubleTapped
{
    if( [self.delegate respondsToSelector:@selector(imageDoubleTappedOnFeedCollectionViewCell:)] )
    {
        [self.delegate imageDoubleTappedOnFeedCollectionViewCell:self];
    }
}

- (void)locationButtonTapped
{
    if( [self.delegate respondsToSelector:@selector(locationButtonTappedOnFeedCollectionViewCell:)] )
    {
        [self.delegate locationButtonTappedOnFeedCollectionViewCell:self];
    }
}

- (void)creatorButtonTapped
{
    if( [self.delegate respondsToSelector:@selector(creatorButtonTappedOnFeedCollectionViewCell:)] )
    {
        [self.delegate creatorButtonTappedOnFeedCollectionViewCell:self];
    }
}

- (void)userImageTapped
{
    if( [self.delegate respondsToSelector:@selector(userImageTappedOnFeedCollectionViewCell:)] )
    {
        [self.delegate userImageTappedOnFeedCollectionViewCell:self];
    }
}

@end