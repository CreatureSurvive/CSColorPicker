//
//  UIViewController+CSColorPicker_Internal.h
//  CSColorPicker
//
//  Created by Dana Buehre on 6/24/19.
//  Copyright © 2019 CreatureCoding. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (CSColorPicker_Internal)

- (CGFloat)navigationHeightWithStatusbar:(BOOL)withStatusbar;
- (BOOL)isLandscape;
- (BOOL)isModal;

@end

NS_ASSUME_NONNULL_END
