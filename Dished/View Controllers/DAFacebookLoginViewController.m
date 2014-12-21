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
    self.navigationItem.leftBarButtonItem = nil;
    
    [[FBRequest requestForMe] startWithCompletionHandler:
    ^( FBRequestConnection *connection, NSDictionary<FBGraphUser> *user, NSError *error )
    {
        if( !error )
        {
            [self attemptFacebookLoginWithFacebookUser:user];
        }
        else
        {
            [self showErrorAlertView];
        }
    }];
}

- (void)attemptFacebookLoginWithFacebookUser:(NSDictionary<FBGraphUser> *)user
{
    [[DAAPIManager sharedManager] loginWithFacebookUserID:user.objectID completion:^( BOOL success, BOOL accountExists )
    {
        if( success )
        {
            [[DAUserManager sharedManager] loadUserInfoWithCompletion:^( BOOL userLoadSuccess )
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