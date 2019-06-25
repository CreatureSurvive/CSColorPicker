//
// Created by CreatureSurvive on 3/17/17.
// Copyright (c) 2016 - 2019 CreatureCoding. All rights reserved.
//

#import "CSColorSlider.h"
#import "UIImage+CSColorPicker_Internal.h"

@interface CSColorSlider ()

@property (nonatomic, strong) UIImageView *colorTrackImageView;
@property (nonatomic, strong) UILabel *sliderValueLabel;
@property (nonatomic, strong) UIImage *currentTrackImage;

@end

@implementation CSColorSlider

- (instancetype)initWithFrame:(CGRect)frame sliderType:(CSColorSliderType)sliderType label:(NSString *)label startColor:(UIColor *)startColor {
    self = [super initWithFrame:frame];
    if (self) {
        [self baseInitWithType:sliderType label:label startColor:startColor];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self baseInitWithType:0 label:@"" startColor:[UIColor whiteColor]];
    }
    return self;
}

- (void)baseInitWithType:(CSColorSliderType)sliderType label:(NSString *)label startColor:(UIColor *)startColor {

    _colorTrackImageView = [UIImageView new];
    [self addSubview:_colorTrackImageView];
    [self sendSubviewToBack:_colorTrackImageView];

    // set clear track images to set margins on either side for labels
    UIImage *sliderValueImageRight = [UIImage imageWithColor:[UIColor clearColor] size:CGSizeMake(29, 1)];
    UIImage *sliderValueImageLeft = [UIImage imageWithColor:[UIColor clearColor] size:CGSizeMake(29, 1)];

    [self setMaximumValueImage:sliderValueImageRight];
    [self setMinimumValueImage:sliderValueImageLeft];

    // set thumb image
    [self setThumbImage:[UIImage imageWithColor:[UIColor lightGrayColor] size:CGSizeMake(5, 28)] forState:UIControlStateNormal];

    // set min/max thumb images for label margins
    [super setMinimumTrackImage:[UIImage imageWithColor:[UIColor clearColor] size:CGSizeMake(1, 1)] forState:UIControlStateNormal];
    [super setMaximumTrackImage:[UIImage imageWithColor:[UIColor clearColor] size:CGSizeMake(1, 1)] forState:UIControlStateNormal];

    // set the slider label
    self.sliderLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.sliderLabel setNumberOfLines:1];
	[self.sliderLabel setFont:[UIFont boldSystemFontOfSize:16.0f]];
    [self.sliderLabel setText:label];
    [self.sliderLabel setBackgroundColor:[UIColor clearColor]];
    [self.sliderLabel setTextColor:[UIColor blackColor]];
    [self.sliderLabel setTextAlignment:NSTextAlignmentLeft];
    [self insertSubview:self.sliderLabel atIndex:0];
    [self.sliderLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.sliderLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:0.5 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.sliderLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:14.5]];

    // set the value slider
    self.sliderValueLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.sliderValueLabel setNumberOfLines:1];
    [self.sliderValueLabel setFont:[UIFont systemFontOfSize:16.0f]];
    [self.sliderValueLabel setText:@"0"];
    [self.sliderValueLabel setBackgroundColor:[UIColor clearColor]];
    [self.sliderValueLabel setTextColor:[UIColor blackColor]];
    [self.sliderValueLabel setTextAlignment:NSTextAlignmentRight];
    [self insertSubview:self.sliderValueLabel atIndex:0];
    [self.sliderValueLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.sliderValueLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:0.5 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.sliderValueLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:0.98 constant:0]];

    self.sliderType = sliderType;
    self.selectedColor = startColor;
	self.clipsToBounds = YES;

	_colorTrackHeight = 18;// (sliderType <= 2) ? 20 : (sliderType > 5) ? 20 : 8;
    [self updateTrackImage];
    [self setColor:startColor];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    self.colorTrackImageView.frame = [self trackRectForBounds:self.bounds];
    CGPoint center = self.colorTrackImageView.center;
    CGRect rect = self.colorTrackImageView.frame;
    rect.size.height = self.colorTrackHeight;
    self.colorTrackImageView.frame = rect;
    self.colorTrackImageView.center = center;

}

#pragma mark UISlider Implementation

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    BOOL tracking = [super beginTrackingWithTouch:touch withEvent:event];

    if (self.sliderValueLabel) {
        [self updateValueLabel];
    }
    return tracking;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    BOOL con = [super continueTrackingWithTouch:touch withEvent:event];

    if (self.sliderValueLabel) {
        [self updateValueLabel];
    }
    return con;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [super endTrackingWithTouch:touch withEvent:event];

    if (self.sliderValueLabel) {
        [self updateValueLabel];
    }
}

