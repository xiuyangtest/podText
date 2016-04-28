//
//  UIApplication+AppVersion.h
//  MGJAnalytics
//
//  Created by limboy on 12/2/14.
//  Copyright (c) 2014 mogujie. All rights reserved.
//

#if TARGET_OS_IOS
#import <UIKit/UIKit.h>

@interface UIApplication (MGJKit)

+ (NSString *) mgj_appVersion;
+ (NSString *) mgj_buildVersion;
+ (NSString *) mgj_appStoreVersion;
@end
#endif