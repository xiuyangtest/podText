//
//  ModuleManager.h
//  ModuleManager
//
//  Created by 止水 on 10/8/15.
//  Copyright © 2015 mogujie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol ModuleProtocol;
@interface ModuleManager : NSObject

+ (ModuleManager *)sharedInstance;

/*!
 @brief 从plist文件中读取模块入口列表。
 */
- (void)loadModuleFromPlist:(NSString *)plist;

/*!
 @brief 根据模块入口类名反射实例，
 */
- (id<ModuleProtocol>)loadModule:(NSString *)moduleName;
- (void)unloadModule:(NSString *)moduleName;

/*!
 @brief 返回所有模块，每个模块都遵循 ModuleProtocol 协议
 */
- (NSArray *)allModules;

- (void)registerClass:(Class)class forProtocol:(Protocol *)protocol;
- (void)deRegisterForProtocol:(Protocol *)protocol;

/*!
 @brief 根据注册的类-协议表返回处理类
 @discussion 注意根据协议的内容，选择合适的初始化方式(alloc/alloc:with:/sharedInstance)
 */
- (Class)classForProtocol:(Protocol *)protocol;

@end


@protocol ModuleProtocol <UIApplicationDelegate>

/*!
 @brief 初始化时要做的事情：
 a). 注册协议的实现类
 b). 注册通知
 c). ...
 @discussion 只处理模块元信息，不涉及模块内部业务逻辑。
 */
- (void)moduleOnInit;

- (void)moduleOnDeInit;

@optional
- (NSString *)name;
- (NSString *)version;
- (NSString *)description;

@end


