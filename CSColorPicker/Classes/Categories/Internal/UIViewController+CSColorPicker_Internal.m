//
//  UIViewController+CSColorPicker_Internal.m
//  CSColorPicker
//
//  Created by Dana Buehre on 6/24/19.
//  Copyright © 2019 CreatureCoding. All rights reserved.
//

#import "UIViewController+CSColorPicker_Internal.h"

@implementation UIViewController (CSColorPicker_Internal)

- (CGFloat)navigationHeight {
	return [self isLandscape] ?
		self.navigationController.navigationBar.frame.size.height :
		self.navigationController.navigationBar.frame.size.height + UIApplication.sharedApplication.statusBarFrame.size.height;
}

- (BOOL)isLandscape {
	return UIInterfaceOrientationIsLandscape(UIApplication.sharedApplication.statusBarOrientation);
}

// credit: https://stackoverflow.com/a/23620377/4668186
- (BOOL)isModal {
	if([self presentingViewController])
		return YES;
	if([[[self navigationController] presentingViewController] presentedViewController] == [self navigationController])
		return YES;
	if([[[self tabBarController] presentingViewController] isKindOfClass:[UITabBarController class]])
		return YES;
	
	return NO;
}

@end
