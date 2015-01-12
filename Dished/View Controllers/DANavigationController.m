//
//  DANavigationController.m
//  Dished
//
//  Created by Ryan Khalili on 9/6/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DANavigationController.h"


@implementation DANavigationController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self adjustAppearance];
}

- (void)adjustAppearance
{
    CGRect hairlineRect = CGRectMake( 0, self.navigationBar.frame.size.height, self.navigationBar.frame.size.width, 0.5 );
    UIView *navBorder = [[UIView alloc] initWithFrame:hairlineRect];
    
    [navBorder setBackgroundColor:[UIColor colorWithRed:0.78 green:0.78 blue:0.78 alpha:1]];
    [navBorder setOpaque:YES];
    [self.navigationBar addSubview:navBorder];
    
    self.navigationBar.barTintColor = [UIColor whiteColor];
}

@end