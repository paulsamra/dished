//
//  DACaptureManager.m
//  Dished
//
//  Created by Ryan Khalili on 6/29/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DACaptureManager.h"
#import <UIKit/UIKit.h>
#import <Accelerate/Accelerate.h>


@interface DACaptureManager() <AVCaptureVideoDataOutputSampleBufferDelegate>

@property (strong, nonatomic) AVCaptureDevice           *backCamera;
@property (strong, nonatomic) AVCaptureDevice           *frontCamera;
@property (strong, nonatomic) AVCaptureDevice           *currentDevice;
@property (strong, nonatomic) AVCaptureSession          *captureSession;
@property (strong, nonatomic) AVCaptureDeviceInput      *videoInput;
@property (strong, nonatomic) AVCaptureStillImageOutput *stillImageOutput;

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
    
    self.videoInput = [AVCaptureDeviceInput deviceInputWithDevice:self.backCamera error:nil];
    self.currentDevice = self.backCamera;
    
    if( [self.captureSession canAddInput:self.videoInput] )
    {
        [self.captureSession addInput:self.videoInput];
    }
    
    NSDictionary *outputSettings = @{ (NSString *)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA) };
    
    self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    self.stillImageOutput.outputSettings = outputSettings;
    
    if( [self.captureSession canAddOutput:self.stillImageOutput] )
    {
        [self.captureSession addOutput:self.stillImageOutput];
    }
    
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:[self captureSession]];
	[self.previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    int flags = NSKeyValueObservingOptionNew;
    [self.currentDevice addObserver:self forKeyPath:@"adjustingFocus" options:flags context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if( [keyPath isEqualToString:@"adjustingFocus"] )
    {
        BOOL adjustingFocus = [[change objectForKey:NSKeyValueChangeNewKey] isEqualToNumber:[NSNumber numberWithInt:1]];
        
        if( adjustingFocus )
        {
            if( [self.delegate respondsToSelector:@selector(captureManagerDidBeginAdjustingFocus:)] )
            {
                [self.delegate captureManagerDidBeginAdjustingFocus:self];
            }
        }
        else
        {
            if( [self.delegate respondsToSelector:@selector(captureManagerDidFinishAdjustingFocus:)] )
            {
                [self.delegate captureManagerDidFinishAdjustingFocus:self];
            }
        }
    }
}

- (BOOL)cameraIsFocusing
{
    return self.currentDevice.adjustingFocus;
}

- (void)startCapture
{
    [self.captureSession startRunning];
}

- (void)stopCapture
{
    [self.captureSession stopRunning];
}

- (BOOL)isCapturing
{
    return [self.captureSession isRunning];
}

- (BOOL)isCaptureConnectionActive
{
    return [self sessionConnection].active && [self sessionConnection].enabled;
}

- (void)toggleCamera
{
    [self.currentDevice removeObserver:self forKeyPath:@"adjustingFocus"];
    
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
        
        int flags = NSKeyValueObservingOptionNew;
        [self.currentDevice addObserver:self forKeyPath:@"adjustingFocus" options:flags context:nil];
        
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

- (CVPixelBufferRef)rotateBuffer:(CMSampleBufferRef)sampleBuffer
{
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer( sampleBuffer );
    CVPixelBufferLockBaseAddress( imageBuffer, 0 );
    
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow( imageBuffer );
    size_t width = CVPixelBufferGetWidth( imageBuffer );
    size_t height = CVPixelBufferGetHeight( imageBuffer );
    size_t currSize = bytesPerRow * height * sizeof( unsigned char );
    size_t bytesPerRowOut = 4 * height * sizeof( unsigned char );
    
    uint8_t rotationConstant = 3;
    
    void *srcBuff = CVPixelBufferGetBaseAddress( imageBuffer );
    
    unsigned char *outBuff = (unsigned char *)malloc( currSize );
    
    vImage_Buffer iBuff =
    {
        srcBuff, height, width, bytesPerRow
    };
    
    vImage_Buffer uBuff =
    {
        outBuff, width, height, bytesPerRowOut
    };
    
    uint8_t bgColor[4] = { 0, 0, 0, 0 };
    
    vImage_Error error = vImageRotate90_ARGB8888(&iBuff, &uBuff, rotationConstant, bgColor, 0);
    
    if( error != kvImageNoError )
    {
        NSLog(@"ERROR IN VIMAGE");
    }
    
    CVPixelBufferRef rotatedBuffer = NULL;
    CVPixelBufferCreateWithBytes(NULL,
                                 height,
                                 width,
                                 kCVPixelFormatType_32BGRA,
                                 uBuff.data,
                                 bytesPerRowOut,
                                 freePixelBufferDataAfterRelease,
                                 NULL,
                                 NULL,
                                 &rotatedBuffer);
    
    return rotatedBuffer;
}

void freePixelBufferDataAfterRelease(void *releaseRefCon, const void *baseAddress)
{
    free((void *)baseAddress);
}

- (UIImage *)imageFromCVPixelBuffer:(CVPixelBufferRef)pixelBuffer
{
    size_t w = CVPixelBufferGetWidth(pixelBuffer);
    size_t h = CVPixelBufferGetHeight(pixelBuffer);
    
    CVPixelBufferLockBaseAddress( pixelBuffer, 0 );
    
    unsigned char *buffer = CVPixelBufferGetBaseAddress(pixelBuffer);
    
    UIGraphicsBeginImageContext(CGSizeMake(w, h));
    
    CGContextRef c = UIGraphicsGetCurrentContext();
    
    unsigned char* data = CGBitmapContextGetData(c);
    
    memcpy(data, buffer, CVPixelBufferGetDataSize( pixelBuffer) );
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    CVPixelBufferUnlockBaseAddress( pixelBuffer, 0 );
    
    return img;
}

- (void)captureStillImage
{
    AVCaptureConnection *currentConnection = [self sessionConnection];
    
    if( currentConnection.enabled && currentConnection.active )
    {
        [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:[self sessionConnection]
        completionHandler:^( CMSampleBufferRef imageSampleBuffer, NSError *error )
        {
            if( imageSampleBuffer )
            {
                [self receivedSampleBuffer:imageSampleBuffer];
            }
        }];
    }
}

- (void)receivedSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    CVPixelBufferRef rotatedBuffer = [self rotateBuffer:sampleBuffer];
    UIImage *image = [self imageFromCVPixelBuffer:rotatedBuffer];
    CVBufferRelease( rotatedBuffer );
    
    [self performSelectorOnMainThread:@selector(callDelegateWithImage:) withObject:image waitUntilDone:NO];
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
    
    return videoConnection;
}

- (void)focusAtPoint:(CGPoint)point inFrame:(CGRect)frame
{
    CGPoint focusPoint = [self convertToPointOfInterestFromViewCoordinates:point inFrame:frame];
    
    AVCaptureDevice *device = [[self videoInput] device];
    
    if( [device isFocusPointOfInterestSupported] && [device isFocusModeSupported:AVCaptureFocusModeAutoFocus] )
    {
        NSError *error;
        
        if( [device lockForConfiguration:&error] )
        {
            [device setFocusPointOfInterest:focusPoint];
            [device setFocusMode:AVCaptureFocusModeAutoFocus];
            [device unlockForConfiguration];
        }
    }
}

- (CGPoint)convertToPointOfInterestFromViewCoordinates:(CGPoint)viewCoordinates inFrame:(CGRect)frame
{
    CGPoint pointOfInterest = CGPointMake( 0.5f, 0.5f );
    CGSize frameSize = frame.size;
    
    if( [self sessionConnection].videoMirrored )
    {
        viewCoordinates.x = frameSize.width - viewCoordinates.x;
    }
    
    CGRect cleanAperture;
    
    for( AVCaptureInputPort *port in [self.videoInput ports] )
    {
        if( port.mediaType == AVMediaTypeVideo )
        {
            cleanAperture = CMVideoFormatDescriptionGetCleanAperture( [port formatDescription], YES );
            CGSize apertureSize = cleanAperture.size;
            CGPoint newPoint = viewCoordinates;
            
            CGFloat apertureRatio = apertureSize.height / apertureSize.width;
            CGFloat viewRatio = frameSize.width / frameSize.height;
            CGFloat xc = 0.5f;
            CGFloat yc = 0.5f;
            
            if( viewRatio > apertureRatio )
            {
                CGFloat y2 = apertureSize.width * ( frameSize.width / apertureSize.height );
                xc = ( newPoint.y + ( ( y2 - frameSize.height ) / 2.f ) ) / y2;
                yc = ( frameSize.width - newPoint.x ) / frameSize.width;
            }
            else
            {
                CGFloat x2 = apertureSize.height * ( frameSize.height / apertureSize.width );
                yc = 1.f - ( ( newPoint.x + ( ( x2 - frameSize.width ) / 2 ) ) / x2 );
                xc = newPoint.y / frameSize.height;
            }
            
            pointOfInterest = CGPointMake( xc, yc );
            break;
        }
    }
    
    return pointOfInterest;
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

- (BOOL)isTapToFocusSupported
{
    return [self.currentDevice isFocusPointOfInterestSupported];
}

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    
    for( AVCaptureDevice *device in devices )
    {
        if( [device position] == position )
        {
            if( [device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure] )
            {
                [device lockForConfiguration:nil];
                device.exposureMode = AVCaptureExposureModeContinuousAutoExposure;
                [device unlockForConfiguration];
            }
            
            if( [device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance] )
            {
                [device lockForConfiguration:nil];
                device.whiteBalanceMode = AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance;
                [device unlockForConfiguration];
            }
            
            return device;
        }
    }
    
    return nil;
}

- (void)dealloc
{
    [self.currentDevice removeObserver:self forKeyPath:@"adjustingFocus"];
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