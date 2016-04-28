//
//  UIButton+MGJKit.m
//  Example
//
//  Created by limboy on 12/19/14.
//  Copyright (c) 2014 juangua. All rights reserved.
//

#import "UIButton+MGJKit.h"

@implementation UIButton (MGJKit)

+ (UIButton *)mgj_buttonWithImageNamed:(NSString *)imageName {
    UIImage *image = [UIImage imageNamed:imageName];
    UIButton *button;
    
    if (image != nil) {
        button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = (CGRect){CGPointZero,image.size};
        [button setImage:image forState:UIControlStateNormal];
    }
    
    return button;
}

@end
