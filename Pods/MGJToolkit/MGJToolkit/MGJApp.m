//
//  MGJApp.m
//  MGJiPhoneSDK
//
//  Created by kunka on 14-6-13.
//  Copyright (c) 2014年 juangua. All rights reserved.
//

#import "MGJApp.h"
#import "MGJMacros.h"
#import "MGJLog.h"

#define kFIRST_INSTALL_SOURCE       @"mgj_first_source"
#define kFIRST_LAUNCH_VERSION       @"mgj_first_launch_version"
#define kDEVICE_TOKEN               @"mgj_devicetoken"
#define kTimeOffset                 @"mgj_init_timeOffset"


static MGJApp *mgjApp = nil;

@interface MGJApp ()<SKStoreProductViewControllerDelegate>
@property(nonatomic, strong) NSString *appName;
@property(nonatomic, strong) NSString *appType;
@property(nonatomic, strong) NSString *appChannel;
@property(nonatomic, strong) NSString *appleId;
@property(nonatomic, assign) BOOL firstLaunchInCurrentVersion;
@end


@implementation MGJApp

+ (MGJApp *)currentApp
{
    return mgjApp;
}

+ (MGJApp *)registerApp:(NSString *)appName type:(NSString *)appType channel:(NSString *)appChannel appleId:(NSString *)appleId
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSParameterAssert(appName);
        NSParameterAssert(appType);
        NSParameterAssert(appChannel);
        NSParameterAssert(appleId);
        
        if (appName && appType && appChannel && appleId) {
            if (!mgjApp) {
                mgjApp = [[MGJApp alloc] init];
                mgjApp.appName = appName;
                mgjApp.appType = appType;
                mgjApp.appChannel = appChannel;
                mgjApp.appleId = appleId;
                [mgjApp recordFirstInstallSource];
                [mgjApp recordFirstLaunch];
                [mgjApp addSkipBackupAttribute];
            }
        }
    });
    return mgjApp;
}

/**
 *  设置useragent
 */
- (void)configUserAgentWithAppName:(NSString *)appName
{
    if (appName) {
        NSString *customUserAgent = [NSString stringWithFormat:@"%@/%@/%ld" , appName, self.appChannel ,(long)self.appVersion];
        
        UIWebView *webView = [[UIWebView alloc] init];
        NSString *defaultUserAgent = [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
        if (!MGJ_IS_EMPTY(defaultUserAgent)) {
            NSString *newUserAgent = [NSString stringWithFormat:@"%@ %@",defaultUserAgent , customUserAgent];
            NSDictionary *dictionnary = [NSDictionary dictionaryWithObjectsAndKeys:newUserAgent , @"UserAgent" , nil];
            [[NSUserDefaults standardUserDefaults] registerDefaults:dictionnary];
        }
    }
}

- (BOOL)addSkipBackupAttribute
{
    NSString *documentDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSURL *URL = [NSURL fileURLWithPath:documentDirectory];
    
    NSError *error = nil;
    BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                                  forKey: NSURLIsExcludedFromBackupKey error: &error];
    if(!success){
        MGJLogDebug(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }
    return success;
}

- (NSData *)deviceToken
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kDEVICE_TOKEN];
}

- (void)setDeviceToken:(NSData *)deviceToken
{
    if (deviceToken) {
        [[NSUserDefaults standardUserDefaults] setObject:deviceToken forKey:kDEVICE_TOKEN];
    }
}

- (void)setServerTime:(NSTimeInterval)serverTime
{
    NSTimeInterval currentInterval = [[NSDate date] timeIntervalSince1970];
    
    currentInterval = floor(currentInterval);
    
    //服务器时间戳减去当前时间戳得到时间offset
    NSTimeInterval timeOffset = serverTime - currentInterval;
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithDouble:timeOffset] forKey:kTimeOffset];
}

- (NSTimeInterval)timeOffset
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:kTimeOffset] doubleValue];
}

- (NSTimeInterval)correctTime
{
    return [[NSDate date] timeIntervalSince1970] + self.timeOffset;
}

- (NSString *)bundleVersionString
{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
}

- (NSInteger)appVersion
{
    return [[[UIApplication mgj_appVersion] stringByReplacingOccurrencesOfString:@"." withString:@""] integerValue];
}


- (void)updateApp
{
    NSString *updateUrl = self.customUpdateUrl;
    if (MGJ_IS_EMPTY(updateUrl)) {
        SKStoreProductViewController *storeVC = [[SKStoreProductViewController alloc] init];
        storeVC.delegate = self;
        [storeVC loadProductWithParameters:@{SKStoreProductParameterITunesItemIdentifier: self.appleId}
                           completionBlock:nil];
        [[[UIApplication sharedApplication].delegate window].rootViewController presentViewController:storeVC
                                                                                             animated:YES
                                                                                           completion:nil];
    }
    else
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:updateUrl]];
    }
}


- (void)rateApp
{
    NSString *rateUrl = self.customRateUrl;
    if (MGJ_IS_EMPTY(rateUrl)) {
        SKStoreProductViewController *storeVC = [[SKStoreProductViewController alloc] init];
        storeVC.delegate = self;
        [storeVC loadProductWithParameters:@{SKStoreProductParameterITunesItemIdentifier: self.appleId}
                           completionBlock:nil];
        [[[UIApplication sharedApplication].delegate window].rootViewController presentViewController:storeVC
                                                                                             animated:YES
                                                                                           completion:nil];
    }
    else
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:rateUrl]];
    }
}


- (BOOL)checkUpdate
{
    return self.needUpdate;
}

- (NSString *)appSource
{
    return [NSString stringWithFormat:@"%@%ld", self.appChannel, (long)self.appVersion];
}

- (NSString *)firstInstallSource
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kFIRST_INSTALL_SOURCE];
}

- (void)recordFirstInstallSource {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *firstSource = [userDefault objectForKey:kFIRST_INSTALL_SOURCE];
    
    if (!firstSource) {
        [userDefault setObject:self.appSource forKey:kFIRST_INSTALL_SOURCE];
    }
}

- (void)recordFirstLaunch {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *firstLauchString = [userDefault objectForKey:kFIRST_LAUNCH_VERSION];
    
    if (!firstLauchString || ![firstLauchString isEqualToString:self.bundleVersionString]) {
        self.firstLaunchInCurrentVersion = YES;
        [userDefault setObject:self.bundleVersionString forKey:kFIRST_LAUNCH_VERSION];
    }
}

- (UIRemoteNotificationType)pushStatus
{
    if (SYSTEM_VERSION_GREATER_THAN(@"8.0")) {
        UIRemoteNotificationType remoteType;
        if ([[UIApplication sharedApplication] isRegisteredForRemoteNotifications]) {
            remoteType = (UIRemoteNotificationType)[[UIApplication sharedApplication] currentUserNotificationSettings].types;
        } else {
            remoteType = (UIRemoteNotificationType)UIUserNotificationTypeNone;
        }
        return remoteType;
    } else {
        return [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
    }
}

#pragma mark - SKStoreProductViewControllerDelegate
- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController
{
    [viewController dismissViewControllerAnimated:YES completion:nil];
}
@end
