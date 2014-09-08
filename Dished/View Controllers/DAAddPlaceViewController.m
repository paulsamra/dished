//
//  DAAddPlaceViewController.m
//  Dished
//
//  Created by Daryl Stimm on 7/9/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DAAddPlaceViewController.h"
#import "DAReviewFormViewController.h"
#import "DALocationManager.h"


@interface DAAddPlaceViewController() <UITextFieldDelegate>

@end


@implementation DAAddPlaceViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[DALocationManager sharedManager] startUpdatingLocation];
    [self.nameTextField becomeFirstResponder];
    
    self.nameTextField.delegate = self;
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if( textField == self.nameTextField )
    {
        [self save:nil];
    }
    
    return YES;
}

- (IBAction)save:(id)sender
{
    NSArray *navigationStack = self.navigationController.viewControllers;
    
    [self.nameTextField resignFirstResponder];
    
    self.review.locationID = @"";
    self.review.googleID   = @"";
    
    [[DALocationManager sharedManager] getAddress];
    
    self.review.locationLatitude  = [[DALocationManager sharedManager] currentLocation].latitude;
    self.review.locationLongitude = [[DALocationManager sharedManager] currentLocation].longitude;
    
    for( UIViewController *parentController in navigationStack )
    {
        if( [parentController isKindOfClass:[DAReviewFormViewController class]] )
        {
            self.review.locationName = self.nameTextField.text;
            [self.navigationController popToViewController:parentController animated:YES];
        }
    }
}
@end
