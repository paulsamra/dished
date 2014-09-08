//
//  DAViewController.m
//  Dished
//
//  Created by Ryan Khalili on 9/7/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DAViewController.h"


@interface DAViewController()

@end


@implementation DAViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)showAlertViewWithTitle:(NSString *)title message:(NSString *)message
{
    [[[UIAlertView alloc] initWithTitle:title
                                message:message
                               delegate:self
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
}

@end