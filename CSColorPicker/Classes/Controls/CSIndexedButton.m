//
//  CSIndexedButton.m
//  CSColorPicker
//
//  Created by Dana Buehre on 6/26/19.
//  Copyright © 2019 CreatureCoding. All rights reserved.
//

#import "CSIndexedButton.h"
#import "UIColor+CSColorPicker.h"

@implementation CSIndexedButton

+ (CSIndexedButton *)_accessoryButtonWithTitle:(NSString *)title target:(id)target action:(SEL)action color:(UIColor *)color {
	UIColor *titleColor = (!color.cscp_light && color.cscp_alpha > 0.5) ? UIColor.whiteColor : UIColor.blackColor;
	UIColor *shadowColor = titleColor == UIColor.blackColor ? UIColor.whiteColor : UIColor.blackColor;
	CSIndexedButton *button = [CSIndexedButton buttonWithType:UIButtonTypeCustom];
	button.contentEdgeInsets = UIEdgeInsetsMake(6.5, 6.5, 6.5, 6.5);
	button.layer.backgroundColor = color.CGColor;
	button.layer.borderColor = UIColor.lightGrayColor.CGColor;
	button.layer.borderWidth = 1;
	button.layer.cornerRadius = 9.0;
	
	[button.titleLabel.layer setShadowOffset:CGSizeZero];
	[button.titleLabel.layer setShadowRadius:1];
	[button.titleLabel.layer setShadowOpacity:1];
	[button.titleLabel.layer setShadowColor:shadowColor.CGColor];
	
	[button.titleLabel setFont:[UIFont boldSystemFontOfSize:14]];
	[button.titleLabel setAdjustsFontSizeToFitWidth:YES];
	[button setTitleColor:titleColor forState:UIControlStateNormal];
	[button setTitleColor:[titleColor colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
	
	[button setTitle:title forState:UIControlStateNormal];
//	[button.widthAnchor constraintEqualToConstant:button.bounds.size.width].active = YES;
	[button.heightAnchor constraintEqualToConstant:30].active = YES;
	
	[button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
	
	return button;
}

+ (CSIndexedButton *)_accessoryButton:(BOOL)add target:(id)target action:(SEL)action {
	CSIndexedButton *button = [CSIndexedButton buttonWithType:UIButtonTypeCustom];
	[button setBackgroundImage:[[UIImage imageNamed:add ? @"plus" : @"minus" inBundle:[NSBundle bundleForClass:self] compatibleWithTraitCollection:nil] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
	[button setTintColor:UIColor.lightGrayColor];
	button.contentEdgeInsets = UIEdgeInsetsMake(3.5, 5, 3.5, 5);
	
//	[button.widthAnchor constraintEqualToConstant:button.bounds.size.width].active = YES;
	[button.heightAnchor constraintEqualToConstant:30].active = YES;
	
	[button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
	
	return button;
}

@end

