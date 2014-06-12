//
//  DAForgotPasswordViewController.m
//  Dished
//
//  Created by Ryan Khalili on 6/12/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DAForgotPasswordViewController.h"


@interface DAForgotPasswordViewController() <UIAlertViewDelegate>

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

@end