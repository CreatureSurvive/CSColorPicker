//
// Created by CreatureSurvive on 3/17/17.
// Copyright (c) 2016 - 2019 CreatureCoding. All rights reserved.
//

#import "CSColorPickerViewController.h"
#import "CSColorSlider.h"
#import "CSColorPickerPreviewView.h"
#import "CSGradientSelector.h"
#import "CSColorObjectManager.h"
#import "CSColorSelector.h"

#import "UIColor+CSColorPicker_Internal.h"
#import "UIImage+CSColorPicker_Internal.h"
#import "UIViewController+CSColorPicker_Internal.h"

#define SLIDER_HEIGHT 40.0
#define GRADIENT_HEIGHT 50.0

@implementation CSColorPickerViewController {
	BOOL _isGradient;
	BOOL _alphaEnabled;
	UIView *_containerView;
    CSColorPickerPreviewView *_previewView;
    CSGradientSelector *_colorSelector;
	UIStackView *_topStack;
	UIStackView *_bottomStack;
	CSColorObjectManager *_colorManager;
}

#pragma Mark - Initialiation

- (instancetype)initWithColor:(UIColor *)color showingAlpha:(BOOL)alphaEnabled {
	if ((self = [super init])) {
		_alphaEnabled = alphaEnabled;
		_blurStyle = UIBlurEffectStyleExtraLight;
		_useSafeArea = YES;
		_colorObject = [CSColorObject colorObjectWithColor:color];
	}
	
	return self;
}

- (instancetype)initWithColors:(NSArray<UIColor*> *)colors showingAlpha:(BOOL)alphaEnabled {
	if ((self = [super init])) {
		_alphaEnabled = alphaEnabled;
		_isGradient = YES;
		_blurStyle = UIBlurEffectStyleExtraLight;
		_useSafeArea = YES;
		_colorObject = [CSColorObject gradientObjectWithColors:colors];
	}
	
	return self;
}

- (instancetype)initWithColorObject:(CSColorObject *)colorObject showingAlpha:(BOOL)alphaEnabled {
	if ((self = [super init])) {
		_isGradient = colorObject.isGradient;
		_identifier = colorObject.identifier;
		_colorObject = colorObject;
		_alphaEnabled = alphaEnabled;
		_blurStyle = UIBlurEffectStyleExtraLight;
		_useSafeArea = YES;
	}
	
	return self;
}

#pragma Mark UIViewController

- (void)loadView {
	[super loadView];
	_colorManager = [[CSColorObjectManager alloc] initWithColorType:CSColorTypeAll colorObject:_colorObject target:self action:@selector(colorDidChange:)];
	
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
	
	// gradient
	_colorSelector = [[CSGradientSelector alloc] initWithFrame:CGRectZero colorObject:_colorObject];
	[_colorSelector addTarget:self action:@selector(addAction:) forControlEvents:CSColorSelectionAdd];
	[_colorSelector addTarget:self action:@selector(removeAction:) forControlEvents:CSColorSelectionRemove];
	[_colorSelector addTarget:self action:@selector(selectAction:) forControlEvents:CSColorSelectionChanged];
//	if (_isGradient) [_colorSelector.heightAnchor constraintEqualToConstant:50.0].active = YES;

	// view hierarchy
	[_topStack addSubview:topBlur];
	[_bottomStack addSubview:bottomBlur];
	[_bottomStack addArrangedSubview:[_colorManager sliderOfType:CSColorSliderTypeHue]];
	[_bottomStack addArrangedSubview:[_colorManager sliderOfType:CSColorSliderTypeSaturation]];
	[_bottomStack addArrangedSubview:[_colorManager sliderOfType:CSColorSliderTypeBrightness]];
	[_bottomStack addArrangedSubview:[_colorManager sliderOfType:CSColorSliderTypeAlpha]];
	[_topStack addArrangedSubview:[_colorManager sliderOfType:CSColorSliderTypeRed]];
	[_topStack addArrangedSubview:[_colorManager sliderOfType:CSColorSliderTypeGreen]];
	[_topStack addArrangedSubview:[_colorManager sliderOfType:CSColorSliderTypeBlue]];
	[_topStack addArrangedSubview:_colorSelector];
	[_containerView addSubview:_previewView.labelContainer];
	[_containerView addSubview:_topStack];
	[_containerView addSubview:_bottomStack];
	[self.view insertSubview:_previewView atIndex:0];
	[self.view insertSubview:_containerView atIndex:1];
	
	// alpha|gradient enabled
	[_colorManager sliderOfType:CSColorSliderTypeAlpha].hidden = !_alphaEnabled;
	[_colorManager sliderOfType:CSColorSliderTypeAlpha].userInteractionEnabled = _alphaEnabled;
	_colorSelector.hidden = !_isGradient;
	_colorSelector.userInteractionEnabled = _isGradient;
	
	[self setBlurStyle:self.blurStyle];
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
		[self->_previewView setPreviewColor:self->_colorObject.selectedColor];
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
	[_containerView setFrame:[self calculatedBounds]];
	[_previewView setPreviewColor:[_colorManager hsbaColor]];
}

- (CGRect)calculatedBounds {
	
	UIEdgeInsets insets = UIEdgeInsetsZero;
	if (self.useSafeArea) {
		if (@available(iOS 11.0, *)) insets = [self.view safeAreaInsets];
		insets.top = [self navigationHeightWithStatusbar:YES];
	} else {
		insets.top = [self navigationHeightWithStatusbar:NO];
	}
	
	return UIEdgeInsetsInsetRect(self.view.bounds, insets);
}

