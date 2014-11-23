//
//  DAForgotPasswordViewController.m
//  Dished
//
//  Created by Ryan Khalili on 6/12/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DAForgotPasswordViewController.h"
#import "DAResetPasswordViewController.h"
#import "MRProgress.h"


@interface DAForgotPasswordViewController() <UIAlertViewDelegate, UITextFieldDelegate>

@property (strong, nonatomic) UIAlertView *sentAlert;
@property (strong, nonatomic) UIAlertView *errorAlert;

@end


@implementation DAForgotPasswordViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setSubmitButtonStatus:NO];
}

- (IBAction)submitPhoneNumber
{
    [self.view endEditing:YES];
    
    [MRProgressOverlayView showOverlayAddedTo:self.navigationController.view title:@"" mode:MRProgressOverlayViewModeIndeterminate animated:YES];
    
    NSString *after1 = [self.phoneNumberField.text substringFromIndex:3];
    NSArray  *components = [after1 componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]];
    NSString *phoneNumber = [[components componentsJoinedByString:@""] mutableCopy];
    
    [[DAAPIManager sharedManager] requestPasswordResetCodeWithPhoneNumber:phoneNumber completion:^( BOOL success )
    {
        [MRProgressOverlayView dismissOverlayForView:self.navigationController.view animated:YES completion:^
        {
            if( success )
            {
                [self.sentAlert show];
            }
            else
            {
                [self.errorAlert show];
            }
        }];
    }];
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

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if( alertView == self.sentAlert )
    {
        [self performSegueWithIdentifier:@"resetPassword" sender:nil];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if( [segue.identifier isEqualToString:@"resetPassword"] )
    {
        DAResetPasswordViewController *dest = segue.destinationViewController;
        
        NSString *after1 = [self.phoneNumberField.text substringFromIndex:3];
        NSArray  *numbers = [after1 componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]];
        NSString *phoneNumber = [[numbers componentsJoinedByString:@""] mutableCopy];
        
        dest.phoneNumber = phoneNumber;
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self animateTextField:textField up:YES];
    
    if( textField.text.length == 0 )
    {
        textField.text = @"+1 ";
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self animateTextField:textField up:NO];
    
    if( textField.text.length == 3 )
    {
        textField.text = @"";
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if( newString.length < 3 )
    {
        return NO;
    }
    
    NSString *after1 = [newString substringFromIndex:3];
    NSArray  *components = [after1 componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]];
    NSString *decimalString = [[components componentsJoinedByString:@""] mutableCopy];
    NSUInteger length = decimalString.length;
    
    if( length > 10 )
    {
        return NO;
    }
    
    NSUInteger index = 0;
    NSMutableString *formattedString = [[NSMutableString alloc] initWithString:@"+1 "];
    
    if( length - index > 3 )
    {
        NSString *areaCode = [decimalString substringWithRange:NSMakeRange(index, 3)];
        [formattedString appendFormat:@"(%@) ",areaCode];
        index += 3;
    }
    
    if( length - index > 3 )
    {
        NSString *prefix = [decimalString substringWithRange:NSMakeRange(index, 3)];
        [formattedString appendFormat:@"%@-",prefix];
        index += 3;
    }
    
    NSString *remainder = [decimalString substringFromIndex:index];
    [formattedString appendString:remainder];
    
    textField.text = formattedString;
    
    if( length == 10 )
    {
        [self setSubmitButtonStatus:YES];
    }
    else
    {
        [self setSubmitButtonStatus:NO];
    }
    
    return NO;
}

- (void)setSubmitButtonStatus:(BOOL)enabled
{
    self.submitButton.enabled = enabled;
    self.submitButton.alpha = enabled ? 1 : 0.4;
}

- (void)animateTextField:(UITextField*)textField up:(BOOL)up
{
    const int movementDistance = -25;
    const float movementDuration = 0.3f;
    
    int movement = up ? movementDistance : -movementDistance;
    
    [UIView beginAnimations:@"animateTextField" context:nil];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:movementDuration];
    self.view.frame = CGRectOffset( self.view.frame, 0, movement );
    [UIView commitAnimations];
}

- (UIAlertView *)sentAlert
{
    if( !_sentAlert )
    {
        _sentAlert = [[UIAlertView alloc] initWithTitle:@"Verification Code Sent" message:@"You will receive a text message with your verification code. Enter it on the next screen, along with your new password." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    }
    
    return _sentAlert;
}

- (UIAlertView *)errorAlert
{
    if( !_errorAlert )
    {
        _errorAlert = [[UIAlertView alloc] initWithTitle:@"Request Error" message:@"There was an error requesting a password reset code. Please make sure you entered the correct phone number." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    }
    
    return _errorAlert;
}

@end