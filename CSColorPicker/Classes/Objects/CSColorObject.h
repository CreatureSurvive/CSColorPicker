//
//  CSColorObject.h
//  CSColorPicker
//
//  Created by Dana Buehre on 6/22/19.
//  Copyright © 2019 CreatureCoding. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIColor.h>

NS_ASSUME_NONNULL_BEGIN

@interface CSColorObject : NSObject
@property (nonatomic, assign, readonly) BOOL isGradient;
@property (nonatomic, strong, readonly) NSString *hexValue;
@property (nonatomic, strong, readonly) UIColor *color;
@property (nonatomic, strong, readonly) NSMutableArray<UIColor *> *colors;
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, strong) NSString *identifier;

+ (instancetype)colorObjectWithHex:(NSString *)hex;
+ (instancetype)colorObjectWithColor:(UIColor *)color;
+ (instancetype)gradientObjectWithHex:(NSString *)hex;
+ (instancetype)gradientObjectWithColors:(NSArray <UIColor *> *)colors;

- (NSArray<id>*)gradientCGColors;
- (NSString *)displayHexValue;
- (UIColor *)selectedColor;

- (void)removeColor;
- (void)addColor:(UIColor *)color;
- (void)updateColor:(UIColor *)color;

- (void)finalizeChange;

- (instancetype)init NS_UNAVAILABLE;
@end

NS_ASSUME_NONNULL_END
