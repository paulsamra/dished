//
//  DALoginViewController.m
//  Dished
//
//  Created by Ryan Khalili on 6/5/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DALoginViewController.h"
#import "UIViewController+TAPKeyboardPop.h"


@interface DALoginViewController()

@end


@implementation DALoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
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

- (void)textFieldDidChange:(NSNotification *)notification
{
    [self setLoginButtonState];
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
    
    return YES;
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

@end