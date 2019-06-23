//
// Created by CreatureSurvive on 3/17/17.
// Copyright (c) 2016 - 2019 CreatureCoding. All rights reserved.
//

#import "CSColorPickerViewController.h"
#import "CSColorSlider.h"
#import "CSColorPickerBackgroundView.h"
#import "CSGradientSelection.h"

#define SLIDER_HEIGHT 40.0
#define GRADIENT_HEIGHT 50.0
#define ALERT_TITLE @"Set Hex Color"
#define ALERT_MESSAGE @"supported formats: 'RGB' 'ARGB' 'RRGGBB' 'AARRGGBB' 'RGB:0.25' 'RRGGBB:0.25'"
#define ALERT_COPY @"Copy Color"
#define ALERT_SET @"Set Color"
#define ALERT_PASTEBOARD @"Set From PasteBoard"
#define ALERT_CANCEL @"Cancel"

@implementation CSColorPickerViewController {
    NSLayoutConstraint *_topConstraint;
    CSColorSlider *_colorPickerHueSlider;
    CSColorSlider *_colorPickerSaturationSlider;
    CSColorSlider *_colorPickerBrightnessSlider;
    CSColorSlider *_colorPickerAlphaSlider;
    CSColorSlider *_colorPickerRedSlider;
    CSColorSlider *_colorPickerGreenSlider;
    CSColorSlider *_colorPickerBlueSlider;
    CSColorPickerBackgroundView *_colorPickerBackgroundView;
    CSGradientSelection *_gradientSelection;
    UIView *_colorPickerContainerView;
    UILabel *_colorInformationLable;
    UIImageView *_colorTrackImageView;
    UIView *_colorPickerPreviewView;
    NSInteger _selectedIndex;
    BOOL _isGradient;
	BOOL _alphaEnabled;
}

- (id)initWithColor:(UIColor *)color showingAlpha:(BOOL)alphaEnabled {
	if ((self = [super init])) {
		_color = color;
		_alphaEnabled = alphaEnabled;
		_blurStyle = UIBlurEffectStyleExtraLight;
	}
	
	return self;
}

- (id)initWithColors:(NSArray<UIColor*> *)colors showingAlpha:(BOOL)alphaEnabled {
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
		_alphaEnabled = alphaEnabled;
		_blurStyle = UIBlurEffectStyleExtraLight;
	}
	
	return self;
}

- (void)loadView {
	[super loadView];
	[self loadColorPickerView];
}

