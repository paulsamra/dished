//
//  DAGradeGraphCollectionViewCell.h
//  Dished
//
//  Created by POST on 9/8/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DAGraphControl.h"

@class DAGradeGraphCollectionViewCell;


@protocol DAGradeGraphCollectionViewCellDelegate <NSObject>

@optional
- (void)utilityButtonTappedOnGradeGraphCollectionViewCell:(DAGradeGraphCollectionViewCell *)cell;

@end


@interface DAGradeGraphCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet DAGraphControl *control;

- (IBAction)touchedArrow:(DAGraphControl *)sender;

@end