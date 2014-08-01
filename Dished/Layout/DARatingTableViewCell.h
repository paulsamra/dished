//
//  DARatingCustomTableViewCell.h
//  Dished
//
//  Created by Daryl Stimm on 7/10/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DARatingTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel  *gradeLabel;
@property (weak, nonatomic) IBOutlet UIButton *plusButton;
@property (weak, nonatomic) IBOutlet UIButton *minusButton;

@end