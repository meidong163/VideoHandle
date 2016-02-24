//
//  ViewController.m
//  CaptureMovie
//
//  Created by 没懂 on 16/1/27.
//  Copyright © 2016年 com.comelet. All rights reserved.
//

#import "MDMediaGenerateController.h"
#import "AVCaptureView.h"
#import <AssetsLibrary/AssetsLibrary.h>//资源库，访问本地相册的
#import <AVFoundation/AVFoundation.h>
#define Width self.view.frame.size.width
#define Height self.view.frame.size.height
// 有内涵的标记
static void * CapturingStillImageContext = &CapturingStillImageContext;
static void * RecordingContext = &RecordingContext;
static void * SessionRunningAndDeviceAuthorizedContext = &SessionRunningAndDeviceAuthorizedContext;

@interface MDMediaGenerateController () <AVCaptureFileOutputRecordingDelegate>
@property (strong, nonatomic) IBOutlet UIButton *recodingBtn;
@property (strong, nonatomic) IBOutlet UIButton *stillBtn;
@property (strong, nonatomic) IBOutlet UIButton *exchangeBtn;
@property (weak, nonatomic) IBOutlet AVCaptureView *captureView;

@property (nonatomic, strong)UIButton *btn;

@property (nonatomic)AVCaptureSession *session;
/**
 *  渲染图片的层
 */
//@property (nonatomic)AVCaptureView *previewView;
/**
 *  授权状态
 */
@property (nonatomic, getter=isDeviceAuthorized)BOOL deviceAuthorized;
@property (nonatomic)dispatch_queue_t sessionQueue;
@property (nonatomic)UIBackgroundTaskIdentifier backgroundTaskID;
// 输入的数据是调用的那个设备
@property (nonatomic)AVCaptureDeviceInput *captureDeviceInput;

/**
 *  做录音文件的
 */
@property (nonatomic)AVCaptureAudioDataOutput *audioOutput;
/**
 *  视频输出
 */
@property (nonatomic)AVCaptureMovieFileOutput *videoOutput;
/**
 *  图片输出
 */
@property (nonatomic)AVCaptureStillImageOutput *imageOutput;
/**
 *  会话运行，设备授权
 */
@property (nonatomic, readonly, getter = isSessionRunningAndDeviceAuthorized) BOOL sessionRunningAndDeviceAuthorized;
/**
 *  运行时错误监听者
 */
@property (nonatomic) id runtimeErrorHandlingObserver;

@property (nonatomic, assign)BOOL lockInterfaceRotation;

@end

@implementation MDMediaGenerateController

- (BOOL)isSessionRunningAndDeviceAuthorized
{
    return [[self session] isRunning] && [self isDeviceAuthorized];
}
// 这个东西干什么的不熟悉？
+ (NSSet *)keyPathsForValuesAffectingSessionRunningAndDeviceAuthorized
{
    return [NSSet setWithObjects:@"session.running", @"deviceAuthorized", nil];
}

- (UIButton *)setButton:(NSString *)buttontitle sel:(SEL)action frame:(CGRect)frame
{
    UIButton *startBtn = [[UIButton alloc]initWithFrame:frame];
    startBtn.autoresizingMask = UIViewContentModeBottom |UIViewContentModeBottomLeft | UIViewContentModeBottomRight;
    startBtn.backgroundColor = [UIColor grayColor];
    [startBtn setTitle:buttontitle forState:UIControlStateNormal];
    [startBtn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:startBtn];
    return startBtn;
}

