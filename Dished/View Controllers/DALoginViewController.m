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

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomDistanceConstraint;

@property (nonatomic) CGFloat minBottomDistance;

@end


@implementation DALoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.minBottomDistance = self.bottomDistanceConstraint.constant;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardUpdate:) name:UIKeyboardWillChangeFrameNotification object:nil];
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
    completion:^( BOOL success, BOOL wrongUser, BOOL wrongPass, BOOL deactivated )
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
                        [[DAAPIManager sharedManager] forceUserLogout];
                        [self showAlertWithTitle:@"Failed to Login"
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
                    [self showAlertWithTitle:@"Incorrect Username or Email"
                                     message:@"The email or username you entered does not belong to an account."];
                }
                else if( wrongPass )
                {
                    [self showAlertWithTitle:@"Incorrect Password"
                                     message:@"The password you entered is incorrect. Please try again."];
                }
                else if( deactivated )
                {
                    [self showAlertWithTitle:@"Inactive Account"
                                     message:@"This account has been deactivated."];
                }
                else
                {
                    [self showAlertWithTitle:@"Failed to Login"
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
    [FBSession openActiveSessionWithReadPermissions:@[ @"public_profile", @"email", @"user_friends" ] allowLoginUI:YES
    completionHandler:^( FBSession *session, FBSessionState state, NSError *error )
    {
        if( state == FBSessionStateOpen )
        {
            [self performSegueWithIdentifier:@"facebookLogin" sender:nil];
        }
        
        DAAppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
        [appDelegate sessionStateChanged:session state:state error:error];
    }];
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

@end