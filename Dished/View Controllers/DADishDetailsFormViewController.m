//
//  DADishDetailsFormViewController.m
//  Dished
//
//  Created by Ryan Khalili on 7/5/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DADishDetailsFormViewController.h"

@interface DADishDetailsFormViewController ()

@end

@implementation DADishDetailsFormViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.barTintColor = nil;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
}

@end