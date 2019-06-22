//
// Created by CreatureSurvive on 7/28/17.
// Copyright (c) 2016 - 2019 CreatureCoding. All rights reserved.
//

#import "NSString+CSColorPicker.h"
#import <UIKit/UIColor.h>

struct CGFloat;
@interface NSString (Private)
+ (CGFloat)_cscp_colorComponentFrom:(NSString *)string start:(NSUInteger)start length:(NSUInteger)length;
@end

@implementation NSString (CSColorPicker)

+ (UIColor *)cscp_colorFromHexString:(NSString *)hexString {
    NSString *colorString = [[hexString stringByReplacingOccurrencesOfString:@"#" withString:@""] uppercaseString];
    CGFloat red, blue, green, alpha = 1.0f;

    if ([colorString rangeOfString:@":"].location != NSNotFound) {
        NSArray *stringComponents = [colorString componentsSeparatedByString:@":"];
        colorString = stringComponents[0];
        alpha = [stringComponents[1] floatValue] ? : 1.0f;
    }

    if (![self cscp_isValidHexString:colorString]) {
        return [UIColor colorWithRed:255.0f green:0.0f blue:0.0f alpha:alpha];
    }

    switch ([colorString length]) {
        case 3:
            alpha = 1.0f;
            red = [self _cscp_colorComponentFrom:colorString start:0 length:1];
            green = [self _cscp_colorComponentFrom:colorString start:1 length:1];
            blue = [self _cscp_colorComponentFrom:colorString start:2 length:1];
            break;
        case 4:
            alpha = [self _cscp_colorComponentFrom:colorString start:0 length:1];
            red = [self _cscp_colorComponentFrom:colorString start:1 length:1];
            green = [self _cscp_colorComponentFrom:colorString start:2 length:1];
            blue = [self _cscp_colorComponentFrom:colorString start:3 length:1];
            break;
        case 6:
            alpha = 1.0f;
            red = [self _cscp_colorComponentFrom:colorString start:0 length:2];
            green = [self _cscp_colorComponentFrom:colorString start:2 length:2];
            blue = [self _cscp_colorComponentFrom:colorString start:4 length:2];
            break;
        case 8:
            alpha = [self _cscp_colorComponentFrom:colorString start:0 length:2];
            red = [self _cscp_colorComponentFrom:colorString start:2 length:2];
            green = [self _cscp_colorComponentFrom:colorString start:4 length:2];
            blue = [self _cscp_colorComponentFrom:colorString start:6 length:2];
            break;
        default:
            alpha = 100.0f;
            red = green = blue = 255.0f;
            break;
    }
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

+ (CGFloat)_cscp_colorComponentFrom:(NSString *)string start:(NSUInteger)start length:(NSUInteger)length {
    NSString *substring = [string substringWithRange:NSMakeRange(start, length)];
    NSString *fullHex = length == 2 ? substring : [NSString stringWithFormat:@"%@%@", substring, substring];
    unsigned hexComponent;
    [[NSScanner scannerWithString:fullHex] scanHexInt:&hexComponent];
    return hexComponent / 255.0;
}

+ (BOOL)cscp_isValidHexString:(NSString *)hexString {
    NSCharacterSet *hexChars = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789ABCDEFabcdef"] invertedSet];
    return (NSNotFound == [[[hexString stringByReplacingOccurrencesOfString:@"#" withString:@""] uppercaseString] rangeOfCharacterFromSet:hexChars].location);
}

- (UIColor *)cscp_hexColor {
    return [NSString cscp_colorFromHexString:self];
}

- (BOOL)cscp_validHex {
    return [NSString cscp_isValidHexString:self];
}

- (NSArray<UIColor *> *)cscp_gradientStringColors {
    NSMutableArray<UIColor *> *colors = [NSMutableArray new];
    for (NSString *hex in [[self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] componentsSeparatedByString:@","]) {
        [colors addObject:[hex cscp_hexColor]];
    }
    return colors.copy;
}

- (NSArray<id> *)cscp_gradientStringCGColors {
    NSMutableArray<id> *colors = [NSMutableArray new];
    for (NSString *hex in [[self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] componentsSeparatedByString:@","]) {
        [colors addObject:(id)[hex cscp_hexColor].CGColor];
    }
    return colors.copy;
}

@end
