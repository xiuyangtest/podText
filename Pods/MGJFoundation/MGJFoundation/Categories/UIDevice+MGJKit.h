//
//  UIDevice+MGJKit.h
//  MGJAnalytics
//
//  Created by limboy on 12/2/14.
//  Copyright (c) 2014 mogujie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AFNetworking/AFNetworkReachabilityManager.h>

#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#include <ifaddrs.h>
#include <arpa/inet.h>

@interface UIDevice (MGJKit)

+ (NSString *)mgj_deviceName;

/**
 *  蘑菇街设备唯一识别码 iOS 6 及以下用 MAC 地址，iOS 7 以后用 IDFA，IDFA 取不到的情况下使用时间戳（精确到小数点后5位）+ 随机数（0-9999）
 */
+ (NSString *)mgj_uniqueID;

/**
 *  模拟一个device id，方便调试
 */
+ (void)mgj_simulateUniqueIDWithString:(NSString *)fakeUniqueID;

+ (BOOL)mgj_isJailbroken;

/**
 *  当前系统运行的版本，如 7.1
 */
+ (NSString *)mgj_systemVersion;

+ (NSString *)mgj_IDFA;

/**
 *  运营商
 */
+ (NSString *)mgj_cellularProvider;

+ (NSString *)mgj_ipAddress;

+ (AFNetworkReachabilityStatus)mgj_networkStatus;

+ (CGSize)mgj_screenPixelSize;

+ (CGFloat)mgj_availableMemory;

+ (CGFloat)mgj_usedMemory;
@end
