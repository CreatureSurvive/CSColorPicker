//
//  CSColorObjectManager.h
//  CSColorPicker
//
//  Created by Dana Buehre on 6/25/19.
//  Copyright © 2019 CreatureCoding. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSColorSlider.h"

NS_ASSUME_NONNULL_BEGIN
typedef enum : NSUInteger {
	CSColorTypeAll,
	CSColorTypeRGB,
	CSColorTypeHSB,
	CSColorTypeRGBA,
	CSColorTypeHSBA,
	CSColorTypeCMYK,
	CSColorTypeCMYKA
} CSColorType;


@class CSColorObject, UIColor;
@interface CSColorObjectManager : NSObject

@property (nonatomic, assign) NSInteger gradientIndex;

@property (nonatomic, assign, readonly) CSColorType colorType;
@property (nonatomic, strong, readonly) CSColorObject *colorObject;

@property (nonatomic, strong, readonly) CSColorSlider *alphaSlider;
@property (nonatomic, strong, readonly) NSArray<CSColorSlider*> *rgbSliders;
@property (nonatomic, strong, readonly) NSArray<CSColorSlider*> *hsbSliders;
@property (nonatomic, strong, readonly) NSArray<CSColorSlider*> *cmykSliders;

+ (instancetype)sharedColorManager;

- (instancetype)initWithColorType:(CSColorType)colorType colorObject:(CSColorObject *)colorObject target:(id)target action:(SEL)action;
- (instancetype)initWithColorType:(CSColorType)colorType startColor:(UIColor *)startColor target:(id)target action:(SEL)action;
- (instancetype)initWithColorType:(CSColorType)colorType startColors:(NSArray<UIColor*> *)startColors target:(id)target action:(SEL)action;
- (instancetype)initWithColorType:(CSColorType)colorType colorHex:(NSString *)colorHex target:(id)target action:(SEL)action;

- (void)colorDidChange:(CSColorObject *)color;
- (void)sliderDidChangeValue:(CSColorSlider *)slider;

- (CSColorSlider *)sliderOfType:(CSColorSliderType)sliderType;
- (void)setColor:(UIColor *)color animated:(BOOL)animated;
- (void)setGradientIndex:(NSInteger)gradientIndex;
- (void)setGradientIndex:(NSInteger)gradientIndex animated:(BOOL)animated;
- (void)addColor:(UIColor *)color;
- (void)removeColor;

- (void)setLightContent:(BOOL)lightContent;

- (UIColor *)rgbColor;
- (UIColor *)hsbColor;
- (UIColor *)rgbaColor;
- (UIColor *)hsbaColor;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