/**
 *  设备添加到会话
 *  输入设备，输出设备，
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    // 1.创建一个录制回话
    AVCaptureSession *ssession = [[AVCaptureSession alloc]init];
    self.session = ssession;
    // 2.指定渲染图层 -回话渲染到图层
    AVCaptureView *captureView = [[AVCaptureView alloc]initWithFrame:CGRectMake(0, 20, Width, Height)];
    //搞定横屏下的问题。
    captureView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin |UIViewAutoresizingFlexibleLeftMargin |UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:captureView];
    // 初始化按钮
   self.recodingBtn = [self setButton:@"Record" sel:@selector(didClickRecoding:) frame:CGRectMake(20, Height - 100, 80, 40)];
   self.stillBtn = [self setButton:@"Still" sel:@selector(didClickStill:) frame:CGRectMake(Width / 2 - 40, Height - 100, 80, 40) ];
   self.exchangeBtn = [self setButton:@"exchange" sel:@selector(didClickExchangeCamra:) frame:CGRectMake(Width - 100, Height - 100, 80, 40)];
    
    self.captureView = captureView;
    [self.captureView setSession:ssession];
    // 3.查看授权状态
    [self checkDeviceAuthorizationStatus];
    // 4.创建同步队列，实时处理图像。
    dispatch_queue_t sessionQueue = dispatch_queue_create("session Queue", DISPATCH_QUEUE_SERIAL);
    [self setSessionQueue:sessionQueue];
    dispatch_async(sessionQueue, ^{
        [self setBackgroundTaskID:UIBackgroundTaskInvalid];
        NSError *error = nil;
        // 获取到后置摄像头

        AVCaptureDevice *captureDevice = [MDMediaGenerateController deviceWithMediaType:AVMediaTypeVideo preferringPosition:AVCaptureDevicePositionBack];
        // 指定输入设备
        AVCaptureDeviceInput *captureDiviceInput = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
        if (error) {
            NSLog(@"%@",error);
        }
        // 把输入添加到会话
        if ([ssession canAddInput:captureDiviceInput]) {
            [ssession addInput:captureDiviceInput];
            [self setCaptureDeviceInput:captureDiviceInput];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[(AVCaptureVideoPreviewLayer *)[[self captureView] layer] connection] setVideoOrientation:(AVCaptureVideoOrientation)[self interfaceOrientation]];
            });
        }
        // 指定音频设备。
        AVCaptureDevice *AudioDevice = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio]firstObject];
        AVCaptureDeviceInput *audioDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:AudioDevice error:&error];
        if (error) {
            NSLog(@"%@",error);
        }
        // 音频输入设备，添加到会话
        if ([ssession canAddInput:audioDeviceInput]) {
            [ssession addInput:audioDeviceInput];
        }
        AVCaptureMovieFileOutput *movieFileOutput = [[AVCaptureMovieFileOutput alloc]init];
        // 视频输出
        if ([ssession canAddOutput:movieFileOutput]) {
            [ssession addOutput:movieFileOutput];
            AVCaptureConnection *connection = [movieFileOutput connectionWithMediaType:AVMediaTypeVideo];
            if ([connection isVideoStabilizationSupported]) {
                [connection setPreferredVideoStabilizationMode:AVCaptureVideoStabilizationModeStandard];
                [self setVideoOutput:movieFileOutput];
            }
        }
        
        AVCaptureStillImageOutput *imageOutput = [[AVCaptureStillImageOutput alloc]init];
        if ([ssession canAddOutput:imageOutput]) {
            // 输出图片的格式
            [imageOutput setOutputSettings:@{AVVideoCodecKey:AVVideoCodecJPEG}];
            [ssession addOutput:imageOutput];
            self.imageOutput = imageOutput;
        }
    });
    
}

-(void)viewWillAppear:(BOOL)animated
{
    dispatch_async([self sessionQueue], ^{
        // 监听会话是否运行 设备是否授权。
        [self addObserver:self forKeyPath:@"sessionRunningAndDeviceAuthorized" options:NSKeyValueObservingOptionNew |NSKeyValueObservingOptionOld context:SessionRunningAndDeviceAuthorizedContext];
        // 图片的属性
        [self addObserver:self forKeyPath:@"imageOutput.capturingStillImage" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:CapturingStillImageContext];
        // 视频的属性
        [self addObserver:self forKeyPath:@"videoOutput.recording" options:NSKeyValueObservingOptionNew |NSKeyValueObservingOptionOld context:RecordingContext];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subjectAreaDidChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:[self.captureDeviceInput device]];
        __weak MDMediaGenerateController *weakself = self;
        //这个东西是干什么用的？注释运行 猜* ：监听拍摄过程中的错误。并发送通知
        // 监听线程的一个通知，如果线程出现错误，收到通知后执行block
        
        [self setRuntimeErrorHandlingObserver:[[NSNotificationCenter defaultCenter] addObserverForName:AVCaptureSessionRuntimeErrorNotification object:[self session] queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            MDMediaGenerateController *strongSelf = weakself;
            dispatch_async([strongSelf sessionQueue], ^{
                [[strongSelf session]startRunning];
//                [[strongSelf recodingBtn]setTitle:NSLocalizedString(@"录制", @"Record Button record title") forState:UIControlStateNormal];
            });
        }]];
        //运行会话
        [[self session] startRunning];
    });
    
}

- (BOOL)shouldAutorotate
{
    return ![self lockInterfaceRotation];
}
// 设置屏幕显示的方向
//- (UIInterfaceOrientationMask)supportedInterfaceOrientations
//{
//    return UIInterfaceOrientationMaskLandscapeLeft;
//}
// 输出信号（view方向随着画面动）
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [[(AVCaptureVideoPreviewLayer *)[[self captureView] layer] connection] setVideoOrientation:(AVCaptureVideoOrientation)toInterfaceOrientation];
}
/**
 *  集成到项目中的
 */
