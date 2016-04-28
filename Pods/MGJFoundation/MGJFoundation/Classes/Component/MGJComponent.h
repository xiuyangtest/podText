//
//  MGJComponent.h
//  Example
//
//  Created by limboy on 7/15/15.
//  Copyright (c) 2015 juangua. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+MGJSingleton.h"
#import "MGJApplicationStateMonitor.h"

@interface MGJComponent : NSObject <Singleton, UIApplicationDelegate>

/**
 *  有了这个属性后，设置 Tabbar 会方便些
 */
@property (nonatomic) UIViewController *rootViewController;

/**
 *  组件的入口方法，在这里做 URL 注册，初始化等事情
 */
- (void)register;
@end
