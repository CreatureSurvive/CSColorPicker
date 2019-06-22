//
// Created by CreatureSurvive on 3/17/17.
// Copyright (c) 2016 - 2019 CreatureCoding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CSColorObject.h"
#import "UIColor+CSColorPicker.h"
#import "NSString+CSColorPicker.h"

@class CSColorSlider, CSColorPickerBackgroundView, CSGradientSelection;
@interface CSColorPickerViewController : UIViewController

@property (nonatomic, strong) UIView *colorPickerContainerView;
@property (nonatomic, strong) UILabel *colorInformationLable;
@property (nonatomic, strong) UIImageView *colorTrackImageView;
@property (nonatomic, strong) CSColorPickerBackgroundView *colorPickerBackgroundView;
@property (nonatomic, strong) UIView *colorPickerPreviewView;
@property (nonatomic, strong) CSGradientSelection *gradientSelection;

@property (nonatomic, retain) CSColorSlider *colorPickerHueSlider;
@property (nonatomic, retain) CSColorSlider *colorPickerSaturationSlider;
@property (nonatomic, retain) CSColorSlider *colorPickerBrightnessSlider;
@property (nonatomic, retain) CSColorSlider *colorPickerAlphaSlider;

@property (nonatomic, retain) CSColorSlider *colorPickerRedSlider;
@property (nonatomic, retain) CSColorSlider *colorPickerGreenSlider;
@property (nonatomic, retain) CSColorSlider *colorPickerBlueSlider;

@property (nonatomic, assign) BOOL alphaEnabled;
@property (nonatomic, assign) BOOL isGradient;
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, retain) NSMutableArray<UIColor *> *colors;
@property (nonatomic, retain) NSString *identifier;

- (void)loadColorPickerView;
- (void)sliderDidChange:(CSColorSlider *)sender;
- (BOOL)isLandscape;

- (id)initWithColor:(UIColor *)color showingAlpha:(BOOL)alphaEnabled;
- (id)initWithColors:(NSArray<UIColor*> *)colors showingAlpha:(BOOL)alphaEnabled;
- (id)initWithColor:(UIColor *)color showingAlpha:(BOOL)alphaEnabled target:(id)target action:(SEL)action;
- (id)initWithColors:(NSArray<UIColor*> *)colors showingAlpha:(BOOL)alphaEnabled target:(id)target action:(SEL)action;

@end
