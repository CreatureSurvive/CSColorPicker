//
//  CSColorObjectManager.m
//  CSColorPicker
//
//  Created by Dana Buehre on 6/25/19.
//  Copyright © 2019 CreatureCoding. All rights reserved.
//

#import "CSColorObjectManager.h"
#import "CSColorObject.h"
#import "CSColorSlider.h"

static CSColorObjectManager *sharedManager;

@implementation CSColorObjectManager {
	__weak id _target;
	SEL _action;
}

#pragma Mark - (Class Instance)

+ (instancetype)sharedColorManager {
	
	return sharedManager;
}

#pragma Mark - (Initialization)

- (instancetype)initWithColorType:(CSColorType)colorType colorObject:(CSColorObject *)colorObject target:(id)target action:(SEL)action {
	if (sharedManager) return sharedManager;
	if ((self = [super init])) {
		[self _setColorType:colorType startColor:colorObject target:target action:action];
		[self _generateSliders];
	}
	
	return self;
}

- (instancetype)initWithColorType:(CSColorType)colorType startColor:(UIColor *)startColor target:(id)target action:(SEL)action {
	if (sharedManager) return sharedManager;
	if ((self = [super init])) {
		[self _setColorType:colorType startColor:[CSColorObject colorObjectWithColor:startColor] target:target action:action];
		[self _generateSliders];
	}
	
	return self;
}

- (instancetype)initWithColorType:(CSColorType)colorType startColors:(NSArray<UIColor*> *)startColors target:(id)target action:(SEL)action {
	if (sharedManager) return sharedManager;
	if ((self = [super init])) {
		[self _setColorType:colorType startColor:[CSColorObject gradientObjectWithColors:startColors] target:target action:action];
		[self _generateSliders];
	}
	
	return self;
}

- (instancetype)initWithColorType:(CSColorType)colorType colorHex:(NSString *)colorHex target:(id)target action:(SEL)action {
	if (sharedManager) return sharedManager;
	if ((self = [super init])) {
		if (colorHex && [colorHex containsString:@","])
			[self _setColorType:colorType startColor:[CSColorObject gradientObjectWithHex:colorHex] target:target action:action];
		else
			[self _setColorType:colorType startColor:[CSColorObject colorObjectWithHex:colorHex] target:target action:action];
		
		[self _generateSliders];
	}
	
	return self;
}

- (void)_setColorType:(CSColorType)colorType startColor:(CSColorObject *)colorObject target:(id)target action:(SEL)action {
	_colorObject = colorObject;
	_colorType = colorType;
	_target = target;
	_action = action;
	if (colorObject.isGradient) {
		_gradientIndex = colorObject.colors.count - 1;
		[_colorObject setSelectedIndex:_gradientIndex];
	}
}

#pragma Mark - (Value Changed)

- (void)colorDidChange:(CSColorObject *)color {
	if (_target && _action && [_target respondsToSelector:_action]) {
		((void (*)(id, SEL, CSColorObject*))[_target methodForSelector:_action])(_target, _action, color);
	}
}

- (void)sliderDidChangeValue:(CSColorSlider *)slider {
	[self _updateColorForSlider:slider];
}

- (void)sliderDidFinishEditing:(CSColorSlider *)slider {
	[_colorObject finalizeChange];
}

#pragma Mark - (Private)

- (NSArray<CSColorSlider*> *)_allSliders {
	return [[[_rgbSliders arrayByAddingObjectsFromArray:_hsbSliders] arrayByAddingObjectsFromArray:_cmykSliders] arrayByAddingObject:_alphaSlider];
}

- (void)_generateSliders {
	
	void (^addRGB)(void) = ^void(void) {
		self->_rgbSliders = @[
			  [[CSColorSlider alloc] initWithFrame:CGRectZero sliderType:CSColorSliderTypeRed label:Localize("R") startColor:self->_colorObject.selectedColor],
			  [[CSColorSlider alloc] initWithFrame:CGRectZero sliderType:CSColorSliderTypeGreen label:Localize("G") startColor:self->_colorObject.selectedColor],
			  [[CSColorSlider alloc] initWithFrame:CGRectZero sliderType:CSColorSliderTypeBlue label:Localize("B") startColor:self->_colorObject.selectedColor]
		];
	};
	
	void (^addHSB)(void) = ^void(void) {
		self->_hsbSliders = @[
			[[CSColorSlider alloc] initWithFrame:CGRectZero sliderType:CSColorSliderTypeHue label:Localize("H") startColor:self->_colorObject.selectedColor],
			[[CSColorSlider alloc] initWithFrame:CGRectZero sliderType:CSColorSliderTypeSaturation label:Localize("S") startColor:self->_colorObject.selectedColor],
			[[CSColorSlider alloc] initWithFrame:CGRectZero sliderType:CSColorSliderTypeBrightness label:Localize("B") startColor:self->_colorObject.selectedColor]
		];
	};
	
	void (^addAlpha)(void) = ^void(void) {
		self->_alphaSlider = [[CSColorSlider alloc] initWithFrame:CGRectZero sliderType:CSColorSliderTypeAlpha label:Localize("A") startColor:self->_colorObject.selectedColor];
	};
	
	void (^addCMYK)(void) = ^void(void) {};
	
	switch (self.colorType) {
		case CSColorTypeAll: 	{ addAlpha(); addRGB(); addHSB(); } break;
		case CSColorTypeRGB: 	{ addRGB(); } break;
		case CSColorTypeHSB: 	{ addHSB(); } break;
		case CSColorTypeRGBA: 	{ addAlpha(); addRGB(); } break;
		case CSColorTypeHSBA: 	{ addAlpha(); addHSB(); } break;
		case CSColorTypeCMYK: 	{ addCMYK(); } break;
		case CSColorTypeCMYKA: 	{ addAlpha(); addCMYK(); } break;
	}
	
	for (CSColorSlider *colorSlider in [self _allSliders]) {
		[colorSlider addTarget:self action:@selector(sliderDidChangeValue:) forControlEvents:UIControlEventValueChanged];
		[colorSlider addTarget:self action:@selector(sliderDidFinishEditing:) forControlEvents:(UIControlEventTouchUpInside | UIControlEventTouchUpOutside)];
	}
	
	[self setColor:_colorObject.selectedColor animated:NO];
}

