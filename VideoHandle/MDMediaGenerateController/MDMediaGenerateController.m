//
//  ViewController.m
//  CaptureMovie
//
//  Created by 没懂 on 16/1/27.
//  Copyright © 2016年 com.comelet. All rights reserved.
//

#import "MDMediaGenerateController.h"
#import "AVCaptureView.h"
#import <AVFoundation/AVFoundation.h>
#import "MDCaptureTool.h"
#define Width self.view.frame.size.width
#define Height self.view.frame.size.height

@interface MDMediaGenerateController ()

@property (nonatomic, strong) MDCaptureTool *tool;

@end

@implementation MDMediaGenerateController

-(MDCaptureTool *)tool
{
    if (_tool == nil) {
        _tool = [[MDCaptureTool alloc]init];
    }
    return _tool;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.tool.checkDeviceAuthorizationStatus();
    self.tool.addCaptureViewToControllerAndPerpareSession(self,CGRectMake(0, 20, Width, Height));
    self.tool.addSomeToyToControllerView(self);
}

-(void)viewWillAppear:(BOOL)animated
{
    self.tool.viewdidAppearAddOberver();
}
// 设置屏幕显示的方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}
// 输出信号（view方向随着画面动）
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [[(AVCaptureVideoPreviewLayer *)[self.tool.captureView layer] connection] setVideoOrientation:(AVCaptureVideoOrientation)toInterfaceOrientation];
}

-(void)viewWillDisappear:(BOOL)animated
{
    self.tool.viewdidDisappearRemoveObserver();
}

@end
