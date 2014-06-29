//
//  DAImagePickerController.m
//  Dished
//
//  Created by Ryan Khalili on 6/29/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DAImagePickerController.h"
#import "DACaptureManager.h"


@interface DAImagePickerController()

@property (strong, nonatomic) DACaptureManager *captureManager;

@end


@implementation DAImagePickerController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
    
    self.navigationController.navigationBar.titleTextAttributes = @{ NSForegroundColorAttributeName : [UIColor whiteColor] };
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    self.captureManager = [[DACaptureManager alloc] init];
    
    [self.view.layer setMasksToBounds:YES];
    self.captureManager.previewLayer.frame = self.view.bounds;
    [self.view.layer insertSublayer:self.captureManager.previewLayer below:[[self.view.layer sublayers] objectAtIndex:0]];
    
    [self.captureManager startCapture];
}

- (IBAction)toggleCamera
{
    [self.captureManager toggleCamera];
}

- (IBAction)toggleFlash
{
}

- (IBAction)cancelReview:(UIBarButtonItem *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end