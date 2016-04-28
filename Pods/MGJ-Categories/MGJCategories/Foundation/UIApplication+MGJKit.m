//
//  UIApplication+AppVersion.m
//  MGJAnalytics
//
//  Created by limboy on 12/2/14.
//  Copyright (c) 2014 mogujie. All rights reserved.
//

#if TARGET_OS_IOS
#import "UIApplication+MGJKit.h"

@implementation UIApplication (MGJKit)

+ (NSString *)mgj_appVersion
{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
}

+ (NSString *)mgj_buildVersion
{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey: (NSString *)kCFBundleVersionKey];
}

+ (NSString *)mgj_appStoreVersion
{
    return [NSString stringWithFormat:@"%@.%@", [self mgj_appVersion], [self mgj_buildVersion]];
}
@end
#endif