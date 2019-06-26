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


@implementation CSColorObject {
	NSArray *_gradientCGColors;
	NSString *_displayHexValue;
}

+ (instancetype)colorObjectWithHex:(NSString *)hex {
	if (!hex || ![hex cscp_validHex]) hex = @"#FF0000";
	CSColorObject * object = [CSColorObject new];
	object->_isGradient = NO;
	object->_hexValue = hex;
	object->_color = [hex cscp_hexColor];
	
	return object;
}

+ (instancetype)colorObjectWithColor:(UIColor *)color {
	if (!color) color = UIColor.redColor;
	CSColorObject * object = [CSColorObject new];
	object->_isGradient = NO;
	object->_color = color;
	object->_hexValue = [color cscp_hexStringWithAlpha];
	
	return object;
}

+ (instancetype)gradientObjectWithHex:(NSString *)hex {
	if (!hex) hex = @"#000000,FFFFFF";
	CSColorObject * object = [CSColorObject new];
	object->_isGradient = YES;
	object->_hexValue = hex;
	object->_colors = [hex cscp_gradientStringColors].mutableCopy;
	
	return object;
}

+ (instancetype)gradientObjectWithColors:(NSArray <UIColor *> *)colors {
	if (!colors || !colors.count) colors = @[UIColor.redColor, UIColor.redColor];
	CSColorObject * object = [CSColorObject new];
	object->_isGradient = YES;
	object->_colors = colors.mutableCopy;
	object->_hexValue = [self _stringFromColorArray:colors forDisplay:NO];
	
	return object;
}

+ (NSString *)_stringFromColorArray:(NSArray<UIColor*>*)colors forDisplay:(BOOL)forDisplay {
	NSString *string;
	for (UIColor *color in colors) {
		string = forDisplay ?
		string ? [string stringByAppendingFormat:@" #%@", color.cscp_hexString] : [NSString stringWithFormat: @"#%@", color.cscp_hexString] :
		string ? [string stringByAppendingFormat:@",%@", color.cscp_hexStringWithAlpha] : [NSString stringWithFormat:@"%@", color.cscp_hexStringWithAlpha];
	}
	
	return string ? : @"";
}

- (NSArray<id>*)gradientCGColors {
	if (!_gradientCGColors) {
		NSArray *colors = _isGradient ? self.colors : @[self.color, self.color];
		NSMutableArray *cgColors = [NSMutableArray new];
		for (UIColor *color in colors) {
			[cgColors addObject:(id)color.CGColor];
		}
		_gradientCGColors = [cgColors copy];
	}
	
	return _gradientCGColors;
}

- (NSString *)displayHexValue {
	if (!_displayHexValue) {
		if (_isGradient) {
			_displayHexValue = [self.class _stringFromColorArray:self.colors forDisplay:YES];
		} else {
			_displayHexValue = [NSString stringWithFormat:@"#%@", [self.color cscp_hexString]];
		}
	}
	
	return _displayHexValue;
}

- (void)updateColor:(UIColor *)color {
	if (!color) return;
	if (!_isGradient) {
		_color = color;
		_hexValue = nil; _displayHexValue = nil;
	}
	else if (_colors.count > _selectedIndex) {
		_colors[_selectedIndex] = color;
		_hexValue = nil; _displayHexValue = nil; _gradientCGColors = nil;
	}
}

- (void)addColor:(UIColor *)color {
	if (!_isGradient) return;
	[_colors addObject:color];
	_hexValue = nil; _displayHexValue = nil; _gradientCGColors = nil;
}

- (void)removeColor {
	if (!_isGradient) return;
//	[_colors removeLastObject];
	[_colors removeObjectAtIndex:_selectedIndex];
	_hexValue = nil; _displayHexValue = nil; _gradientCGColors = nil;
}

- (UIColor *)selectedColor {
	if (!_isGradient) return _color;
	else return _colors[_selectedIndex];
}

- (void)finalizeChange {
	if (!_isGradient) {
		if (!_hexValue) _hexValue = [_color cscp_hexString];
	}
	else if (_colors.count > _selectedIndex) {
		if (!_hexValue) _hexValue = [self.class _stringFromColorArray:_colors forDisplay:NO];
	}
}

@end

