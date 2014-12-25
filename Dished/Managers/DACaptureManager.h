//
//  DACaptureManager.h
//  Dished
//
//  Created by Ryan Khalili on 6/29/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>


@class DACaptureManager;


@protocol DACaptureManagerDelegate <NSObject>

@required
- (void)captureManager:(DACaptureManager *)captureManager didCaptureImage:(UIImage *)image;

@optional
- (void)captureManagerDidBeginAdjustingFocus:(DACaptureManager *)captureManager;
- (void)captureManagerDidFinishAdjustingFocus:(DACaptureManager *)captureManager;

@end


@interface DACaptureManager : NSObject

@property (strong, nonatomic) AVCaptureVideoPreviewLayer *previewLayer;
@property (weak, nonatomic) id<DACaptureManagerDelegate> delegate;

- (void)startCapture;
- (void)stopCapture;
- (BOOL)isCapturing;
- (BOOL)isCaptureConnectionActive;
- (void)toggleCamera;
- (void)captureStillImage;
- (void)enableFlash:(BOOL)enabled;
- (BOOL)isFlashOn;
- (BOOL)cameraIsFocusing;
- (BOOL)isTapToFocusSupported;
- (AVCaptureConnection *)sessionConnection;
- (void)focusAtPoint:(CGPoint)point inFrame:(CGRect)frame;

@end