//
//  DACaptureManager.h
//  Dished
//
//  Created by Ryan Khalili on 6/29/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface DACaptureManager : NSObject

@property (strong, nonatomic) AVCaptureVideoPreviewLayer *previewLayer;

- (void)startCapture;
- (void)toggleCamera;
- (void)captureStillImage;
- (void)enableFlash:(BOOL)enabled;

@end