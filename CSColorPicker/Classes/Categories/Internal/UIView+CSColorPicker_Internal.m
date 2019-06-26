//
//  UIView+CSColorPicker_Internal.m
//  CSColorPicker
//
//  Created by Dana Buehre on 6/26/19.
//  Copyright © 2019 CreatureCoding. All rights reserved.
//

#import "UIView+CSColorPicker_Internal.h"

@implementation UIView (CSColorPicker_Internal)

- (void)addTopBorderWithColor:(UIColor *)color andWidth:(CGFloat) borderWidth {
	UIView *border = [UIView new];
	border.backgroundColor = color;
	[border setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin];
	border.frame = CGRectMake(0, 0, self.frame.size.width, borderWidth);
	border.tag = 0;
	[self addSubview:border];
}

- (void)addBottomBorderWithColor:(UIColor *)color andWidth:(CGFloat) borderWidth {
	UIView *border = [UIView new];
	border.backgroundColor = color;
	[border setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin];
	border.frame = CGRectMake(0, self.frame.size.height - borderWidth, self.frame.size.width, borderWidth);
	border.tag = 1;
	[self addSubview:border];
}

- (void)addLeftBorderWithColor:(UIColor *)color andWidth:(CGFloat) borderWidth {
	UIView *border = [UIView new];
	border.backgroundColor = color;
	border.frame = CGRectMake(0, 0, borderWidth, self.frame.size.height);
	[border setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin];
	border.tag = 2;
	[self addSubview:border];
}

- (void)addRightBorderWithColor:(UIColor *)color andWidth:(CGFloat) borderWidth {
	UIView *border = [UIView new];
	border.backgroundColor = color;
	[border setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin];
	border.frame = CGRectMake(self.frame.size.width - borderWidth, 0, borderWidth, self.frame.size.height);
	border.tag = 3;
	[self addSubview:border];
}

- (UIView *)topBorder {
	return [self viewWithTag:0];
}

- (UIView *)bottomBorder {
	return [self viewWithTag:1];
}

- (UIView *)leftBorder {
	return [self viewWithTag:2];
}

- (UIView *)rightBorder {
	return [self viewWithTag:3];
}

@end