- (void)setBlurStyle:(UIBlurEffectStyle)blurStyle {
	_blurStyle = blurStyle;
	[_colorSelector setLightContent:blurStyle == UIBlurEffectStyleDark];
	[_colorManager setLightContent:blurStyle == UIBlurEffectStyleDark];
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

#pragma Mark - CSColorPickerViewController (Actions)

- (void)valueDidUpdate:(CSColorSlider *)slider {
	if (self.delegate && [self.delegate respondsToSelector:@selector(colorPicker:didUpdateColor:)]) {
		[self.delegate colorPicker:self didUpdateColor:_colorObject];
	}
}

- (void)colorDidChange:(CSColorObject *)colorObject {
	_colorObject = colorObject;
	[_colorObject setIdentifier:self.identifier];
	
	if (_isGradient) {
		[_colorSelector setColor:colorObject.selectedColor atIndex:_colorManager.gradientIndex];
	}
}

#pragma Mark - CSColorPickerViewController (Colors)

- (void)saveColor {
	[_colorObject finalizeChange];
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

- (void)addAction:(CSGradientSelector *)sender {
    UIColor *color = [_colorObject.colors.lastObject complementaryColor];
	[_colorManager addColor:color];
    [_colorSelector addColor:color animated:YES];
}

- (void)removeAction:(CSGradientSelector *)sender {
	NSInteger index = _colorManager.gradientIndex;
	[_colorManager removeColor];
    [_colorSelector removeColorAtIndex:index animated:YES];
}

- (void)selectAction:(CSGradientSelector *)sender {
	[_colorManager setGradientIndex:sender.index animated:YES];
}

- (void)presentHexColorAlert {
	[_colorObject finalizeChange];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:Localize("ALERT_TITLE") message:Localize("ALERT_MESSAGE") preferredStyle:UIAlertControllerStyleAlert];

    [alertController addTextFieldWithConfigurationHandler:^(UITextField *hexField) {
        hexField.text = [self->_colorManager colorObject].selectedColor.cscp_hexString;
		hexField.clearButtonMode = UITextFieldViewModeAlways;
    }];

    [alertController addAction:[UIAlertAction actionWithTitle:Localize("ALERT_COPY") style:UIAlertActionStyleDefault handler:^(UIAlertAction *copy) {
		[[UIPasteboard generalPasteboard] setString:[self->_colorManager colorObject].hexValue];
    }]];

    [alertController addAction:[UIAlertAction actionWithTitle:Localize("ALERT_SET") style:UIAlertActionStyleDefault handler:^(UIAlertAction *set) {
        [self->_colorManager setColor:[UIColor cscp_colorFromHexString:alertController.textFields[0].text] animated:YES];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:Localize("ALERT_PASTEBOARD") style:UIAlertActionStyleDefault handler:^(UIAlertAction *set) {
        [self->_colorManager setColor:[UIColor cscp_colorFromHexString:[UIPasteboard generalPasteboard].string] animated:YES];
    }]];

    [alertController addAction:[UIAlertAction actionWithTitle:Localize("ALERT_CANCEL") style:UIAlertActionStyleCancel handler:nil]];


    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)setLayoutConstraints {
	
	[_containerView removeConstraints:_containerView.constraints];
	
	BOOL landscape = [self isLandscape];
	NSInteger rowCount = 6 + _alphaEnabled;
	CGFloat sliderHeight = landscape ? sliderHeight = (CGRectGetHeight(_containerView.bounds) - (_isGradient ? 50 : 0)) / rowCount : SLIDER_HEIGHT;
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
		[NSLayoutConstraint constraintWithItem:_topStack attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_containerView attribute:NSLayoutAttributeTop multiplier:1 constant:0],
		[NSLayoutConstraint constraintWithItem:_topStack attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_containerView attribute:NSLayoutAttributeWidth multiplier:widthMultiplier constant:0],
		[NSLayoutConstraint constraintWithItem:_topStack attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:(sliderHeight * 3) + (_isGradient ? 50 : 0)],
		// bottom stack constraints
		[NSLayoutConstraint constraintWithItem:_bottomStack attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_containerView attribute:NSLayoutAttributeBottom multiplier:1 constant:0],
		[NSLayoutConstraint constraintWithItem:_bottomStack attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_containerView attribute:NSLayoutAttributeWidth multiplier:widthMultiplier constant:0],
		[NSLayoutConstraint constraintWithItem:_bottomStack attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:sliderHeight * (_alphaEnabled ? 4 : 3)],
		// label constraints
		[NSLayoutConstraint constraintWithItem:_previewView.labelContainer attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_containerView attribute:NSLayoutAttributeWidth multiplier:widthMultiplier constant:0],
		[NSLayoutConstraint constraintWithItem:_previewView.labelContainer attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:_containerView attribute:NSLayoutAttributeTrailing multiplier:1 constant:0],
		[NSLayoutConstraint constraintWithItem:_previewView.labelContainer attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_topStack attribute:landscape ? NSLayoutAttributeTop : NSLayoutAttributeBottom multiplier:1 constant:0],
		[NSLayoutConstraint constraintWithItem:_previewView.labelContainer attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:landscape ? _containerView : _bottomStack attribute:landscape ? NSLayoutAttributeBottom : NSLayoutAttributeTop multiplier:1 constant:0]
    ];

    [_containerView addConstraints:constraints];
}

@end
