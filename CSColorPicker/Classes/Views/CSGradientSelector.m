//
// Created by CreatureSurvive on 4/7/19.
// Copyright (c) 2016 - 2019 CreatureCoding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CSColorObject.h"
#import "CSGradientSelector.h"
#import "UIColor+CSColorPicker.h"
#import "NSString+CSColorPicker.h"

@implementation CSGradientSelector {
	UIEdgeInsets _gradientInsets;
}

- (instancetype)initWithFrame:(CGRect)frame colorObject:(CSColorObject *)colorObject {
	if ((self = [super initWithFrame:frame colorObject:colorObject])) {
		
		_gradient = [CAGradientLayer layer];
		_gradient.frame = self.bounds;
		_gradient.colors = @[(id)UIColor.clearColor.CGColor, (id)UIColor.clearColor.CGColor];
		_gradient.startPoint = CGPointMake(0, 0.5);
		_gradient.endPoint = CGPointMake(1, 0.5);
		_gradient.hidden = YES;
		
		[self.layer addSublayer:self.gradient];
		
		[self updateGradient];
	}
	
	return self;
}

- (void)setGradientOnTop:(BOOL)gradientOnTop {
	_gradientOnTop = gradientOnTop;
	[self setAdditionalInsets:UIEdgeInsetsMake(_gradientOnTop ? 15 : 0, 0, _gradientOnTop ? 0 : 15, 0)];
	[self setNeedsLayout];
}

- (void)layoutSubviews {
	[super layoutSubviews];
	_gradient.frame = CGRectMake(0, _gradientOnTop ? 0 : self.bounds.size.height - 17, self.bounds.size.width, 15);
}

- (void)addColor:(UIColor *)color animated:(BOOL)animated {
	[super addColor:color animated:animated];
	[self updateGradient];
}

- (void)removeColorAtIndex:(NSInteger)index animated:(BOOL)animated {
	[super removeColorAtIndex:index animated:animated];
	[self updateGradient];
}

- (void)setColor:(UIColor *)color atIndex:(NSInteger)index {
	[super setColor:color atIndex:index];
	[self updateGradient];
}

- (void)updateGradient {
	self.gradient.hidden = self.colorObject.colors.count ? NO : YES;
	self.gradient.colors = self.colorObject.gradientCGColors;
}

@end
