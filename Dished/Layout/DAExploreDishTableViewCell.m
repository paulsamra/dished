//
//  DAExploreSearchCellTableViewCell.m
//  Dished
//
//  Created by POST on 7/29/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DAExploreDishTableViewCell.h"


@implementation DAExploreDishTableViewCell

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.influencersNumberLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dish_result_influencers"]];
    self.friendsNumberLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dish_result_friends"]];
    self.reviewsNumberLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dish_result_reviews"]];
}

@end