//
//  MGJTabBar.h
//  Mogujie4iPhone
//
//  Created by kongkong on 13-5-20.
//  Copyright (c) 2013年 juangua. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MGJTabBarItem.h"

/**
 *  TabBar 控件
 */

@protocol MGJTabBarDelegate;

@interface MGJTabBar : UIView <MGJTabBarItemDelegate>

/**
 *  tabbardelegate
 */
@property (nonatomic, weak) id<MGJTabBarDelegate> delegate;

/**
 *  当前选中 item 的索引
 */
@property (nonatomic, assign, readonly) NSUInteger selectedIndex;


/**
 *  创建 tabbar
 *
 *  @param frame    frame
 *  @param items    items 数组
 *  @param delegate delegate
 *
 *  @return
 */
- (id)initWithFrame:(CGRect)frame items:(NSArray *)items delegate:(id<MGJTabBarDelegate>)delegate;

/**
 *  设置背景
 *
 *  @param backgroundImage 背景图
 */
- (void)setBackgroundImage:(UIImage *)backgroundImage;


/**
 *  选中某个 item
 *
 *  @param index 索引
 */
- (void)selectItemAtIndex:(NSInteger)index;

/**
 *  设置指定 item 的 badge
 *
 *  @param badge badge 数字
 *  @param index item 索引
 */
- (void)setBadge:(NSInteger)badge atIndex:(NSInteger)index;

@end


/**
 *  MGJTabBarDelegate
 */
@protocol MGJTabBarDelegate <NSObject>
@optional

/**
 *  选中了某个 item
 *
 *  @param tabBar tabbar
 *  @param index  索引
 */
- (void)tabBar:(MGJTabBar *)tabBar didSelectItemAtIndex:(NSUInteger)index;

/**
 *  是否能选中某个 item
 *
 *  @param tabBar tabbar
 *  @param index  索引
 *
 *  @return 
 */
- (BOOL)tabBar:(MGJTabBar *)tabBar shouldSelectItemAtIndex:(NSUInteger)index;
@end