- (void)viewDidLoad {
    [super viewDidLoad];

	self.view.backgroundColor = [UIColor whiteColor];
    self->_colorPickerContainerView.alpha = 0;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	self.navigationItem.rightBarButtonItems = @[
		[[UIBarButtonItem alloc] initWithTitle:@"#" style:UIBarButtonItemStylePlain target:self action:@selector(presentHexColorAlert)],
		[[UIBarButtonItem alloc] initWithTitle:@"•" style:UIBarButtonItemStylePlain target:self action:@selector(toggleStyle)]
	];
	
	if ([self isModal]) {
		self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismiss)];
	}
	
	[UIView animateWithDuration:0.3 animations:^{
		self->_colorPickerContainerView.alpha = 1;
		self->_colorPickerPreviewView.backgroundColor = [self startColor];
	}];

	[self setLayoutConstraints];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self saveColor];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
	[coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
		[self updateView];
	} completion:nil];
	
	[super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

- (void)dismiss {
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)loadColorPickerView {

    // create views
    CGRect bounds = [self calculatedBounds];
    _colorPickerContainerView = [[UIView alloc] initWithFrame:bounds];
    _colorPickerContainerView.tag = 199;
    _colorPickerBackgroundView = [[CSColorPickerBackgroundView alloc] initWithFrame:bounds];
    _colorPickerPreviewView = [[UIView alloc] initWithFrame:bounds];
    _colorPickerPreviewView.tag = 199;

    _selectedIndex = self.colors.count - 1;
    _gradientSelection = [[CSGradientSelection alloc] initWithSize:CGSizeZero target:self addAction:@selector(addAction:) removeAction:@selector(removeAction:) selectAction:@selector(selectAction:)];
    [_gradientSelection setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_colorPickerContainerView addSubview:_gradientSelection];

    [_gradientSelection addColors:self.colors];

    _colorInformationLable = [[UILabel alloc] initWithFrame:CGRectZero];
    [_colorInformationLable setNumberOfLines:_alphaEnabled ? 11 : 9];
    [_colorInformationLable setFont:[UIFont boldSystemFontOfSize:[self isLandscape] ? 16 : 20]];
    [_colorInformationLable setBackgroundColor:[UIColor clearColor]];
    [_colorInformationLable setTextAlignment:NSTextAlignmentCenter];
    [_colorPickerContainerView addSubview:_colorInformationLable];
    [_colorInformationLable setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_colorInformationLable.layer setShadowOffset:CGSizeZero];
    [_colorInformationLable.layer setShadowRadius:2];
    [_colorInformationLable.layer setShadowOpacity:1];
    _colorInformationLable.tag = 199;

    //Alpha slider
    _colorPickerAlphaSlider = [[CSColorSlider alloc] initWithFrame:CGRectZero sliderType:CSColorSliderTypeAlpha label:@"A" startColor:[self startColor]];
    [_colorPickerAlphaSlider addTarget:self action:@selector(sliderDidChange:) forControlEvents:UIControlEventValueChanged];
	[_colorPickerAlphaSlider addTarget:self action:@selector(valueDidUpdate:) forControlEvents:(UIControlEventTouchUpInside | UIControlEventTouchUpOutside)];
    [_colorPickerContainerView addSubview:_colorPickerAlphaSlider];
    [_colorPickerAlphaSlider setTranslatesAutoresizingMaskIntoConstraints:NO];

    //hue slider
    _colorPickerHueSlider = [[CSColorSlider alloc] initWithFrame:CGRectZero sliderType:CSColorSliderTypeHue label:@"H" startColor:[self startColor]];
    [_colorPickerHueSlider addTarget:self action:@selector(sliderDidChange:) forControlEvents:UIControlEventValueChanged];
	[_colorPickerHueSlider addTarget:self action:@selector(valueDidUpdate:) forControlEvents:(UIControlEventTouchUpInside | UIControlEventTouchUpOutside)];
    [_colorPickerContainerView addSubview:_colorPickerHueSlider];
    [_colorPickerHueSlider setTranslatesAutoresizingMaskIntoConstraints:NO];

    // saturation slider
    _colorPickerSaturationSlider = [[CSColorSlider alloc] initWithFrame:CGRectZero sliderType:CSColorSliderTypeSaturation label:@"S" startColor:[self startColor]];
    [_colorPickerSaturationSlider addTarget:self action:@selector(sliderDidChange:) forControlEvents:UIControlEventValueChanged];
	[_colorPickerSaturationSlider addTarget:self action:@selector(valueDidUpdate:) forControlEvents:(UIControlEventTouchUpInside | UIControlEventTouchUpOutside)];
    [_colorPickerContainerView addSubview:_colorPickerSaturationSlider];
    [_colorPickerSaturationSlider setTranslatesAutoresizingMaskIntoConstraints:NO];

    // brightness slider
    _colorPickerBrightnessSlider = [[CSColorSlider alloc] initWithFrame:CGRectZero sliderType:CSColorSliderTypeBrightness label:@"B" startColor:[self startColor]];
    [_colorPickerBrightnessSlider addTarget:self action:@selector(sliderDidChange:) forControlEvents:UIControlEventValueChanged];
	[_colorPickerBrightnessSlider addTarget:self action:@selector(valueDidUpdate:) forControlEvents:(UIControlEventTouchUpInside | UIControlEventTouchUpOutside)];
    [_colorPickerContainerView addSubview:_colorPickerBrightnessSlider];
    [_colorPickerBrightnessSlider setTranslatesAutoresizingMaskIntoConstraints:NO];

    // red slider
    _colorPickerRedSlider = [[CSColorSlider alloc] initWithFrame:CGRectZero sliderType:CSColorSliderTypeRed label:@"R" startColor:[self startColor]];
    [_colorPickerRedSlider addTarget:self action:@selector(sliderDidChange:) forControlEvents:UIControlEventValueChanged];
	[_colorPickerRedSlider addTarget:self action:@selector(valueDidUpdate:) forControlEvents:(UIControlEventTouchUpInside | UIControlEventTouchUpOutside)];
    [_colorPickerContainerView addSubview:_colorPickerRedSlider];
    [_colorPickerRedSlider setTranslatesAutoresizingMaskIntoConstraints:NO];

    // green slider
    _colorPickerGreenSlider = [[CSColorSlider alloc] initWithFrame:CGRectZero sliderType:CSColorSliderTypeGreen label:@"G" startColor:[self startColor]];
    [_colorPickerGreenSlider addTarget:self action:@selector(sliderDidChange:) forControlEvents:UIControlEventValueChanged];
	[_colorPickerGreenSlider addTarget:self action:@selector(valueDidUpdate:) forControlEvents:(UIControlEventTouchUpInside | UIControlEventTouchUpOutside)];
    [_colorPickerContainerView addSubview:_colorPickerGreenSlider];
    [_colorPickerGreenSlider setTranslatesAutoresizingMaskIntoConstraints:NO];

    // blue slider
    _colorPickerBlueSlider = [[CSColorSlider alloc] initWithFrame:CGRectZero sliderType:CSColorSliderTypeBlue label:@"B" startColor:[self startColor]];
    [_colorPickerBlueSlider addTarget:self action:@selector(sliderDidChange:) forControlEvents:UIControlEventValueChanged];
	[_colorPickerBlueSlider addTarget:self action:@selector(valueDidUpdate:) forControlEvents:(UIControlEventTouchUpInside | UIControlEventTouchUpOutside)];
    [_colorPickerContainerView addSubview:_colorPickerBlueSlider];
	[_colorPickerBlueSlider setTranslatesAutoresizingMaskIntoConstraints:NO];

    [self.view insertSubview:_colorPickerBackgroundView atIndex:0];
    [self.view insertSubview:_colorPickerPreviewView atIndex:2];
    [self.view insertSubview:_colorPickerContainerView atIndex:2];

    // alpha enabled
    _colorPickerAlphaSlider.hidden = !_alphaEnabled;
    _colorPickerAlphaSlider.userInteractionEnabled = _alphaEnabled;
    _gradientSelection.hidden = !_isGradient;
    _gradientSelection.userInteractionEnabled = _isGradient;
	
	[self setBlurStyle:self.blurStyle];
	
	[self updateColorObject];
}

- (void)viewDidLayoutSubviews {
	[super viewDidLayoutSubviews];
	[self updateView];
}

- (void)updateView {
	CGRect bounds = [self calculatedBounds];
	[_colorPickerContainerView setFrame:bounds];
	[_colorPickerPreviewView setFrame:bounds];
	[_colorPickerBackgroundView setFrame:bounds];
	_topConstraint.constant = [self navigationHeight];
	[self setColorInformationTextWithInformationFromColor:[self colorForHSBSliders]];
}

- (CGRect)calculatedBounds {
    UIEdgeInsets insets = UIEdgeInsetsZero;
    if ([self.view respondsToSelector:@selector(safeAreaInsets)]) {
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Wunguarded-availability-new"
        insets = [self.view safeAreaInsets];
        #pragma clang diagnostic pop
        insets.top = 0;
    }

    return UIEdgeInsetsInsetRect(self.view.bounds, insets);
}

- (void)setBlurStyle:(UIBlurEffectStyle)blurStyle {
	_blurStyle = blurStyle;
	[_colorPickerHueSlider setBlurStyle:blurStyle];
	[_colorPickerSaturationSlider setBlurStyle:blurStyle];
	[_colorPickerBrightnessSlider setBlurStyle:blurStyle];
	[_colorPickerAlphaSlider setBlurStyle:blurStyle];
	[_colorPickerRedSlider setBlurStyle:blurStyle];
	[_colorPickerGreenSlider setBlurStyle:blurStyle];
	[_colorPickerBlueSlider setBlurStyle:blurStyle];
	[_gradientSelection setBlurStyle:blurStyle];
}

- (void)setBlurStyle:(UIBlurEffectStyle)blurStyle animated:(BOOL)animated {
	if (animated) [UIView animateWithDuration:0.3 animations:^{ [self setBlurStyle:blurStyle]; }];
	else [self setBlurStyle:blurStyle];
}

- (void)valueDidUpdate:(CSColorSlider *)slider {
	[self updateColorObject];
	if (self.delegate && [self.delegate respondsToSelector:@selector(colorPicker:didUpdateColor:)]) {
		[self.delegate colorPicker:self didUpdateColor:_colorObject];
	}
}

- (void)sliderDidChange:(CSColorSlider *)sender {
    UIColor *color = (sender.sliderType > 2) ? [self colorForRGBSliders] : [self colorForHSBSliders];
    [self updateColor:color animated:NO];
}

- (UIColor *)colorForHSBSliders {
    return [UIColor colorWithHue:_colorPickerHueSlider.value
                      saturation:_colorPickerSaturationSlider.value
                      brightness:_colorPickerBrightnessSlider.value
                           alpha:_colorPickerAlphaSlider.value];
}

- (UIColor *)colorForRGBSliders {
    return [UIColor colorWithRed:_colorPickerRedSlider.value
                           green:_colorPickerGreenSlider.value
                            blue:_colorPickerBlueSlider.value
                           alpha:_colorPickerAlphaSlider.value];
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
        [_gradientSelection setColor:color atIndex:_selectedIndex];
	}
}

