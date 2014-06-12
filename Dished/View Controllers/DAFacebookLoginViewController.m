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

@end


@implementation DAFacebookLoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.activityIndicator startAnimating];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if( FBSession.activeSession.state == FBSessionStateOpen || FBSession.activeSession.state == FBSessionStateOpenTokenExtended )
    {
        [FBSession.activeSession closeAndClearTokenInformation];
    }
    else
    {
        [FBSession openActiveSessionWithReadPermissions:@[@"public_profile"] allowLoginUI:YES
        completionHandler:^(FBSession *session, FBSessionState state, NSError *error)
        {
            DAAppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
            [appDelegate sessionStateChanged:session state:state error:error];
        }];
    }
}

@end