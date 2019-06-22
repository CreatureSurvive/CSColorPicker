//
//  ViewController.m
//  CSColorPickerExample
//
//  Created by Dana Buehre on 6/22/19.
//  Copyright © 2019 CreatureCoding. All rights reserved.
//

#import "ViewController.h"
#import <CSColorPicker/CSColorPickerViewController.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view.
	
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	[button setTitle:@"Open Color Picker" forState:UIControlStateNormal];
	[button setTitleColor:UIColor.grayColor forState:UIControlStateNormal];
	[button addTarget:self action:@selector(openCP) forControlEvents:UIControlEventTouchUpInside];
	[button sizeToFit];
	button.center = self.view.center;
	[self.view addSubview:button];
	
}

- (void)openCP {
	CSColorPickerViewController *vc = [[CSColorPickerViewController alloc] initWithColors:@[UIColor.redColor] showingAlpha:YES];
	[self presentViewController:vc animated:YES completion:nil];
}

@end
