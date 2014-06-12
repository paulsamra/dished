//
//  DAFacebookLoginViewController.m
//  Dished
//
//  Created by Ryan Khalili on 6/10/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DAFacebookLoginViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "DAAppDelegate.h"


@interface DAFacebookLoginViewController()

@property (nonatomic) BOOL shouldLogin;

@end


@implementation DAFacebookLoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.shouldLogin = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.activityIndicator startAnimating];
    self.logoutButton.hidden = YES;
    
    if( FBSession.activeSession.state == FBSessionStateOpen || FBSession.activeSession.state == FBSessionStateOpenTokenExtended )
    {
        [self.activityIndicator stopAnimating];
        self.activityIndicator.hidden = YES;
        self.statusLabel.text = @"Logged into Facebook";
        self.logoutButton.hidden = NO;
        self.shouldLogin = NO;
    }
    else
    {
        self.shouldLogin = YES;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if( self.shouldLogin )
    {
        [FBSession openActiveSessionWithReadPermissions:@[@"public_profile"] allowLoginUI:YES
                                      completionHandler:^(FBSession *session, FBSessionState state, NSError *error)
         {
             if( state == FBSessionStateOpen )
             {
                 self.statusLabel.text = @"Logged into Facebook";
                 [self.activityIndicator stopAnimating];
                 self.activityIndicator.hidden = YES;
                 self.logoutButton.hidden = NO;
             }
             
             DAAppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
             [appDelegate sessionStateChanged:session state:state error:error];
         }];
    }
}

- (IBAction)logout
{
    [FBSession.activeSession closeAndClearTokenInformation];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end