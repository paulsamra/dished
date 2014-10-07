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
#import <AddressBook/AddressBook.h>


@interface DAAddPlaceViewController() <UITextFieldDelegate>

@property (nonatomic) BOOL isCancelled;

@end


@implementation DAAddPlaceViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[DALocationManager sharedManager] startUpdatingLocation];
    [self.nameTextField becomeFirstResponder];
    
    self.nameTextField.delegate = self;
    
    self.isCancelled = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.isCancelled = YES;
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
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    NSArray *navigationStack = self.navigationController.viewControllers;
    
    [self.nameTextField resignFirstResponder];
    
    self.review.locationID = 0;
    self.review.googleID   = 0;
    
    self.review.locationName      = self.nameTextField.text;
    self.review.locationLatitude  = [[DALocationManager sharedManager] currentLocation].latitude;
    self.review.locationLongitude = [[DALocationManager sharedManager] currentLocation].longitude;
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.center = self.view.center;
    [spinner startAnimating];
    [self.view addSubview:spinner];
    
    [[DALocationManager sharedManager] getAddressWithCompletion:^( NSDictionary *addressDictionary )
    {
        if( !self.isCancelled )
        {
            self.review.locationStreetNum  = addressDictionary[@"SubThoroughfare"];
            self.review.locationStreetName = addressDictionary[@"Thoroughfare"];
            self.review.locationCity       = addressDictionary[(NSString *)kABPersonAddressCityKey];
            self.review.locationState      = addressDictionary[(NSString *)kABPersonAddressStateKey];
            self.review.locationZip        = addressDictionary[(NSString *)kABPersonAddressZIPKey];
            
            for( UIViewController *parentController in navigationStack )
            {
                if( [parentController isKindOfClass:[DAReviewFormViewController class]] )
                {
                    [self.navigationController popToViewController:parentController animated:YES];
                }
            }
        }
    }];    
}
@end
