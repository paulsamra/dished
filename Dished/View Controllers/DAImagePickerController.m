//
//  DAImagePickerController.m
//  Dished
//
//  Created by Ryan Khalili on 6/29/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DAImagePickerController.h"
#import "DACaptureManager.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "UIImage+Orientation.h"


@interface DAImagePickerController() <DACaptureManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) UIImage           *pictureTaken;
@property (strong, nonatomic) UIImageView       *previewImageView;
@property (strong, nonatomic) DACaptureManager  *captureManager;

@property (nonatomic) BOOL gridIsVisible;
@property (nonatomic) BOOL shouldLoadGridImage;

@end


@implementation DAImagePickerController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.shouldLoadGridImage = NO;
    
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
    self.navigationController.navigationBar.titleTextAttributes = @{ NSForegroundColorAttributeName : [UIColor whiteColor] };
    self.navigationItem.rightBarButtonItem.enabled = NO;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    self.captureManager = [[DACaptureManager alloc] init];
    self.captureManager.delegate = self;
    
    [self.view.layer setMasksToBounds:YES];
    
    self.captureManager.previewLayer.frame = self.videoView.bounds;
    [self.videoView.layer addSublayer:self.captureManager.previewLayer];
    
    [self.captureManager startCapture];
    
    [self.captureManager enableFlash:NO];
    
    self.gridIsVisible = NO;
    self.gridImageView.hidden = !self.gridIsVisible;
    
    self.retakeButton.hidden = YES;
    
    [self loadCameraRollThumbnail];
}

- (void)loadCameraRollThumbnail
{
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    
    [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop)
    {
        if( group != nil )
        {
            UIImage *thumbnail = [UIImage imageWithCGImage:[group posterImage]];
            
            if( thumbnail )
            {
                *stop = YES;
                
                [self.cameraRollButton setBackgroundImage:thumbnail forState:UIControlStateNormal];
            }
        }
    }
    failureBlock: ^(NSError *error)
    {
        NSLog(@"No groups");
    }];
}

- (IBAction)toggleCamera
{
    [self.captureManager toggleCamera];
    
    [self.captureManager enableFlash:NO];
    [self.flashButton setTitle:@" Off" forState:UIControlStateNormal];
}

- (IBAction)toggleFlash
{
    [self.captureManager enableFlash:![self.captureManager isFlashOn]];
    
    NSString *flashButtonText = [self.captureManager isFlashOn] ? @" On" : @" Off";
    [self.flashButton setTitle:flashButtonText forState:UIControlStateNormal];
}

- (IBAction)takePicture
{
    [self.captureManager captureStillImage];
    
    self.gridButton.hidden          = YES;
    self.flashButton.hidden         = YES;
    self.cameraRollButton.hidden    = YES;
    self.takePictureButton.enabled  = NO;
    self.toggleCameraButton.hidden  = YES;
    
    UIView *shutterView = [[UIView alloc] initWithFrame:self.videoView.frame];
    shutterView.backgroundColor = [UIColor blackColor];
    shutterView.alpha = 0;
    [self.view addSubview:shutterView];
    
    UIViewAnimationOptions options =  UIViewAnimationOptionCurveLinear;
    
    [UIView animateWithDuration:0.1
    delay:0 options:options animations:^
    {
        shutterView.alpha = 1;
    }
    completion:^( BOOL finished )
    {
        if( finished )
        {
            [UIView animateWithDuration:0.1 delay:0 options:options animations:^
            {
                shutterView.alpha = 0;
            }
            completion:^(BOOL finished)
            {
                if( finished )
                {
                    [shutterView removeFromSuperview];
                }
            }];
        }
    }];
}

- (void)captureManager:(DACaptureManager *)captureManager didCaptureImage:(UIImage *)image
{
    self.retakeButton.hidden = NO;
    self.navigationItem.rightBarButtonItem.enabled = YES;
    
    self.previewImageView.image = image;
    [self.view insertSubview:self.previewImageView belowSubview:self.overlayImageVew];
    self.captureManager.previewLayer.connection.enabled = NO;
    
    dispatch_async( dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0 ), ^
    {
        UIImage *fixedImage = [image fixOrientation];
        
        CGFloat cropWidth = ( image.size.width / self.videoView.bounds.size.width ) * self.gridImageView.bounds.size.width;
        CGFloat cropHeight = ( image.size.height / self.videoView.bounds.size.height ) * self.gridImageView.bounds.size.height;
        
        CGFloat x = self.gridImageView.frame.origin.x * ( image.size.width / self.videoView.bounds.size.width );
        CGFloat y = ( self.gridImageView.frame.origin.y - self.videoView.frame.origin.y ) * ( image.size.height / self.videoView.bounds.size.height );
        
        CGRect cropRect = CGRectMake( x, y, cropWidth, cropHeight );
        
        CGImageRef imageRef = CGImageCreateWithImageInRect([fixedImage CGImage], cropRect);
        UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
        CGImageRelease(imageRef);
        
        self.pictureTaken = croppedImage;
    });
}

- (IBAction)retakePicture
{
    [self.previewImageView removeFromSuperview];
    
    if( self.shouldLoadGridImage )
    {
        self.gridImageView.image = [UIImage imageNamed:@"camera_grid"];
        self.shouldLoadGridImage = NO;
    }
    self.gridImageView.hidden = !self.gridIsVisible;
    
    [self.captureManager startCapture];
    
    self.retakeButton.hidden = YES;
    self.takePictureButton.enabled = YES;
    
    self.cameraRollButton.hidden = NO;
    self.flashButton.hidden = NO;
    self.gridButton.hidden = NO;
    self.toggleCameraButton.hidden = NO;
    
    self.pictureTaken = nil;
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    self.captureManager.previewLayer.connection.enabled = YES;
    self.videoView.hidden = NO;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self retakePicture];
}

- (IBAction)toggleGrid
{
    self.gridIsVisible = !self.gridIsVisible;

    self.gridImageView.hidden = !self.gridIsVisible;
}

- (IBAction)chooseFromCameraRoll
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.allowsEditing = YES;
    imagePicker.delegate = self;
    
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:imagePicker animated:YES completion:nil];
    
    self.captureManager.previewLayer.connection.enabled = NO;
    self.videoView.hidden = YES;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    self.shouldLoadGridImage = YES;
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    self.gridImageView.image = chosenImage;
    self.gridImageView.hidden = NO;
    self.pictureTaken = chosenImage;
    
    self.retakeButton.hidden = NO;
    self.takePictureButton.enabled = NO;
    
    self.gridButton.hidden = YES;
    self.flashButton.hidden = YES;
    self.toggleCameraButton.hidden = YES;
    self.cameraRollButton.hidden = YES;
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)cancelReview:(UIBarButtonItem *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (UIImageView *)previewImageView
{
    if( !_previewImageView )
    {
        _previewImageView = [[UIImageView alloc] initWithFrame:self.videoView.frame];
    }
    
    return _previewImageView;
}

@end