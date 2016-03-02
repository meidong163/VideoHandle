//
//  MDTrimTool.m
//  VideoHandle
//
//  Created by 没懂 on 16/3/1.
//  Copyright © 2016年 com.comelet. All rights reserved.
//


#import "MDTrimTool.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import "ShowImage.h"
@interface MDTrimTool()<ShowImageDelegate>

@property (nonatomic, strong)AVAssetExportSession *exportSession;
@property (nonatomic, strong)AVAsset *asset;
@property (nonatomic, assign)CGFloat startTime;
@property (nonatomic, assign)CGFloat stopTime;
@end

@implementation MDTrimTool

- (void)timerVideoWithStartTime:(CGFloat)startTime endTime:(CGFloat)endtime
{
    self.startTime = startTime;
    self.stopTime = endtime;
    NSLog(@"stopTime = %f endTime = %f",self.startTime,self.stopTime);
}

// block函数式的方法
- (MDTrimTool *(^)())deleteTempFileBlock
{
    MDTrimTool *(^block)() = [^(){
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
        return self;
    }copy];
    return block;
}

//- (void)deleteTempFile
//{
//    NSURL *url = [NSURL fileURLWithPath:self.tempVideoPath];
//    NSFileManager *fm = [NSFileManager defaultManager];
//    BOOL exist = [fm fileExistsAtPath:url.path];
//    NSError *err;
//    if (exist) {
//        [fm removeItemAtURL:url error:&err];
//        NSLog(@"file deleted");
//        if (err) {
//            NSLog(@"file remove error, %@", err.localizedDescription );
//        }
//    } else {
//        NSLog(@"no file by that name");
//    }
//}
// 这种有参数的该怎么改呢 写在他的返回值的类型的参数中
//- (void)trimVideoWith:(AVAsset *)asset
//{
//    self.asset = asset;
//
//    // 把之前的剪掉地文件删除掉。
//    //    [self deleteTempFile];
//    [self deleteTempFile];
//    self.deleteTempFileBlock();
//    // 这个array存的是什么？视频的格式质量等等。
//    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:self.asset];
//    
//    NSLog(@"compatiblePresets = %@",compatiblePresets);
//    
//    if ([compatiblePresets containsObject:AVAssetExportPresetMediumQuality]) {
//        // 初始化一个AVAssetExportSession,输出资源的会话
//        self.exportSession = [[AVAssetExportSession alloc]
//                              initWithAsset:self.asset presetName:AVAssetExportPresetPassthrough];
//        NSLog(@"self.exportSession = %@",self.exportSession);
//        // Implementation continues.
//        // 1.截取视频后放的一个路径。
//        NSURL *furl = [NSURL fileURLWithPath:self.tempVideoPath];
//        // 2.输出文件的类型
//        self.exportSession.outputURL = furl;
//        self.exportSession.outputFileType = AVFileTypeQuickTimeMovie;
//        // 3.开始时间
//        CMTime start = CMTimeMakeWithSeconds(self.startTime, self.asset.duration.timescale);
//        // 4.结束时间
//        CMTime duration = CMTimeMakeWithSeconds(self.stopTime - self.startTime, self.asset.duration.timescale);
//        CMTimeRange range = CMTimeRangeMake(start, duration);
//        self.exportSession.timeRange = range;
//        // 5.后台处理完成后的回调
//        [self.exportSession exportAsynchronouslyWithCompletionHandler:^{
//            
//            switch ([self.exportSession status]) {
//                case AVAssetExportSessionStatusFailed:
//                    
//                    NSLog(@"Export failed: %@", [[self.exportSession error] localizedDescription]);
//                    break;
//                case AVAssetExportSessionStatusCancelled:
//                    
//                    NSLog(@"Export canceled");
//                    break;
//                default:
//                    NSLog(@"NONE");
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        // 处理成功，回调。
//                        NSURL *movieUrl = [NSURL fileURLWithPath:self.tempVideoPath];
//                        UISaveVideoAtPathToSavedPhotosAlbum([movieUrl relativePath], self,@selector(video:didFinishSavingWithError:contextInfo:), nil);
//                    });
//                    
//                    break;
//            }
//        }];
//        
//    }
//}

- (MDTrimTool *(^)(AVAsset *))trimVideoBlock
{
    MDTrimTool *(^blcok)(AVAsset *) = [^(AVAsset *asset){
        // 把之前的剪掉地文件删除掉。
        self.deleteTempFileBlock();
        self.asset = asset;
        // 这个array存的是什么？视频的格式质量等等。
        NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:self.asset];
        
        NSLog(@"compatiblePresets = %@",compatiblePresets);
        
        if ([compatiblePresets containsObject:AVAssetExportPresetMediumQuality]) {
            // 初始化一个AVAssetExportSession,输出资源的会话
            self.exportSession = [[AVAssetExportSession alloc]
                                  initWithAsset:self.asset presetName:AVAssetExportPresetPassthrough];
            NSLog(@"self.exportSession = %@",self.exportSession);
            // Implementation continues.
            // 1.截取视频后放的一个路径。
            NSURL *furl = [NSURL fileURLWithPath:self.tempVideoPath];
            // 2.输出文件的类型
            self.exportSession.outputURL = furl;
            self.exportSession.outputFileType = AVFileTypeQuickTimeMovie;
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
        return self;
    }copy];
    return blcok;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
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
#pragma clang diagnostic pop

- (void)dealloc
{
    NSLog(@"%@",NSStringFromSelector(_cmd));
}

@end
