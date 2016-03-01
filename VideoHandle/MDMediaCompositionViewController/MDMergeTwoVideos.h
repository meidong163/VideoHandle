//
//  MDMergeTwoVideos.h
//  VideoHandle
//
//  Created by 没懂 on 16/3/1.
//  Copyright © 2016年 com.comelet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class AVAsset,UIViewController,UIButton;
typedef BOOL (^OpenBrowserBolck) (UIViewController*,id);
typedef void (^OpenMPMediaPickerBrowserBlock)(UIViewController*);
typedef UIButton * (^ButtonFactoryMethod)(UIViewController*, NSString *,SEL,CGRect);
@interface MDMergeTwoVideos : NSObject
@property (nonatomic, copy)OpenBrowserBolck openBrowserBlock;
@property (nonatomic, copy)OpenMPMediaPickerBrowserBlock openMPMediaPickerBrowserBlock;
@property (nonatomic, copy)ButtonFactoryMethod newAButton;
- (void)mergeTwoVideowithAudioAsset:(AVAsset*)audioAsset;
-(BOOL)startMediaBrowserFromViewController:(UIViewController*)controller usingDelegate:(id)delegate;
- (AVAsset *)checkWheatherGetAsset:(AVAsset *)firstAsset wihtSecoundAsset:(AVAsset *)secoundAsset isOne:(BOOL)isSelectingAssetOne info:(NSDictionary *)info;

@end
