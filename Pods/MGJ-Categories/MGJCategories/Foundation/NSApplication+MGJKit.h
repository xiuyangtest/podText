//
//  NSApplication+MGJKit.h
//  Pods
//
//  Created by kongkong on 16/3/24.
//
//

#if TARGET_OS_IOS
#elif TARGET_OS_MAC
#import <Cocoa/Cocoa.h>

@interface NSApplication (MGJKit)

+ (NSString *) mgj_appVersion;
+ (NSString *) mgj_buildVersion;
+ (NSString *) mgj_appStoreVersion;
+ (NSString *) mgj_macDid;
+ (NSString *) mgj_ipAddress;
@end
#endif