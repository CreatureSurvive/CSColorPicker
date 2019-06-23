//
//  TableViewController.m
//  CSColorPickerExample_IOS
//
//  Created by Dana Buehre on 6/23/19.
//  Copyright © 2019 CreatureCoding. All rights reserved.
//

#import "TableViewController.h"
#import <CSColorPicker/CSColorPicker.h>
#import <CSColorPicker/CSColorDisplayCell.h>
#import <CSColorPicker/CSGradientDisplayCell.h>


@interface TableViewController ()

@end

@implementation TableViewController {
	NSMutableDictionary *_colors;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	_colors = [NSMutableDictionary new];
	[self.tableView registerClass:[CSColorDisplayCell class] forCellReuseIdentifier:@"color_cell"];
	[self.tableView registerClass:[CSGradientDisplayCell class] forCellReuseIdentifier:@"gradient_cell"];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *reuse_identifier = indexPath.row == 0 ? @"color_cell" : @"gradient_cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuse_identifier forIndexPath:indexPath];
	
	if (!cell) {
		if (indexPath.row == 0)
			cell = [[CSColorDisplayCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuse_identifier];
		else
			cell = [[CSGradientDisplayCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuse_identifier];
	}
	
	CSColorObject *colorObject = [self colorObjectAtIndexPath:indexPath];
	[(CSColorDisplayCell *)cell setColorObject:colorObject delegate:self];
	
	cell.textLabel.text = colorObject.identifier;
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
	if ([cell isKindOfClass:[CSColorDisplayCell class]] || [cell isKindOfClass:[CSGradientDisplayCell class]]) {
		[self.navigationController pushViewController:[(CSColorDisplayCell *)cell colorPicker] animated:YES];
	}
}

- (CSColorObject *)colorObjectAtIndexPath:(NSIndexPath *)indexPath {
	NSString *identifier = [NSString stringWithFormat:@"row (%ld)", (long)indexPath.row];
	CSColorObject *colorObject = _colors[identifier];
	if (!colorObject) {
		NSString *hex = [[NSUserDefaults standardUserDefaults] stringForKey:identifier] ? : @"FF0000";
		if (indexPath.row == 0) colorObject = [CSColorObject colorObjectWithHex:hex];
		else colorObject = [CSColorObject gradientObjectWithHex:hex];
		colorObject.identifier = identifier;
	}
	return colorObject;
}

- (void)colorPicker:(CSColorPickerViewController *)picker didPickColor:(CSColorObject *)colorObject {
	if (colorObject.identifier)
		_colors[colorObject.identifier] = colorObject;
}

- (void)colorPicker:(CSColorPickerViewController *)picker didUpdateColor:(CSColorObject *)colorObject {
	if (colorObject.identifier)
		_colors[colorObject.identifier] = colorObject;
}
@end
