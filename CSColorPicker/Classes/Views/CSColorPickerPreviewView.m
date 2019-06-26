//
// Created by CreatureSurvive on 3/17/17.
// Copyright (c) 2016 - 2019 CreatureCoding. All rights reserved.
//

#import "CSColorPickerPreviewView.h"
#import "UIColor+CSColorPicker.h"

@implementation CSColorPickerPreviewView {
	UIView *_previewView;
	UIStackView *_colorLabelStack;
}

- (id)initWithFrame:(CGRect)frame alphaEnabled:(BOOL)alphaEnabled {
    if ((self = [super initWithFrame:frame])) {
		self.alphaEnabled = alphaEnabled;
        self.tag = 199;
		
		_previewView = [[UIView alloc] initWithFrame:self.bounds];
		[_previewView setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
		[_previewView setBackgroundColor:UIColor.clearColor];
		[self addSubview:_previewView];
		
		UILabel *topLabel = [self newPreviewLabel];
		topLabel.numberOfLines = 1;
		topLabel.font = [UIFont systemFontOfSize:40 weight:UIFontWeightBlack];
		
		_labelContainer = [[UIStackView alloc] initWithFrame:self.bounds];
		[_labelContainer setTranslatesAutoresizingMaskIntoConstraints:NO];
		[_labelContainer setAxis:UILayoutConstraintAxisVertical];
		[_labelContainer setDistribution:UIStackViewDistributionFillProportionally];
		[_labelContainer setAlignment:UIStackViewAlignmentFill];
		
		_colorLabelStack = [[UIStackView alloc] initWithFrame:self.bounds];
		[_colorLabelStack setTranslatesAutoresizingMaskIntoConstraints:NO];
		[_colorLabelStack setAxis:UILayoutConstraintAxisHorizontal];
		[_colorLabelStack setDistribution:UIStackViewDistributionEqualCentering];
		[_colorLabelStack setAlignment:UIStackViewAlignmentCenter];
		[_colorLabelStack addArrangedSubview:[UIView new]];
		[_colorLabelStack addArrangedSubview:[self newPreviewLabel]];
		[_colorLabelStack addArrangedSubview:[self newPreviewLabel]];
		[_colorLabelStack addArrangedSubview:[UIView new]];
		
		[_labelContainer addArrangedSubview:topLabel];
		[_labelContainer addArrangedSubview:_colorLabelStack];
    }
    return self;
}

// credits libColorPicker https://github.com/atomikpanda/libcolorpicker/blob/master/PFColorTransparentView.m
- (void)drawRect:(CGRect)rect {
    int scale = rect.size.width / 25;
	NSArray *colors = @[self.isDark ? UIColor.darkGrayColor : UIColor.whiteColor, UIColor.grayColor];

    for (int row = 0; row < rect.size.height; row += scale) {

        int index = row % (scale * 2) == 0 ? 0 : 1;
        
        for (int column = 0; column < rect.size.width; column += scale) {
        
            [[colors objectAtIndex:index++ % 2] setFill];
            
            UIRectFill(CGRectMake(column, row, scale, scale));
        }
    }
}

- (void)layoutSubviews {
	[super layoutSubviews];
	[_labelContainer layoutIfNeeded];
	[_colorLabelStack layoutIfNeeded];
}

- (void)setDarkMode:(BOOL)darkMode {
	if (_isDark != darkMode) {
		[self setNeedsDisplay];
	}
	_isDark = darkMode;
}

- (void)setPreviewColor:(UIColor *)color {
	[_previewView setBackgroundColor:color];
	
	[self updateLabelsTextWithColor:color];
	UIColor *legibilityTint = (!color.cscp_light && color.cscp_alpha > 0.5) ? UIColor.whiteColor : UIColor.blackColor;
	UIColor *shadowColor = legibilityTint == UIColor.blackColor ? UIColor.whiteColor : UIColor.blackColor;
	
	UILabel *rgb = _colorLabelStack.arrangedSubviews[1], *hsb = _colorLabelStack.arrangedSubviews[2], *hex = _labelContainer.arrangedSubviews[0];
	[rgb setTextColor:legibilityTint];
	[hsb setTextColor:legibilityTint];
	[hex setTextColor:legibilityTint];
	[rgb.layer setShadowColor:[shadowColor CGColor]];
	[hsb.layer setShadowColor:[shadowColor CGColor]];
	[hex.layer setShadowColor:[shadowColor CGColor]];
}

- (void)updateLabelsTextWithColor:(UIColor *)color {
	CGFloat h, s, b, a, r, g, bb;
	[color getHue:&h saturation:&s brightness:&b alpha:&a];
	[color getRed:&r green:&g blue:&bb alpha:nil];
	
	UILabel *rgb = _colorLabelStack.arrangedSubviews[1], *hsb = _colorLabelStack.arrangedSubviews[2], *hex = _labelContainer.arrangedSubviews[0];
	hex.text = [NSString stringWithFormat:@"#%@", [color cscp_hexString]];
	if (_alphaEnabled) {
		rgb.text = [NSString stringWithFormat:@"R: %.f\nG: %.f\nB: %.f\nA: %.f", r * 255, g * 255, bb * 255, a * 100];
		hsb.text = [NSString stringWithFormat:@"H: %.f\nS: %.f\nB: %.f\nA: %.f", h * 360, s * 100, b * 100, a * 100];
	
	} else {
		rgb.text = [NSString stringWithFormat:@"R: %.f\nG: %.f\nB: %.f", r * 255, g * 255, bb * 255];
		hsb.text = [NSString stringWithFormat:@"H: %.f\nS: %.f\nB: %.f", h * 360, s * 100, b * 100];
	}
}

- (UILabel *)newPreviewLabel {
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
	[label setTranslatesAutoresizingMaskIntoConstraints:NO];
	[label setNumberOfLines:_alphaEnabled ? 4 : 3];
	[label setFont:[UIFont systemFontOfSize:22 weight:UIFontWeightBold]];
	[label setBackgroundColor:[UIColor clearColor]];
	[label setTextAlignment:NSTextAlignmentCenter];
	[label.layer setShadowOffset:CGSizeZero];
	[label.layer setShadowRadius:2];
	[label.layer setShadowOpacity:1];
	return label;
}

@end
