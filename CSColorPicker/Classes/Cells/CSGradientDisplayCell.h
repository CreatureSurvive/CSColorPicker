//
//  CSGradientDisplayCell.h
//  CSColorPicker
//
//  Created by Dana Buehre on 6/23/19.
//  Copyright © 2019 CreatureCoding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CSColorPickerDelegate.h"
#import "CSColorCellObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface CSGradientDisplayCell : UITableViewCell <CSColorCellObject>

@property (nonatomic, strong) CSColorObject *colorObject;
@property (nonatomic, assign) id<CSColorPickerDelegate> delegate;

- (void)setColorObject:(CSColorObject *)colorObject;
- (void)setColorObject:(CSColorObject *)colorObject delegate:(id<CSColorPickerDelegate>)delegate;

- (CSColorPickerViewController *)colorPicker;
@end

NS_ASSUME_NONNULL_END
