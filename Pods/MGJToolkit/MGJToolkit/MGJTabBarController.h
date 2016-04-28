//
//  TabBarViewController.h
//  Mogujie4iPhone
//
//  Created by ght on 13-9-6.
//  Copyright (c) 2013年 juangua. All rights reserved.
//

#import "MGJTabBar.h"
#import "MGJTabBarItem.h"

@class MGJTabBarController;

@protocol MGJViewControllerProtocol <NSObject>

@property (nonatomic, assign) CGRect defaultFrame;
@property (nonatomic, strong) MGJTabBarItem *mgjTabBarItem;
@property (nonatomic, weak) MGJTabBarController *mgjTabBarController;

@end


extern CGFloat const MGJTabbarHeight;

@protocol MGJTabBarControllerDelegate;

/**
 *  自定义的 TabBarController
 */
@interface MGJTabBarController : UIViewController<MGJTabBarDelegate, MGJViewControllerProtocol>

@property (nonatomic, assign) CGRect defaultFrame;
@property (nonatomic, strong) MGJTabBarItem *mgjTabBarItem;
@property (nonatomic, weak) MGJTabBarController *mgjTabBarController;

/**
 *  文字颜色
 */
@property (nonatomic, strong) UIColor *titleColor;
/**
 *  被选中时的文字颜色
 */
@property (nonatomic, strong) UIColor *selectedTitleColor;

/**
 *  tabbar
 */
@property(nonatomic, strong, readonly) MGJTabBar *mgjTabBar;

/**
 *  tabbarcontroller 中的 viewcontroller
 */
@property(nonatomic, strong, readonly) NSArray *viewControllers;

/**
 *  当前选中的 viewcontroller
 */
@property(nonatomic, strong, readonly) UIViewController *selectedViewController;

/**
 *  当前选中的 index
 */
@property(nonatomic, assign, readonly) NSInteger selectIndex;

/**
 *  delegate
 */
@property(nonatomic, weak) id<MGJTabBarControllerDelegate> mgjTabBarControllerDelegate;

/**
 *  初始化 tabbarcontroller
 *
 *  @param viewControllers tabbarcontroller 中的 viewcontroller
 *
 *  @return
 */
- (id)initWithViewControllers:(NSArray *)viewControllers;

/**
 *  选中某个 tab
 *
 *  @param index 索引
 */
- (void)selectAtIndex:(NSInteger)index;

@end



/**
 *  MGJTabBarControllerDelegate
 */
@protocol MGJTabBarControllerDelegate <NSObject>
@optional
/**
 *  是否能选中制定的 viewcontroller
 *
 *  @param tabBarController tabbarcontroller
 *  @param viewController   将要选中的 viewcontroller
 *  @param index            将要选中的 viewcontroller 在 tabbar 中的索引
 *
 *  @return
 */
- (BOOL)tabBarController:(MGJTabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController atIndex:(NSInteger)index;

/**
 *  选中 tabbarcontroller 中某个 viewcontroller 时调用
 *
 *  @param tabBarController tabbarcontroller
 *  @param viewController   选中的 viewcontroller
 *  @param index            选中的 viewcontroller 在 tabbar 中的索引
 */
- (void)tabBarController:(MGJTabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController atIndex:(NSInteger)index;

@end



/**
 *  MGJTabBarControllerProtocal 协议
 */
@protocol MGJTabBarControllerProtocal <NSObject>

@optional
/**
 *  当 viewcontroller 被选中时调用，必须是切换的情况下
 */
- (void)didSelectedInTabBarController;

/**
 *  是否能选中
 *
 *  @return 
 */
- (BOOL)shoudSelectedInTabBarController;

/**
 *  点击时，当前 viewcontroller 已经是选中的情况下调用
 */
- (void)didSelectedInTabBarControllerWhenAppeared;
@end
