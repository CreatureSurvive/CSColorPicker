//
//  CSColorDisplayCellTableViewCell.m
//  CSColorPicker
//
//  Created by Dana Buehre on 6/23/19.
//  Copyright © 2019 CreatureCoding. All rights reserved.
//

#import "CSColorDisplayCell.h"
#import "CSColorPickerViewController.h"
#import "CSColorObject.h"

@implementation CSColorDisplayCell {
	UIView *_colorDisplay;
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
		_colorDisplay.backgroundColor = _colorObject.color;
	}
}

- (void)setColorObject:(CSColorObject *)colorObject {
	_colorObject = colorObject;
	_colorDisplay.backgroundColor = colorObject.color;
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
	}
}

- (CSColorPickerViewController *)colorPicker {
	CSColorPickerViewController *vc = [[CSColorPickerViewController alloc] initWithColorObject:_colorObject showingAlpha:YES];
	vc.cellObject = self;
	vc.delegate = _delegate;
	
	return vc;
}

@end
