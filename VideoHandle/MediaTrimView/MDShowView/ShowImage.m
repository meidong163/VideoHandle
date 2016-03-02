//
//  ShowImage.m
//  视频展示成连续的图片控件
//
//  Created by 没懂 on 16/2/26.
//  Copyright © 2016年 com.comelet. All rights reserved.
//  展示视频中的图片的类。

#import "ShowImage.h"
#import "SliderView.h"

@interface ShowImage()
@property (nonatomic, strong)SliderView *liftSliderView;
@property (nonatomic, strong)SliderView *rightSliderView;
@property (nonatomic, strong)AVAssetImageGenerator *imgeGenerator;
@property (nonatomic, strong)UIView *contentView;
@property (nonatomic, strong)NSMutableArray *imageViews;
@property (nonatomic, assign)CGFloat probblytime;
@property (nonatomic, assign)CGFloat liftTime;
@property (nonatomic, assign)CGFloat rightTime;

@property (nonatomic, assign)CGPoint liftStartPoint;
@property (nonatomic, assign)CGPoint rightStartPoint;

@end

@implementation ShowImage

- (NSMutableArray *)imageViews
{
    if (_imageViews == nil) {
        _imageViews = [NSMutableArray array];
    }
    return _imageViews;
}

// remove last generate images
- (void)resetSubviews
{
    if (self.minLengh == 0) {
        self.minLengh = 15;
    }
    
    self.imgeGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:self.asset];
    self.imgeGenerator.appliesPreferredTrackTransform = YES;
    // 去掉所有的子视图
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.contentView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    CGFloat durition = CMTimeGetSeconds(self.asset.duration);
    [self.contentView.layer setMasksToBounds:YES];// 啥意思？
    [self addSubview:self.contentView];
    [self addSubview:self.liftSliderView];
    [self addSubview:self.rightSliderView];
    
    //视频的时间转换成秒，然后可以通过准确的秒来去照片。
    CGFloat probblytime = durition / 20;
    self.probblytime = probblytime;
    CGFloat  widthPerImage = self.contentView.frame.size.width / 20;
    for (int i = 0 ; i <= 20; i++) { // 展示20张时的情况。
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(i * widthPerImage, 0, widthPerImage, CGRectGetHeight(self.frame))];
        imageView.tag = i;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.contentView addSubview:imageView];
            [self.imageViews addObject:imageView];
        });
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (int i = 0 ; i <= 20; i++)
        {
            CMTime time = [((NSValue *)@(i * probblytime)) CMTimeValue];
            CGImageRef theTimeImage = [self.imgeGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
            UIImage *videoImage;
            if ([self isRetina]) {
                videoImage = [UIImage imageWithCGImage:theTimeImage scale:2.0 orientation:UIImageOrientationUp];
            }else
            {
                videoImage = [UIImage imageWithCGImage:theTimeImage];
            }
            CGImageRelease(theTimeImage);
            dispatch_async(dispatch_get_main_queue(), ^{
                UIImageView *imageView = (UIImageView *)[self.imageViews[i] viewWithTag:i];
                [imageView setImage:videoImage];
            });
        }
    });
}

- (void)notifyDelegate
{
    if ([self.delegate respondsToSelector:@selector(timerVideoWithStartTime:endTime:)]) {
        [self.delegate timerVideoWithStartTime:self.liftTime endTime:self.rightTime];
    }
}

- (SliderView *)liftSliderView
{
    if (_liftSliderView == nil) {
        _liftSliderView = [[SliderView alloc]initWithFrame:CGRectMake(10, -10, 10, 60)];// 默认，
        [self addSubview:_liftSliderView];
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panLiftSliderView:)];
        _liftSliderView.userInteractionEnabled = YES;
        [_liftSliderView addGestureRecognizer:pan];
        [_liftSliderView setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.6]];
    }
    return _liftSliderView;
}
// 1. 保证左边的view不超过右边的View 
// 2. 根据slider的位置传递出去，时间值。
- (void)panLiftSliderView:(UIPanGestureRecognizer *)gesture
{
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            self.liftStartPoint = [gesture locationInView:self];
            break;
        case UIGestureRecognizerStateChanged:
        {
            CGPoint center = self.liftSliderView.center;
            CGPoint newPoint = [gesture locationInView:self];
            int moveLengh = newPoint.x - self.liftStartPoint.x;
            if (self.rightSliderView.center.x - self.liftSliderView.center.x<= self.minLengh) {
                if (moveLengh > 0) {
                    moveLengh = 0;
                }
            }// 处理两个控件的距离走入到死胡同
            CGFloat newPointMoveX = center.x + moveLengh;
            self.liftSliderView.center = CGPointMake(newPointMoveX, self.liftSliderView.center.y);
            self.liftTime = newPoint.x / 20 * self.probblytime;
            self.liftStartPoint = newPoint;
            break;
        }
        default:
            break;
    }
    [self notifyDelegate];
}

- (SliderView *)rightSliderView
{
    if (_rightSliderView == nil) {
        _rightSliderView = [[SliderView alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.frame) - 10, -10, 10, 60)];
        [self addSubview:_rightSliderView];
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panRightSliderView:)];
        [_rightSliderView addGestureRecognizer:pan];
        _rightSliderView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
        _rightSliderView.userInteractionEnabled = YES;
    }
    return _rightSliderView;
}

- (void)panRightSliderView:(UIPanGestureRecognizer *)gesture
{
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            self.rightStartPoint = [gesture locationInView:self];            break;
            case UIGestureRecognizerStateChanged:
        {
            CGPoint center = _rightSliderView.center;
            CGPoint newpoint = [gesture locationInView:self];
            int moveLenth = newpoint.x - self.rightStartPoint.x;
            if (self.rightSliderView.center.x - self.liftSliderView.center.x <= self.minLengh) {
                if (moveLenth < 0) {
                    moveLenth = 0;
                };
            }
            CGFloat newPointmidX = center.x +=moveLenth;
            self.rightSliderView.center = CGPointMake(newPointmidX, self.rightSliderView.center.y);
            self.rightTime = newpoint.x / 20 * self.probblytime;
            self.rightStartPoint = newpoint;
            break;
        }
        default:
            break;
    }
    [self notifyDelegate];
}

- (BOOL)isRetina
{
    return ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] &&
            ([UIScreen mainScreen].scale == 2.0));
}
@end
