//
//  DAGradeGraphCollectionViewCell.m
//  Dished
//
//  Created by POST on 9/8/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DAGradeGraphCollectionViewCell.h"


@implementation DAGradeGraphCollectionViewCell

- (IBAction)touchedArrow:(DAGraphControl *)sender
{
    [CATransaction setAnimationDuration:1.0];
    
    if( sender.percentage == 1.0 )
    {
        sender.percentage = 0.0;
    }
    else
    {
        sender.percentage = 1.0;
    }
}

- (void)setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    
    self.contentView.frame = bounds;
}


@end