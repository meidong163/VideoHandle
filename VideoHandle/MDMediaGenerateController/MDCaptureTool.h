//
//  MDCaptureTool.h
//  VideoHandle
//
//  Created by 没懂 on 16/3/2.
//  Copyright © 2016年 com.comelet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class AVCaptureView,AVCaptureSession,AVCaptureDeviceInput,AVCaptureAudioDataOutput,AVCaptureMovieFileOutput,AVCaptureStillImageOutput;
@interface MDCaptureTool : NSObject
@property (strong, nonatomic)  AVCaptureView *captureView;

#pragma mark -method
- (MDCaptureTool *(^)(UIViewController *,CGRect))addCaptureViewToControllerAndPerpareSession;
- (MDCaptureTool *(^)())checkDeviceAuthorizationStatus;
- (MDCaptureTool *(^)(UIViewController*))addSomeToyToControllerView;
- (MDCaptureTool *(^)())viewdidAppearAddOberver;
- (MDCaptureTool *(^)())viewdidDisappearRemoveObserver;
@end
