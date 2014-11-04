//
//  DAGradeGraphCollectionViewCell.m
//  Dished
//
//  Created by POST on 9/8/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DAGradeGraphCollectionViewCell.h"


@implementation DAGradeGraphCollectionViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.opaque = YES;
        
    [self.gradeGraph    addTarget:self action:@selector(touchedGraph:event:) forControlEvents:UIControlEventTouchUpInside];
    [self.utilityButton addTarget:self action:@selector(utilityButtonTapped) forControlEvents:UIControlEventTouchUpInside];
}

- (void)touchedGraph:(DAGraphControl *)sender event:(UIEvent *)event
{
    
}
     
- (void)utilityButtonTapped
{
    if( [self.delegate respondsToSelector:@selector(utilityButtonTappedOnGradeGraphCollectionViewCell:)] )
    {
        [self.delegate utilityButtonTappedOnGradeGraphCollectionViewCell:self];
    }
}

- (void)setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    
    self.contentView.frame = bounds;
}

@end