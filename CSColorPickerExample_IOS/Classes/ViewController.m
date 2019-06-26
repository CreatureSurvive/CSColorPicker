//
//  ViewController.m
//  CSColorPickerExample_IOS
//
//  Created by Dana Buehre on 6/23/19.
//  Copyright © 2019 CreatureCoding. All rights reserved.
//

#import "ViewController.h"
#import "TableViewController.h"

@interface ViewController ()

@end

@implementation ViewController {
	CAGradientLayer *_gradient;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.title = @"CSColorPicker";

	_gradient = [CAGradientLayer new];
	_gradient.frame = self.view.bounds;
	_gradient.startPoint = CGPointZero;
	_gradient.endPoint = CGPointMake(1, 1);
	[self.view.layer addSublayer:_gradient];
	
	UIStackView *stack = [[UIStackView alloc] initWithFrame:CGRectMake(0, 0, 300, 300)];
	stack.axis = UILayoutConstraintAxisVertical;
	stack.distribution = UIStackViewDistributionFillEqually;
	stack.center = self.view.center;
	stack.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
	[self.view addSubview:stack];
	
	UIButton *pushCP = [UIButton buttonWithType:UIButtonTypeSystem];
	[pushCP setTitle:@"Push Color Picker" forState:UIControlStateNormal];
	[pushCP addTarget:self action:@selector(pushCP) forControlEvents:UIControlEventTouchUpInside];
	UIButton *presentCP = [UIButton buttonWithType:UIButtonTypeSystem];
	[presentCP setTitle:@"Present Color Picker" forState:UIControlStateNormal];
	[presentCP addTarget:self action:@selector(presentCP) forControlEvents:UIControlEventTouchUpInside];
	UIButton *pushGP = [UIButton buttonWithType:UIButtonTypeSystem];
	[pushGP setTitle:@"Push Gradient Picker" forState:UIControlStateNormal];
	[pushGP addTarget:self action:@selector(pushGP) forControlEvents:UIControlEventTouchUpInside];
	UIButton *presentGP = [UIButton buttonWithType:UIButtonTypeSystem];
	[presentGP setTitle:@"Present Gradient Picker" forState:UIControlStateNormal];
	[presentGP addTarget:self action:@selector(presentGP) forControlEvents:UIControlEventTouchUpInside];
	UIButton *pushTable = [UIButton buttonWithType:UIButtonTypeSystem];
	[pushTable setTitle:@"Push Table" forState:UIControlStateNormal];
	[pushTable addTarget:self action:@selector(pushTable) forControlEvents:UIControlEventTouchUpInside];
	UIButton *showCP = [UIButton buttonWithType:UIButtonTypeSystem];
	[showCP setTitle:@"Show Color Picker" forState:UIControlStateNormal];
	[showCP addTarget:self action:@selector(showConhtroller) forControlEvents:UIControlEventTouchUpInside];
	
	[stack addArrangedSubview:pushCP];
	[stack addArrangedSubview:presentCP];
	[stack addArrangedSubview:pushGP];
	[stack addArrangedSubview:presentGP];
	[stack addArrangedSubview:pushTable];
	[stack addArrangedSubview:showCP];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
	[coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
		self->_gradient.frame = self.view.bounds;
	} completion:nil];
	
	[super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

- (void)viewDidLayoutSubviews {
	[super viewDidLayoutSubviews];
	self->_gradient.frame = self.view.bounds;
}

- (CSColorPickerViewController *)pickerForType:(NSInteger)type {
	static NSString *const COLOR_ID = @"test_color", *const GRADIENT_ID = @"test_gradient";
	CSColorObject *colorObject;
	
	switch (type) {
		case 0: {
			NSString *hex = [[NSUserDefaults standardUserDefaults] stringForKey:COLOR_ID] ? : @"FF0000";
			colorObject = [CSColorObject colorObjectWithHex:hex];
			colorObject.identifier = COLOR_ID;
		} break;
			
		default:{
			NSString *hex = [[NSUserDefaults standardUserDefaults] stringForKey:GRADIENT_ID] ? : @"FF0000,00FF00";
			colorObject = [CSColorObject gradientObjectWithHex:hex];
			colorObject.identifier = GRADIENT_ID;
		} break;
	}
	
	CSColorPickerViewController *vc = [[CSColorPickerViewController alloc] initWithColorObject:colorObject showingAlpha:NO];
	vc.showsDarkmodeToggle = YES;
	vc.delegate = self;
	
	return vc;
}

- (void)presentCP {
	[self presentVC:[self pickerForType:0]];
}

- (void)presentGP {
	[self presentVC:[self pickerForType:1]];
}

- (void)pushCP {
	[self.navigationController pushViewController:[self pickerForType:0] animated:YES];
}

- (void)pushGP {
	[self.navigationController pushViewController:[self pickerForType:1] animated:YES];
}

- (void)presentVC:(UIViewController *)vc {
	UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
	nc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	[self presentViewController:nc animated:YES completion:nil];
}

- (void)pushTable {
	TableViewController *tvc = [[TableViewController alloc] init];
	[self.navigationController pushViewController:tvc animated:YES];
}

- (void)showConhtroller {
	CSColorPickerViewController *vc = [self pickerForType:0];
	vc.useSafeArea = NO;
	UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
	nc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	nc.view.frame = CGRectMake(0, 0, 200, 300);
	nc.view.center = self.view.center;
	[self addChildViewController:nc];
	[self.view addSubview:nc.view];
}

#pragma mark - CSColorPickerDelegate

// called whenever the color picker is dismissed
- (void)colorPicker:(CSColorPickerViewController *)picker didPickColor:(CSColorObject *)colorObject {
	NSLog(@"ColorPicker didPickColor: %@ (%@)", colorObject.hexValue, colorObject.identifier);
	_gradient.colors = [colorObject gradientCGColors];
}

// called whenever the color picker finishes changing colors
- (void)colorPicker:(CSColorPickerViewController *)picker didUpdateColor:(CSColorObject *)colorObject {
	NSLog(@"ColorPicker didUpdateColor: %@ (%@)", colorObject.hexValue, colorObject.identifier);
}

@end
