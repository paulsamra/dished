//
//  DAForgotPasswordViewController.m
//  Dished
//
//  Created by Ryan Khalili on 6/12/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DAPhoneNumberViewController.h"
#import "DAResetPasswordViewController.h"
#import "DARegisterViewController.h"
#import "MRProgress.h"


@interface DAPhoneNumberViewController() <UIAlertViewDelegate, UITextFieldDelegate>

@property (copy,   nonatomic) NSString    *verifiedPhoneNumber;
@property (strong, nonatomic) UIAlertView *sentAlert;
@property (strong, nonatomic) UIAlertView *enterPinAlert;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomDistanceConstraint;

@property (nonatomic) CGFloat minBottomDistance;

@end


@implementation DAPhoneNumberViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.minBottomDistance = self.bottomDistanceConstraint.constant;
    
    [self setSubmitButtonStatus:NO];
    
    self.registerPhoneNumberLabel.hidden = !self.registrationMode;
    self.resetPasswordLabel.hidden = self.registrationMode;
    
    self.navigationItem.title = self.registrationMode ? @"Enter Phone Number" : @"Forgot Password";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardUpdate:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)keyboardUpdate:(NSNotification *)notification
{
    NSDictionary *info  = notification.userInfo;
    NSValue      *value = info[UIKeyboardFrameEndUserInfoKey];
    
    CGRect rawFrame      = [value CGRectValue];
    CGRect keyboardFrame = [self.view convertRect:rawFrame fromView:nil];
    
    if( keyboardFrame.origin.y > self.view.frame.size.height )
    {
        return;
    }
    
    CGFloat newDistance = self.view.frame.size.height - keyboardFrame.origin.y;
    newDistance = newDistance < self.minBottomDistance ? self.minBottomDistance : newDistance;
    
    self.bottomDistanceConstraint.constant = newDistance;
    [self.view setNeedsUpdateConstraints];
    [self.view layoutIfNeeded];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if( !IS_IPHONE4 )
    {
        [self.phoneNumberField becomeFirstResponder];
    }
}

- (void)showProgressView
{
    [MRProgressOverlayView showOverlayAddedTo:self.navigationController.view title:@"" mode:MRProgressOverlayViewModeIndeterminate animated:YES];
}

- (void)hideProgressViewWithCompletion:( void(^)() )completion
{
    [MRProgressOverlayView dismissOverlayForView:self.navigationController.view animated:YES completion:^
    {
        if( completion )
        {
            completion();
        }
    }];
}

- (IBAction)submitPhoneNumber
{
    [self.view endEditing:YES];
    
    [self showProgressView];
    
    NSString *after1 = [self.phoneNumberField.text substringFromIndex:3];
    NSArray  *components = [after1 componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]];
    NSString *phoneNumber = [[components componentsJoinedByString:@""] mutableCopy];
    
    if( self.registrationMode )
    {
        [self verifyPhoneNumber:phoneNumber];
    }
    else
    {
        [self submitPasswordResetRequestWithPhoneNumber:phoneNumber];
    }
}

- (void)submitPasswordResetRequestWithPhoneNumber:(NSString *)phoneNumber
{
    [[DAAPIManager sharedManager] requestPasswordResetCodeWithPhoneNumber:phoneNumber completion:^( BOOL success )
    {
        [self hideProgressViewWithCompletion:^
        {
            success ? [self.sentAlert show] : [self showErrorAlert];
        }];
    }];
}

- (void)verifyPhoneNumber:(NSString *)phoneNumber
{
    NSDictionary *parameters = @{ kPhoneKey : phoneNumber };
    
    [[DAAPIManager sharedManager] POST:kAuthPhoneVerifyURL parameters:parameters
    success:^( NSURLSessionDataTask *task, id responseObject )
    {
        [self.enterPinAlert show];
        self.verifiedPhoneNumber = phoneNumber;
    }
    failure:^( NSURLSessionDataTask *task, NSError *error )
    {
        [self hideProgressViewWithCompletion:^
        {
            [self showErrorAlert];
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
    
    if( alertView == self.enterPinAlert )
    {
        if( buttonIndex != alertView.cancelButtonIndex )
        {
            NSString *codeEntered = [alertView textFieldAtIndex:0].text;
            
            if( codeEntered.length == 0 )
            {
                [self showAlertWithTitle:@"Incorrect Code" message:@"The verification code was incorrect. Please try again."];
            }
            else
            {
                [self verifyRegistrationCode:codeEntered];
            }
        }
        else
        {
            [self hideProgressViewWithCompletion:nil];
        }
    }
}

- (void)verifyRegistrationCode:(NSString *)code
{    
    NSDictionary *parameters = @{ kPhoneKey : self.verifiedPhoneNumber, @"pin" : code };
    
    [[DAAPIManager sharedManager] POST:kAuthPhoneVerifyURL parameters:parameters
    success:^( NSURLSessionDataTask *task, id responseObject )
    {
        [self hideProgressViewWithCompletion:^
        {
            [self performSegueWithIdentifier:@"registerForm" sender:nil];
        }];
    }
    failure:^( NSURLSessionDataTask *task, NSError *error )
    {
        [self hideProgressViewWithCompletion:^
        {
            [self showAlertWithTitle:@"Incorrect Code" message:@"The verification code was incorrect. Please try again."];
        }];
    }];
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
    
    if( [segue.identifier isEqualToString:@"registerForm"] )
    {
        DARegisterViewController *dest = segue.destinationViewController;
        
        dest.phoneNumber = self.phoneNumberField.text;
        dest.facebookUserInfo = self.facebookUserInfo;
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if( textField.text.length == 0 )
    {
        textField.text = @"+1 ";
    }
}

- (void)showErrorAlert
{
    [self showAlertWithTitle:@"Request Error"
                     message:@"There was an error requesting a verification code. Please make sure you entered a valid phone number."];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
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

- (UIAlertView *)enterPinAlert
{
    if( !_enterPinAlert )
    {
        _enterPinAlert = [[UIAlertView alloc] initWithTitle:@"Enter Verification Code" message:@"You will receive a text message with a six-digit verification code." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
        
        _enterPinAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
        [_enterPinAlert textFieldAtIndex:0].keyboardType = UIKeyboardTypeDecimalPad;
    }
    
    return _enterPinAlert;
}

- (UIAlertView *)sentAlert
{
    if( !_sentAlert )
    {
        _sentAlert = [[UIAlertView alloc] initWithTitle:@"Verification Code Sent" message:@"You will receive a text message with your verification code. Enter it on the next screen, along with your new password." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    }
    
    return _sentAlert;
}

@end