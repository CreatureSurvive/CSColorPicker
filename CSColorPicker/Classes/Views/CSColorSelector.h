//
//  CSColorSelectionView.h
//  CSColorPicker
//
//  Created by Dana Buehre on 6/26/19.
//  Copyright © 2019 CreatureCoding. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

enum {
	CSColorSelectionChanged = 0x01000000,
	CSColorSelectionAdd = 0x02000000,
	CSColorSelectionRemove = 0x04000000,
	CSColorSelectionNone = 0x08000000
};
typedef UIControlEvents CSColorSelection;

@class CSColorObject;
@interface CSColorSelector : UIControl

@property (nonatomic, retain) CSColorObject *colorObject;
@property (nonatomic, assign) NSInteger index;

- (instancetype)initWithFrame:(CGRect)frame colorObject:(CSColorObject *)colorObject;

- (void)setAdditionalInsets:(UIEdgeInsets)insets;

- (void)addColors:(NSArray *)colors;
- (void)addColor:(UIColor *)color animated:(BOOL)animated;
- (void)removeColorAtIndex:(NSInteger)index animated:(BOOL)animated;
- (void)setColor:(UIColor *)color atIndex:(NSInteger)index;

- (void)setLightContent:(BOOL)lightContent;

@end

NS_ASSUME_NONNULL_END