- (void)cancelTrackingWithEvent:(UIEvent *)event {
    [super cancelTrackingWithEvent:event];

    if (self.sliderValueLabel) {
        [self updateValueLabel];
    }
}

- (void)setMinimumTrackImage:(UIImage *)image forState:(UIControlState)state {}
- (void)setMaximumTrackImage:(UIImage *)image forState:(UIControlState)state {}

#pragma mark - Color Methods

- (UIColor *)colorFromCurrentValue {
    switch (self.sliderType) {
        case CSColorSliderTypeHue: {
            return [UIColor colorWithHue:self.value saturation:1 brightness:1.0 alpha:1.0];
        }
        case CSColorSliderTypeSaturation: {
            return [UIColor colorWithHue:1.0 saturation:self.value brightness:1.0 alpha:1.0];
        }
        case CSColorSliderTypeBrightness: {
            return [UIColor colorWithHue:1.0 saturation:1.0 brightness:self.value alpha:1.0];
        }
        case CSColorSliderTypeRed: {
            return [UIColor colorWithRed:self.value green:1.0 blue:1.0 alpha:1.0];
        }
        case CSColorSliderTypeGreen: {
            return [UIColor colorWithRed:1.0 green:self.value blue:1.0 alpha:1.0];
        }
        case CSColorSliderTypeBlue: {
            return [UIColor colorWithRed:1.0 green:1.0 blue:self.value alpha:1.0];
        }
        case CSColorSliderTypeAlpha: {
            return [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:self.value];
        }
        default: {
            return [UIColor colorWithHue:self.value saturation:1 brightness:1.0 alpha:1.0];
        }
    }
}

- (UIColor *)color {
    return [self colorFromCurrentValue];
}

- (void)setColor:(UIColor *)color {

    CGFloat value;

    switch (self.sliderType) {
        case CSColorSliderTypeHue: {
            [color getHue:&value saturation:nil brightness:nil alpha:nil];
        } break;
        case CSColorSliderTypeSaturation: {
            [color getHue:nil saturation:&value brightness:nil alpha:nil];
        } break;
        case CSColorSliderTypeBrightness: {
            [color getHue:nil saturation:nil brightness:&value alpha:nil];
        } break;
        case CSColorSliderTypeRed: {
            [color getRed:&value green:nil blue:nil alpha:nil];
        } break;
        case CSColorSliderTypeGreen: {
            [color getRed:nil green:&value blue:nil alpha:nil];
        } break;
        case CSColorSliderTypeBlue: {
            [color getRed:nil green:nil blue:&value alpha:nil];
        } break;
        case CSColorSliderTypeAlpha: {
            [color getWhite:nil alpha:&value];
        } break;
        default: {
            [color getRed:&value green:nil blue:nil alpha:nil];
        } break;
    }
    
    [self setValue:value animated:YES];
    self.selectedColor = color;
    [self updateTrackImage];
    [self updateValueLabel];
}

- (UIColor *)getMinMaxColor:(BOOL)max {
    switch (self.sliderType) {
        case CSColorSliderTypeBrightness: {
            CGFloat h,s,b = max,a;
            [self.selectedColor getHue:&h saturation:&s brightness:nil alpha:&a];
            return [UIColor colorWithHue:h saturation:s brightness:b alpha:a];
        }
        case CSColorSliderTypeSaturation: {
            CGFloat h,s = max,b,a;
            [self.selectedColor getHue:&h saturation:nil brightness:&b alpha:&a];
            return [UIColor colorWithHue:h saturation:s brightness:b alpha:a];
        }
        case CSColorSliderTypeAlpha: {
            CGFloat h,s,b,a = max;
            [self.selectedColor getHue:&h saturation:&s brightness:&b alpha:nil];
            return [UIColor colorWithHue:h saturation:s brightness:b alpha:a];
        }
		case CSColorSliderTypeRed: {
			CGFloat r = max,g,b,a;
			[self.selectedColor getRed:nil green:&g blue:&b alpha:&a];
			return [UIColor colorWithRed:r green:g blue:b alpha:a];
		}
		case CSColorSliderTypeGreen: {
			CGFloat r,g = max,b,a;
			[self.selectedColor getRed:&r green:nil blue:&b alpha:&a];
			return [UIColor colorWithRed:r green:g blue:b alpha:a];
		}
		case CSColorSliderTypeBlue: {
			CGFloat r,g,b = max,a;
			[self.selectedColor getRed:&r green:&g blue:nil alpha:&a];
			return [UIColor colorWithRed:r green:g blue:b alpha:a];
		}
        default: {
            return self.selectedColor;
        }
    }
}

