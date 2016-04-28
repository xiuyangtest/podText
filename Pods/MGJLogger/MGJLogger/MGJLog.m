//
//  MGJLog.m
//  MGJFoundation
//
//  Created by yongtai on 4/16/15.
//  Copyright (c) 2014 juangua. All rights reserved.
//

#import "MGJLog.h"
#include <asl.h>

@interface DDFileLoggerFormatter : NSObject <DDLogFormatter>
@property (nonatomic) NSDateFormatter *dateFormatter;
@end

@implementation DDFileLoggerFormatter

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.dateFormatter = [[NSDateFormatter alloc] init];
        [self.dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss:SSS"];
    }
    return self;
}

- (NSString *)formatLogMessage:(DDLogMessage *)logMessage
{
    NSString *logLevel = @"Verbose";
    switch (logMessage.flag) {
        case DDLogFlagError:
            logLevel = @"Error";
            break;
        case DDLogFlagWarning:
            logLevel = @"Warning";
            break;
        case DDLogFlagInfo:
            logLevel = @"Info";
            break;
        case DDLogFlagDebug:
            logLevel = @"Debug";
        default:
            break;
    }
    
    NSString *dateAndTime = [self.dateFormatter stringFromDate:(logMessage.timestamp)];
    return [NSString stringWithFormat:@"<%@> %@ %@%ld %@", logLevel, dateAndTime, logMessage.function, (long)logMessage.line, logMessage.message];
}

@end


@interface DDTTYLoggerFormatter : NSObject <DDLogFormatter>

@end

@implementation DDTTYLoggerFormatter

- (NSString *)formatLogMessage:(DDLogMessage *)logMessage
{
    NSString *logLevel = @"Verbose";
    switch (logMessage.flag) {
        case DDLogFlagError:
            logLevel = @"Error";
            break;
        case DDLogFlagWarning:
            logLevel = @"Warning";
            break;
        case DDLogFlagInfo:
            logLevel = @"Info";
            break;
        case DDLogFlagDebug:
            logLevel = @"Debug";
        default:
            break;
    }
    
    return [NSString stringWithFormat:@"<%@> %@%ld %@", logLevel, logMessage.function, (long)logMessage.line, logMessage.message];
}

@end

static void AddLoggerOnce()
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
#ifdef DEBUG
        [DDLog addLogger:[DDTTYLogger sharedInstance]];
        [DDTTYLogger sharedInstance].logFormatter = [[DDTTYLoggerFormatter alloc] init];
#endif
        
        DDFileLogger *fileLogger = [[DDFileLogger alloc] init];
        fileLogger.maximumFileSize = 1024 * 1024;
        fileLogger.logFileManager.maximumNumberOfLogFiles = 5;
        fileLogger.logFormatter = [[DDFileLoggerFormatter alloc] init];
        [DDLog addLogger:fileLogger withLevel:DDLogLevelWarning];
    });
}

@implementation MGJLogger

+ (void)load
{
    AddLoggerOnce();
}

+ (void)enableASL
{
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDASLLogger sharedInstance].logFormatter = [[DDTTYLoggerFormatter alloc] init];
}

+ (void)disableASL
{
    [DDLog removeLogger:[DDASLLogger sharedInstance]];
}

@end
