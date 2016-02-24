//
//  AVCaptureView.m
//  CaptureMovie
//
//  Created by 没懂 on 16/1/28.
//  Copyright © 2016年 com.comelet. All rights reserved.
//

#import "AVCaptureView.h"
#import <AVFoundation/AVFoundation.h>

@implementation AVCaptureView
+ (Class)layerClass
{
    return [AVCaptureVideoPreviewLayer class];
}

- (AVCaptureSession *)session
{
    return [(AVCaptureVideoPreviewLayer *)[self layer] session];
}

- (void)setSession:(AVCaptureSession *)session
{
    [(AVCaptureVideoPreviewLayer *)[self layer] setSession:session];
}

@end
