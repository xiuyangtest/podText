//
//  UIView+MGJAnimation.h
//  Example
//
//  Created by Derek Chen on 4/24/15.
//  Copyright (c) 2015 juangua. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^UIViewMGJKitAnimationCompletionHandler)(UIView *view, BOOL finished);

@interface UIView (MGJAnimation)

/**
 *  animationToFullScreen
 *
 *  @param duration: 动画运算时间
 *
 *  @param completionHandler: 回调
 *
 *  @return void
 */
- (void)mgj_animationToFullScreenWithDuration:(NSTimeInterval)duration completion:(UIViewMGJKitAnimationCompletionHandler)completionHandler;
/**
 *  animationToFullScreen
 *
 *  @param frame: 动画运算后的Frame
 *
 *  @param duration: 动画运算时间
 *
 *  @param completionHandler: 回调
 *
 *  @return void
 */
- (void)mgj_animationToFrame:(CGRect)frame withDuration:(NSTimeInterval)duration completion:(UIViewMGJKitAnimationCompletionHandler)completionHandler;
/**
 *  animationToFullScreen
 *
 *  @param frame: 动画运算后的Frame
 *
 *  @param duration: 动画运算时间
 *
 *  @param alpha: 动画运算后的Alpha
 *
 *  @param options: 动画选项
 *
 *  @param completionHandler: 回调
 *
 *  @return void
 */
- (void)mgj_animationToFrame:(CGRect)frame alpha:(CGFloat)alpha withDuration:(NSTimeInterval)duration options:(UIViewAnimationOptions)options completion:(UIViewMGJKitAnimationCompletionHandler)completionHandler;

@end
