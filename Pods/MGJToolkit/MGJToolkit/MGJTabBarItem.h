//
//  MGJTabBarItem.h
//  Mogujie4iPhone
//
//  Created by kongkong on 13-5-20.
//  Copyright (c) 2013年 juangua. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MGJBadgeView.h"

@protocol MGJTabBarItemDelegate;


/**
 *  用于 MGJTabBar 的 MGJTabBarItem
 */
@interface MGJTabBarItem : UIControl

@property(nonatomic, weak) id<MGJTabBarItemDelegate> delegate;
@property(nonatomic, strong) MGJBadgeView *badgeView;
@property(nonatomic, assign) UIEdgeInsets imageInset;

/**
 *  初始化 tabbaritem
 *
 *  @param title              标题
 *  @param titleColor         标题颜色
 *  @param selectedTitleColor 选中的标题颜色
 *  @param icon               icon
 *  @param selectedIcon       选中的icon
 *
 *  @return
 */
- (id)initWithTitle:(NSString *)title titleColor:(UIColor *)titleColor selectedTitleColor:(UIColor *)selectedTitleColor icon:(UIImage *)icon selectedIcon:(UIImage *)selectedIcon;

/**
 *  设置icon
 *
 *  @param image icon 图片
 */
- (void)setIcon:(UIImage *)image;

/**
 *  设置 selectIcon
 *
 *  @param selectedIcon 选中的 icon 图片
 */
- (void)setSelectedIcon:(UIImage *)selectedIcon;
/**
 *  设置title
 *
 *  @param title 标题
 */
-(void)setTitle:(NSString*)title;
/**
 *  设置 selectedTextColor
 *
 *  @param 选中字的颜色
 */
-(void)setSelectedTextColor:(UIColor *) selectedTitleColor;

@end

/**
 *  MGJTabBarItemDelegate
 */
@protocol MGJTabBarItemDelegate <NSObject>

@optional

/**
 *  item 被选中时调用
 *
 *  @param item 当前item
 */
- (void)tabBarItemdidSelected:(MGJTabBarItem *)item;

@end