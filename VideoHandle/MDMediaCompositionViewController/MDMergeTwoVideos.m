//
//  MDMergeTwoVideos.m
//  VideoHandle
//
//  Created by 没懂 on 16/3/1.
//  Copyright © 2016年 com.comelet. All rights reserved.
//

#import "MDMergeTwoVideos.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <MediaPlayer/MediaPlayer.h>
#import <UIKit/UIKit.h>
@interface MDMergeTwoVideos()<UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (nonatomic, strong)AVAsset *firstAsset;
@property (nonatomic, strong)AVAsset *secondAsset;
@end

@implementation MDMergeTwoVideos
- (void)mergeTwoVideowithAudioAsset:(AVAsset*)audioAsset
{
    AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];
    // 2 - Video track=2
    AVMutableCompositionTrack *firstTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo
                                                                        preferredTrackID:kCMPersistentTrackID_Invalid];
    [firstTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, self.firstAsset.duration)
                        ofTrack:[[self.firstAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:kCMTimeZero error:nil];
    
    [firstTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, self.secondAsset.duration)
                        ofTrack:[[self.secondAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:self.firstAsset.duration error:nil];
    // 3 - Audio track
    if (audioAsset!=nil){
        AVMutableCompositionTrack *AudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio
                                                                            preferredTrackID:kCMPersistentTrackID_Invalid];
        [AudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, CMTimeAdd(self.firstAsset.duration, self.secondAsset.duration))
                            ofTrack:[[audioAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:kCMTimeZero error:nil];
    }
    // 4 - Get path
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *myPathDocs =  [documentsDirectory stringByAppendingPathComponent:
                             [NSString stringWithFormat:@"mergeVideo-%d.mov",arc4random() % 1000]];
    NSURL *url = [NSURL fileURLWithPath:myPathDocs];
    // 5 - Create exporter
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition
                                                                      presetName:AVAssetExportPreset1280x720];
    exporter.outputURL=url;
    exporter.outputFileType = AVFileTypeQuickTimeMovie;
    exporter.shouldOptimizeForNetworkUse = YES;
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self exportDidFinish:exporter];
        });
    }];
}
- (OpenBrowserBolck)openBrowserBlock
{
    return [^(UIViewController *controller,id delegate)
    {
        if (([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO)
            || (delegate == nil)
            || (controller == nil)) {
            return NO;
        }
        UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
        mediaUI.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        mediaUI.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeMovie, nil];
        mediaUI.allowsEditing = YES;
        mediaUI.delegate = delegate;
        [controller presentViewController:mediaUI animated:YES completion:nil];
        return YES;
    } copy];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
- (OpenMPMediaPickerBrowserBlock)openMPMediaPickerBrowserBlock
{
    return [^(UIViewController *controller){
        MPMediaPickerController *mediaPicker = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeMusic];
        mediaPicker.delegate = controller;
        mediaPicker.prompt = @"视频背景音乐😄";
        [controller presentViewController:mediaPicker animated:YES completion:nil];
    }copy];
}

-(ButtonFactoryMethod)newAButton
{
    return [^(UIViewController *controller,NSString *buttontitle,SEL action,CGRect frame)
            {
                UIButton *startBtn = [[UIButton alloc]initWithFrame:frame];
                startBtn.autoresizingMask = UIViewContentModeBottom |UIViewContentModeBottomLeft | UIViewContentModeBottomRight;
                startBtn.backgroundColor = [UIColor grayColor];
                [startBtn setTitle:buttontitle forState:UIControlStateNormal];
                [startBtn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
                [controller.view addSubview:startBtn];
                return startBtn;
            } copy];
}

-(void)exportDidFinish:(AVAssetExportSession*)session {
    // 视频输出流写到本地
    if (session.status == AVAssetExportSessionStatusCompleted) {
        NSURL *outputURL = session.outputURL;
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:outputURL]) {
            [library writeVideoAtPathToSavedPhotosAlbum:outputURL completionBlock:^(NSURL *assetURL, NSError *error){
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (error) {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Video Saving Failed"
                                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alert show];
                    } else {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Video Saved" message:@"Saved To Photo Album"
                                                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alert show];
                    }
                });
            }];
        }
    }
}

-(BOOL)startMediaBrowserFromViewController:(UIViewController*)controller usingDelegate:(id)delegate {
    if (([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO)
        || (delegate == nil)
        || (controller == nil)) {
        return NO;
    }
    UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
    mediaUI.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    mediaUI.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeMovie, nil];
    mediaUI.allowsEditing = YES;
    mediaUI.delegate = delegate;
    [controller presentViewController:mediaUI animated:YES completion:nil];
    return YES;
}

- (AVAsset *)checkWheatherGetAsset:(AVAsset *)firstAsset wihtSecoundAsset:(AVAsset *)secoundAsset isOne:(BOOL)isSelectingAssetOne info:(NSDictionary *)info
{
    // 1 - Get media type
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    AVAsset *avasset;
    // 3 - Handle video selection
    if (CFStringCompare ((__bridge_retained CFStringRef) mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo) {
        if (isSelectingAssetOne){
            NSLog(@"Video One  Loaded");
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Asset Loaded" message:@"Video One Loaded"
                                                           delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            NSLog(@"message: self.firstAsset = %@",firstAsset);
           firstAsset = [AVAsset assetWithURL:[info objectForKey:UIImagePickerControllerMediaURL]];
            self.firstAsset = firstAsset;
            avasset = firstAsset;
        } else {
            NSLog(@"Video two Loaded");
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Asset Loaded" message:@"Video Two Loaded"
                                                           delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            NSLog(@"message: self.secoundAsset = %@",secoundAsset);
           secoundAsset = [AVAsset assetWithURL:[info objectForKey:UIImagePickerControllerMediaURL]];
            self.secondAsset = secoundAsset;
            avasset = secoundAsset;
        }
    }
    return avasset;
}

#pragma clang diagnostic pop
@end
