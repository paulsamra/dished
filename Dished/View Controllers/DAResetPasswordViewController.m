//
//  DAResetPasswordViewController.m
//  Dished
//
//  Created by Ryan Khalili on 6/12/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DAResetPasswordViewController.h"
#import "MRProgress.h"


@interface DAResetPasswordViewController() <UITextFieldDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) UIAlertView *invalidPinAlert;
@property (strong, nonatomic) UIAlertView *successAlert;
@property (strong, nonatomic) UIAlertView *failureAlert;

@end


@implementation DAResetPasswordViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationItem setHidesBackButton:YES];
    
    [self setSubmitButtonStatus:NO];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if( !self.submitButton.enabled )
    {
        for( UITouch *touch in touches )
        {
            CGPoint touchPoint = [touch locationInView:self.view];
            
            if( CGRectContainsPoint(self.submitButton.frame, touchPoint) )
            {
                return;
            }
        }
    }
    
    [self.view endEditing:YES];
}

- (IBAction)submitRequest
{
    [self.view endEditing:YES];
    
    [MRProgressOverlayView showOverlayAddedTo:self.navigationController.view title:@"" mode:MRProgressOverlayViewModeIndeterminate animated:YES];
    
    [[DAAPIManager sharedManager] submitPasswordResetWithPin:self.codeField.text phoneNumber:self.phoneNumber newPassword:self.passwordField.text completion:^( BOOL pinValid, BOOL success )
    {
        [MRProgressOverlayView dismissOverlayForView:self.navigationController.view animated:YES completion:^
        {
            if( pinValid )
            {
                if( success )
                {
                    [self.successAlert show];
                }
                else
                {
                    [self.failureAlert show];
                }
            }
            else
            {
                [self.invalidPinAlert show];
            }
        }];
    }];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if( alertView == self.successAlert )
    {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (IBAction)textFieldDidChange:(UITextField *)sender
{
    BOOL validCode      = self.codeField.text.length > 0;
    BOOL passwordLength = self.passwordField.text.length > 6;
    BOOL confirmLength  = self.confirmField.text.length > 6;
    BOOL passwordMatch  = [self.confirmField.text isEqualToString:self.passwordField.text];
    
    if( validCode && passwordLength && confirmLength && passwordMatch )
    {
        [self setSubmitButtonStatus:YES];
    }
    else
    {
        [self setSubmitButtonStatus:NO];
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self animateTextField:textField up:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self animateTextField:textField up:NO];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if( textField == self.passwordField )
    {
        [self.confirmField becomeFirstResponder];
    }
    
    if( textField == self.confirmField )
    {
        [self submitRequest];
    }
    
    return YES;
}

- (void)setSubmitButtonStatus:(BOOL)enabled
{
    self.submitButton.enabled = enabled;
    self.submitButton.alpha = enabled ? 1 : 0.4;
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

- (UIAlertView *)invalidPinAlert
{
    if( !_invalidPinAlert )
    {
        _invalidPinAlert = [[UIAlertView alloc] initWithTitle:@"Invalid Verification Code!" message:@"You entered an incorrect verification code." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    }
    
    return _invalidPinAlert;
}

- (UIAlertView *)successAlert
{
    if( !_successAlert )
    {
        _successAlert = [[UIAlertView alloc] initWithTitle:@"Password Successfully Reset!" message:@"Your password was successfully changed. You may now login to your account." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    }
    
    return _successAlert;
}

- (UIAlertView *)failureAlert
{
    if( !_failureAlert )
    {
        _failureAlert = [[UIAlertView alloc] initWithTitle:@"Failed to Reset Password" message:@"There was a problem resetting your password. Please try again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    }
    
    return _failureAlert;
}

@end
