//
//  DAExploreSearchCellTableViewCell.m
//  Dished
//
//  Created by POST on 7/29/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DADishTableViewCell.h"


@implementation DADishTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self.locationButton addTarget:self action:@selector(locationButtonTapped) forControlEvents:UIControlEventTouchUpInside];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
        
    if( self.isExplore )
    {
        self.rightNumberLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dish_result_influencers"]];
        self.middleNumberLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dish_result_friends"]];
        self.leftNumberLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dish_result_reviews"]];
    }
    else
    {
        self.rightNumberLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dish_result_reviews"]];
        self.middleNumberLabel.hidden = YES;
        self.leftNumberLabel.hidden = YES;
    }
}

- (void)locationButtonTapped
{
    if( [self.delegate respondsToSelector:@selector(locationButtonTappedOnDishTableViewCell:)] )
    {
        [self.delegate locationButtonTappedOnDishTableViewCell:self];
    }
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.rightNumberLabel.text = @"";
    self.leftNumberLabel.text = @"";
    self.middleNumberLabel.text = @"";
    
    self.dishNameLabel.text = @"";
    self.gradeLabel.text = @"";
    self.mainImageView.image = nil;
    
    [self.locationButton setTitle:@"" forState:UIControlStateNormal];
}

@end