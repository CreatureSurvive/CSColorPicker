//
//  CSGradientDisplayCell.m
//  CSColorPicker
//
//  Created by Dana Buehre on 6/23/19.
//  Copyright © 2019 CreatureCoding. All rights reserved.
//

#import "CSGradientDisplayCell.h"
#import "CSColorPickerViewController.h"
#import "CSColorObject.h"

@implementation CSGradientDisplayCell {
	UIView *_colorDisplay;
	CAGradientLayer *_gradient;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	if ((self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier])) {
		[self commonInit];
	}
	
	return self;
}

- (void)awakeFromNib {
	[super awakeFromNib];
	[self commonInit];
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	if (_colorObject) {
		_gradient.colors = [_colorObject gradientCGColors];
	}
}

- (void)setColorObject:(CSColorObject *)colorObject {
	_colorObject = colorObject;
	_gradient.colors = [colorObject gradientCGColors];
	self.detailTextLabel.text = colorObject.hexValue;
}

- (void)setColorObject:(CSColorObject *)colorObject delegate:(id<CSColorPickerDelegate>)delegate {
	[self setColorObject:colorObject];
	_delegate = delegate;
}

- (void)commonInit {
	self.detailTextLabel.textColor = UIColor.darkGrayColor;
	self.detailTextLabel.adjustsFontSizeToFitWidth = YES;
	
	if (!_colorDisplay) {
		_colorDisplay = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 58, 29)];
		_colorDisplay.tag = 199;
		_colorDisplay.layer.cornerRadius = CGRectGetHeight(_colorDisplay.frame) / 4;
		_colorDisplay.layer.borderWidth = 2;
		_colorDisplay.layer.borderColor = [UIColor lightGrayColor].CGColor;
		[self setAccessoryView:_colorDisplay];
		
		_gradient = [CAGradientLayer layer];
		_gradient.frame = _colorDisplay.bounds;
		_gradient.cornerRadius = _colorDisplay.layer.cornerRadius;
		_gradient.startPoint = CGPointMake(0, 0.5);
		_gradient.endPoint = CGPointMake(1, 0.5);
		
		[_colorDisplay.layer addSublayer:_gradient];
	}
}

- (CSColorPickerViewController *)colorPicker {
	CSColorPickerViewController *vc = [[CSColorPickerViewController alloc] initWithColorObject:_colorObject showingAlpha:YES];
	vc.cellObject = self;
	vc.delegate = _delegate;
	
	return vc;
}

@end
