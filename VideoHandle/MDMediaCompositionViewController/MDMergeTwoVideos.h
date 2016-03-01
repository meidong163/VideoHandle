//
//  MDMergeTwoVideos.h
//  VideoHandle
//
//  Created by 没懂 on 16/3/1.
//  Copyright © 2016年 com.comelet. All rights reserved.
//

#import <Foundation/Foundation.h>
@class AVAsset,UIViewController;

typedef BOOL (^OpenBrowserBolck) (UIViewController*,id);

@interface MDMergeTwoVideos : NSObject
@property (nonatomic, copy)OpenBrowserBolck openBrowserBlock;
- (void)mergeTwoVideowithAudioAsset:(AVAsset*)audioAsset;
-(BOOL)startMediaBrowserFromViewController:(UIViewController*)controller usingDelegate:(id)delegate;
- (AVAsset *)checkWheatherGetAsset:(AVAsset *)firstAsset wihtSecoundAsset:(AVAsset *)secoundAsset isOne:(BOOL)isSelectingAssetOne info:(NSDictionary *)info;
@end
