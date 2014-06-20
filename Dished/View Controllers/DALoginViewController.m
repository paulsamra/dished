//
//  DALoginViewController.m
//  Dished
//
//  Created by Ryan Khalili on 6/5/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DALoginViewController.h"
#import "DAAPIManager.h"
#import "MRProgress.h"
#import "UIViewController+TAPKeyboardPop.h"


@interface DALoginViewController()

@property (strong, nonatomic) UIAlertView *successAlert;
@property (strong, nonatomic) UIAlertView *wrongUserAlert;
@property (strong, nonatomic) UIAlertView *wrongPassAlert;
@property (strong, nonatomic) UIAlertView *loginFailAlert;

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
    
    [[DAAPIManager sharedManager] loginWithUser:user password:self.passwordField.text completion:^( BOOL success, BOOL wrongUser, BOOL wrongPass )
    {
        [MRProgressOverlayView dismissOverlayForView:self.navigationController.view animated:YES completion:^
        {
            if( success )
            {
                [self.successAlert show];
            }
            else if( wrongUser )
            {
                [self.wrongUserAlert show];
            }
            else if( wrongPass )
            {
                [self.wrongPassAlert show];
            }
            else
            {
                [self.loginFailAlert show];
            }
        }];
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

- (UIAlertView *)successAlert
{
    if( !_successAlert )
    {
        _successAlert = [[UIAlertView alloc] initWithTitle:@"Login Successful" message:@"You have been successfully logged in." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    }
    
    return _successAlert;
}

- (UIAlertView *)wrongUserAlert
{
    if( !_wrongUserAlert )
    {
        _wrongUserAlert = [[UIAlertView alloc] initWithTitle:@"Incorrect Username or Email" message:@"The email or username you entered does not belong to an account." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    }
    
    return _wrongUserAlert;
}

- (UIAlertView *)wrongPassAlert
{
    if( !_wrongPassAlert )
    {
        _wrongPassAlert = [[UIAlertView alloc] initWithTitle:@"Incorrect Password" message:@"The password you entered is incorrect. Please try again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    }
    
    return _wrongPassAlert;
}

- (UIAlertView *)loginFailAlert
{
    if( !_loginFailAlert )
    {
        _loginFailAlert = [[UIAlertView alloc] initWithTitle:@"Failed to Login" message:@"There was a problem logging you in. Please try again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    }
    
    return _loginFailAlert;
}

@end