//
//  ViewController.m
//  Videocomposition
//
//  Created by 没懂 on 16/2/18.
//  Copyright © 2016年 com.comelet. All rights reserved.
//

#import "MDVideoCompositionVC.h"
#import <MediaPlayer/MediaPlayer.h>
#import "MDMergeTwoVideos.h"

@interface MDVideoCompositionVC ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate,MPMediaPickerControllerDelegate>
{
    BOOL isSelectingAssetOne;
}
@property (strong, nonatomic) IBOutlet UIButton *loadAssetOne;
@property (strong, nonatomic) IBOutlet UIButton *loadAssetSecound;
@property (strong, nonatomic) IBOutlet UIButton *loadAudio;
@property (strong, nonatomic) IBOutlet UIButton *magreVideo;

@property(nonatomic, strong) AVAsset *firstAsset;
@property(nonatomic, strong) AVAsset *secondAsset;
@property(nonatomic, strong) AVAsset *audioAsset;

@property (nonatomic, strong)MDMergeTwoVideos *merge;
@end

@implementation MDVideoCompositionVC
- (MDMergeTwoVideos *)merge
{
    MDMergeTwoVideos *merge = [[MDMergeTwoVideos alloc]init];
    self.merge = merge;
    return merge;
}
- (void)viewDidLoad {
    [super viewDidLoad];
//    MDMergeTwoVideos *merge = [[MDMergeTwoVideos alloc]init];
//    self.merge = merge;
    self.view.backgroundColor = [UIColor whiteColor];
    self.loadAssetOne = self.merge.newAButton(self,@"firstVideo",@selector(loadAssetOne:),CGRectMake(50, 100, 150, 40));
    self.loadAssetSecound = self.merge.newAButton(self,@"SecoundVideo",@selector(loadAssetTwo:),CGRectMake(50, 150, 150, 40));
    self.magreVideo = self.merge.newAButton(self,@"magreVideo",@selector(magreVideo:),CGRectMake(50, 200, 150, 40));
    self.loadAudio = self.merge.newAButton(self,@"Music",@selector(loadAudio:),CGRectMake(50, 250, 150, 40));
    
//    self.loadAssetOne = [self setButton:@"firstVideo" sel:@selector(loadAssetOne:) frame:CGRectMake(50, 100, 150, 40)];
//    self.loadAssetSecound = [self setButton:@"secondVideo" sel:@selector(loadAssetTwo:) frame:CGRectMake(50, 150, 150, 40)];
//    self.magreVideo = [self setButton:@"magreVideo" sel:@selector(magreVideo:) frame:CGRectMake(50, 200, 150, 40)];
//    self.loadAudio = [self setButton:@"Music" sel:@selector(loadAudio:) frame:CGRectMake(50, 250, 150, 40)];
}

//- (UIButton *)setButton:(NSString *)buttontitle sel:(SEL)action frame:(CGRect)frame 
//{
////    UIButton *startBtn = [[UIButton alloc]initWithFrame:frame];
////    startBtn.autoresizingMask = UIViewContentModeBottom |UIViewContentModeBottomLeft | UIViewContentModeBottomRight;
////    startBtn.backgroundColor = [UIColor grayColor];
////    [startBtn setTitle:buttontitle forState:UIControlStateNormal];
////    [startBtn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
////    [self.view addSubview:startBtn];
////    return startBtn;
//    return self.merge.newAButton(self,buttontitle,action,frame);
//}

- (void)magreVideo:(id)sender
{
    if (self.firstAsset !=nil && self.secondAsset!=nil) {
        [self.merge mergeTwoVideowithAudioAsset:self.audioAsset firstAsset:self.firstAsset secondAsset:self.secondAsset];
    }
}

- (IBAction)loadAudio:(id)sender {
    self.merge.openMPMediaPickerBrowserBlock(self);
}

-(void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection
{
    [mediaPicker dismissViewControllerAnimated:YES completion:nil];
    MPMediaItem *item = [mediaItemCollection.items lastObject];
    self.audioAsset = [AVAsset assetWithURL:item.assetURL];
}

- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker
{
    [mediaPicker dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)loadAssetTwo:(id)sender {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"No Saved Album Found"
                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    } else {
        isSelectingAssetOne = FALSE;
        self.merge.openBrowserBlock(self,self);
    }
}
- (IBAction)loadAssetOne:(id)sender {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"No Saved Album Found"
                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    } else {
        isSelectingAssetOne = TRUE;
        void *mySelf = (__bridge void *)(self);
        [self.merge startMediaBrowserFromViewController:(__bridge UIViewController *)(mySelf) usingDelegate:(__bridge id)(mySelf)];
    }
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self dismissViewControllerAnimated:YES completion:nil];
    if (isSelectingAssetOne) {
        self.firstAsset = [self.merge checkWheatherGetAsset:self.firstAsset wihtSecoundAsset:self.secondAsset isOne:isSelectingAssetOne info:info];
    }else
    {
        self.secondAsset = [self.merge checkWheatherGetAsset:self.firstAsset wihtSecoundAsset:self.secondAsset isOne:isSelectingAssetOne info:info];
    }
}

@end

