//
//  UIViewController+DishedAlert.m
//  Dished
//
//  Created by Ryan Khalili on 12/12/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "UIViewController+Alert.h"

@implementation UIViewController (Alert)

- (void)showAlertViewWithTitle:(NSString *)title message:(NSString *)message
{
    if( IS_IOS8 )
    {
        UIAlertController *alertView = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *dismissAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertView addAction:dismissAction];
        
        [self presentViewController:alertView animated:YES completion:nil];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        [alertView show];
    }
}

@end