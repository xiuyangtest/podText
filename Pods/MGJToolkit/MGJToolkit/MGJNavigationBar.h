//
//  MGJNavigationBar.h
//  Mogujie4iPhone
//
//  Created by dong wu on 12-7-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//


#import <UIKit/UIKit.h>

/**
 *  公用的导航栏控件
 */
@interface MGJNavigationBar : UIView

/**
 *  标题文字
 */
@property(nonatomic, copy) NSString *title;

/**
 *  titleview
 */
@property(nonatomic, strong) UIView *titleView;

/**
 *  标题的 label
 */
@property(nonatomic, readonly) UILabel *titleLabel;

/**
 *  左侧按钮
 */
@property(nonatomic, strong) UIView *leftBarButton;

/**
 *  右侧按钮
 */
@property(nonatomic, strong) UIView *rightBarButton;

/**
 *  放置内容的 view，不包含状态栏
 */
@property(nonatomic, readonly) UIView *containerView;

/**
 *  底部 border 颜色
 */
@property(nonatomic, strong) UIColor *bottomBorderColor UI_APPEARANCE_SELECTOR;

/**
 *  title 颜色
 */
@property(nonatomic, strong) UIColor *titleColor UI_APPEARANCE_SELECTOR;


/**
 *  创建 navigation bar
 *
 *  @param frame          frame
 *  @param needBlurEffect 是否需要模糊效果 (iOS 8 以上支持)
 *
 *  @return 
 */
- (id)initWithFrame:(CGRect)frame needBlurEffect:(BOOL)needBlurEffect;

/**
 *  导航栏背景颜色
 */
- (UIColor *)backgroundColor;


@end