- (void)setColor:(UIColor *)color animated:(BOOL)animated {
	self.color = color;
    void (^update)(void) = ^void(void) {
        [self->_colorPickerAlphaSlider setColor:color];
        [self->_colorPickerHueSlider setColor:color];
        [self->_colorPickerSaturationSlider setColor:color];
        [self->_colorPickerBrightnessSlider setColor:color];
        [self->_colorPickerRedSlider setColor:color];
        [self->_colorPickerGreenSlider setColor:color];
        [self->_colorPickerBlueSlider setColor:color];
        self->_colorPickerPreviewView.backgroundColor = color;

        [self setColorInformationTextWithInformationFromColor:color];
    };

    if (animated) 
        [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{ update(); } completion:nil];
    else 
        update();
}

- (void)setColorInformationTextWithInformationFromColor:(UIColor *)color {
    [_colorInformationLable setText:[self informationStringForColor:color]];
    UIColor *legibilityTint = (!color.cscp_light && color.cscp_alpha > 0.5) ? UIColor.whiteColor : UIColor.blackColor;
    UIColor *shadowColor = legibilityTint == UIColor.blackColor ? UIColor.whiteColor : UIColor.blackColor;
    
    [_colorInformationLable setTextColor:legibilityTint];
    [_colorInformationLable.layer setShadowColor:[shadowColor CGColor]];
    [_colorInformationLable setFont:[UIFont boldSystemFontOfSize:[self isLandscape] ? 16 : 20]];
}

