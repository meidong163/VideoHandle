//
//  SliderView.m
//  视频展示成连续的图片控件
//
//  Created by 没懂 on 16/2/29.
//  Copyright © 2016年 com.comelet. All rights reserved.
//

#import "SliderView.h"

@interface SliderView()

@property (nonatomic, strong)UIImage *thubmImage;

@end

@implementation SliderView
- (void)drawRect:(CGRect)rect
{
    if (self.thubmImage) {// 使用美工做的图
        CGContextRef contentRef = UIGraphicsGetCurrentContext();
        CGContextDrawImage(contentRef, CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)), self.thubmImage.CGImage);
        CGContextFillPath(contentRef);
    }else
    {// draw
        UIBezierPath *bezier = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)) byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(3, 3)];
        UIColor *color = [UIColor colorWithWhite:0.6 alpha:0.6];
        [color set];
        [bezier fill];
    }
}

- (instancetype)initWithFrame:(CGRect)frame withImage:(UIImage *)image
{
    if (self = [super initWithFrame:frame]) {
        self.thubmImage = image;
    }
    return self;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    CGRect relativeFrame = self.bounds;
    UIEdgeInsets hitTestEdgeInsets = UIEdgeInsetsMake(0, -50, 0, -50);
    CGRect hitFrame = UIEdgeInsetsInsetRect(relativeFrame, hitTestEdgeInsets);//点击的frame
    return CGRectContainsPoint(hitFrame, point);
}

@end
