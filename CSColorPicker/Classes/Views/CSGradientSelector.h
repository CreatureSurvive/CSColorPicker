//
// Created by CreatureSurvive on 4/7/19.
// Copyright (c) 2016 - 2019 CreatureCoding. All rights reserved.
//

#import "CSColorSelector.h"

@interface CSGradientSelector : CSColorSelector
@property(nonatomic, retain, readonly) CAGradientLayer *gradient;
@property(nonatomic, assign) BOOL gradientOnTop;

@end