- (UIColor *)startColor {
    return _isGradient ? self.colors.lastObject : self.color;
}

- (void)saveColor {
	// save in NSUserDefaults
	if (self.identifier)
		[[NSUserDefaults standardUserDefaults] setObject:_colorObject.hexValue forKey:self.identifier];
	
	if (self.delegate && [self.delegate respondsToSelector:@selector(colorPicker:didPickColor:)]) {
		[self.delegate colorPicker:self didPickColor:_colorObject];
	}
}

- (void)addAction:(UIButton *)sender {
    UIColor *color = [self complementaryColorForColor:self.colors.lastObject];
    [self.colors addObject:color];
    [_gradientSelection addColor:color];
    [self setColor:self.colors.lastObject animated:YES];
    _selectedIndex = self.colors.count - 1;
	[self updateColorObject];
}

- (void)removeAction:(UIButton *)sender {
    [self.colors removeObjectAtIndex:_selectedIndex];
    [_gradientSelection removeColorAtIndex:_selectedIndex];
    [self setColor:self.colors.lastObject animated:YES];
    _selectedIndex = self.colors.count - 1;
	[self updateColorObject];
}

- (void)selectAction:(UIButton *)sender {
    [self setColor:self.colors[sender.titleLabel.tag] animated:YES];
    _selectedIndex = sender.titleLabel.tag;
}


// well this is ugly
- (NSString *)informationStringForColor:(UIColor *)color {
    CGFloat h, s, b, a, r, g, bb, aa;
    [color getHue:&h saturation:&s brightness:&b alpha:&a];
    [color getRed:&r green:&g blue:&bb alpha:&aa];
    if (self.view.bounds.size.width > self.view.bounds.size.height) {
        if (_alphaEnabled) {
            return [NSString stringWithFormat:@"#%@\n\nR: %.f       H: %.f\nG: %.f       S: %.f\nB: %.f       B: %.f\nA: %.f       A: %.f", [color cscp_hexString], r * 255, h * 360, g * 255, s * 100, bb * 255, b * 100, aa * 100, a * 100];
        }
        return [NSString stringWithFormat:@"#%@\n\nR: %.f       H: %.f\nG: %.f       S: %.f\nB: %.f       B: %.f", [color cscp_hexString], r * 255, h * 360, g * 255, s * 100, bb * 255, b * 100];
    } else {
        if (_alphaEnabled) {
            return [NSString stringWithFormat:@"#%@\n\nR: %.f\nG: %.f\nB: %.f\nA: %.f\n\nH: %.f\nS: %.f\nB: %.f\nA: %.f", [color cscp_hexString], r * 255, g * 255, bb * 255, aa * 100, h * 360, s * 100, b * 100, a * 100];
        }
        return [NSString stringWithFormat:@"#%@\n\nR: %.f\nG: %.f\nB: %.f\n\nH: %.f\nS: %.f\nB: %.f", [color cscp_hexString], r * 255, g * 255, bb * 255, h * 360, s * 100, b * 100];
    }
}

