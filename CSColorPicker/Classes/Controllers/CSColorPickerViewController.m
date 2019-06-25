//
// Created by CreatureSurvive on 3/17/17.
// Copyright (c) 2016 - 2019 CreatureCoding. All rights reserved.
//

#import "CSColorPickerViewController.h"
#import "CSColorSlider.h"
#import "CSColorPickerPreviewView.h"
#import "CSGradientSelection.h"

#import "UIColor+CSColorPicker_Internal.h"
#import "UIImage+CSColorPicker_Internal.h"
#import "UIViewController+CSColorPicker_Internal.h"

#define SLIDER_HEIGHT 40.0
#define GRADIENT_HEIGHT 50.0

@implementation CSColorPickerViewController {
	BOOL _isGradient;
	BOOL _alphaEnabled;
	UIView *_containerView;
	NSInteger _selectedIndex;
    NSLayoutConstraint *_topConstraint;
	NSArray<CSColorSlider*> *_sliders;
    CSColorPickerPreviewView *_previewView;
    CSGradientSelection *_colorSelector;
	UIStackView *_topStack;
	UIStackView *_bottomStack;
}

#pragma Mark - Initialiation

- (instancetype)initWithColor:(UIColor *)color showingAlpha:(BOOL)alphaEnabled {
	if ((self = [super init])) {
		_color = color;
		_alphaEnabled = alphaEnabled;
		_blurStyle = UIBlurEffectStyleExtraLight;
	}
	
	return self;
}

- (instancetype)initWithColors:(NSArray<UIColor*> *)colors showingAlpha:(BOOL)alphaEnabled {
	if ((self = [super init])) {
		_colors = [colors mutableCopy];
		_alphaEnabled = alphaEnabled;
		_isGradient = YES;
		_blurStyle = UIBlurEffectStyleExtraLight;
	}
	
	return self;
}

- (instancetype)initWithColorObject:(CSColorObject *)colorObject showingAlpha:(BOOL)alphaEnabled {
	if ((self = [super init])) {
		_isGradient = colorObject.isGradient;
		_colors = colorObject.colors ? [colorObject.colors mutableCopy] : nil;
		_color = colorObject.color;
		_identifier = colorObject.identifier;
		_alphaEnabled = alphaEnabled;
		_selectedIndex = _isGradient ? _colors.count - 1 : 0;
		_blurStyle = UIBlurEffectStyleExtraLight;
	}
	
	return self;
}

#pragma Mark UIViewController

