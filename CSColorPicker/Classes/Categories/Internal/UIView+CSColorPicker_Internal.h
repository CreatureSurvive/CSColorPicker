//
//  UIView+CSColorPicker_Internal.h
//  CSColorPicker
//
//  Created by Dana Buehre on 6/26/19.
//  Copyright © 2019 CreatureCoding. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (CSColorPicker_Internal)

- (void)addTopBorderWithColor:(UIColor *)color andWidth:(CGFloat) borderWidth;
- (void)addBottomBorderWithColor:(UIColor *)color andWidth:(CGFloat) borderWidth;
- (void)addLeftBorderWithColor:(UIColor *)color andWidth:(CGFloat) borderWidth;
- (void)addRightBorderWithColor:(UIColor *)color andWidth:(CGFloat) borderWidth;

- (UIView *)topBorder;
- (UIView *)bottomBorder;
- (UIView *)leftBorder;
- (UIView *)rightBorder;

@end

NS_ASSUME_NONNULL_END
