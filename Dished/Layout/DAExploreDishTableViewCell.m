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
    
    self.influencersNumberLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"explore_result_influencer"]];
    self.friendsNumberLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"explore_result_dishes_plate"]];
    self.reviewsNumberLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"explore_result_comment"]];
}

@end