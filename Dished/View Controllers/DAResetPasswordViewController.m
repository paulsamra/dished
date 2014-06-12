//
//  DAResetPasswordViewController.m
//  Dished
//
//  Created by Ryan Khalili on 6/12/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DAResetPasswordViewController.h"


@interface DAResetPasswordViewController() <UITextFieldDelegate>

@end


@implementation DAResetPasswordViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationItem setHidesBackButton:YES];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self animateTextField:textField up:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self animateTextField:textField up:NO];
}

- (void)animateTextField:(UITextField*)textField up:(BOOL)up
{
    const int movementDistance = -30;
    const float movementDuration = 0.3f;
    
    int movement = up ? movementDistance : -movementDistance;
    
    [UIView beginAnimations:@"animateTextField" context:nil];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:movementDuration];
    self.view.frame = CGRectOffset( self.view.frame, 0, movement );
    [UIView commitAnimations];
}

@end
