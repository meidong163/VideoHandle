//
//  ViewController.m
//  视频合成
//
//  Created by 没懂 on 16/2/17.
//  Copyright © 2016年 com.comelet. All rights reserved.
//

#import "MDVideoTrimViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "ICGVideoTrimmer.h"
#import <MobileCoreServices/MobileCoreServices.h>
#define Height self.view.frame.size.height
#define Width self.view.frame.size.width
@interface MDVideoTrimViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate,ICGVideoTrimmerDelegate>
@property (nonatomic, strong)AVAsset *asset;
@property (nonatomic, assign)CGFloat startTime;
@property (nonatomic, assign)CGFloat stopTime;
@property (nonatomic, copy)NSString *tempVideoPath;
@property (nonatomic, strong)AVAssetExportSession *exportSession;
@property (weak, nonatomic) IBOutlet ICGVideoTrimmerView *trimmerView;

@property (weak, nonatomic) IBOutlet UITextField *startTimeTextFeild;
@property (weak, nonatomic) IBOutlet UITextField *stopTimeTextFeild;

@property (nonatomic, weak ) IBOutlet UIButton *chooseVideoBtn;
@property (nonatomic, weak ) IBOutlet UIButton *trimVideoBtn;

@end

@implementation MDVideoTrimViewController
#pragma mark - compositionVideo

- (void)viewDidLoad {
    [super viewDidLoad];
    // 临时存储，截下来的视频；
    self.view.backgroundColor = [UIColor whiteColor];
    self.tempVideoPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"tmpMov.mov"];//设置一个临时的路径
    NSLog(@"self.tempVideoPath = %@",self.tempVideoPath);
    UIButton *chooseVideoBtn = [self setButton:@"chooseVideo" sel:@selector(selectAssetFromAulm) frame:CGRectMake(100, 100, 150, 40)];
    self.chooseVideoBtn = chooseVideoBtn;
    UIButton *trimVideoBtn = [self setButton:@"trimVideo" sel:@selector(trimVideo) frame:CGRectMake(100, 150, 150, 40)];
    self.trimVideoBtn = trimVideoBtn;
    [self.chooseVideoBtn addTarget:self action:@selector(selectAssetFromAulm) forControlEvents:UIControlEventTouchUpInside];
    [self.trimVideoBtn addTarget:self action:@selector(trimVideo) forControlEvents:UIControlEventTouchUpInside];
}

- (UIButton *)setButton:(NSString *)buttontitle sel:(SEL)action frame:(CGRect)frame
{
    UIButton *startBtn = [[UIButton alloc]initWithFrame:frame];
    startBtn.autoresizingMask = UIViewContentModeBottom |UIViewContentModeBottomLeft | UIViewContentModeBottomRight;
    startBtn.backgroundColor = [UIColor grayColor];
    [startBtn setTitle:buttontitle forState:UIControlStateNormal];
    [startBtn addTarget:self action:action forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:startBtn];
    return startBtn;
}

#pragma mark - trimmerViewDelegate 设置截取的时间。
- (void)trimmerView:(ICGVideoTrimmerView *)trimmerView didChangeLeftPosition:(CGFloat)startTime rightPosition:(CGFloat)endTime
{
    self.startTime = startTime;
    self.stopTime = endTime;
}

- (void)selectAssetFromAulm
{
    UIImagePickerController *myimagePickerController = [[UIImagePickerController alloc]init];
    myimagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    myimagePickerController.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *) kUTTypeMovie, nil];//默认的写法
    myimagePickerController.delegate = self;
    myimagePickerController.editing = YES;
    [self presentViewController:myimagePickerController animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    NSLog(@"choose from libriary = %@",info);// 选择本地视频的url,其他的属性。
    NSURL *url = [info valueForKey:UIImagePickerControllerMediaURL];
    self.asset = [AVAsset assetWithURL:url];
    // 设置视频选择相关的属性。
    self.trimmerView.themeColor = [UIColor redColor];
    self.trimmerView.asset = self.asset;
    self.trimmerView.showsRulerView = YES;
    self.trimmerView.delegate = self;
    
    [self.trimmerView resetSubviews];
}

