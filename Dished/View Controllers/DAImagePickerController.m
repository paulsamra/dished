//
//  DAImagePickerController.m
//  Dished
//
//  Created by Ryan Khalili on 6/29/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DAImagePickerController.h"
#import "DACaptureManager.h"


@interface DAImagePickerController() <DACaptureManagerDelegate>

@property (strong, nonatomic) DACaptureManager *captureManager;
@property (strong, nonatomic) UIImage *pictureTaken;

@property (nonatomic) BOOL gridIsVisible;

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
    self.captureManager.delegate = self;
    
    [self.view.layer setMasksToBounds:YES];
    
    self.captureManager.previewLayer.frame = self.videoView.bounds;
    [self.videoView.layer insertSublayer:self.captureManager.previewLayer below:[[self.videoView.layer sublayers] objectAtIndex:0]];
    
    [self.captureManager startCapture];
    
    [self.captureManager enableFlash:NO];
    
    self.gridIsVisible = NO;
    self.capturedImageView.hidden = !self.gridIsVisible;
    
    self.retakeButton.hidden = YES;
}

- (IBAction)toggleCamera
{
    [self.captureManager toggleCamera];
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
    
    self.takePictureButton.enabled = NO;
    
    self.flashButton.hidden = YES;
    self.gridButton.hidden = YES;
    self.toggelCameraButton.hidden = YES;
}

- (void)captureManager:(DACaptureManager *)captureManager didCaptureImage:(UIImage *)image
{
    self.retakeButton.hidden = NO;
    self.navigationItem.rightBarButtonItem.enabled = YES;
    
    [self.captureManager stopCapture];
    
    UIImage *fixedImage = [self fixOrientation:image];
    
    CGFloat cropWidth = ( image.size.width / self.videoView.bounds.size.width ) * self.capturedImageView.bounds.size.width;
    CGFloat cropHeight = ( image.size.height / self.videoView.bounds.size.height ) * self.capturedImageView.bounds.size.height;
    
    CGFloat x = self.capturedImageView.frame.origin.x * ( image.size.width / self.videoView.bounds.size.width );
    CGFloat y = ( self.capturedImageView.frame.origin.y - self.videoView.frame.origin.y ) * ( image.size.height / self.videoView.bounds.size.height );
    
    CGRect cropRect = CGRectMake( x, y, cropWidth, cropHeight );
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([fixedImage CGImage], cropRect);
    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    self.capturedImageView.image = croppedImage;
    self.pictureTaken = croppedImage;
    
    self.capturedImageView.hidden = NO;
}

- (UIImage *)fixOrientation:(UIImage *)image {
    
    // No-op if the orientation is already correct
    if (image.imageOrientation == UIImageOrientationUp) return image;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (image.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, image.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, image.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (image.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, image.size.width, image.size.height,
                                             CGImageGetBitsPerComponent(image.CGImage), 0,
                                             CGImageGetColorSpace(image.CGImage),
                                             CGImageGetBitmapInfo(image.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (image.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.height,image.size.width), image.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.width,image.size.height), image.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

- (IBAction)retakePicture
{
    self.capturedImageView.image = [UIImage imageNamed:@"camera_grid"];
    self.capturedImageView.hidden = !self.gridIsVisible;
    
    [self.captureManager startCapture];
    
    self.retakeButton.hidden = NO;
    self.takePictureButton.enabled = YES;
    
    self.flashButton.hidden = NO;
    self.gridButton.hidden = NO;
    self.toggelCameraButton.hidden = NO;
    
    self.pictureTaken = nil;
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
}

- (IBAction)toggleGrid
{
    self.gridIsVisible = !self.gridIsVisible;

    self.capturedImageView.hidden = !self.gridIsVisible;
}

- (IBAction)cancelReview:(UIBarButtonItem *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end