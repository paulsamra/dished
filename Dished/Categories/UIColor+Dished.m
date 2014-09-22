//
//  UIColor+Dished.m
//  Dished
//
//  Created by Ryan Khalili on 8/22/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "UIColor+Dished.h"


@implementation UIColor(Dished)

+ (UIColor *)dishedColor
{
    return [UIColor colorWithRed:0 green:0.55 blue:0.9 alpha:1];
}

+ (UIColor *)commentButtonTextColor
{
    return [UIColor colorWithRed:0.4 green:0.41 blue:0.47 alpha:1];
}

+ (UIColor *)greenGradeColor
{
    return [UIColor colorWithRed:0 green:0.83 blue:0.14 alpha:1];
}

+ (UIColor *)yellowGradeColor
{
    return [UIColor colorWithRed:0.96 green:0.78 blue:0 alpha:1];
}

+ (UIColor *)redGradeColor
{
    return [UIColor colorWithRed:0.92 green:0 blue:0 alpha:1];
}

+ (UIColor *)unviewedNewsColor
{
    return [UIColor colorWithRed:1 green:0.93 blue:0.84 alpha:1];
}

@end