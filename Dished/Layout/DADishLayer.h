//
//  DADishLayer.h
//  Dished
//
//  Created by Ryan Khalili on 9/11/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>


@interface DADishLayer : CALayer

@property (nonatomic) CGFloat blueDishWidthPercentage;
@property (nonatomic) CGFloat blueDishOffsetPercentage;

+ (CGSize)dishSize;

@end