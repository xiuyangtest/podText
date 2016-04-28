//
//  UIImageView+MGJKit.h
//  Example
//
//  Created by limboy on 12/19/14.
//  Copyright (c) 2014 juangua. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (MGJKit)

+ (UIImageView *)imageViewNamed:(NSString *)imageName;

- (void)setImage:(UIImage *)image animated:(BOOL)animated;
- (void)setImage:(UIImage *)image duration:(NSTimeInterval)duration;

@end