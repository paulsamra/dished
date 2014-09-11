//
//  DAGradeGraphCollectionViewCell.h
//  Dished
//
//  Created by POST on 9/8/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DAGraphControl.h"


@interface DAGradeGraphCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet DAGraphControl *control;

- (IBAction)touchedArrow:(DAGraphControl *)sender;

@end