//
// Created by CreatureSurvive on 3/17/17.
// Copyright (c) 2016 - 2019 CreatureCoding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>

@interface CSColorPickerPreviewView : UIView
@property (nonatomic, assign, setter=setDarkMode:) BOOL isDark;
@property (nonatomic, assign) BOOL alphaEnabled;
@property (nonatomic, strong) UIStackView *labelContainer;

- (id)initWithFrame:(CGRect)frame alphaEnabled:(BOOL)alphaEnabled;

- (void)setDarkMode:(BOOL)dark;
- (void)setPreviewColor:(UIColor *)color;
@end
