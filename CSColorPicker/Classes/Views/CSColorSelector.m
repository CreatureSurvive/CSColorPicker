//
//  CSColorSelectionView.m
//  CSColorPicker
//
//  Created by Dana Buehre on 6/26/19.
//  Copyright © 2019 CreatureCoding. All rights reserved.
//

#import "CSColorSelector.h"
#import "UIColor+CSColorPicker.h"
#import "CSIndexedButton.h"
#import "CSColorObject.h"
#import "UIView+CSColorPicker_Internal.h"

#define START_ANIMATION [UIView animateWithDuration:0.2f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
#define END_ANIMATION nil;} completion:nil];
#define COMPLETION nil;} completion:^(BOOL finished) {
#define END_COMPLETION nil;}];

@implementation CSColorSelector {
	SEL _addAction;
	SEL _removeAction;
	SEL _selectAction;
	UIStackView *_stackView;
	UIStackView *_toolStack;
	UIScrollView *_scrollView;
	CSIndexedButton *_addButton;
	CSIndexedButton *_removeButton;
}

- (instancetype)initWithFrame:(CGRect)frame colorObject:(CSColorObject *)colorObject {
	if ((self = [super initWithFrame:frame])) {
		_colorObject = colorObject;
		
		_addAction = @selector(addAction:);
		_removeAction = @selector(removeAction:);
		_selectAction = @selector(changedAction:);
		
		_addButton = [CSIndexedButton _accessoryButton:YES target:self action:_addAction];
		_removeButton = [CSIndexedButton _accessoryButton:NO target:self action:_removeAction];
//		[_addButton removeConstraints:_addButton.constraints];
//		[_removeButton removeConstraints:_removeButton.constraints];
		
		_scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
		[_scrollView setTranslatesAutoresizingMaskIntoConstraints:NO];
		[_scrollView setShowsHorizontalScrollIndicator:NO];
		[_scrollView setShowsVerticalScrollIndicator:NO];
		[_scrollView setContentInset:UIEdgeInsetsMake(3, 5, 3, 5)];
		[self addSubview:_scrollView];
		
		_stackView = [[UIStackView alloc] initWithFrame:self.bounds];
		[_stackView setTranslatesAutoresizingMaskIntoConstraints:NO];
		[_stackView setDistribution:UIStackViewDistributionEqualSpacing];
		[_stackView setAxis:UILayoutConstraintAxisHorizontal];
		[_stackView setAlignment:UIStackViewAlignmentFill];
		[_stackView setSpacing:5];
		[_scrollView addSubview:_stackView];
		
		_toolStack = [UIStackView new];
		[_toolStack setTranslatesAutoresizingMaskIntoConstraints:NO];
		[_toolStack setDistribution:UIStackViewDistributionEqualCentering];
		[_toolStack setAxis:UILayoutConstraintAxisHorizontal];
		[_toolStack setAlignment:UIStackViewAlignmentTrailing];
		[_toolStack addLeftBorderWithColor:UIColor.lightGrayColor andWidth:1];
		[self addSubview:_toolStack];

		
		[_scrollView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor].active = YES;
		[_scrollView.trailingAnchor constraintEqualToAnchor:_toolStack.leadingAnchor].active = YES;
		[_scrollView.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
		[_scrollView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;

		[_stackView.leadingAnchor constraintEqualToAnchor:_scrollView.leadingAnchor].active = YES;
		[_stackView.trailingAnchor constraintEqualToAnchor:_scrollView.trailingAnchor].active = YES;
		[_stackView.topAnchor constraintEqualToAnchor:_scrollView.topAnchor].active = YES;
		[_stackView.bottomAnchor constraintEqualToAnchor:_scrollView.bottomAnchor].active = YES;
		[_stackView.heightAnchor constraintLessThanOrEqualToAnchor:_scrollView.heightAnchor constant:-6].active = YES;
//		[_stackView.heightAnchor constraintLessThanOrEqualToConstant:40].active = YES;
		
		[_toolStack addArrangedSubview:_addButton];
		[_toolStack addArrangedSubview:_removeButton];
		[_toolStack.trailingAnchor constraintEqualToAnchor:self.trailingAnchor].active = YES;
		[_toolStack.topAnchor constraintGreaterThanOrEqualToAnchor:_stackView.topAnchor].active = YES;
		[_toolStack.heightAnchor constraintLessThanOrEqualToAnchor:_stackView.heightAnchor].active = YES;

		[self generateButtons];
	}
	
	return self;
}

- (void)setAdditionalInsets:(UIEdgeInsets)insets {
	_scrollView.contentInset = UIEdgeInsetsMake(3 + insets.top, 5 + insets.left, 3 + insets.bottom, 5 + insets.right);
}

- (void)checkButtonShouldHide {
	BOOL disabled = _stackView.arrangedSubviews.count <= 2 || _colorObject.colors.count <= 2;
	_removeButton.alpha = !(_removeButton.hidden = disabled);
}

- (void)generateButtons {
	
	if ((self.colorObject.colors.count)) {
		[self.colorObject.colors enumerateObjectsUsingBlock:^(UIColor *color, NSUInteger index, BOOL *stop) {
			[self addArrangedSubview:[CSIndexedButton _accessoryButtonWithTitle:color.cscp_hexString target:self action:self->_selectAction color:color]];
		}];
	}
	
	[self checkButtonShouldHide];
	
	[_stackView layoutIfNeeded];
	[self setOffsetPlusSize:0];
}

- (void)setOffsetPlusSize:(CGFloat)size {
	_scrollView.contentOffset = CGPointMake(_scrollView.contentSize.width + size > _scrollView.bounds.size.width ? (_stackView.bounds.size.width - _scrollView.bounds.size.width) + size + (_stackView.spacing * 2) : 0, _scrollView.contentOffset.y);
}

- (void)addColor:(UIColor *)color animated:(BOOL)animated {
	__block CSIndexedButton *button = [CSIndexedButton _accessoryButtonWithTitle:color.cscp_hexString target:self action:self->_selectAction color:color];
	button.alpha = !(button.hidden = YES);
	[self addArrangedSubview:button];
	if (animated) START_ANIMATION
	button.alpha = !(button.hidden = NO);
	[self checkButtonShouldHide];
	[self setOffsetPlusSize:button.bounds.size.width];
	if (animated) END_ANIMATION
}

- (void)addColors:(NSArray *)colors {
	for (UIColor *color in colors) {
		[self addColor:color animated:NO];
	}
	[self setOffsetPlusSize:0];
}

- (void)removeColorAtIndex:(NSInteger)index animated:(BOOL)animated {
	[self checkButtonShouldHide];
	__block CSIndexedButton *button = self->_stackView.arrangedSubviews[index];
	if (animated) START_ANIMATION
	button.alpha = !(button.hidden = YES);
	[self setOffsetPlusSize:0];
	if(animated) COMPLETION
	[self removeArrangedSubview:button];
	if (animated) END_COMPLETION
}

- (void)setColor:(UIColor *)color atIndex:(NSInteger)index {
	if (_colorObject.colors.count < index) return;
	
	UIColor *titleColor = (!color.cscp_light && color.cscp_alpha > 0.5) ? UIColor.whiteColor : UIColor.blackColor;
	UIColor *shadowColor = titleColor == UIColor.blackColor ? UIColor.whiteColor : UIColor.blackColor;
	CSIndexedButton *button = _stackView.arrangedSubviews[index];
	[button.layer setBackgroundColor:color.CGColor];
	[button.titleLabel.layer setShadowColor:shadowColor.CGColor];
	[button setTitle:color.cscp_hexString forState:UIControlStateNormal];
	[button setTitleColor:titleColor forState:UIControlStateNormal];
	[button setTitleColor:[titleColor colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
}

#pragma Mark - (Actions)

- (void)changedAction:(CSIndexedButton *)selectedButton {
	if (_index != selectedButton.index) {
		_index = selectedButton.index;
		[self sendActionsForControlEvents:CSColorSelectionChanged];
	}
}

- (void)addAction:(UIButton *)selectionButton {
	[self sendActionsForControlEvents:CSColorSelectionAdd];
}

- (void)removeAction:(UIButton *)selectionButton {
	if (_stackView.arrangedSubviews.count >= 3 && _colorObject.colors.count >= 3) {
		[self sendActionsForControlEvents:CSColorSelectionRemove];
	}
}

#pragma Mark - (Helpers)

- (void)addArrangedSubview:(UIView *)view {
	if ([view isMemberOfClass:[CSIndexedButton class]])
		[(CSIndexedButton*)view setIndex:_stackView.arrangedSubviews.count];
	[_stackView addArrangedSubview:view];
}

- (void)addArrangedSubview:(UIView *)view atIndex:(NSInteger)index {
	if ([view isMemberOfClass:[CSIndexedButton class]])
		[(CSIndexedButton*)view setIndex:index];
	[_stackView insertArrangedSubview:view atIndex:index];
}

- (void)removeArrangedSubview:(UIView *)view {
	[_stackView removeArrangedSubview:view];
	
	[_stackView.arrangedSubviews enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
		if ([view isMemberOfClass:[CSIndexedButton class]])
			[(CSIndexedButton*)view setIndex:idx];
	}];
}

- (void)setLightContent:(BOOL)lightContent {
	UIColor *tintColor = lightContent ? UIColor.lightGrayColor : UIColor.darkGrayColor;
	_addButton.tintColor = tintColor;
	_removeButton.tintColor = tintColor;
	_toolStack.leftBorder.backgroundColor = tintColor;
}

@end
