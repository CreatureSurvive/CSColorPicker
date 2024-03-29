//
// Created by CreatureSurvive on 3/17/17.
// Copyright (c) 2016 - 2019 CreatureCoding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CSColorObject.h"
#import "CSColorCellObject.h"
#import "CSColorPickerDelegate.h"
#import "UIColor+CSColorPicker.h"
#import "NSString+CSColorPicker.h"

@interface CSColorPickerViewController : UIViewController

@property (nonatomic, retain) NSString *identifier;
@property (nonatomic, assign) UIBlurEffectStyle blurStyle;
@property (nonatomic, assign) BOOL showsDarkmodeToggle;
@property (nonatomic, assign) BOOL useSafeArea;
@property (nonatomic, assign) id<CSColorPickerDelegate> delegate;
@property (nonatomic, assign) id<CSColorCellObject> cellObject;
@property (nonatomic, readonly) CSColorObject *colorObject;

- (instancetype)initWithColor:(UIColor *)color showingAlpha:(BOOL)alphaEnabled;
- (instancetype)initWithColors:(NSArray<UIColor*> *)colors showingAlpha:(BOOL)alphaEnabled;
- (instancetype)initWithColorObject:(CSColorObject *)color showingAlpha:(BOOL)alphaEnabled;

- (void)setBlurStyle:(UIBlurEffectStyle)blurStyle animated:(BOOL)animated;

@end
