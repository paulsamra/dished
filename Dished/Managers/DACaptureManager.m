//
//  DACaptureManager.m
//  Dished
//
//  Created by Ryan Khalili on 6/29/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DACaptureManager.h"
#import <UIKit/UIKit.h>
#import "UIImage+Orientation.h"


@interface DACaptureManager()

@property (strong, nonatomic) AVCaptureDevice           *backCamera;
@property (strong, nonatomic) AVCaptureDevice           *frontCamera;
@property (strong, nonatomic) AVCaptureDevice           *currentDevice;
@property (strong, nonatomic) AVCaptureSession          *captureSession;
@property (strong, nonatomic) AVCaptureStillImageOutput *stillImageOutput;
@property (strong, nonatomic) AVCaptureConnection       *connection;

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
    
    self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    self.stillImageOutput.outputSettings = @{ (id)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA) };
    
    if( [self.captureSession canAddOutput:self.stillImageOutput] )
    {
        [self.captureSession addOutput:self.stillImageOutput];
    }
    
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:[self captureSession]];
	[self.previewLayer setVideoGravity:AVLayerVideoGravityResize];
}

- (void)startCapture
{
    [self.captureSession startRunning];
}

- (void)stopCapture
{
    [self.captureSession stopRunning];
}

- (void)toggleCamera
{
    if( [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count] > 1 )
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

- (UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer
{
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                                 bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    UIImage *image = nil;
    
    if( self.currentDevice.position == AVCaptureDevicePositionBack )
    {
        image = [UIImage imageWithCGImage:quartzImage scale:1 orientation:UIImageOrientationRight];
    }
    else
    {
        image = [UIImage imageWithCGImage:quartzImage scale:1 orientation:UIImageOrientationLeftMirrored];
    }
    
    CGImageRelease(quartzImage);
    
    return (image);
}

- (void)captureStillImage
{
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:[self sessionConnection]
    completionHandler:^( CMSampleBufferRef imageSampleBuffer, NSError *error )
    {
        if( imageSampleBuffer )
        {
            UIImage *image = [self imageFromSampleBuffer:imageSampleBuffer];
            
            [self performSelectorOnMainThread:@selector(callDelegateWithImage:) withObject:image waitUntilDone:NO];
        }
    }];
}

- (void)callDelegateWithImage:(UIImage *)image
{
    if( [self.delegate respondsToSelector:@selector(captureManager:didCaptureImage:)] )
    {
        [self.delegate captureManager:self didCaptureImage:image];
    }
}

- (AVCaptureConnection *)sessionConnection
{
    AVCaptureConnection *videoConnection = nil;
    
    for( AVCaptureConnection *connection in self.stillImageOutput.connections )
    {
        for( AVCaptureInputPort *port in [connection inputPorts] )
        {
            if( [[port mediaType] isEqual:AVMediaTypeVideo] )
            {
                videoConnection = connection;
                break;
            }
        }
        
        if( videoConnection )
        {
            break;
        }
    }
    
    if( [videoConnection isVideoOrientationSupported] )
    {
        videoConnection.videoOrientation = AVCaptureVideoOrientationPortrait;
    }
    
    return videoConnection;
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
                    [self.currentDevice lockForConfiguration:nil];
                    self.currentDevice.flashMode = AVCaptureFlashModeOn;
                    [self.currentDevice unlockForConfiguration];
                }
            }
        }
    }
    else
    {
        if( [self.currentDevice hasFlash] )
        {
            if( [self.currentDevice isFlashModeSupported:AVCaptureFlashModeOff] )
            {
                [self.currentDevice lockForConfiguration:nil];
                self.currentDevice.flashMode = AVCaptureFlashModeOff;
                [self.currentDevice unlockForConfiguration];
            }
        }
    }
}

- (BOOL)isFlashOn
{
    if( self.currentDevice.flashMode == AVCaptureFlashModeOn )
    {
        return YES;
    }
    else
    {
        return NO;
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