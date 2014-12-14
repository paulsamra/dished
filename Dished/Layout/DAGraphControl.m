//
//  DAGraphControl.m
//  Dished
//
//  Created by Daryl Stimm on 8/24/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DAGraphControl.h"


@implementation DAGraphControl

+ (Class)layerClass
{
    return [DAGraphControlLayer class];
}

- (void)showGraphData
{
    ((DAGraphControlLayer *)self.layer).percentage = 1;
}

- (void)hideGraphData
{
    ((DAGraphControlLayer *)self.layer).percentage = 0.1;
}

- (void)setGradeValues:(NSDictionary *)gradeValues
{
    _gradeValues = gradeValues;
    ((DAGraphControlLayer *)self.layer).gradeValues = gradeValues;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if( self = [super initWithCoder:aDecoder] )
    {
        self.layer.needsDisplayOnBoundsChange = YES;
        self.layer.contentsScale = [UIScreen mainScreen].scale;
    }
    
    return self;
}

@end