- (void)presentHexColorAlert {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:ALERT_TITLE message:ALERT_MESSAGE preferredStyle:UIAlertControllerStyleAlert];

    [alertController addTextFieldWithConfigurationHandler:^(UITextField *hexField) {
        hexField.text = [NSString stringWithFormat:@"#%@", [[self colorForHSBSliders] cscp_hexString]];
        hexField.textColor = [UIColor blackColor];
        hexField.clearButtonMode = UITextFieldViewModeAlways;
        hexField.borderStyle = UITextBorderStyleRoundedRect;
    }];

    [alertController addAction:[UIAlertAction actionWithTitle:ALERT_COPY style:UIAlertActionStyleDefault handler:^(UIAlertAction *copy) {
        [[UIPasteboard generalPasteboard] setString:[self colorForHSBSliders].cscp_hexStringWithAlpha];
    }]];

    [alertController addAction:[UIAlertAction actionWithTitle:ALERT_SET style:UIAlertActionStyleDefault handler:^(UIAlertAction *set) {
        [self updateColor:[UIColor cscp_colorFromHexString:alertController.textFields[0].text] animated:YES];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:ALERT_PASTEBOARD style:UIAlertActionStyleDefault handler:^(UIAlertAction *set) {
        [self updateColor:[UIColor cscp_colorFromHexString:[UIPasteboard generalPasteboard].string] animated:YES];
    }]];

    [alertController addAction:[UIAlertAction actionWithTitle:ALERT_CANCEL style:UIAlertActionStyleCancel handler:nil]];


    [self presentViewController:alertController animated:YES completion:nil];
}

- (CGFloat)navigationHeight {
    return [self isLandscape] ? self.navigationController.navigationBar.frame.size.height :
        self.navigationController.navigationBar.frame.size.height + UIApplication.sharedApplication.statusBarFrame.size.height;
}

- (BOOL)isLandscape {
    return UIInterfaceOrientationIsLandscape(UIApplication.sharedApplication.statusBarOrientation);
}