- (void)loadView {
	[super loadView];
	
	// create views
	_containerView = [[UIView alloc] initWithFrame:[self calculatedBounds]];
	_previewView = [[CSColorPickerPreviewView alloc] initWithFrame:self.view.bounds alphaEnabled:_alphaEnabled];
	[_previewView setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
	
	// top stack
	_topStack = [[UIStackView alloc] initWithFrame:CGRectZero];
	[_topStack setTranslatesAutoresizingMaskIntoConstraints:NO];
	[_topStack setAxis:UILayoutConstraintAxisVertical];
	[_topStack setDistribution:UIStackViewDistributionFillProportionally];
	[_topStack setAlignment:UIStackViewAlignmentFill];
	UIVisualEffectView *topBlur = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:self.blurStyle]];
	topBlur.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	
	// bottom stack
	_bottomStack = [[UIStackView alloc] initWithFrame:CGRectZero];
	[_bottomStack setTranslatesAutoresizingMaskIntoConstraints:NO];
	[_bottomStack setAxis:UILayoutConstraintAxisVertical];
	[_bottomStack setDistribution:UIStackViewDistributionFillProportionally];
	[_bottomStack setAlignment:UIStackViewAlignmentFill];
	UIVisualEffectView *bottomBlur = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:self.blurStyle]];
	bottomBlur.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	
	// sliders
	_sliders = @[
		 [[CSColorSlider alloc] initWithFrame:CGRectZero sliderType:CSColorSliderTypeHue label:Localize("H") startColor:[self startColor]],
		 [[CSColorSlider alloc] initWithFrame:CGRectZero sliderType:CSColorSliderTypeSaturation label:Localize("S") startColor:[self startColor]],
		 [[CSColorSlider alloc] initWithFrame:CGRectZero sliderType:CSColorSliderTypeBrightness label:Localize("B") startColor:[self startColor]],
		 [[CSColorSlider alloc] initWithFrame:CGRectZero sliderType:CSColorSliderTypeRed label:Localize("R") startColor:[self startColor]],
		 [[CSColorSlider alloc] initWithFrame:CGRectZero sliderType:CSColorSliderTypeGreen label:Localize("G") startColor:[self startColor]],
		 [[CSColorSlider alloc] initWithFrame:CGRectZero sliderType:CSColorSliderTypeBlue label:Localize("B") startColor:[self startColor]],
		 [[CSColorSlider alloc] initWithFrame:CGRectZero sliderType:CSColorSliderTypeAlpha label:Localize("A") startColor:[self startColor]]
	];
	
	// slider actions
	for (CSColorSlider *slider in _sliders) {
		[slider addTarget:self action:@selector(sliderDidChange:) forControlEvents:UIControlEventValueChanged];
		[slider addTarget:self action:@selector(valueDidUpdate:) forControlEvents:(UIControlEventTouchUpInside | UIControlEventTouchUpOutside)];
	}
	
	// gradient
	_colorSelector = [[CSGradientSelection alloc] initWithSize:CGSizeZero target:self addAction:@selector(addAction:) removeAction:@selector(removeAction:) selectAction:@selector(selectAction:)];
	[_colorSelector addColors:self.colors];
	if (_isGradient) [_colorSelector.heightAnchor constraintEqualToConstant:50.0].active = YES;

	// view hierarchy
	[_topStack addSubview:topBlur];
	[_bottomStack addSubview:bottomBlur];
	[_bottomStack addArrangedSubview:[self sliderOfType:CSColorSliderTypeHue]];
	[_bottomStack addArrangedSubview:[self sliderOfType:CSColorSliderTypeSaturation]];
	[_bottomStack addArrangedSubview:[self sliderOfType:CSColorSliderTypeBrightness]];
	[_bottomStack addArrangedSubview:[self sliderOfType:CSColorSliderTypeAlpha]];
	[_topStack addArrangedSubview:[self sliderOfType:CSColorSliderTypeRed]];
	[_topStack addArrangedSubview:[self sliderOfType:CSColorSliderTypeGreen]];
	[_topStack addArrangedSubview:[self sliderOfType:CSColorSliderTypeBlue]];
	[_topStack addArrangedSubview:_colorSelector];
	[_containerView addSubview:_previewView.labelContainer];
	[_containerView addSubview:_topStack];
	[_containerView addSubview:_bottomStack];
	[self.view insertSubview:_previewView atIndex:0];
	[self.view insertSubview:_containerView atIndex:1];
	
	// alpha|gradient enabled
	[self sliderOfType:CSColorSliderTypeAlpha].hidden = !_alphaEnabled;
	[self sliderOfType:CSColorSliderTypeAlpha].userInteractionEnabled = _alphaEnabled;
	_colorSelector.hidden = !_isGradient;
	_colorSelector.userInteractionEnabled = _isGradient;
	
	[self setBlurStyle:self.blurStyle];
	[self updateColorObject];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	if (self.showsDarkmodeToggle) {
		self.navigationItem.rightBarButtonItems = @[
			[[UIBarButtonItem alloc] initWithTitle:Localize("HEX") style:UIBarButtonItemStylePlain target:self action:@selector(presentHexColorAlert)],
			[[UIBarButtonItem alloc] initWithTitle:self->_blurStyle == UIBlurEffectStyleDark ? Localize("Light") : Localize("Dark") style:UIBarButtonItemStylePlain target:self action:@selector(toggleStyle:)]
		];
	} else {
		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:Localize("HEX") style:UIBarButtonItemStylePlain target:self action:@selector(presentHexColorAlert)];
	}
	
	if ([self isModal]) {
		self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismiss)];
	}
	
	[UIView animateWithDuration:0.3 animations:^{
		[self->_previewView setPreviewColor:[self startColor]];
	}];

	[self setLayoutConstraints];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self setLayoutConstraints];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self saveColor];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
	[coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
		[self setLayoutConstraints];
		[self updateView];
		[self->_previewView setNeedsDisplay];
	} completion:nil];
	
	[super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

- (void)viewDidLayoutSubviews {
	[super viewDidLayoutSubviews];
	[self updateView];
}

#pragma Mark - CSColorPickerViewController (View)

- (void)dismiss {
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)updateView {
	CGRect bounds = [self calculatedBounds];
	[_containerView setFrame:bounds];
	_topConstraint.constant = [self navigationHeight];
	[_previewView setPreviewColor:[self colorForHSBSliders]];
}

- (CGRect)calculatedBounds {
    UIEdgeInsets insets = UIEdgeInsetsZero;
	if (@available(iOS 11.0, *)) insets = [self.view safeAreaInsets];
	insets.top = 0;

    return UIEdgeInsetsInsetRect(self.view.bounds, insets);
}

- (void)setBlurStyle:(UIBlurEffectStyle)blurStyle {
	_blurStyle = blurStyle;
	for (CSColorSlider *slider in _sliders) {
		[slider setBlurStyle:blurStyle];
	}
	[(UIVisualEffectView *)_topStack.subviews.firstObject setEffect:[UIBlurEffect effectWithStyle:blurStyle]];
	[(UIVisualEffectView *)_bottomStack.subviews.firstObject setEffect:[UIBlurEffect effectWithStyle:blurStyle]];
	[_previewView setDarkMode:blurStyle == UIBlurEffectStyleDark];
	[self.navigationController.navigationBar setBarStyle:(blurStyle == UIBlurEffectStyleDark) ? UIBarStyleBlackTranslucent : UIBarStyleDefault];
}

- (void)setBlurStyle:(UIBlurEffectStyle)blurStyle animated:(BOOL)animated {
	if (animated) [UIView animateWithDuration:0.3 animations:^{ [self setBlurStyle:blurStyle]; }];
	else [self setBlurStyle:blurStyle];
}

- (void)toggleStyle:(UIBarButtonItem *)sender {
	if (sender) sender.title = self->_blurStyle == UIBlurEffectStyleDark ? Localize("DARK") : Localize("LIGHT");
	[self setBlurStyle:(self->_blurStyle == UIBlurEffectStyleDark) ? UIBlurEffectStyleExtraLight : UIBlurEffectStyleDark animated:YES];
}

- (CSColorSlider *)sliderOfType:(CSColorSliderType)type {
	return _sliders[type];
}

#pragma Mark - CSColorPickerViewController (Actions)

- (void)valueDidUpdate:(CSColorSlider *)slider {
	[self updateColorObject];
	if (self.delegate && [self.delegate respondsToSelector:@selector(colorPicker:didUpdateColor:)]) {
		[self.delegate colorPicker:self didUpdateColor:_colorObject];
	}
}

- (void)sliderDidChange:(CSColorSlider *)sender {
	NSUInteger fullValue = sender.value * sender.colorMaxValue;
	if (fullValue != sender.lastValue) {
		sender.lastValue = fullValue;
	
		UIColor *color = (sender.sliderType > 2) ? [self colorForRGBSliders] : [self colorForHSBSliders];
		[self updateColor:color animated:NO];
	}
}

#pragma Mark - CSColorPickerViewController (Colors)

- (UIColor *)colorForHSBSliders {
	return [UIColor colorWithHue:[self sliderOfType:CSColorSliderTypeHue].value
					  saturation:[self sliderOfType:CSColorSliderTypeSaturation].value
					  brightness:[self sliderOfType:CSColorSliderTypeBrightness].value
						   alpha:[self sliderOfType:CSColorSliderTypeAlpha].value];
}

- (UIColor *)colorForRGBSliders {
	return [UIColor colorWithRed:[self sliderOfType:CSColorSliderTypeRed].value
						   green:[self sliderOfType:CSColorSliderTypeGreen].value
							blue:[self sliderOfType:CSColorSliderTypeBlue].value
						   alpha:[self sliderOfType:CSColorSliderTypeAlpha].value];
}

- (void)updateColorObject {
	if (_isGradient) _colorObject = [CSColorObject gradientObjectWithColors:self.colors];
	else _colorObject = [CSColorObject colorObjectWithColor:self.color];
	if (self.identifier) _colorObject.identifier = self.identifier;
}

- (void)updateColor:(UIColor *)color animated:(BOOL)animated{
    [self setColor:color animated:animated];
	
	if (_isGradient) {
        self.colors[_selectedIndex] = color;
        [_colorSelector setColor:color atIndex:_selectedIndex];
	}
}

- (void)setColor:(UIColor *)color animated:(BOOL)animated {
	self.color = color;
    void (^update)(void) = ^void(void) {
		for (CSColorSlider *slider in self->_sliders) {
			[slider setColor:color];
		}

        [self->_previewView setPreviewColor:color];
    };

    if (animated) 
        [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{ update(); } completion:nil];
    else 
        update();
}

- (UIColor *)startColor {
    return _isGradient ? self.colors.lastObject : self.color;
}

- (void)saveColor {
	// save in NSUserDefaults
	if (self.identifier)
		[[NSUserDefaults standardUserDefaults] setObject:_colorObject.hexValue forKey:self.identifier];
	
	// call delegate didPickColor method
	if (self.delegate && [self.delegate respondsToSelector:@selector(colorPicker:didPickColor:)]) {
		[self.delegate colorPicker:self didPickColor:_colorObject];
	}
	
	// update the cell display
	if (self.cellObject) {
		[self.cellObject setColorObject:_colorObject];
	}
}

#pragma Mark - CSColorPickerViewController (Color Selection Actions)

- (void)addAction:(UIButton *)sender {
    UIColor *color = [self.colors.lastObject complementaryColor];
    [self.colors addObject:color];
    [_colorSelector addColor:color];
    [self setColor:self.colors.lastObject animated:YES];
    _selectedIndex = self.colors.count - 1;
	[self updateColorObject];
}

- (void)removeAction:(UIButton *)sender {
    [self.colors removeObjectAtIndex:_selectedIndex];
    [_colorSelector removeColorAtIndex:_selectedIndex];
    [self setColor:self.colors.lastObject animated:YES];
    _selectedIndex = self.colors.count - 1;
	[self updateColorObject];
}

- (void)selectAction:(UIButton *)sender {
    [self setColor:self.colors[sender.titleLabel.tag] animated:YES];
    _selectedIndex = sender.titleLabel.tag;
}

- (void)presentHexColorAlert {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:Localize("ALERT_TITLE") message:Localize("ALERT_MESSAGE") preferredStyle:UIAlertControllerStyleAlert];

    [alertController addTextFieldWithConfigurationHandler:^(UITextField *hexField) {
        hexField.text = [NSString stringWithFormat:@"#%@", [[self colorForHSBSliders] cscp_hexString]];
		hexField.clearButtonMode = UITextFieldViewModeAlways;
    }];

    [alertController addAction:[UIAlertAction actionWithTitle:Localize("ALERT_COPY") style:UIAlertActionStyleDefault handler:^(UIAlertAction *copy) {
        [[UIPasteboard generalPasteboard] setString:[self colorForHSBSliders].cscp_hexStringWithAlpha];
    }]];

    [alertController addAction:[UIAlertAction actionWithTitle:Localize("ALERT_SET") style:UIAlertActionStyleDefault handler:^(UIAlertAction *set) {
        [self updateColor:[UIColor cscp_colorFromHexString:alertController.textFields[0].text] animated:YES];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:Localize("ALERT_PASTEBOARD") style:UIAlertActionStyleDefault handler:^(UIAlertAction *set) {
        [self updateColor:[UIColor cscp_colorFromHexString:[UIPasteboard generalPasteboard].string] animated:YES];
    }]];

    [alertController addAction:[UIAlertAction actionWithTitle:Localize("ALERT_CANCEL") style:UIAlertActionStyleCancel handler:nil]];


    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)setLayoutConstraints {
	
	[_containerView removeConstraints:_containerView.constraints];
	
	BOOL landscape = [self isLandscape];
	NSInteger rowCount = 6 + _alphaEnabled;
	CGFloat sliderHeight = landscape ? sliderHeight = (CGRectGetHeight(_containerView.bounds) - [self navigationHeight] - (_isGradient ? 50 : 0)) / rowCount : SLIDER_HEIGHT;
	CGFloat widthMultiplier = landscape ? 0.5 : 1;
	
	if (landscape && _isGradient) {
		[_colorSelector setGradientOnTop:YES];
		[_topStack removeArrangedSubview:_colorSelector];
		[_topStack insertArrangedSubview:_colorSelector atIndex:0];
	} else if (!landscape && _isGradient) {
		[_colorSelector setGradientOnTop:NO];
		[_topStack removeArrangedSubview:_colorSelector];
		[_topStack insertArrangedSubview:_colorSelector atIndex:3];
	}

    NSArray *constraints = @[
		// top stack constraints
		[NSLayoutConstraint constraintWithItem:_topStack attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_containerView attribute:NSLayoutAttributeTop multiplier:1 constant:[self navigationHeight]],
		[NSLayoutConstraint constraintWithItem:_topStack attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_containerView attribute:NSLayoutAttributeWidth multiplier:widthMultiplier constant:0],
		[NSLayoutConstraint constraintWithItem:_topStack attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:(sliderHeight * 3) + (_isGradient ? 50 : 0)],
		// bottom stack constraints
		[NSLayoutConstraint constraintWithItem:_bottomStack attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_containerView attribute:NSLayoutAttributeBottom multiplier:1 constant:0],
		[NSLayoutConstraint constraintWithItem:_bottomStack attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_containerView attribute:NSLayoutAttributeWidth multiplier:widthMultiplier constant:0],
		[NSLayoutConstraint constraintWithItem:_bottomStack attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:sliderHeight * (_alphaEnabled ? 4 : 3)],
		// label constraints
		[NSLayoutConstraint constraintWithItem:_previewView.labelContainer attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_containerView attribute:NSLayoutAttributeWidth multiplier:widthMultiplier constant:0],
		[NSLayoutConstraint constraintWithItem:_previewView.labelContainer attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:_containerView attribute:NSLayoutAttributeTrailing multiplier:1 constant:0],
		[NSLayoutConstraint constraintWithItem:_previewView.labelContainer attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:landscape ? _containerView : _topStack attribute:landscape ? NSLayoutAttributeTop : NSLayoutAttributeBottom multiplier:1 constant:landscape ? [self navigationHeight] : 0],
		[NSLayoutConstraint constraintWithItem:_previewView.labelContainer attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:landscape ? _containerView : _bottomStack attribute:landscape ? NSLayoutAttributeBottom : NSLayoutAttributeTop multiplier:1 constant:0]
    ];

    _topConstraint = constraints.firstObject;
    [_containerView addConstraints:constraints];
}

@end
