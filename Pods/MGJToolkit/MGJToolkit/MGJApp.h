//
//  MGJApp.h
//  MGJiPhoneSDK
//
//  Created by kunka on 14-6-13.
//  Copyright (c) 2014年 juangua. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import <MGJFoundation/UIApplication+MGJKit.h>


/**
 *  MGJApp 实例，包括 App 的基础信息。在 App 启动时需要调用 registApp 方法初始化 App 信息。
 */
@interface MGJApp : NSObject

/**
 *  蘑菇街内部应用名称标识
 */
@property(nonatomic, strong, readonly) NSString *appName;

/**
 *  应用类型 ：iPhone
 */
@property(nonatomic, strong, readonly) NSString *appType;

/**
 *  应用渠道
 */
@property(nonatomic, strong, readonly) NSString *appChannel;

/**
 *  应用版本号
 */
@property(nonatomic, assign, readonly) NSInteger appVersion;

/**
 *  项目中配置的应用版本号字符串
 */
@property(nonatomic, strong, readonly) NSString *bundleVersionString;

/**
 *  应用的 Source，为 渠道+版本号
 */
@property(nonatomic, strong, readonly) NSString *appSource;

/**
 *  首次安装时的 source
 */
@property(nonatomic, strong, readonly) NSString *firstInstallSource;


/**
 *  矫正后的时间
 */
@property(nonatomic, assign, readonly) NSTimeInterval correctTime;

/**
 *  与服务器时间差
 */
@property(nonatomic, assign, readonly) NSTimeInterval timeOffset;

/**
 *  设置服务器时间
 *
 *  @param serverTime 服务器时间戳
 */
- (void)setServerTime:(NSTimeInterval)serverTime;

/**
 *  推送的devicetoken
 */
@property(nonatomic, strong) NSData *deviceToken;

/**
 *  当前最新版本
 */
@property(nonatomic, assign) NSInteger latestVersion;

/**
 *  是否有新版本需要升级
 */
@property(nonatomic, assign) BOOL needUpdate;

/**
 *  自定义更新地址
 */
@property(nonatomic, strong) NSString *customUpdateUrl;


/**
 *  自定义评价地址
 */
@property(nonatomic, strong) NSString *customRateUrl;


/**
 *  自定义请求的 useragent
 */
@property(nonatomic, strong) NSString *customRequestUserAgent;

/**
 *  是否为当前版本第一次启动
 */
@property(nonatomic, readonly) BOOL firstLaunchInCurrentVersion;

/**
 *  获取当前的 MGJApp 对象
 *
 *  @return
 */
+ (MGJApp *)currentApp;

/**
 *  注册当前 App，启动时调用一次即可
 *
 *  @param appName    蘑菇街内部应用名称标识
 *  @param appType    应用类型：iPhone
 *  @param appChannel 渠道名
 *  @param appleId    应用在 AppStore 中的 ID，用来生成更新和评价地址
 *  @return
 */
+ (MGJApp *)registerApp:(NSString *)appName type:(NSString *)appType channel:(NSString *)appChannel appleId:(NSString *)appleId;

/**
 *  设置 Webview UA 所需要用到的 AppName
 *
 *  @param appName AppName
 */
- (void)configUserAgentWithAppName:(NSString *)appName;

/**
 *  去 App 更新页面
 */
- (void)updateApp;

/**
 *  去 App 评价页面
 */
- (void)rateApp;

/**
 *  检查是否有新版
 *
 *  @return 是否有新版
 */
- (BOOL)checkUpdate;


/**
 *  当前应用通知开关状态
 *
 *  @return 
 */
- (UIRemoteNotificationType)pushStatus;
@end
