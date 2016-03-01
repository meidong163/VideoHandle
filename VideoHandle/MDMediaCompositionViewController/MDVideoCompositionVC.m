//
//  ViewController.m
//  Videocomposition
//
//  Created by 没懂 on 16/2/18.
//  Copyright © 2016年 com.comelet. All rights reserved.
//

#import "MDVideoCompositionVC.h"
#import <CoreMedia/CoreMedia.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <MediaPlayer/MediaPlayer.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>

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

//-(BOOL)startMediaBrowserFromViewController:(UIViewController*)controller usingDelegate:(id)delegate;
//-(void)exportDidFinish:(AVAssetExportSession*)session;
@end

@implementation MDVideoCompositionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.loadAssetOne = [self setButton:@"firstVideo" sel:@selector(loadAssetOne:) frame:CGRectMake(50, 100, 150, 40)];
    self.loadAssetSecound = [self setButton:@"SecoundVideo" sel:@selector(loadAssetTwo:) frame: CGRectMake(50, 150, 150, 40)];
    self.magreVideo = [self setButton:@"magreVideo" sel:@selector(MagreVideo:) frame: CGRectMake(50, 200, 150, 40)];
    self.loadAudio = [self setButton:@"Music" sel:@selector(loadAudio:) frame:CGRectMake(50, 250, 150, 40)];
    MDMergeTwoVideos *merge = [[MDMergeTwoVideos alloc]init];
    self.merge = merge;
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

- (void)MagreVideo:(id)sender
{
    if (self.self.firstAsset !=nil && self.self.secondAsset!=nil) {
        [self.merge mergeTwoVideowithAudioAsset:self.audioAsset];
    }
   
}

//// 判断一下视频的方向，然后在合成。
//- (IBAction)MagreVideo:(id)sender {
//    if (self.self.firstAsset !=nil && self.self.secondAsset!=nil) {
//        AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];
//        // 2 - Video track=2
//        AVMutableCompositionTrack *firstTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo
//                                                                            preferredTrackID:kCMPersistentTrackID_Invalid];
//        [firstTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, self.firstAsset.duration)
//                            ofTrack:[[self.firstAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:kCMTimeZero error:nil];
//        
//        [firstTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, self.secondAsset.duration)
//                            ofTrack:[[self.secondAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:self.firstAsset.duration error:nil];
//        // 3 - Audio track
//        if (self.audioAsset!=nil){
//            AVMutableCompositionTrack *AudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio
//                                                                                preferredTrackID:kCMPersistentTrackID_Invalid];
//            [AudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, CMTimeAdd(self.firstAsset.duration, self.secondAsset.duration))
//                                ofTrack:[[self.audioAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:kCMTimeZero error:nil];
//        }
//        // 4 - Get path
//        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//        NSString *documentsDirectory = [paths objectAtIndex:0];
//        NSString *myPathDocs =  [documentsDirectory stringByAppendingPathComponent:
//                                 [NSString stringWithFormat:@"mergeVideo-%d.mov",arc4random() % 1000]];
//        NSURL *url = [NSURL fileURLWithPath:myPathDocs];
//        // 5 - Create exporter
//        AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition
//                                                                          presetName:AVAssetExportPreset1280x720];
//        exporter.outputURL=url;
//        exporter.outputFileType = AVFileTypeQuickTimeMovie;
//        exporter.shouldOptimizeForNetworkUse = YES;
//        [exporter exportAsynchronouslyWithCompletionHandler:^{
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self exportDidFinish:exporter];
//            });
//        }];
//    }
//}
- (IBAction)loadAudio:(id)sender {
    // 合成的视频中插入的音乐－ 手动插入
    NSString *path = [[NSBundle mainBundle] pathForResource:@"单身情歌.mp3" ofType:nil];
    NSURL *url = [[NSURL alloc] initFileURLWithPath:path];
    self.audioAsset = [AVAsset assetWithURL:url];
    // 如果没有选择的到，就单身情歌了。
    MPMediaPickerController *mediaPicker = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeMusic];
    mediaPicker.delegate = self;
    mediaPicker.prompt = @"没有音乐，就单身情歌，😄";
    [self presentViewController:mediaPicker animated:YES completion:nil];
}

-(void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection
{
    [mediaPicker dismissViewControllerAnimated:YES completion:nil];
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
//        [self startMediaBrowserFromViewController:self usingDelegate:self];
        [self.merge startMediaBrowserFromViewController:self usingDelegate:self];
//        self.merge.openBrowserBlock(self,self);
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
//        [self startMediaBrowserFromViewController:self usingDelegate:self];
        [self.merge startMediaBrowserFromViewController:(__bridge UIViewController *)(mySelf) usingDelegate:(__bridge id)(mySelf)];
    }
}

//-(void)exportDidFinish:(AVAssetExportSession*)session {
//    // 视频输出流写到本地
//    if (session.status == AVAssetExportSessionStatusCompleted) {
//        NSURL *outputURL = session.outputURL;
//        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
//        if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:outputURL]) {
//            [library writeVideoAtPathToSavedPhotosAlbum:outputURL completionBlock:^(NSURL *assetURL, NSError *error){
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    if (error) {
//                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Video Saving Failed"
//                                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//                        [alert show];
//                    } else {
//                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Video Saved" message:@"Saved To Photo Album"
//                                                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
//                        [alert show];
//                    }
//                });
//            }];
//        }
//    }
//    self.audioAsset = nil;
//    self.firstAsset = nil;
//    self.secondAsset = nil;
//}

//-(BOOL)startMediaBrowserFromViewController:(UIViewController*)controller usingDelegate:(id)delegate {
//    if (([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO)
//        || (delegate == nil)
//        || (controller == nil)) {
//        return NO;
//    }
//    UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
//    mediaUI.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
//    mediaUI.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeMovie, nil];
//    mediaUI.allowsEditing = YES;
//    mediaUI.delegate = delegate;
//    [controller presentViewController:mediaUI animated:YES completion:nil];
//    return YES;
//}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    // 2 - Dismiss image picker
    [self dismissViewControllerAnimated:YES completion:nil];
    if (isSelectingAssetOne) {
        self.firstAsset = [self.merge checkWheatherGetAsset:self.firstAsset wihtSecoundAsset:self.secondAsset isOne:isSelectingAssetOne info:info];
    }else
    {
        self.secondAsset = [self.merge checkWheatherGetAsset:self.firstAsset wihtSecoundAsset:self.secondAsset isOne:isSelectingAssetOne info:info];
    }
//    // 1 - Get media type
//    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
//    
//    // 3 - Handle video selection
//    if (CFStringCompare ((__bridge_retained CFStringRef) mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo) {
//        if (isSelectingAssetOne){
//            NSLog(@"Video One  Loaded");
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Asset Loaded" message:@"Video One Loaded"
//                                                           delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//            [alert show];
//            self.firstAsset = [AVAsset assetWithURL:[info objectForKey:UIImagePickerControllerMediaURL]];
//            NSLog(@"message: self.firstAsset = %@",self.firstAsset);
//        } else {
//            NSLog(@"Video two Loaded");
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Asset Loaded" message:@"Video Two Loaded"
//                                                           delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//            [alert show];
//            self.secondAsset = [AVAsset assetWithURL:[info objectForKey:UIImagePickerControllerMediaURL]];
//            NSLog(@"message: self.secoundAsset = %@",self.secondAsset);
//        }
//    }
}

@end

