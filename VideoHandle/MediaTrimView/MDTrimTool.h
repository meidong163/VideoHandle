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


- (void)trimVideoWith:(AVAsset *)asset;//像这些有参数的方法应该怎么样去处理呢？如果用block的函数式写代码的话。

//- (void)deleteTempFile;

- (MDTrimTool *(^)())deleteTempFileBlock;

- (MDTrimTool *(^)(AVAsset *))trimVideoBlock;
@end
