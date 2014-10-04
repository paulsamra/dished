//
//  DAExploreSearchCellTableViewCell.h
//  Dished
//
//  Created by POST on 7/29/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kDishSearchCellID @"dishCell"


@interface DADishTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel     *dishNameLabel;
@property (weak, nonatomic) IBOutlet UILabel     *gradeLabel;
@property (weak, nonatomic) IBOutlet UILabel     *leftNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel     *middleNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel     *rightNumberLabel;
@property (weak, nonatomic) IBOutlet UIButton    *locationButton;
@property (weak, nonatomic) IBOutlet UIImageView *mainImageView;

@property (nonatomic) BOOL isExplore;

@end