//
//  DAForgotPasswordViewController.m
//  Dished
//
//  Created by Ryan Khalili on 6/12/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DAForgotPasswordViewController.h"


@interface DAForgotPasswordViewController() <UIAlertViewDelegate, UITextFieldDelegate>

@end


@implementation DAForgotPasswordViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (IBAction)submitPhoneNumber
{
    UIAlertView *popup = [[UIAlertView alloc] initWithTitle:@"Verification Code Sent" message:@"You will receive a text message with your verification code. Enter it on the next screen, along with your new password." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [popup show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self performSegueWithIdentifier:@"resetPassword" sender:nil];
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