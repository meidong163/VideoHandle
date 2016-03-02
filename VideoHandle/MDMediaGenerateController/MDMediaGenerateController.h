//
//  ViewController.h
//  CaptureMovie
//
//  Created by 没懂 on 16/1/27.
//  Copyright © 2016年 com.comelet. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AVCaptureSession;
@interface MDMediaGenerateController : UIViewController
@property (nonatomic, strong)AVCaptureSession *session;
@property (nonatomic)dispatch_queue_t sessionQueue;
@end