- (void)_updateColorForSlider:(CSColorSlider *)slider {
	switch (slider.sliderType) {
		case CSColorSliderTypeHue:
		case CSColorSliderTypeSaturation:
		case CSColorSliderTypeBrightness:
			[self setColor:[self hsbaColor] animated:NO];
			break;
		case CSColorSliderTypeRed:
		case CSColorSliderTypeGreen:
		case CSColorSliderTypeBlue:
			[self setColor:[self rgbaColor] animated:NO];
			break;
		case CSColorSliderTypeAlpha:
			[self setColor:[self rgbaColor] animated:NO];
			break;
	}
	
	[self colorDidChange:_colorObject];
}

#pragma Mark - (Slider Colors)

- (CSColorSlider *)sliderOfType:(CSColorSliderType)sliderType {
	switch (sliderType) {
		case CSColorSliderTypeAlpha:
			return _alphaSlider;
		case CSColorSliderTypeRed:
			return _rgbSliders ? _rgbSliders[0] : nil;
		case CSColorSliderTypeGreen:
			return _rgbSliders ? _rgbSliders[1] : nil;
		case CSColorSliderTypeBlue:
			return _rgbSliders ? _rgbSliders[2] : nil;
		case CSColorSliderTypeHue:
			return _hsbSliders ? _hsbSliders[0] : nil;
		case CSColorSliderTypeSaturation:
			return _hsbSliders ? _hsbSliders[1] : nil;
		case CSColorSliderTypeBrightness:
			return _hsbSliders ? _hsbSliders[2] : nil;
	}
	
	return nil;
}

- (nonnull UIColor *)rgbColor {
	return [UIColor colorWithRed:_rgbSliders[0].value green:_rgbSliders[1].value blue:_rgbSliders[2].value alpha:1.f];
}

- (nonnull UIColor *)hsbColor {
	return [UIColor colorWithHue:_hsbSliders[0].value saturation:_hsbSliders[1].value brightness:_hsbSliders[2].value alpha:1.f];
}

- (nonnull UIColor *)rgbaColor {
	return [UIColor colorWithRed:_rgbSliders[0].value green:_rgbSliders[1].value blue:_rgbSliders[2].value alpha:_alphaSlider.value];
}

- (nonnull UIColor *)hsbaColor {
	return [UIColor colorWithHue:_hsbSliders[0].value saturation:_hsbSliders[1].value brightness:_hsbSliders[2].value alpha:_alphaSlider.value];
}

#pragma Mark - (CSColorObject Updating)

- (void)setColor:(UIColor *)color animated:(BOOL)animated {
	[_colorObject updateColor:color];
	
	void (^update)(void) = ^void(void) {
		for (CSColorSlider *slider in [self _allSliders]) {
			[slider setColor:color];
		}
	};
	
	animated ? [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{ update(); } completion:nil] : update();
}

- (void)setGradientIndex:(NSInteger)gradientIndex animated:(BOOL)animated {
	void (^update)(void) = ^void(void) {
		[self setGradientIndex:gradientIndex];
	};
	animated ? [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{ update(); } completion:nil] : update();
}

- (void)setGradientIndex:(NSInteger)gradientIndex {
	if (!_colorObject.isGradient) return;
	_gradientIndex = gradientIndex;
	[_colorObject setSelectedIndex:gradientIndex];
	
	for (CSColorSlider *slider in [self _allSliders]) {
		[slider setColor:_colorObject.selectedColor];
	}
}

- (void)addColor:(UIColor *)color {
	if (!_colorObject.isGradient) return;
	[_colorObject addColor:color];
	[self setGradientIndex:_colorObject.colors.count - 1 animated:YES];
}

- (void)removeColor {
	if (!_colorObject.isGradient) return;
	[_colorObject removeColor];
	[self setGradientIndex:_colorObject.colors.count - 1 animated:YES];
}

#pragma Mark - (Appearance)

- (void)setLightContent:(BOOL)lightContent {
	for (CSColorSlider *slider in [self _allSliders]) [slider setLightContent:lightContent];
}

@end
