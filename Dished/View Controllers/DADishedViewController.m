//
//  DADishedViewController.m
//  Dished
//
//  Created by Ryan Khalili on 1/7/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

#import "DADishedViewController.h"


@implementation DADishedViewController

- (void)loadData
{
    return;
}

- (void)dataLoaded
{
    [self hideErrorView];
}

- (void)handleError:(NSError *)error
{
    eErrorType errorType = [DAAPIManager errorTypeForError:error];
    
    switch( errorType )
    {
        case eErrorTypeTimeout:
            [self showErrorViewWithErrorMessageType:eErrorMessageTypeTimeout coverNav:NO];
            [self loadData];
            break;
            
        case eErrorTypeConnection:
            [self showErrorViewWithErrorMessageType:eErrorMessageTypeConnectionFailure coverNav:NO];
            break;
            
        case eErrorTypeRequestCancelled:
            break;
            
        case eErrorTypeUnknown:
        default:
            [self showErrorViewWithErrorMessageType:eErrorMessageTypeUnknownFailure coverNav:NO];
            break;
    }
}


@end