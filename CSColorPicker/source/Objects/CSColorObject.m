//
//  CSColorObject.m
//  CSColorPicker
//
//  Created by Dana Buehre on 6/22/19.
//  Copyright © 2019 CreatureCoding. All rights reserved.
//

#import "CSColorObject.h"
#import "UIColor+CSColorPicker.h"
#import "NSString+CSColorPicker.h"


@implementation CSColorObject

+ (instancetype)colorObjectWithHex:(NSString *)hex {
	if (!hex || ![hex cscp_validHex]) hex = @"#FF0000";
	CSColorObject * object = [CSColorObject new];
	object.isGradient = NO;
	object.hexValue = hex;
	object.color = [hex cscp_hexColor];
	
	return object;
}

+ (instancetype)colorObjectWithColor:(UIColor *)color {
	if (!color) color = UIColor.redColor;
	CSColorObject * object = [CSColorObject new];
	object.isGradient = NO;
	object.color = color;
	object.hexValue = [color cscp_hexStringWithAlpha];
	
	return object;
}

+ (instancetype)gradientObjectWithHex:(NSString *)hex {
	if (!hex || ![hex cscp_validHex]) hex = @"#000000,FFFFFF";
	CSColorObject * object = [CSColorObject new];
	object.isGradient = YES;
	object.hexValue = hex;
	object.colors = [hex cscp_gradientStringColors];
	
	return object;
}

+ (instancetype)gradientObjectWithColors:(NSArray <UIColor *> *)colors {
	if (!colors || !colors.count) colors = @[UIColor.redColor, UIColor.redColor];
	CSColorObject * object = [CSColorObject new];
	object.isGradient = YES;
	object.colors = colors;
	object.hexValue = [self _stringFromColorArray:colors];
	
	return object;
}

+ (NSString *)_stringFromColorArray:(NSArray<UIColor*>*)colors {
	NSString *string;
	for (UIColor *color in colors) {
		string = string ? [string stringByAppendingFormat:@",%@", color.cscp_hexStringWithAlpha] : [NSString stringWithFormat:@"%@", color.cscp_hexStringWithAlpha];
	}
	
	return string ? : @"";
}

@end

