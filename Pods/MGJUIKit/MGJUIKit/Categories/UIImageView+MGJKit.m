//
//  UIImageView+MGJKit.m
//  Example
//
//  Created by limboy on 12/19/14.
//  Copyright (c) 2014 juangua. All rights reserved.
//

#import "UIImageView+MGJKit.h"

@implementation UIImageView (MGJKit)

+ (UIImageView *)imageViewNamed:(NSString *)imageName {
    return [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
}

- (void)setImage:(UIImage *)image animated:(BOOL)animated {
    [self setImage:image duration:(animated ? 0.25 : 0.)];
}

- (void)setImage:(UIImage *)image duration:(NSTimeInterval)duration {
    if (duration > 0.) {
        CATransition *transition = [CATransition animation];
        
        transition.duration = duration;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.type = kCATransitionFade;
        
        [self.layer addAnimation:transition forKey:nil];
    }
    
    self.image = image;
}

@end
