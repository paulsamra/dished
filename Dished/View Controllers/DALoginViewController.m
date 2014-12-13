//
//  DALoginViewController.m
//  Dished
//
//  Created by Ryan Khalili on 6/5/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DALoginViewController.h"
#import "MRProgress.h"
#import "DAAppDelegate.h"
#import "UIViewController+TAPKeyboardPop.h"
#import "DAUserManager.h"
#import "DAPhoneNumberViewController.h"


@interface DALoginViewController()

@end


@implementation DALoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if( !self.loginButton.enabled )
    {
        for( UITouch *touch in touches )
        {
            CGPoint touchPoint = [touch locationInView:self.view];
            
            if( CGRectContainsPoint(self.loginButton.frame, touchPoint) )
            {
                return;
            }
        }
    }
    
    [self.view endEditing:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if( [self.usernameField.text length] == 0 || [self.passwordField.text length] == 0 )
    {
        self.loginButton.enabled = NO;
        self.loginButton.alpha = 0.4;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardOnScreen:) name:UIKeyboardDidShowNotification object:nil];
}

- (void)keyboardOnScreen:(NSNotification *)notification
{
    NSDictionary *info  = notification.userInfo;
    NSValue      *value = info[UIKeyboardFrameEndUserInfoKey];
    
    CGRect rawFrame      = [value CGRectValue];
    CGRect keyboardFrame = [self.view convertRect:rawFrame fromView:nil];
    
    if( keyboardFrame.origin.y > self.view.frame.size.height )
    {
        return;
    }
    
    //self.keyboardFrame = keyboardFrame;
}

- (IBAction)textFieldDidChange:(UITextField *)sender
{
    [self setLoginButtonState];
}

- (IBAction)login
{
    NSString *user = self.usernameField.text;
    
    if( [user characterAtIndex:0] == '@' )
    {
        user = [user substringFromIndex:1];
    }
    
    [self.view endEditing:YES];
    
    [MRProgressOverlayView showOverlayAddedTo:self.navigationController.view title:@"Logging In..." mode:MRProgressOverlayViewModeIndeterminate animated:YES];
    
    [[DAAPIManager sharedManager] loginWithUser:user password:self.passwordField.text
    completion:^( BOOL success, BOOL wrongUser, BOOL wrongPass )
    {
        if( success )
        {
            [[DAUserManager sharedManager] loadUserInfoWithCompletion:^( BOOL userLoadSuccess )
            {
                [MRProgressOverlayView dismissOverlayForView:self.navigationController.view animated:YES completion:^
                {
                    if( userLoadSuccess )
                    {
                        DAAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
                        [delegate login];
                    }
                    else
                    {
                        [[DAAPIManager sharedManager] logout];
                        [self showAlertViewWithTitle:@"Failed to Login"
                                             message:@"There was a problem logging you in. Please try again."];
                    }
                }];
            }];
        }
        else
        {
            [MRProgressOverlayView dismissOverlayForView:self.navigationController.view animated:YES completion:^
            {
                if( wrongUser )
                {
                    [self showAlertViewWithTitle:@"Incorrect Username or Email"
                                         message:@"The email or username you entered does not belong to an account."];
                }
                else if( wrongPass )
                {
                    [self showAlertViewWithTitle:@"Incorrect Password"
                                         message:@"The password you entered is incorrect. Please try again."];
                }
                else
                {
                    [self showAlertViewWithTitle:@"Failed to Login"
                                         message:@"There was a problem logging you in. Please try again."];
                }
            }];
        }
    }];
}

- (void)setLoginButtonState
{
    if( [self.passwordField.text length] == 0 || [self.usernameField.text length] <= 1 )
    {
        self.loginButton.enabled = NO;
        self.loginButton.alpha = 0.4;
    }
    else
    {
        self.loginButton.alpha = 1;
        self.loginButton.enabled = YES;
    }}

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
    if( textField == self.usernameField )
    {
        [self.passwordField becomeFirstResponder];
    }
    
    if( textField == self.passwordField )
    {
        [self login];
    }
    
    return YES;
}

- (IBAction)goToFacebookLogin
{
    [self performSegueWithIdentifier:@"facebookLogin" sender:nil];
}

- (IBAction)goToForgotPassword
{
    [self performSegueWithIdentifier:@"forgotPassword" sender:nil];
}

- (IBAction)goToRegister
{
    [self performSegueWithIdentifier:@"goToRegister" sender:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if( [segue.identifier isEqualToString:@"goToRegister"] )
    {
        DAPhoneNumberViewController *dest = segue.destinationViewController;
        dest.registrationMode = YES;
    }
    
    if( [segue.identifier isEqualToString:@"forgotPassword"] )
    {
        DAPhoneNumberViewController *dest = segue.destinationViewController;
        dest.registrationMode = NO;
    }
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