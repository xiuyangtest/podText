//
//  MGJLog.h
//  MGJFoundation
//
//  Created by yongtai on 4/16/15.
//  Copyright (c) 2014 juangua. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CocoaLumberjack/CocoaLumberjack.h>

@interface MGJLogger : NSObject
+ (void)enableASL;
+ (void)disableASL;
@end

// 临时去掉，打包时出现莫名错误，会再加回来

#define MGJLog(frmt, ...) LOG_MAYBE(LOG_ASYNC_ENABLED, LOG_LEVEL_DEF, DDLogFlagDebug,   0, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define MGJLogDebug(frmt, ...) LOG_MAYBE(LOG_ASYNC_ENABLED, LOG_LEVEL_DEF, DDLogFlagDebug,   0, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define MGJLogInfo(frmt, ...) LOG_MAYBE(LOG_ASYNC_ENABLED, LOG_LEVEL_DEF, DDLogFlagInfo,   0, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define MGJLogWarning(frmt, ...) LOG_MAYBE(LOG_ASYNC_ENABLED, LOG_LEVEL_DEF, DDLogFlagWarning,   0, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define MGJLogError(frmt, ...) LOG_MAYBE(LOG_ASYNC_ENABLED, LOG_LEVEL_DEF, DDLogFlagError,   0, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define MGJLogAlert(frmt, ...) LOG_MAYBE(LOG_ASYNC_ENABLED, LOG_LEVEL_DEF, DDLogFlagError,   0, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)