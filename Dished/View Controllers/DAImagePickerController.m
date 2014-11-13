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
#import "DAImageFilterViewController.h"
#import "DALocationManager.h"


@interface DAImagePickerController() <DACaptureManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) UIView           *focusView;
@property (strong, nonatomic) DACaptureManager *captureManager;

@property (nonatomic) BOOL    gridIsVisible;
@property (nonatomic) BOOL    shouldShutterAfterFocus;
@property (nonatomic) CGFloat beginGestureScale;
@property (nonatomic) CGFloat effectiveScale;

@end


@implementation DAImagePickerController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
#if TARGET_IPHONE_SIMULATOR
    NSLog(@"Running in the simulator");
    [self performSelectorOnMainThread:@selector(imageIsReady:) withObject:[UIImage imageNamed:@"logo_blue.png"] waitUntilDone:NO];
    [self performSegueWithIdentifier:@"chooseFilter" sender:nil];

#elif TARGET_OS_IPHONE
    NSLog(@"Running on a device");
    self.shouldShutterAfterFocus = NO;
    
    [self.view.layer setMasksToBounds:YES];
    
    self.effectiveScale = 1.0f;
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [self.view addSubview:spinner];
    [spinner startAnimating];
    spinner.center = self.view.center;
    
    dispatch_async( dispatch_get_main_queue(), ^
    {
        self.captureManager = [[DACaptureManager alloc] init];
        self.captureManager.delegate = self;
       
        self.captureManager.previewLayer.frame = self.videoView.bounds;
        [self.videoView.layer addSublayer:self.captureManager.previewLayer];
        self.videoView.layer.masksToBounds = YES;
       
        [self.captureManager startCapture];
       
        [self.captureManager enableFlash:NO];
        
        [spinner removeFromSuperview];
    });
    
    self.gridIsVisible = NO;
    self.gridImageView.hidden = !self.gridIsVisible;
    
    [self loadCameraRollThumbnail];

#else
#endif
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
    self.navigationController.navigationBar.titleTextAttributes = @{ NSForegroundColorAttributeName : [UIColor whiteColor] };
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    self.takePictureButton.enabled = YES;
    
    dispatch_async( dispatch_get_main_queue(), ^
    {
        if( !self.captureManager.previewLayer.connection.enabled )
        {
            self.captureManager.previewLayer.connection.enabled = YES;
        }
    });
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
    
    self.takePictureButton.enabled = NO;
    self.pictureTaken = nil;
    
    if( ![self.captureManager cameraIsFocusing] )
    {
        [self animateShutter];
    }
    else
    {
        self.shouldShutterAfterFocus = YES;
    }
}

- (void)animateShutter
{
    UIView *shutterView = [[UIView alloc] initWithFrame:self.videoView.frame];
    shutterView.backgroundColor = [UIColor blackColor];
    shutterView.alpha = 0;
    [self.view addSubview:shutterView];
    
    UIViewAnimationOptions options =  UIViewAnimationOptionCurveLinear;
    
    [UIView animateWithDuration:0.1 delay:0 options:options animations:^
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
                    
                    dispatch_async( dispatch_get_main_queue(), ^
                    {
                        self.captureManager.previewLayer.connection.enabled = NO;
                    });
                      
                    [self performSegueWithIdentifier:@"chooseFilter" sender:nil];
                }
            }];
        }
    }];
}

- (void)captureManager:(DACaptureManager *)captureManager didCaptureImage:(UIImage *)image
{
    dispatch_async( dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0 ), ^
    {        
        CGFloat cropWidth = ( image.size.width / self.videoView.bounds.size.width ) * self.view.bounds.size.width;
        CGFloat cropHeight = ( image.size.height / self.videoView.bounds.size.height ) * self.gridImageView.bounds.size.height;
        
        CGFloat x = 0;
        CGFloat y = ( self.gridImageView.frame.origin.y - self.videoView.frame.origin.y ) * ( image.size.height / self.videoView.bounds.size.height );
        
        CGRect cropRect = CGRectMake( x, y, cropWidth, cropHeight );
        
        CGImageRef imageRef = CGImageCreateWithImageInRect( [image CGImage], cropRect );
        UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
        CGImageRelease( imageRef );
        
        self.pictureTaken = [self scaleDownImage:croppedImage];
        
        [self performSelectorOnMainThread:@selector(imageIsReady:) withObject:self.pictureTaken waitUntilDone:NO];
    });
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if( gestureRecognizer == self.pinchGesture )
    {
        self.beginGestureScale = self.effectiveScale;
    }
    
    return YES;
}

