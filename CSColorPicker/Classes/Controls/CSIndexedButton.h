//
//  CSIndexedButton.h
//  CSColorPicker
//
//  Created by Dana Buehre on 6/26/19.
//  Copyright © 2019 CreatureCoding. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CSIndexedButton : UIButton

@property (nonatomic, assign) NSInteger index;

+ (CSIndexedButton *)_accessoryButton:(BOOL)add target:(id)target action:(SEL)action;
+ (CSIndexedButton *)_accessoryButtonWithTitle:(NSString *)title target:(id)target action:(SEL)action color:(UIColor *)color;

@end

NS_ASSUME_NONNULL_END
