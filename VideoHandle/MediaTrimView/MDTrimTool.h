//
//  MDTrimTool.h
//  VideoHandle
//
//  Created by 没懂 on 16/3/1.
//  Copyright © 2016年 com.comelet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ShowImage.h"
@class AVAsset;
@interface MDTrimTool : NSObject
@property (nonatomic, copy)NSString *tempVideoPath;

@property (nonatomic, strong)ShowImage *showVideoView;

- (MDTrimTool *(^)())deleteTempFileBlock;

- (MDTrimTool *(^)(AVAsset *))trimVideoBlock;
@end
