# CSColorPicker

**CSColorPicker** is a **modern** and **light-weight** framework for **color picking / adjustment** with support for **gradient objects**.

![example](example.gif)

## Usage

Displaying the picker is as simple as:

```
CSColorObject *colorObject = [CSColorObject colorObjectWithHex:@"#FF0000"];
CSColorPickerViewController *colorPicker = [[CSColorPickerViewController alloc] initWithColorObject:colorObject showingAlpha:NO];
[self.navigationController pushViewController:colorPicker animated:YES];
```

Need to perform a task when a color is picked, then simply assign a `CSColorPickerDelegate` to the color picker, and implement one of its methods

```
// the header
#import <CSColorPicker/CSColorPickerDelegate.h>

@interface MyClass : NSObject <CSColorPickerDelegate>
@end

// the implementation
CSColorObject *colorObject = [CSColorObject colorObjectWithHex:@"#FF0000"];
CSColorPickerViewController *colorPicker = [[CSColorPickerViewController alloc] initWithColorObject:colorObject showingAlpha:NO]; 
[colorPicker setDelegate:self];

// delegate callbacks
// called when the color picker is dismissed providing the picked color
- (void)colorPicker:(CSColorPickerViewController *)picker didPickColor:(CSColorObject *)colorObject {
	NSLog(@"Color Picker Did Pick Color %@", colorObject.hexValue);
}

// called whenever the color picker updates the color
- (void)colorPicker:(CSColorPickerViewController *)picker didUpdateColor:(CSColorObject *)colorObject {
	NSLog(@"Color Picker Did Update Color %@", colorObject.hexValue);
}
```

For persistence using `NSUserDefaults`, simply set the `CSColorPickerViewController.identifier` to the key you want to save the color to. If the color picker has an identifier it will automatically save its value in `NSUserDefaults` when picking a color.  **note:** the same applies when initializing a color picker using a `CSColorObject` That has an identifier set. 

## License

**CSColorPicker** is available under the **MIT license**. See the [`LICENSE`](CSColorPicker/LICENSE)file for more info.