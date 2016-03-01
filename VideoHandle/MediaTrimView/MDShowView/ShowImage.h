//
//  ShowImage.h
//  视频展示成连续的图片控件
//
//  Created by 没懂 on 16/2/26.
//  Copyright © 2016年 com.comelet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
@protocol ShowImageDelegate <NSObject>

- (void)timerVideoWithStartTime:(CGFloat)startTime endTime:(CGFloat)endtime;

@end

@interface ShowImage : UIView
@property (nonatomic, strong) AVAsset *asset ;
@property (nonatomic, assign) CGFloat minLengh;
@property  (nonatomic , weak) id<ShowImageDelegate> delegate;

- (void)resetSubviews;
@end
