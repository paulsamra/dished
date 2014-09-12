//
//  DAProgressView.m
//  Dished
//
//  Created by Ryan Khalili on 9/11/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DAProgressView.h"
#import "DADishLayer.h"


@implementation DAProgressView

+ (Class)layerClass
{
    return [DADishLayer class];
}

- (void)setPercentage:(CGFloat)percentage
{
    _percentage = percentage;
    ((DADishLayer *)self.layer).blueDishWidthPercentage = percentage;
}

- (id)init
{
    if( self = [super init] )
    {
        self.layer.contentsScale = [UIScreen mainScreen].scale;
        
        CGRect currFrame = self.frame;
        currFrame.size = [DADishLayer dishSize];
        self.frame = currFrame;
        
        [self.layer setNeedsDisplay];
    }
    
    return self;
}

@end