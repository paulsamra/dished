//
//  UIViewController+Error.m
//  Dished
//
//  Created by Ryan Khalili on 1/7/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

#import "DADishedViewController+Error.h"

@implementation DADishedViewController (Error)

- (UIView *)errorViewWithType:(eErrorMessageType)type
{
    CGFloat y = self.navigationController ? 0 : -40;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake( 0, y, self.view.frame.size.width, 70 )];
    view.tag = 1234;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake( 0, 0, view.frame.size.width, view.frame.size.height / 2 )];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont fontWithName:kHelveticaNeueLightFont size:17.0f];
    [view addSubview:label];
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.frame = CGRectMake( view.frame.size.width / 2 - spinner.frame.size.width / 2, view.frame.size.height / 2 + 5, spinner.frame.size.width, spinner.frame.size.width );
    [view addSubview:spinner];
    
    switch( type )
    {
        case eErrorMessageTypeTimeout:
            view.backgroundColor = [UIColor yellowGradeColor];
            label.text = @"Trying to connect to network...";
            [spinner startAnimating];
            break;
            
        case eErrorMessageTypeConnectionFailure:
            label.text = @"Failed to connect to network.";
            view.backgroundColor = [UIColor redGradeColor];
            label.textColor = [UIColor whiteColor];
            view.frame = CGRectMake( 0, y, view.frame.size.width, 40 );
            break;
            
        case eErrorMessageTypeUnknownFailure:
            label.text = @"Something went wrong! Tap to reload.";
            view.backgroundColor = [UIColor redGradeColor];
            label.textColor = [UIColor whiteColor];
            view.frame = CGRectMake( 0, y, view.frame.size.width, 35 );
            break;
    }
    
    return view;
}

- (void)showErrorViewWithErrorMessageType:(eErrorMessageType)type
{
    [self hideErrorView];
    
    UIView *errorView = [self errorViewWithType:type];
    
    [self.view addSubview:errorView];
    
    CGRect newFrame = errorView.frame;
    CGFloat statusBarHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
    newFrame.origin.y = self.navigationController ? self.navigationController.navigationBar.frame.size.height + statusBarHeight : 0;
    
    [UIView animateWithDuration:0.3 animations:^
    {
        errorView.frame = newFrame;
    }];
}

- (void)hideErrorView
{
    UIView *errorView = [self.view viewWithTag:1234];
    
    if( !errorView )
    {
        return;
    }
    
    CGRect currentFrame = errorView.frame;
    currentFrame.origin.y = -currentFrame.size.height;
    
    [UIView animateWithDuration:0.3 animations:^
    {
        errorView.frame = currentFrame;
    }
    completion:^( BOOL finished )
    {
        [errorView removeFromSuperview];
    }];
}

- (void)handleError:(NSError *)error
{
    eErrorType errorType = [DAAPIManager errorTypeForError:error];
    
    switch( errorType )
    {
        case eErrorTypeTimeout:
            [self showErrorViewWithErrorMessageType:eErrorMessageTypeTimeout];
            [self loadData];
            break;
            
        case eErrorTypeConnection:
            [self showErrorViewWithErrorMessageType:eErrorMessageTypeConnectionFailure];
            break;
            
        case eErrorTypeRequestCancelled:
            break;
            
        case eErrorTypeUnknown:
        default:
            [self showErrorViewWithErrorMessageType:eErrorMessageTypeUnknownFailure];
            break;
    }
}

@end