//
//  UIImage+UIImage_CSColorPicker_Internal.m
//  CSColorPicker
//
//  Created by Dana Buehre on 6/24/19.
//  Copyright © 2019 CreatureCoding. All rights reserved.
//

#import "UIImage+CSColorPicker_Internal.h"

@implementation UIImage (CSColorPicker_Internal)

+ (UIImage *)imageWithColor:(UIColor * _Nullable)color size:(CGSize)size {
	return [self imageWithColor:color size:size strokeColor:nil strokeWidth:0];
}

+ (UIImage *)imageWithColor:(UIColor * _Nullable)color size:(CGSize)size strokeColor:( UIColor * _Nullable)strokeColor strokeWidth:(CGFloat)strokeWidth {
	CGRect rect = CGRectMake(0, 0, size.width, size.height);
	
	UIGraphicsBeginImageContext(rect.size);
	CGContextRef context = UIGraphicsGetCurrentContext();
	if (color) {
		CGContextSetFillColorWithColor(context, [color CGColor]);
		CGContextFillRect(context, rect);
	}
	if (strokeColor && strokeWidth > 0) {
		CGContextSetLineWidth(context, strokeWidth);
		CGContextSetStrokeColorWithColor(context, [strokeColor CGColor]);
		CGContextStrokeRect(context, rect);
	}
	
	UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return img;
}

+ (UIImage *)imageWithGradientStart:(UIColor *)start end:(UIColor *)end size:(CGSize)size {
	CGRect rect = CGRectMake(0, 0, size.width, size.height);
	
	//make gradient
	CAGradientLayer *gradient = [CAGradientLayer layer];
	gradient.frame = rect;
	gradient.startPoint = CGPointMake(0, 0.5);
	gradient.endPoint = CGPointMake(1, 0.5);
	gradient.colors = @[(id)start.CGColor, (id)end.CGColor];
	
	UIGraphicsBeginImageContext(rect.size);
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextFillRect(context, rect);
	[gradient renderInContext:UIGraphicsGetCurrentContext()];
	
	UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return img;
}

+ (UIImage *)hueTrackImage {
	
	NSMutableArray *colors = [NSMutableArray array];
	for (NSInteger deg = 0; deg <= 360; deg += 1) {
		
		UIColor *color;
		color = [UIColor colorWithHue:1.0f * deg / 360.0f
						   saturation:1.0f
						   brightness:1.0f
								alpha:1.0f];
		[colors addObject:(__bridge id)[color CGColor]];
	}
	
	//make gradient
	CGRect rect = CGRectMake(0, 0, colors.count, 1);
	CAGradientLayer *gradient = [CAGradientLayer layer];
	gradient.frame = rect;
	gradient.startPoint = CGPointMake(0, 0.5);
	gradient.endPoint = CGPointMake(1, 0.5);
	gradient.colors = colors;
	
	UIGraphicsBeginImageContext(rect.size);
	
	[gradient renderInContext:UIGraphicsGetCurrentContext()];
	
	UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return img;
}

@end
