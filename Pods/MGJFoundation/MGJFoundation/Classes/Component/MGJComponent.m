//
//  MGJComponent.m
//  Example
//
//  Created by limboy on 7/15/15.
//  Copyright (c) 2015 juangua. All rights reserved.
//

#import "MGJComponent.h"
#import <ModuleManager/ModuleManager.h>

@interface MGJComponent() <ModuleProtocol>
@property (nonatomic) MGJApplicationStateMonitor *stateMonitor;
@end

@implementation MGJComponent

- (instancetype)init
{
    self = [super init];
    if (self) {
        _stateMonitor = [[MGJApplicationStateMonitor alloc] init];
        _stateMonitor.delegate = self;
    }
    return self;
}

- (void)register
{
    // 子类需要重写这个方法
    // 可以在这里进行 URL 注册等初始化的操作
    [NSException raise:NSInternalInconsistencyException format:@"You must override %@ in subclass", NSStringFromSelector(_cmd)];
}

- (void)moduleOnInit
{
    [self register];
}

- (void)moduleOnDeInit
{
    
}

@end
