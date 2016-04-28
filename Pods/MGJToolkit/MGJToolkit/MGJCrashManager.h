//
//  MGJCrashReporter.h
//  MGJiPhoneSDKDemo
//
//  Created by kunka on 9/12/14.
//  Copyright (c) 2014 juangua. All rights reserved.
//
//  如果启用 Crashlytics，需要在 Build Phases 中添加 Run Script
//  if [ "${CONFIGURATION}" = "Release" ]; then
//  ./Pods/CrashlyticsFramework/Crashlytics.framework/run key
//  fi
//

#import <Foundation/Foundation.h>
#import <CrashReporter/CrashReporter.h>
#import <AFNetworking/AFNetworking.h>
#import <Crashlytics/Crashlytics.h>
#import <UIDevice+MGJKit.h>
#import <NSMutableDictionary+MGJKit.h>
#import <NSString+MGJKit.h>

/**
 *  crash 统计类
 */
@interface MGJCrashManager : NSObject

/**
 *  自定义参数
 */
@property (nonatomic, strong, readonly) NSMutableDictionary *customParameters;

/**
 *  crash文件目录
 */
@property (nonatomic, strong, readonly) NSString *crashReportDirectory;

/**
 *  参数文件目录
 */
@property (nonatomic, strong, readonly) NSString *liveParametersFilePath;

/**
 *  是否启用 Crashlytics
 */
@property (nonatomic, assign, readonly) BOOL hasEnableCrashlytics;

/**
 *  crash 后台地址
 */
@property (nonatomic, strong) NSString *requestURL;

/**
 *  单例方法
 *
 *  @return
 */
+ (instancetype)sharedInstance;

/**
 *  开启 crash 统计 不包括 crashlytics
 */
- (void)enableCrashReporter;

/**
 *  开启 crash 统计 包括crashlytics
 *
 *  @param crashlyticsKey crashlytics 的 appkey
 */
- (void)enableCrashReporterWithCrashlyticsKey:(NSString *)crashlyticsKey;

/**
 *  设置要一起传的自定义参数
 *
 *  @param object 参数值
 *  @param key    key
 */
- (void)setCustomParameter:(id)object forKey:(NSString *)key;

/**
 *  设置登录用户id
 *
 *  @param uid 用户id
 */
- (void)setUserId:(NSString *)uid;

/**
 *  设置登录用户名
 *
 *  @param uname 用户名
 */
- (void)setUserName:(NSString *)uname;

/**
 *  设置渠道
 *
 *  @param channel 渠道
 */
- (void)setChannel:(NSString *)channel;

/**
 *  模拟产生一个 exception 类型的 crash
 */
- (void)crash;

/**
 *  模拟产生一个 c/c++ 的 crash
 */
- (void)signal;
@end
