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
	object.hexColor = hex;
	object.color = [hex cscp_hexColor];
	
	return object;
}

+ (instancetype)colorObjectWithColor:(UIColor *)color {
	if (!color) color = UIColor.redColor;
	CSColorObject * object = [CSColorObject new];
	object.color = color;
	object.hexColor = [color cscp_hexString];
	
	return object;
}

@end

