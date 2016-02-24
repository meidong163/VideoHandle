//
//  AVCaptureView.h
//  CaptureMovie
//
//  Created by 没懂 on 16/1/28.
//  Copyright © 2016年 com.comelet. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AVCaptureSession;

@interface AVCaptureView : UIView

@property (nonatomic)AVCaptureSession *session;

@end
