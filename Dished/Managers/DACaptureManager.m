//
//  DACaptureManager.m
//  Dished
//
//  Created by Ryan Khalili on 6/29/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DACaptureManager.h"


@interface DACaptureManager() <AVCaptureVideoDataOutputSampleBufferDelegate>

@property (strong, nonatomic) AVCaptureDevice  *backCamera;
@property (strong, nonatomic) AVCaptureDevice  *frontCamera;
@property (strong, nonatomic) AVCaptureDevice  *currentDevice;
@property (strong, nonatomic) AVCaptureSession *captureSession;

@end


@implementation DACaptureManager

- (id)init
{
    self = [super init];
    
    if( self )
    {
        [self setupSession];
    }
    
    return self;
}

- (void)setupSession
{
    self.captureSession = [[AVCaptureSession alloc] init];
    self.captureSession.sessionPreset = AVCaptureSessionPresetPhoto;
    
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:self.backCamera error:nil];
    self.currentDevice = self.backCamera;
    
    if( [self.captureSession canAddInput:videoInput] )
    {
        [self.captureSession addInput:videoInput];
    }
    
    AVCaptureStillImageOutput *stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    
    if( [self.captureSession canAddOutput:stillImageOutput] )
    {
        [self.captureSession addOutput:stillImageOutput];
    }
    
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:[self captureSession]];
	[self.previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
}

- (void)startCapture
{
    [self.captureSession startRunning];
}

- (void)toggleCamera
{
    if ([[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count] > 1)
    {
        AVCaptureDeviceInput *newVideoInput = nil;
        
        AVCaptureDeviceInput *currentInput = [self.captureSession.inputs lastObject];
        AVCaptureDevicePosition position = [currentInput.device position];
        
        if( position == AVCaptureDevicePositionBack )
        {
            newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:self.frontCamera error:nil];
            self.currentDevice = self.frontCamera;
        }
        else if( position == AVCaptureDevicePositionFront )
        {
            newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:self.backCamera error:nil];
            self.currentDevice = self.backCamera;
        }
        
        if( newVideoInput != nil )
        {
            [self.captureSession beginConfiguration];
            [self.captureSession removeInput:currentInput];
            
            if( [self.captureSession canAddInput:newVideoInput] )
            {
                [self.captureSession addInput:newVideoInput];
            }
            else
            {
                [self.captureSession addInput:currentInput];
            }
            
            [self.captureSession commitConfiguration];
        }
    }
}

- (void)captureStillImage
{
    
}

- (void)enableFlash:(BOOL)enabled
{
    if( enabled )
    {
        if( [self.currentDevice hasFlash] )
        {
            if( [self.currentDevice isFlashModeSupported:AVCaptureFlashModeOn] )
            {
                if( self.currentDevice.flashAvailable )
                {
                    self.currentDevice.flashMode = AVCaptureFlashModeOn;
                }
            }
        }
    }
    else
    {
        self.currentDevice.flashMode = AVCaptureFlashModeOff;
    }
}

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    
    for( AVCaptureDevice *device in devices )
    {
        if( [device position] == position )
        {
            return device;
        }
    }
    
    return nil;
}

- (AVCaptureDevice *)backCamera
{
    if( !_backCamera )
    {
        _backCamera = [self cameraWithPosition:AVCaptureDevicePositionBack];
    }
    
    return _backCamera;
}

- (AVCaptureDevice *)frontCamera
{
    if( !_frontCamera )
    {
        _frontCamera = [self cameraWithPosition:AVCaptureDevicePositionFront];
    }
    
    return _frontCamera;
}

@end