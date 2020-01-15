//
//  YPUIHelper.h
//  YPItools
//
//  Created by qipeng_yuhao on 2020/1/15.
//  Copyright © 2020 qipeng_yuhao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YPUIHelper : NSObject

// color 转 image
+ (UIImage *)drawImageWithColor:(UIColor *)color;

//截图
+ (UIImage *)viewScreenshot:(UIView*)view;

//高斯模糊
+ (UIImage *)blurryImage:(UIImage *)image withBlurLevel:(CGFloat)blur exclusionPath:(UIBezierPath *)exclusionPath;

//自动将图片旋转至正常角度
+ (UIImage *)fixrotation:(UIImage *)image;

// set radius
+ (void)setViewRadius:(CGFloat)radius toView:(UIView *)view;

/// 设置视图圆角、边框、边框颜色
/// @param radius 圆角半径，必须有，0：没有半径
/// @param width 边框半径，必须有，0：没有边框
/// @param color 边框颜色，可以nil，默认黑色
/// @param view 传入需设置的view
+ (void)setViewRadius:(CGFloat)radius borderWidth:(CGFloat)width borderColor:(UIColor *)color toView:(UIView *)view;


/// 画虚线
/// @param lineView 虚线的画布view
/// @param lineLength 单个线段的长度
/// @param lineSpacing 线段间的空隙
/// @param lineColor 线段的颜色
+ (void)drawDashLine:(UIView *)lineView lineLength:(int)lineLength lineSpacing:(int)lineSpacing lineColor:(UIColor *)lineColor;

//color contrast
+ (BOOL)equalColorWithColor:(UIColor*)color withOtherColor:(UIColor*)otherColor;

@end

NS_ASSUME_NONNULL_END
