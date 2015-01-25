//
//  UIViewController+Error.h
//  Dished
//
//  Created by Ryan Khalili on 1/7/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
    eErrorMessageTypeTimeout,
    eErrorMessageTypeConnectionFailure,
    eErrorMessageTypeUnknownFailure
} eErrorMessageType;

@interface UIViewController (Error)

- (void)showErrorViewWithErrorMessageType:(eErrorMessageType)type coverNav:(BOOL)coverNav;
- (void)hideErrorView;

@end