- (float)colorMaxValue {
    switch (self.sliderType) {
        case CSColorSliderTypeHue: {
            return 360;
        }
        case CSColorSliderTypeSaturation:
        case CSColorSliderTypeBrightness:
        case CSColorSliderTypeAlpha: {
            return 100;
        }
        case CSColorSliderTypeRed:
        case CSColorSliderTypeGreen:
        case CSColorSliderTypeBlue: {
            return 255;
        }
        default: {
            return 1;
        }
    }
}

#pragma mark - Update Views

- (void)updateValueLabel {
    [self.sliderValueLabel setText:[NSString stringWithFormat:@"%.f", self.value * [self colorMaxValue]]];
}

- (void)updateTrackImage {
    switch (self.sliderType) {
        case CSColorSliderTypeHue: {
            if (!self.currentTrackImage) self.currentTrackImage = [UIImage hueTrackImage];
        } break;
        case CSColorSliderTypeSaturation: {
            UIColor *maxColor = [self getMinMaxColor:YES];
            BOOL maxChanged = (self.maxColor != maxColor);
            if ((self.maxColor = maxColor) && (!self.currentTrackImage || maxChanged)) self.currentTrackImage = [UIImage imageWithGradientStart:[UIColor whiteColor] end:maxColor size:CGSizeMake(2, 1)];
        } break;
        case CSColorSliderTypeBrightness: {
            UIColor *maxColor = [self getMinMaxColor:YES];
            BOOL maxChanged = (self.maxColor != maxColor);
            if ((self.maxColor = maxColor) && (!self.currentTrackImage || maxChanged)) self.currentTrackImage = [UIImage imageWithGradientStart:[UIColor blackColor] end:maxColor size:CGSizeMake(2, 1)];
        } break;
        case CSColorSliderTypeAlpha: {
            UIColor *maxColor = [self getMinMaxColor:YES];
            BOOL maxChanged = (self.maxColor != maxColor);
            if ((self.maxColor = maxColor) && (!self.currentTrackImage || maxChanged)) self.currentTrackImage = [UIImage imageWithGradientStart:[UIColor clearColor] end:maxColor size:CGSizeMake(2, 1)];
        } break;
        case CSColorSliderTypeRed: {
			UIColor *minColor = [self getMinMaxColor:NO], *maxColor = [self getMinMaxColor:YES];
			BOOL changed = (self.maxColor != maxColor || self.minColor != minColor);
			if ((self.maxColor = maxColor)&&(self.minColor = minColor) && (!self.currentTrackImage || changed)) self.currentTrackImage = [UIImage imageWithGradientStart:minColor end:maxColor size:CGSizeMake(2, 1)];
        } break;
        case CSColorSliderTypeGreen: {
			UIColor *minColor = [self getMinMaxColor:NO], *maxColor = [self getMinMaxColor:YES];
			BOOL changed = (self.maxColor != maxColor || self.minColor != minColor);
			if ((self.maxColor = maxColor)&&(self.minColor = minColor) && (!self.currentTrackImage || changed)) self.currentTrackImage = [UIImage imageWithGradientStart:minColor end:maxColor size:CGSizeMake(2, 1)];
        } break;
        case CSColorSliderTypeBlue: {
			UIColor *minColor = [self getMinMaxColor:NO], *maxColor = [self getMinMaxColor:YES];
			BOOL changed = (self.maxColor != maxColor || self.minColor != minColor);
			if ((self.maxColor = maxColor)&&(self.minColor = minColor) && (!self.currentTrackImage || changed)) self.currentTrackImage = [UIImage imageWithGradientStart:minColor end:maxColor size:CGSizeMake(2, 1)];
        } break;
        default: {
			UIColor *maxColor = [self getMinMaxColor:YES];
			BOOL changed = (self.maxColor != maxColor);
			if ((self.maxColor = maxColor) && (!self.currentTrackImage || changed)) self.currentTrackImage = [UIImage imageWithColor:maxColor size:CGSizeMake(1, 1)];
        } break;
    }

    [self.colorTrackImageView setImage:self.currentTrackImage];
}

- (void)setBlurStyle:(UIBlurEffectStyle)style {
	BOOL isDark = (style == UIBlurEffectStyleDark);
	if (_sliderLabel)
		[_sliderLabel setTextColor:isDark ? UIColor.lightTextColor : UIColor.darkGrayColor];
	if (_sliderValueLabel)
		[_sliderValueLabel setTextColor:isDark ? UIColor.lightTextColor : UIColor.darkGrayColor];
}

@end
