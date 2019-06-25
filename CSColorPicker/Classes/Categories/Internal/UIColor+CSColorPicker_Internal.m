//
//  UIColor+CSColorPicker_Internal.m
//  CSColorPicker
//
//  Created by Dana Buehre on 6/24/19.
//  Copyright © 2019 CreatureCoding. All rights reserved.
//

#import "UIColor+CSColorPicker_Internal.h"

@implementation UIColor (CSColorPicker_Internal)

- (UIColor *)complementaryColor {
	CGFloat h, s, b, a;
	if ([self getHue:&h saturation:&s brightness:&b alpha:&a]) {
		if (s < 0.25) {
			b = ((int)((b * 100) + 10) % 100) / 100.0f;
		}
		
		else {
			h = h - 0.1;
			if (h < 0) h = 1.0f - fabs(h);
		}
		
		return [UIColor colorWithHue:h saturation:s brightness:b alpha:a];
	}
	return nil;
}

@end
