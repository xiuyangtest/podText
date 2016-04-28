//
//  MGJTabBarViewController.m
//  Mogujie4iPhone
//
//  Created by kongkong on 13-5-20.
//  Copyright (c) 2013年 juangua. All rights reserved.
//

#import "MGJTabBarController.h"
#import <UIView+MGJKit.h>

CGFloat const MGJTabbarHeight = 49.f;

@interface MGJTabBarController()
@property(nonatomic, strong) MGJTabBar *mgjTabBar;
@property(nonatomic, strong) NSArray *viewControllers;
@property(nonatomic, strong) UIViewController *selectedViewController;
@property(nonatomic, assign) NSInteger selectIndex;
@end

@implementation MGJTabBarController

- (id)initWithViewControllers:(NSArray *)viewControllers
{
    self = [super init];
    if (self) {
        self.viewControllers = viewControllers;
        self.automaticallyAdjustsScrollViewInsets = NO;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarFrameDidChanged) name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSMutableArray *itemsArray = [NSMutableArray array];
    for (UIViewController<MGJViewControllerProtocol> *viewController in self.viewControllers) {
        viewController.defaultFrame = CGRectMake(0, 0, self.view.width, self.view.height - MGJTabbarHeight);
        
        MGJTabBarItem *tabBarItem = viewController.mgjTabBarItem;
        if (!tabBarItem) {
            tabBarItem = [[MGJTabBarItem alloc] initWithTitle:viewController.title titleColor:self.titleColor selectedTitleColor:self.selectedTitleColor icon:nil selectedIcon:nil];
            viewController.mgjTabBarItem = tabBarItem;
        }
        [itemsArray addObject:tabBarItem];
        [self addChildViewController:viewController];
        viewController.mgjTabBarController = self;
    }
    
    self.selectIndex = 0;
    self.selectedViewController = self.viewControllers[0];
    [self.view addSubview:[self.viewControllers[self.selectIndex] view]];
    
    self.mgjTabBar = [[MGJTabBar alloc] initWithFrame:CGRectMake(0, self.view.height - MGJTabbarHeight, self.view.width, MGJTabbarHeight) items:itemsArray delegate:self];

    [self.view addSubview:self.mgjTabBar];
}

- (void)selectAtIndex:(NSInteger)index {
    if (index > self.viewControllers.count - 1) {
        return;
    }
    [self.mgjTabBar selectItemAtIndex:index];
}

#pragma mark - MGJTabBarDelegate

- (BOOL)tabBar:(MGJTabBar *)tabBar shouldSelectItemAtIndex:(NSUInteger)index
{
    BOOL shouldSelect = YES;
    if ([self.mgjTabBarControllerDelegate respondsToSelector:@selector(tabBarController:shouldSelectViewController:atIndex:)]) {
        shouldSelect = [self.mgjTabBarControllerDelegate tabBarController:self shouldSelectViewController:self.viewControllers[index] atIndex:index];
    }
    
    return shouldSelect;
}

- (void)tabBar:(MGJTabBar *)tabBar didSelectItemAtIndex:(NSUInteger)index
{
    if (self.selectIndex == index) {
        self.selectedViewController.view.frame = CGRectMake(0, 0, self.view.width, self.view.height - MGJTabbarHeight);
        if ([self.selectedViewController respondsToSelector:@selector(didSelectedInTabBarControllerWhenAppeared)])
        {
            [self.selectedViewController performSelector:@selector(didSelectedInTabBarControllerWhenAppeared) withObject:nil];
        }
    }
    else
    {
        [self.selectedViewController.view removeFromSuperview];
        
        self.selectIndex = index;
        self.selectedViewController = self.viewControllers[self.selectIndex];
        
        [self.view insertSubview:self.selectedViewController.view belowSubview:self.mgjTabBar];
        
        if ([self.mgjTabBarControllerDelegate respondsToSelector:@selector(tabBarController:didSelectViewController:atIndex:)]) {
            [self.mgjTabBarControllerDelegate tabBarController:self didSelectViewController:self.selectedViewController atIndex:self.selectIndex];
        }
        
        if ([self.selectedViewController respondsToSelector:@selector(didSelectedInTabBarController)])
        {
            [self.selectedViewController performSelector:@selector(didSelectedInTabBarController) withObject:nil];
        }
    }

}


- (void)statusBarFrameDidChanged
{
    self.mgjTabBar.bottom = self.view.height - ([self.view convertPoint:CGPointMake(0, self.view.height) toView:nil].y - [UIApplication sharedApplication].keyWindow.size.height);
}

@end
