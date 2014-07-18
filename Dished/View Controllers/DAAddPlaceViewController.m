//
//  DAAddPlaceViewController.m
//  Dished
//
//  Created by Daryl Stimm on 7/9/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DAAddPlaceViewController.h"
#import "DAFormTableViewController.h"
#import "DALocationManager.h"

@interface DAAddPlaceViewController ()

@end

@implementation DAAddPlaceViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[DALocationManager sharedManager] startUpdatingLocation];
    [self.nameTextField becomeFirstResponder];
}

- (IBAction)textFieldChanged:(UITextField *)sender
{
    if( sender == self.nameTextField )
    {
        if( self.nameTextField.text.length > 0 )
        {
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }
        else
        {
            self.navigationItem.rightBarButtonItem.enabled = NO;
        }
    }
}

- (IBAction)save:(id)sender
{
    NSArray *navigationStack = self.navigationController.viewControllers;
    
    [self.nameTextField resignFirstResponder];
    
    [[DALocationManager sharedManager] getAddress];
    
    for( UIViewController *parentController in navigationStack )
    {
        if( [parentController isKindOfClass:[DAFormTableViewController class]] )
        {
            self.review.locationName = self.nameTextField.text;
            [self.navigationController popToViewController:parentController animated:YES];
        }
    }
}
@end
