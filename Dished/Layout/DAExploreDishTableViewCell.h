//
//  DAExploreSearchCellTableViewCell.h
//  Dished
//
//  Created by POST on 7/29/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kDishSearchCellID @"dishCell"


@interface DAExploreDishTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel     *dishNameLabel;
@property (weak, nonatomic) IBOutlet UILabel     *locationNameLabel;
@property (weak, nonatomic) IBOutlet UILabel     *gradeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *mainImageView;
@property (weak, nonatomic) IBOutlet UILabel     *reviewsNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel     *friendsNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel     *influencersNumberLabel;

@end