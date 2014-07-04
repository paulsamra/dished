//
//  DAImagePickerController.h
//  Dished
//
//  Created by Ryan Khalili on 6/29/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DAImagePickerController : UIViewController

@property (weak, nonatomic) IBOutlet UIView         *videoView;
@property (weak, nonatomic) IBOutlet UIButton       *flashButton;
@property (weak, nonatomic) IBOutlet UIButton       *gridButton;
@property (weak, nonatomic) IBOutlet UIButton       *toggleCameraButton;
@property (weak, nonatomic) IBOutlet UIButton       *takePictureButton;
@property (weak, nonatomic) IBOutlet UIButton       *cameraRollButton;
@property (weak, nonatomic) IBOutlet UIButton       *retakeButton;
@property (weak, nonatomic) IBOutlet UIImageView    *overlayImageVew;
@property (weak, nonatomic) IBOutlet UIImageView    *gridImageView;

@end