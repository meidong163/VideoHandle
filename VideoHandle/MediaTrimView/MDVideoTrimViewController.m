//
//  ViewController.m
//  视频合成
//
//  Created by 没懂 on 16/2/17.
//  Copyright © 2016年 com.comelet. All rights reserved.
//

#import "MDVideoTrimViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "MDTrimTool.h"

#define Height self.view.frame.size.height
#define Width self.view.frame.size.width

@interface MDVideoTrimViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate>
@property (nonatomic, strong)AVAsset *asset;
@property (nonatomic, copy)NSString *tempVideoPath;
@property (nonatomic, weak ) IBOutlet UIButton *chooseVideoBtn;
@property (nonatomic, weak ) IBOutlet UIButton *trimVideoBtn;

@property (nonatomic, strong)MDTrimTool *trimTool;
@end

@implementation MDVideoTrimViewController

-(MDTrimTool *)trimTool
{
    if (_trimTool == nil) {
        _trimTool = [[MDTrimTool alloc]init];
    }
    return _trimTool;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // 临时存储，截下来的视频；
    self.view.backgroundColor = [UIColor whiteColor];
    self.trimTool.tempVideoPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"tmpMov.mov"];
    
    UIButton *chooseVideoBtn = [self setButton:@"chooseVideo" sel:@selector(selectAssetFromPickerController) frame:CGRectMake(100, 100, 150, 40)];
    self.chooseVideoBtn = chooseVideoBtn;
    UIButton *trimVideoBtn = [self setButton:@"trimVideo" sel:@selector(trimVideo) frame:CGRectMake(100, 150, 150, 40)];
    self.trimVideoBtn = trimVideoBtn;
    [self.chooseVideoBtn addTarget:self action:@selector(selectAssetFromPickerController) forControlEvents:UIControlEventTouchUpInside];
    [self.trimVideoBtn addTarget:self action:@selector(trimVideo) forControlEvents:UIControlEventTouchUpInside];
    
    self.trimTool.showVideoView = [[ShowImage alloc]initWithFrame:CGRectMake(10, 220, Width - 20, 40)];
    self.trimTool.showVideoView.backgroundColor = [UIColor grayColor];
    [self.view addSubview:self.trimTool.showVideoView];
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

- (void)selectAssetFromPickerController
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
    self.trimTool.showVideoView.asset = self.asset;
    self.trimTool.showVideoView.delegate = self.trimTool;
    self.trimTool.showVideoView.resetSubViews();
}

- (void)trimVideo
{
    self.trimTool.trimVideoBlock(self.asset);
}


@end
