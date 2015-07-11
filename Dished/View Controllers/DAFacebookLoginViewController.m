//
//  DAFacebookLoginViewController.m
//  Dished
//
//  Created by Ryan Khalili on 6/10/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DAFacebookLoginViewController.h"
#import "DAAppDelegate.h"
#import "DAAPIManager.h"
#import "DAUserManager.h"
#import "DAPhoneNumberViewController.h"


@interface DAFacebookLoginViewController()

@end


@implementation DAFacebookLoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.activityIndicator startAnimating];
    self.navigationItem.backBarButtonItem = nil;
    
    NSDictionary *parameters = @{ @"fields" : @"id,name,first_name,last_name,email,picture.width(400).height(400)" };
    
    [FBRequestConnection startWithGraphPath:@"me" parameters:parameters HTTPMethod:@"GET"
    completionHandler:^( FBRequestConnection *connection, id result, NSError *error )
    {
        if( !error )
        {
            [self attemptFacebookLoginWithFacebookUser:result];
        }
        else
        {
            [self showErrorAlertView];
            [self.navigationController popToRootViewControllerAnimated:YES];
            [FBSession.activeSession closeAndClearTokenInformation];
        }
    }];
}

- (void)attemptFacebookLoginWithFacebookUser:(NSDictionary *)user
{
    [[DAAPIManager sharedManager] loginWithFacebookUserID:user[kIDKey] completion:^( BOOL success, BOOL accountExists )
    {
        if( success )
        {
            [DAUserManager2 loadCurrentUserWithCompletion:^( BOOL userLoadSuccess )
            {
                if( userLoadSuccess )
                {
                    DAAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
                    [delegate followFacebookFriends];
                    [delegate login];
                }
                else
                {
                    [[DAAPIManager sharedManager] forceUserLogout];
                    [self showAlertWithTitle:@"Failed to Login"
                                     message:@"There was a problem logging you in. Please try again."];
                }
            }];
        }
        else
        {
            if( !accountExists )
            {
                [self performSegueWithIdentifier:@"goToRegister" sender:user];
            }
            else
            {
                [self showErrorAlertView];
                [self.navigationController popToRootViewControllerAnimated:YES];
                [FBSession.activeSession closeAndClearTokenInformation];
            }
        }
    }];
}

- (void)showErrorAlertView
{
    [[[UIAlertView alloc] initWithTitle:@"An error occurred." message:@"There was an error logging into Facebook. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if( [segue.identifier isEqualToString:@"goToRegister"] )
    {
        DAPhoneNumberViewController *dest = segue.destinationViewController;
        dest.registrationMode = YES;
        dest.facebookUserInfo = sender;
    }
}

@end