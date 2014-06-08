//
//  DAReplaceSegue.m
//  Dished
//
//  Created by Ryan Khalili on 6/7/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DAReplaceSegue.h"

@implementation DAReplaceSegue

- (void)perform
{
    UIViewController *source = self.sourceViewController;
    UIViewController *dest   = self.destinationViewController;
    UINavigationController *navigationController = source.navigationController;
    
    [navigationController popToRootViewControllerAnimated:NO];
    [navigationController pushViewController:dest animated:YES];
}

@end