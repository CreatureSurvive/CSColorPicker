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
@property (nonatomic, strong) NSString *hexColor;
@property (nonatomic, strong) UIColor *color;

+ (instancetype)colorObjectWithHex:(NSString *)hex;
+ (instancetype)colorObjectWithColor:(UIColor *)color;
@end

NS_ASSUME_NONNULL_END
