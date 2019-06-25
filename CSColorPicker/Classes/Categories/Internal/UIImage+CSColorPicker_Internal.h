//
//  UIImage+UIImage_CSColorPicker_Internal.h
//  CSColorPicker
//
//  Created by Dana Buehre on 6/24/19.
//  Copyright © 2019 CreatureCoding. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (CSColorPicker_Internal)

+ (UIImage *)imageWithColor:(UIColor * _Nullable)color size:(CGSize)size;
+ (UIImage *)imageWithColor:(UIColor * _Nullable)color size:(CGSize)size strokeColor:(UIColor * _Nullable)strokeColor strokeWidth:(CGFloat)strokeWidth;
+ (UIImage *)imageWithGradientStart:(UIColor *)start end:(UIColor *)end size:(CGSize)size;
+ (UIImage *)hueTrackImage;

@end

NS_ASSUME_NONNULL_END
