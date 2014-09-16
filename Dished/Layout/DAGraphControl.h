//
//  DAGraphControl.h
//  Dished
//
//  Created by Daryl Stimm on 8/24/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DAGraphControlLayer.h"


@interface DAGraphControl : UIControl

@property (nonatomic) CGFloat percentage;
@property (strong, nonatomic) NSDictionary *gradeValues;

@end