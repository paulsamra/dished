//
//  DAGraphControlLayer.h
//  Dished
//
//  Created by Daryl Stimm on 8/24/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>


@interface DAGraphControlLayer : CALayer

@property (nonatomic) CGFloat percentage;
@property (strong, nonatomic) NSDictionary *gradeValues;

@end