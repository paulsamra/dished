//
//  DATransitionManager.h
//  Dished
//
//  Created by Ryan Khalili on 1/7/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    eTransitionTypeUp,
    eTransitionTypeDown,
    eTransitionTypeLeft,
    eTransitionTypeRight
} eTransitionType;


@interface DAModalTransitionManager : NSObject <UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate>

@property (nonatomic) eTransitionType transitionType;

@end