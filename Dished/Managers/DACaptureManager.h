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

@end


@interface DACaptureManager : NSObject

@property (strong, nonatomic) AVCaptureVideoPreviewLayer *previewLayer;
@property (weak, nonatomic) id<DACaptureManagerDelegate> delegate;

- (void)startCapture;
- (void)stopCapture;
- (void)toggleCamera;
- (void)captureStillImage;
- (void)enableFlash:(BOOL)enabled;
- (BOOL)isFlashOn;

@end