-(void)viewWillDisappear:(BOOL)animated
{
    dispatch_async([self sessionQueue], ^{
        [[self session]stopRunning];
        [self removeObserver:self forKeyPath:@"sessionRunningAndDeviceAuthorized"context:SessionRunningAndDeviceAuthorizedContext];
        [self removeObserver:self forKeyPath:@"videoOutput.recording"context:RecordingContext];
        [self removeObserver:self forKeyPath:@"imageOutput.capturingStillImage" context:CapturingStillImageContext];
        [[NSNotificationCenter defaultCenter]removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:[self.captureDeviceInput device]];
        [[NSNotificationCenter defaultCenter]removeObserver:self.runtimeErrorHandlingObserver];//这样添加通知也是一种好方式
    });
    
}

/**
 *  猜：摄像头移动－－调教的
 */
- (void)subjectAreaDidChange:(NSNotification *)notification
{
    CGPoint devicePoint = CGPointMake(.5, .5);
    [self focusWithMode:AVCaptureFocusModeContinuousAutoFocus exposeWithMode:AVCaptureExposureModeContinuousAutoExposure atDevicePoint:devicePoint monitorSubjectAreaChange:NO];
}

// 配置一下设备相关的属性。－对焦的模式,亮度，获取人的头像，这可能需要算法做。 这里边的一些东西并没有动。－－ 不知何时调用？
- (void)focusWithMode:(AVCaptureFocusMode)focusMode exposeWithMode:(AVCaptureExposureMode)exposureMode atDevicePoint:(CGPoint)point monitorSubjectAreaChange:(BOOL)monitorSubjectAreaChange
{
    dispatch_async([self sessionQueue], ^{
        AVCaptureDevice *device = [[self captureDeviceInput] device];
        NSError *error = nil;
        if ([device lockForConfiguration:&error])
        {
            if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:focusMode])
            {
                [device setFocusMode:focusMode];
                [device setFocusPointOfInterest:point];
            }
            if ([device isExposurePointOfInterestSupported] && [device isExposureModeSupported:exposureMode])
            {
                [device setExposureMode:exposureMode];
                [device setExposurePointOfInterest:point];
            }
            [device setSubjectAreaChangeMonitoringEnabled:monitorSubjectAreaChange];
            [device unlockForConfiguration];
        }
        else
        {
            NSLog(@"%@", error);
        }
    });
}
#pragma mark - File Output Delegate
// 代理方法 ——方法什么时候调用？－ 写到文件中调用，猜：录制的时候
-(void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error
{
    if (error) {
        NSLog(@"%@",error);
    }
    UIBackgroundTaskIdentifier backgroundRecordingID = [self backgroundTaskID];
    [self setBackgroundTaskID:UIBackgroundTaskInvalid];
    //资源类
    [[[ALAssetsLibrary alloc]init ] writeVideoAtPathToSavedPhotosAlbum:outputFileURL completionBlock:^(NSURL *assetURL, NSError *error) {
        if (error) {
            NSLog(@"%@",error);
            [[NSFileManager defaultManager] removeItemAtURL:outputFileURL error:nil];
            if (backgroundRecordingID != UIBackgroundTaskInvalid) {
                [[UIApplication sharedApplication ]endBackgroundTask:backgroundRecordingID];
            }
        }
    }];
    
}
#pragma mark - delegate use to
// 根据监听的情况做事情 － 修改，button 的title，以及设置一些button能不能点。
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if (context == CapturingStillImageContext) {
        BOOL isCapturingStillImage = [change[NSKeyValueChangeNewKey]boolValue];
        if (isCapturingStillImage) {
            // 闪屏动作
            [self runStillImageCamare];
        }
    }else if (context == RecordingContext)
    {
        BOOL isRecording = [change[NSKeyValueChangeNewKey]boolValue];
        // 到主线程修改UI - 在viewDidLoad中不能修改吗？为什么要这样去设计呢？
        dispatch_async(dispatch_get_main_queue(), ^{
            if (isRecording) {
                [self.exchangeBtn setEnabled:YES];// 并没有改掉文字
//                [self.recodingBtn setTitle:NSLocalizedString(@"Stop", @"Recording button stop title") forState:UIControlStateNormal];
                [self.recodingBtn setTitle:@"Stop" forState:UIControlStateNormal];
//                [self.btn setTitle:@"haha" forState:UIControlStateNormal];
//                [self.btn setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
                [self.recodingBtn setEnabled:YES];
            }else
            {
                [self.stillBtn setEnabled:YES];
                [self.recodingBtn setTitle:NSLocalizedString(@"Record", @"Recording button record title") forState:UIControlStateNormal];
//                [self.recodingBtn setTitle:@"开始" forState:UIControlStateNormal];
//                [self.btn setTitle:@"fuck" forState:UIControlStateNormal];
//                [self.btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
                [self.recodingBtn setEnabled:YES];
            }
        });
    }else if (context == SessionRunningAndDeviceAuthorizedContext)
    {
        BOOL isRuning = [change[NSKeyValueChangeNewKey]boolValue];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (isRuning) {
                self.exchangeBtn.enabled = YES;
                self.stillBtn.enabled = YES;
                self.recodingBtn.enabled = YES;
            }else
            {
                self.exchangeBtn.enabled = NO;
                self.stillBtn.enabled = NO;
                self.recodingBtn.enabled = NO;
            }
        });
    }else
    {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

// 前置摄像头还是后置摄像头
+ (AVCaptureDevice *)deviceWithMediaType:(NSString *)mediaType preferringPosition:(AVCaptureDevicePosition)position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:mediaType];
    AVCaptureDevice *captureDevice = [devices firstObject];
    
    for (AVCaptureDevice *device in devices)
    {
        if ([device position] == position)
        {
            captureDevice = device;
            break;
        }
    }
    
    return captureDevice;
}
#pragma mark - Userintactive
- (IBAction)didClickRecoding:(id)sender {

    [[self recodingBtn]setEnabled:NO];
    dispatch_async([self sessionQueue], ^{
        if (![[self videoOutput]isRecording]) {//开始录制
            //不让屏幕旋转。
            [self setLockInterfaceRotation:YES];
            // 启动后台线程
            if ([[UIDevice currentDevice] isMultitaskingSupported]) {
                [self setBackgroundTaskID:[[UIApplication sharedApplication]beginBackgroundTaskWithExpirationHandler:nil]];
            }
            // 输出的文件和要现实的图层connection起来
            [[[self videoOutput] connectionWithMediaType:AVMediaTypeVideo] setVideoOrientation:[[(AVCaptureVideoPreviewLayer *)[self.captureView layer] connection] videoOrientation]];
            // 关闭缓存
            NSString *outPutFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[@"movieIlove"stringByAppendingPathExtension:@"mov"]];
            //开始录制了并执行代理
            [self.videoOutput startRecordingToOutputFileURL:[NSURL fileURLWithPath:outPutFilePath] recordingDelegate:self];
        }else//停止录制
        {
            [self.videoOutput stopRecording];
        }
    });
}
- (IBAction)didClickStill:(id)sender {
    dispatch_async([self sessionQueue], ^{
        // 设置一下拍摄的方向
        [[[self imageOutput]connectionWithMediaType:AVMediaTypeVideo] setVideoOrientation:[[(AVCaptureVideoPreviewLayer *)[[self captureView]layer] connection] videoOrientation]];
        // 自动闪光灯
        [MDMediaGenerateController setFlashMode:AVCaptureFlashModeAuto device:[self.captureDeviceInput device]];
        // Capture a still image
        [[self imageOutput]captureStillImageAsynchronouslyFromConnection:[[self imageOutput]connectionWithMediaType:AVMediaTypeVideo] completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
            if (imageDataSampleBuffer) {
                NSData *imagedata = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                UIImage *image = [[UIImage alloc]initWithData:imagedata];
                //写到相册
                [[[ALAssetsLibrary alloc]init]writeImageToSavedPhotosAlbum:[image CGImage] orientation:(ALAssetOrientation)[image imageOrientation] completionBlock:nil];
            }
        }];
    });
}
// 翻转摄像头
- (IBAction)didClickExchangeCamra:(id)sender {
    NSLog(@"摄像头翻转");
    self.recodingBtn.enabled = NO;
    self.exchangeBtn.enabled=NO;
    self.stillBtn.enabled = NO;
    
    dispatch_async([self sessionQueue], ^{
        AVCaptureDevice *currentVideoDevice = [[self captureDeviceInput]device];
        AVCaptureDevicePosition preferredPosition = AVCaptureDevicePositionUnspecified;
        AVCaptureDevicePosition currentPosition = [currentVideoDevice position];
        switch (currentPosition) {
            case AVCaptureDevicePositionUnspecified:
                preferredPosition = AVCaptureDevicePositionBack;
                break;
            case AVCaptureDevicePositionFront:
                preferredPosition = AVCaptureDevicePositionBack;
                break;
            case AVCaptureDevicePositionBack:
                preferredPosition = AVCaptureDevicePositionFront;
                break;
            default:
                break;
        }
        AVCaptureDevice *videoDevice = [MDMediaGenerateController deviceWithMediaType:AVMediaTypeVideo preferringPosition:preferredPosition];
        AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:nil];
        [[self session] beginConfiguration];
        
        [[self session]removeInput:[self captureDeviceInput]];
        if ([[self session] canAddInput:videoDeviceInput]) {
            //移除对当前，摄像范围的通知
            [[NSNotificationCenter defaultCenter]removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:currentVideoDevice];
            //闪光灯模式
            [MDMediaGenerateController setFlashMode:AVCaptureFlashModeAuto device:videoDevice];
            [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(subjectAreaDidChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:videoDevice];
            [self.session addInput:videoDeviceInput];
            self.captureDeviceInput = videoDeviceInput;
        }else{
            [[self session]addInput:[self captureDeviceInput]];
        }
        [[self session]commitConfiguration];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.exchangeBtn.enabled = YES;
            self.recodingBtn.enabled = YES;
            self.stillBtn.enabled = YES;
        });
    });
    
}




#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
/**
 *  检查授权状态
 */
- (void)checkDeviceAuthorizationStatus
{
    NSString *mediaType = AVMediaTypeAudio;
    [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
        if (granted) {
            [self setDeviceAuthorized:YES];
        }else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[[UIAlertView alloc] initWithTitle:@"AVCam!"
                                            message:@"AVCam doesn't have permission to use Camera, please change privacy settings"
                                           delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil] show];
                [self setDeviceAuthorized:NO];
            });
        }
    }];
}
#pragma clang disagnostic pop

- (void)runStillImageCamare
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[self.captureView layer]setOpacity:0.0];
        [UIView animateWithDuration:.25 animations:^{
            [[self.captureView layer]setOpacity:1.0];
        }];
    });
}

+ (void)setFlashMode:(AVCaptureFlashMode)flashMode device:(AVCaptureDevice*)device
{
    if ([device hasFlash]&&[device isFlashModeSupported:flashMode]) {
        NSError *error = nil;
        // 检查是否锁定配置
        if ([device lockForConfiguration:&error]) {
            [device setFlashMode:flashMode];
            [device unlockForConfiguration];
        }else
        {
            NSLog(@"%@",error);
        }
    }
}

@end
