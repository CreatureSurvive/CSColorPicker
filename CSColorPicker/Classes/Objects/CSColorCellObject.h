//
//  CSCellObject.h
//  CSColorPicker
//
//  Created by Dana Buehre on 6/23/19.
//  Copyright © 2019 CreatureCoding. All rights reserved.
//


@class CSColorObject;
@protocol CSColorCellObject <NSObject>

@required
- (void)setColorObject:(CSColorObject *)colorObject;

@end
