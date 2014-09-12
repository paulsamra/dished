//
//  DANewsViewController.m
//  Dished
//
//  Created by Ryan Khalili on 8/9/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DANewsViewController.h"
#import "DAAppDelegate.h"
#import "DAAPIManager.h"
#import "UIImageView+DishProgress.h"


@interface DANewsViewController()

@end


@implementation DANewsViewController

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