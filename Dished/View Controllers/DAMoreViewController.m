//
//  DAMoreViewController.m
//  Dished
//
//  Created by Ryan Khalili on 9/17/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DAMoreViewController.h"
#import "DAAPIManager.h"
#import "DAAppDelegate.h"


@implementation DAMoreViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (IBAction)logout
{
    [[DAAPIManager sharedManager] logout];
    
    DAAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate setLoginView];
}

@end