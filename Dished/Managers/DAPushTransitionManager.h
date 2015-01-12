//
//  DAPushTransitionManager.h
//  Dished
//
//  Created by Ryan Khalili on 1/7/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DAPushTransitionManager : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic) BOOL pushing;

@end