- (void)setLayoutConstraints {
    for (id constraint in _colorPickerContainerView.constraints) {
        [_colorPickerContainerView removeConstraint:constraint];
    }

    NSArray *constraints = @[
        // red constraints
        [NSLayoutConstraint constraintWithItem:_colorPickerRedSlider attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_colorPickerContainerView attribute:NSLayoutAttributeTop multiplier:1 constant:[self navigationHeight]],
        [NSLayoutConstraint constraintWithItem:_colorPickerRedSlider attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_colorPickerContainerView attribute:NSLayoutAttributeWidth multiplier:1 constant:0],
        [NSLayoutConstraint constraintWithItem:_colorPickerRedSlider attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:SLIDER_HEIGHT],
        // green constraints
        [NSLayoutConstraint constraintWithItem:_colorPickerGreenSlider attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_colorPickerRedSlider attribute:NSLayoutAttributeBottom multiplier:1 constant:0],
        [NSLayoutConstraint constraintWithItem:_colorPickerGreenSlider attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_colorPickerContainerView attribute:NSLayoutAttributeWidth multiplier:1 constant:0],
        [NSLayoutConstraint constraintWithItem:_colorPickerGreenSlider attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:SLIDER_HEIGHT],
        // blue constraints
        [NSLayoutConstraint constraintWithItem:_colorPickerBlueSlider attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_colorPickerGreenSlider attribute:NSLayoutAttributeBottom multiplier:1 constant:0],
        [NSLayoutConstraint constraintWithItem:_colorPickerBlueSlider attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_colorPickerContainerView attribute:NSLayoutAttributeWidth multiplier:1 constant:0],
        [NSLayoutConstraint constraintWithItem:_colorPickerBlueSlider attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:SLIDER_HEIGHT],
        // gradient constraints
        [NSLayoutConstraint constraintWithItem:_gradientSelection attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_colorPickerBlueSlider attribute:NSLayoutAttributeBottom multiplier:1 constant:0],
        [NSLayoutConstraint constraintWithItem:_gradientSelection attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_colorPickerContainerView attribute:NSLayoutAttributeWidth multiplier:1 constant:0],
        [NSLayoutConstraint constraintWithItem:_gradientSelection attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:_isGradient ? 50.0 : 0],
        // alpha constraints
        [NSLayoutConstraint constraintWithItem:_colorPickerAlphaSlider attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_colorPickerHueSlider attribute:NSLayoutAttributeTop multiplier:1 constant:0],
        [NSLayoutConstraint constraintWithItem:_colorPickerAlphaSlider attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_colorPickerContainerView attribute:NSLayoutAttributeWidth multiplier:1 constant:0],
        [NSLayoutConstraint constraintWithItem:_colorPickerAlphaSlider attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:_alphaEnabled ? SLIDER_HEIGHT : 0],
        // hue constraints
        [NSLayoutConstraint constraintWithItem:_colorPickerHueSlider attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_colorPickerSaturationSlider attribute:NSLayoutAttributeTop multiplier:1 constant:0],
        [NSLayoutConstraint constraintWithItem:_colorPickerHueSlider attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_colorPickerContainerView attribute:NSLayoutAttributeWidth multiplier:1 constant:0],
        [NSLayoutConstraint constraintWithItem:_colorPickerHueSlider attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:SLIDER_HEIGHT],
        // saturation constraints
        [NSLayoutConstraint constraintWithItem:_colorPickerSaturationSlider attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_colorPickerBrightnessSlider attribute:NSLayoutAttributeTop multiplier:1 constant:0],
        [NSLayoutConstraint constraintWithItem:_colorPickerSaturationSlider attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_colorPickerContainerView attribute:NSLayoutAttributeWidth multiplier:1 constant:0],
        [NSLayoutConstraint constraintWithItem:_colorPickerSaturationSlider attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:SLIDER_HEIGHT],
        // brightness constraints
        [NSLayoutConstraint constraintWithItem:_colorPickerBrightnessSlider attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_colorPickerContainerView attribute:NSLayoutAttributeBottom multiplier:1 constant:0],
        [NSLayoutConstraint constraintWithItem:_colorPickerBrightnessSlider attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_colorPickerContainerView attribute:NSLayoutAttributeWidth multiplier:1 constant:0],
        [NSLayoutConstraint constraintWithItem:_colorPickerBrightnessSlider attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:SLIDER_HEIGHT],
        // label constraints
        [NSLayoutConstraint constraintWithItem:_colorInformationLable attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_gradientSelection attribute:NSLayoutAttributeBottom multiplier:1 constant:0],
        [NSLayoutConstraint constraintWithItem:_colorInformationLable attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_colorPickerContainerView attribute:NSLayoutAttributeWidth multiplier:1 constant:0],
        [NSLayoutConstraint constraintWithItem:_colorInformationLable attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_colorPickerAlphaSlider attribute:NSLayoutAttributeTop multiplier:1 constant:0]
    ];

    _topConstraint = constraints.firstObject;
    [_colorPickerContainerView addConstraints:constraints];
}

- (UIColor *)complementaryColorForColor:(UIColor *)color {
    CGFloat h, s, b, a;
    if ([color getHue:&h saturation:&s brightness:&b alpha:&a]) {
        if (s < 0.25) {
            b = ((int)((b * 100) + 10) % 100) / 100.0f;
        }

        else {
            h = h - 0.1;
            if (h < 0) h = 1.0f - fabs(h);
        }

        return [UIColor colorWithHue:h saturation:s brightness:b alpha:a];
    }
    return nil;
}

// credit: https://stackoverflow.com/a/23620377/4668186
- (BOOL)isModal {
	if([self presentingViewController])
		return YES;
	if([[[self navigationController] presentingViewController] presentedViewController] == [self navigationController])
		return YES;
	if([[[self tabBarController] presentingViewController] isKindOfClass:[UITabBarController class]])
		return YES;
	
	return NO;
}

- (void)toggleStyle {
	[self setBlurStyle:(self->_blurStyle == UIBlurEffectStyleDark) ? UIBlurEffectStyleExtraLight : UIBlurEffectStyleDark animated:YES];
}

@end
