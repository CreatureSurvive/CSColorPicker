//
// Created by CreatureSurvive on 3/17/17.
// Copyright (c) 2016 - 2019 CreatureCoding. All rights reserved.
//

#import "CSColorPickerViewController.h"
#import "CSColorSlider.h"
#import "CSColorPickerPreviewView.h"
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
    CSColorPickerPreviewView *_colorPickerPreviewView;
    CSGradientSelection *_gradientSelection;
    UIView *_colorPickerContainerView;
    UIImageView *_colorTrackImageView;
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
		_identifier = colorObject.identifier;
		_alphaEnabled = alphaEnabled;
		_blurStyle = UIBlurEffectStyleExtraLight;
	}
	
	return self;
}

- (void)loadView {
	[super loadView];
	
	// create views
	CGRect bounds = [self calculatedBounds];
	_colorPickerContainerView = [[UIView alloc] initWithFrame:bounds];
	_colorPickerContainerView.tag = 199;
	_colorPickerPreviewView = [[CSColorPickerPreviewView alloc] initWithFrame:bounds alphaEnabled:_alphaEnabled];
	[_colorPickerContainerView addSubview:_colorPickerPreviewView.labelContainer];
	
	_selectedIndex = self.colors.count - 1;
	_gradientSelection = [[CSGradientSelection alloc] initWithSize:CGSizeZero target:self addAction:@selector(addAction:) removeAction:@selector(removeAction:) selectAction:@selector(selectAction:)];
	[_gradientSelection setTranslatesAutoresizingMaskIntoConstraints:NO];
	[_colorPickerContainerView addSubview:_gradientSelection];
	
	[_gradientSelection addColors:self.colors];
	
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
	
	[self.view insertSubview:_colorPickerPreviewView atIndex:0];
	[self.view insertSubview:_colorPickerContainerView atIndex:1];
	
	// alpha enabled
	_colorPickerAlphaSlider.hidden = !_alphaEnabled;
	_colorPickerAlphaSlider.userInteractionEnabled = _alphaEnabled;
	_gradientSelection.hidden = !_isGradient;
	_gradientSelection.userInteractionEnabled = _isGradient;
	
	[self setBlurStyle:self.blurStyle];
	
	[self updateColorObject];
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
		[self->_colorPickerContainerView setAlpha:1];
		[self->_colorPickerPreviewView setPreviewColor:[self startColor]];
		[self.view setBackgroundColor:[self startColor]];
	}];

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
	} completion:nil];
	
	[super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

- (void)viewDidLayoutSubviews {
	[super viewDidLayoutSubviews];
	[self updateView];
}

- (void)dismiss {
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)updateView {
	CGRect bounds = [self calculatedBounds];
	[_colorPickerContainerView setFrame:bounds];
	[_colorPickerPreviewView setFrame:bounds];
	_topConstraint.constant = [self navigationHeight];
	[_colorPickerPreviewView setPreviewColor:[self colorForHSBSliders]];
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
	[_colorPickerPreviewView setDarkMode:blurStyle == UIBlurEffectStyleDark];
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

        [self->_colorPickerPreviewView setPreviewColor:color];
		[self.view setBackgroundColor:color];
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
	
	NSInteger rowCount = 6 + _alphaEnabled;
	CGFloat sliderHeight = SLIDER_HEIGHT, widthMultiplier = 1;
	BOOL landscape = [self isLandscape];
	
	if (landscape) {
		sliderHeight = (CGRectGetHeight(_colorPickerContainerView.bounds) - [self navigationHeight] - (_isGradient ? 50 : 0)) / rowCount;
		widthMultiplier = 0.5;
	}

    NSArray *constraints = @[
        // red constraints
        [NSLayoutConstraint constraintWithItem:_colorPickerRedSlider attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_colorPickerContainerView attribute:NSLayoutAttributeTop multiplier:1 constant:[self navigationHeight]],
        [NSLayoutConstraint constraintWithItem:_colorPickerRedSlider attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_colorPickerContainerView attribute:NSLayoutAttributeWidth multiplier:widthMultiplier constant:0],
        [NSLayoutConstraint constraintWithItem:_colorPickerRedSlider attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:sliderHeight],
        // green constraints
        [NSLayoutConstraint constraintWithItem:_colorPickerGreenSlider attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_colorPickerRedSlider attribute:NSLayoutAttributeBottom multiplier:1 constant:0],
        [NSLayoutConstraint constraintWithItem:_colorPickerGreenSlider attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_colorPickerContainerView attribute:NSLayoutAttributeWidth multiplier:widthMultiplier constant:0],
        [NSLayoutConstraint constraintWithItem:_colorPickerGreenSlider attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:sliderHeight],
        // blue constraints
        [NSLayoutConstraint constraintWithItem:_colorPickerBlueSlider attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_colorPickerGreenSlider attribute:NSLayoutAttributeBottom multiplier:1 constant:0],
        [NSLayoutConstraint constraintWithItem:_colorPickerBlueSlider attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_colorPickerContainerView attribute:NSLayoutAttributeWidth multiplier:widthMultiplier constant:0],
        [NSLayoutConstraint constraintWithItem:_colorPickerBlueSlider attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:sliderHeight],
        // gradient constraints
        [NSLayoutConstraint constraintWithItem:_gradientSelection attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_colorPickerBlueSlider attribute:NSLayoutAttributeBottom multiplier:1 constant:0],
        [NSLayoutConstraint constraintWithItem:_gradientSelection attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_colorPickerContainerView attribute:NSLayoutAttributeWidth multiplier:widthMultiplier constant:0],
        [NSLayoutConstraint constraintWithItem:_gradientSelection attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:_isGradient ? 50.0 : 0],
        // alpha constraints
        [NSLayoutConstraint constraintWithItem:_colorPickerAlphaSlider attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_colorPickerHueSlider attribute:NSLayoutAttributeTop multiplier:1 constant:0],
        [NSLayoutConstraint constraintWithItem:_colorPickerAlphaSlider attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_colorPickerContainerView attribute:NSLayoutAttributeWidth multiplier:widthMultiplier constant:0],
        [NSLayoutConstraint constraintWithItem:_colorPickerAlphaSlider attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:_alphaEnabled ? sliderHeight : 0],
        // hue constraints
        [NSLayoutConstraint constraintWithItem:_colorPickerHueSlider attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_colorPickerSaturationSlider attribute:NSLayoutAttributeTop multiplier:1 constant:0],
        [NSLayoutConstraint constraintWithItem:_colorPickerHueSlider attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_colorPickerContainerView attribute:NSLayoutAttributeWidth multiplier:widthMultiplier constant:0],
        [NSLayoutConstraint constraintWithItem:_colorPickerHueSlider attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:sliderHeight],
        // saturation constraints
        [NSLayoutConstraint constraintWithItem:_colorPickerSaturationSlider attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_colorPickerBrightnessSlider attribute:NSLayoutAttributeTop multiplier:1 constant:0],
        [NSLayoutConstraint constraintWithItem:_colorPickerSaturationSlider attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_colorPickerContainerView attribute:NSLayoutAttributeWidth multiplier:widthMultiplier constant:0],
        [NSLayoutConstraint constraintWithItem:_colorPickerSaturationSlider attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:sliderHeight],
        // brightness constraints
        [NSLayoutConstraint constraintWithItem:_colorPickerBrightnessSlider attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_colorPickerContainerView attribute:NSLayoutAttributeBottom multiplier:1 constant:0],
        [NSLayoutConstraint constraintWithItem:_colorPickerBrightnessSlider attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_colorPickerContainerView attribute:NSLayoutAttributeWidth multiplier:widthMultiplier constant:0],
        [NSLayoutConstraint constraintWithItem:_colorPickerBrightnessSlider attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:sliderHeight],
		// label constraints
		[NSLayoutConstraint constraintWithItem:_colorPickerPreviewView.labelContainer attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_colorPickerContainerView attribute:NSLayoutAttributeWidth multiplier:widthMultiplier constant:0],
		[NSLayoutConstraint constraintWithItem:_colorPickerPreviewView.labelContainer attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:_colorPickerContainerView attribute:NSLayoutAttributeTrailing multiplier:1 constant:0],
		[NSLayoutConstraint constraintWithItem:_colorPickerPreviewView.labelContainer attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:landscape ? _colorPickerContainerView : _gradientSelection attribute:landscape ? NSLayoutAttributeTop : NSLayoutAttributeBottom multiplier:1 constant:landscape ? [self navigationHeight] : 0],
		[NSLayoutConstraint constraintWithItem:_colorPickerPreviewView.labelContainer attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:landscape ? _colorPickerContainerView : _colorPickerAlphaSlider attribute:landscape ? NSLayoutAttributeBottom : NSLayoutAttributeTop multiplier:1 constant:0]
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
