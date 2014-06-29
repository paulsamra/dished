//
//  DATabBarController.m
//  Dished
//
//  Created by Ryan Khalili on 6/29/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DATabBarController.h"
#import "DAImagePickerController.h"


@interface DATabBarController() <UITabBarControllerDelegate>

@end


@implementation DATabBarController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UITabBarItem *addReviewTabItem = [self.tabBar.items objectAtIndex:2];
    
    UIImage *image = [UIImage imageNamed:@"add_review"];
    addReviewTabItem.image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    [addReviewTabItem setTitleTextAttributes:@{ NSForegroundColorAttributeName : [UIColor whiteColor] } forState:UIControlStateNormal];
    
    self.delegate = self;
    
    [[UITabBar appearance] setTintColor:[UIColor colorWithRed:0.11 green:0.64 blue:0.99 alpha:1]];
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    if( [viewController.title isEqualToString:@"dummy"] )
    {
        DAImagePickerController *reviewImagePicker = [self.storyboard instantiateViewControllerWithIdentifier:@"addReviewNav"];
        [self presentViewController:reviewImagePicker animated:YES completion:nil];
        
        return NO;
    }
    
    return YES;
}

@end