- (IBAction)handlePinchGesture:(UIPinchGestureRecognizer *)sender
{
    BOOL allTouchesAreOnThePreviewLayer = YES;
    
	NSUInteger numTouches = [sender numberOfTouches];
    
	for( int i = 0; i < numTouches; ++i )
    {
		CGPoint location = [sender locationOfTouch:i inView:self.videoView];
        
		CGPoint convertedLocation = [self.captureManager.previewLayer convertPoint:location fromLayer:self.captureManager.previewLayer.superlayer];
        
		if( ![self.captureManager.previewLayer containsPoint:convertedLocation] )
        {
			allTouchesAreOnThePreviewLayer = NO;
			break;
		}
	}
	
	if( allTouchesAreOnThePreviewLayer )
    {
		self.effectiveScale = self.beginGestureScale * sender.scale;
        
		if( self.effectiveScale < 1.0 )
        {
            self.effectiveScale = 1.0;
        }
        
		CGFloat maxScaleAndCropFactor = [[self.captureManager sessionConnection] videoMaxScaleAndCropFactor];
        
		if( self.effectiveScale > maxScaleAndCropFactor )
        {
			self.effectiveScale = maxScaleAndCropFactor;
        }
        
        [[self.captureManager sessionConnection] setVideoScaleAndCropFactor:self.effectiveScale];
        
		[CATransaction begin];
		[CATransaction setAnimationDuration:.025];
		[self.captureManager.previewLayer setAffineTransform:CGAffineTransformMakeScale( self.effectiveScale, self.effectiveScale )];
		[CATransaction commit];
	}
}

- (IBAction)handleTapGesture:(UITapGestureRecognizer *)sender
{
    if( [self.captureManager isTapToFocusSupported] )
    {
        CGPoint tapPoint = [sender locationInView:self.videoView];
        [self.captureManager focusAtPoint:tapPoint inFrame:self.videoView.frame];
        
        if( self.focusView )
        {
            [self.focusView removeFromSuperview];
        }
        
        self.focusView = [self focusViewAtPoint:tapPoint];
        [self.videoView addSubview:self.focusView];
        [self.focusView setNeedsDisplay];
        
        [UIView animateWithDuration:2.0f animations:^
        {
            self.focusView.alpha = 0.0f;
        }
        completion:^( BOOL finished )
        {
            if( finished )
            {
                [self.focusView removeFromSuperview];
            }
        }];
    }
}

- (UIView *)focusViewAtPoint:(CGPoint)point
{
    UIView *focusView = [[UIView alloc] initWithFrame:CGRectMake( point.x - 40, point.y - 40, 80, 80 )];
    focusView.backgroundColor = [UIColor clearColor];
    focusView.layer.borderWidth = 1.5f;
    focusView.layer.borderColor = [UIColor whiteColor].CGColor;
    
    CABasicAnimation* selectionAnimation = [CABasicAnimation animationWithKeyPath:@"borderColor"];
    selectionAnimation.toValue = (id)[UIColor yellowColor].CGColor;
    selectionAnimation.repeatCount = 8;
    [focusView.layer addAnimation:selectionAnimation forKey:@"selectionAnimation"];
    
    return focusView;
}

- (void)imageIsReady:(UIImage *)image
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kImageReadyNotificationKey object:image];
}

- (void)captureManagerDidFinishAdjustingFocus:(DACaptureManager *)captureManager
{
    if( self.shouldShutterAfterFocus )
    {
        self.shouldShutterAfterFocus = NO;
        [self animateShutter];
    }
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
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    self.pictureTaken = chosenImage;
    
    self.takePictureButton.enabled = NO;
    
    [self dismissViewControllerAnimated:YES completion:^
    {
        dispatch_async( dispatch_get_main_queue(), ^
        {
            self.captureManager.previewLayer.connection.enabled = NO;
        });
        
        [self performSegueWithIdentifier:@"chooseFilter" sender:nil];
    }];
}

- (IBAction)cancelReview:(UIBarButtonItem *)sender
{
    [[DALocationManager sharedManager] stopUpdatingLocation];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (UIImage *)scaleDownImage:(UIImage *)image
{
    CIImage *beginImage = [CIImage imageWithCGImage:image.CGImage];
    
    CIFilter *scaleFilter = [CIFilter filterWithName:@"CILanczosScaleTransform"];
    [scaleFilter setValue:beginImage forKey:kCIInputImageKey];
    [scaleFilter setValue:@(0.5f) forKey:kCIInputScaleKey];
    [scaleFilter setValue:@(1.0f) forKey:kCIInputAspectRatioKey];
    
    CIImage *outputImage = [scaleFilter outputImage];
    
    CGImageRef imageRef = [[CIContext contextWithOptions:nil] createCGImage:outputImage fromRect:outputImage.extent];
    UIImage *newImg = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    return newImg;
}

@end