//
//  ViewController.m
//  CSColorPickerExample
//
//  Created by Dana Buehre on 6/22/19.
//  Copyright © 2019 CreatureCoding. All rights reserved.
//

#import "ViewController.h"

#define COLOR_IDENTIFIER @"test_color"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view.
	
	UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
	[button setTitle:@"Open Color Picker" forState:UIControlStateNormal];
	[button addTarget:self action:@selector(openCP) forControlEvents:UIControlEventTouchUpInside];
	[button sizeToFit];
	button.center = self.view.center;
	[self.view addSubview:button];
	
}

- (void)openCP {
	// get the color from NSUserDefaults or use red if no color was saved
	NSString *hex = [[NSUserDefaults standardUserDefaults] stringForKey:COLOR_IDENTIFIER] ? : @"FF0000";
	CSColorObject *colorObject = [CSColorObject colorObjectWithHex:hex];
	// initialize the ColorPicker with the starting color,
	// set the delegate
	// set the identifier
	CSColorPickerViewController *vc = [[CSColorPickerViewController alloc] initWithColorObject:colorObject showingAlpha:NO];
	vc.blurStyle = UIBlurEffectStyleDark;
	vc.delegate = self;
	vc.identifier = COLOR_IDENTIFIER;
	
	[self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - CSColorPickerDelegate

// called whenever the color picker is dismissed with including a color object representing the picked color
- (void)colorPicker:(CSColorPickerViewController *)picker didPickColor:(CSColorObject *)colorObject {
	self.view.backgroundColor = colorObject.color;
}

@end
