//
//  UIViewController+Error.h
//  Dished
//
//  Created by Ryan Khalili on 1/7/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DADishedViewController.h"

typedef enum
{
    eErrorMessageTypeTimeout,
    eErrorMessageTypeConnectionFailure,
    eErrorMessageTypeUnknownFailure
} eErrorMessageType;

@interface DADishedViewController (Error)

- (void)showErrorViewWithErrorMessageType:(eErrorMessageType)type;
- (void)hideErrorView;
- (void)handleError:(NSError *)error;

@end