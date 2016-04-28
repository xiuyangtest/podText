//
//  UIButton+MGJKit.h
//  Example
//
//  Created by limboy on 12/19/14.
//  Copyright (c) 2014 juangua. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (MGJKit)

/**
 *  就像 [UIImage imageNamed:] 一样，这个方法可以根据 imageName 生成一个 normal 状态 size 跟 image 一样的 button
 *
 *  @param imageName
 *
 *  @return
 */
+ (UIButton *)mgj_buttonWithImageNamed:(NSString *)imageName;

@end
