//
//  DASplashViewController.m
//  Dished
//
//  Created by Ryan Khalili on 6/4/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DASplashViewController.h"

@interface DASplashViewController ()

@end

@implementation DASplashViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (IBAction)goToLogin
{
    [self performSegueWithIdentifier:@"loginSegue" sender:nil];
}

- (IBAction)goToRegister
{
    [self performSegueWithIdentifier:@"registerSegue" sender:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
}

@end