/**
 *  点击修剪视频
 */
- (void)trimVideo
{
    // 把之前的剪掉地文件删除掉。
    [self deleteTempFile];
    // 这个array存的是什么？视频的格式质量等等。
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:self.asset];
    
    NSLog(@"compatiblePresets = %@",compatiblePresets);
    
    if ([compatiblePresets containsObject:AVAssetExportPresetMediumQuality]) {
        // 初始化一个AVAssetExportSession,输出资源的会话
        self.exportSession = [[AVAssetExportSession alloc]
                              initWithAsset:self.asset presetName:AVAssetExportPresetPassthrough];
        NSLog(@"self.exportSession = %@",self.exportSession);
        //  self.exportSession = <AVAssetExportSession: 0x137f6d910, asset = <AVURLAsset: 0x139258410, URL = file:///private/var/mobile/Containers/Data/Application/14DA1CC4-06E0-4515-B3AE-021CE837D8CD/tmp/trim.0C174268-D087-41FA-BB8F-DD3A9D898767.MOV>, presetName = AVAssetExportPresetPassthrough, outputFileType = (null)
        // Implementation continues.
        // 1.截取视频后放的一个路径。
        NSURL *furl = [NSURL fileURLWithPath:self.tempVideoPath];
        // 2.输出文件的类型
        self.exportSession.outputURL = furl;
        self.exportSession.outputFileType = AVFileTypeQuickTimeMovie;
        // 3.开始时间
        double time = [self.stopTimeTextFeild.text doubleValue] - [self.startTimeTextFeild.text doubleValue];
        if ( time > 0) {
            
            self.startTime = [self.startTimeTextFeild.text doubleValue];
            self.stopTime = [self.stopTimeTextFeild.text doubleValue];
            NSLog(@"startTime = %f,stopTime = %f",self.startTime, self.stopTime);
        }
        CMTime start = CMTimeMakeWithSeconds(self.startTime, self.asset.duration.timescale);
        // 4.结束时间
        CMTime duration = CMTimeMakeWithSeconds(self.stopTime - self.startTime, self.asset.duration.timescale);
        CMTimeRange range = CMTimeRangeMake(start, duration);
        self.exportSession.timeRange = range;
        // 5.后台处理完成后的回调
        [self.exportSession exportAsynchronouslyWithCompletionHandler:^{
            
            switch ([self.exportSession status]) {
                case AVAssetExportSessionStatusFailed:
                    
                    NSLog(@"Export failed: %@", [[self.exportSession error] localizedDescription]);
                    break;
                case AVAssetExportSessionStatusCancelled:
                    
                    NSLog(@"Export canceled");
                    break;
                default:
                    NSLog(@"NONE");
                    dispatch_async(dispatch_get_main_queue(), ^{
                        // 处理成功，回调。
                        NSURL *movieUrl = [NSURL fileURLWithPath:self.tempVideoPath];
                        UISaveVideoAtPathToSavedPhotosAlbum([movieUrl relativePath], self,@selector(video:didFinishSavingWithError:contextInfo:), nil);
                    });
                    
                    break;
            }
        }];
        
    }
}
// 修剪完成后的提示
- (void)video:(NSString*)videoPath didFinishSavingWithError:(NSError*)error contextInfo:(void*)contextInfo {
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Video Saving Failed"
                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Video Saved" message:@"Saved To Photo Album"
                                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

- (void)deleteTempFile
{
    NSURL *url = [NSURL fileURLWithPath:self.tempVideoPath];
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL exist = [fm fileExistsAtPath:url.path];
    NSError *err;
    if (exist) {
        [fm removeItemAtURL:url error:&err];
        NSLog(@"file deleted");
        if (err) {
            NSLog(@"file remove error, %@", err.localizedDescription );
        }
    } else {
        NSLog(@"no file by that name");
    }
}
@end
