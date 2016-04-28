//
//  UIView+MGJAnimation.m
//  Example
//
//  Created by Derek Chen on 4/24/15.
//  Copyright (c) 2015 juangua. All rights reserved.
//

#import "UIView+MGJAnimation.h"

@implementation UIView (MGJAnimation)

- (void)mgj_animationToFullScreenWithDuration:(NSTimeInterval)duration completion:(UIViewMGJKitAnimationCompletionHandler)completionHandler {
    [self mgj_animationToFrame:[UIScreen mainScreen].bounds withDuration:duration completion:completionHandler];
}

- (void)mgj_animationToFrame:(CGRect)frame withDuration:(NSTimeInterval)duration completion:(UIViewMGJKitAnimationCompletionHandler)completionHandler {
    [self mgj_animationToFrame:frame alpha:self.alpha withDuration:duration options:0 completion:completionHandler];
}

- (void)mgj_animationToFrame:(CGRect)frame alpha:(CGFloat)alpha withDuration:(NSTimeInterval)duration options:(UIViewAnimationOptions)options completion:(UIViewMGJKitAnimationCompletionHandler)completionHandler {
    if (!(duration > 0) || alpha < 0.0f || alpha > 1.0f) {
        return;
    }
    __weak __typeof(self)weakSelf = self;
    [UIView animateWithDuration:duration delay:0.0 options:options animations:^{
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        strongSelf.frame = frame;
        strongSelf.alpha = alpha;
    } completion:^(BOOL finished) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (completionHandler) {
            completionHandler(strongSelf, finished);
        }
    }];
}

@end
