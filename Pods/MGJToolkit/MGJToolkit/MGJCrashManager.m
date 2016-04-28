//
//  MGJCrashReporter.m
//  MGJiPhoneSDKDemo
//
//  Created by kunka on 9/12/14.
//  Copyright (c) 2014 juangua. All rights reserved.
//

#import "MGJCrashManager.h"

static NSString * const CRASH_PARAMETER_FILENAME = @"live_report_parameters";
static NSString * const CRASHFILE_SUFFIX = @".mgjcrash";
static NSString * const PARAMETERFILE_SUFFIX = @".parameters";
static NSString * const DETAULT_REQUESTURL = @"https://www.mogujie.com/mobile/crash_log/ios";

static NSInteger const TIMEOFFSET = 3600;

static NSUncaughtExceptionHandler *preHandler = nil;
static NSUncaughtExceptionHandler *plHandler = nil;

/**
 *  记录发生 crash 时的参数
 */
static void recordParameters (){
    
    NSMutableDictionary *parameters = [[MGJCrashManager sharedInstance].customParameters mutableCopy];
    [parameters mgj_setObject:[UIDevice mgj_uniqueID] forKeyIfNotNil:@"did"];
    [parameters mgj_setObject:[UIDevice mgj_isJailbroken] ? @"1" : @"0" forKeyIfNotNil:@"isJailbroken"];
    [parameters mgj_setObject:[NSString stringWithFormat:@"%0.fx%0.f",[UIDevice mgj_screenPixelSize].width, [UIDevice mgj_screenPixelSize].height] forKeyIfNotNil:@"screensize"];
    [parameters mgj_setObject:[UIDevice mgj_cellularProvider] forKeyIfNotNil:@"cellular"];
    [parameters mgj_setObject:[NSString stringWithFormat:@"%d", (int)[UIDevice mgj_networkStatus]] forKeyIfNotNil:@"network"];
    [parameters mgj_setObject:[[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"] forKeyIfNotNil:@"version"];
    
    NSString *filePath = [MGJCrashManager sharedInstance].liveParametersFilePath;
    
    [parameters writeToFile:filePath atomically:YES];
}

/**
 *  uncaughtexceptionhandler
 *
 *  @param exception exception
 */
static void mgj_uncaught_exception_handler (NSException *exception) {
    
    recordParameters();
    
    if (preHandler) {
        preHandler(exception);
    }
    
    if (plHandler) {
        plHandler(exception);
    }
}

static void signalHandler (siginfo_t *info, ucontext_t *uap, void *context){
    recordParameters();
}

@interface MGJCrashManager (){
    PLCrashReporterCallbacks _crashCallbacks;
}

@property (nonatomic, strong) PLCrashReporter *reporter;
@property (nonatomic, strong) NSString *crashReportDirectory;
@property (nonatomic, strong) NSFileManager *fileManager;
@property (nonatomic, strong) AFHTTPRequestOperationManager *httpManager;
@property (nonatomic, strong) NSMutableDictionary *customParameters;
@property (nonatomic, strong) NSString *liveParametersFilePath;
@property (nonatomic, assign) BOOL hasEnableCrashlytics;
@end

@implementation MGJCrashManager

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static MGJCrashManager *reporter = nil;
    dispatch_once(&onceToken, ^{
        reporter = [[MGJCrashManager alloc] init];
    });
    return reporter;
}


- (id)init
{
    self = [super init];
    if (self) {
        
        self.requestURL = DETAULT_REQUESTURL;
        
        self.reporter = [PLCrashReporter sharedReporter];
        
        _crashCallbacks = (PLCrashReporterCallbacks){
            .version = 0,
            .context = NULL,
            .handleSignal = signalHandler
        };
        [self.reporter setCrashCallbacks:&_crashCallbacks];
        
        self.fileManager = [[NSFileManager alloc] init];
        self.httpManager = [[AFHTTPRequestOperationManager alloc] init];
        self.crashReportDirectory = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]  stringByAppendingPathComponent:@"mogujie.crash.data"];
        self.liveParametersFilePath = [self.crashReportDirectory stringByAppendingPathComponent:CRASH_PARAMETER_FILENAME];
        
        self.customParameters = [NSMutableDictionary dictionary];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendCrashReport) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setCustomParameter:(id)object forKey:(NSString *)key
{
    [self.customParameters mgj_setObject:object forKeyIfNotNil:key];
    if (self.hasEnableCrashlytics && object && key) {
        [[Crashlytics sharedInstance] setObjectValue:object forKey:key];
    }
}

- (void)enableCrashReporter
{
    [self enableCrashReporterWithCrashlyticsKey:nil];
}

- (void)enableCrashReporterWithCrashlyticsKey:(NSString *)crashlyticsKey
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (crashlyticsKey) {
            [Crashlytics startWithAPIKey:crashlyticsKey];
            [[Crashlytics sharedInstance] setObjectValue:[UIDevice mgj_uniqueID] forKey:@"did"];
            [[Crashlytics sharedInstance] setObjectValue:[UIDevice mgj_IDFA] forKey:@"idfa"];
            self.hasEnableCrashlytics = YES;
        }
        [self checkDirectory];
        [self handleLastCrash];
        [self setExceptionHandler];
    });
}

- (void)checkDirectory
{
    BOOL isDirectory = NO;
    
    if (![self.fileManager fileExistsAtPath:self.crashReportDirectory isDirectory:&isDirectory]) {
        [self.fileManager createDirectoryAtPath:self.crashReportDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

- (void)setExceptionHandler
{
    //存下前一个handler
    preHandler = NSGetUncaughtExceptionHandler();
    
    //设置 plcrashreporter 的 handler
    [self.reporter enableCrashReporter];
    
    //存下 plcrashreporter 的 handler
    plHandler = NSGetUncaughtExceptionHandler();
    
    //设置自己的 handler
    NSSetUncaughtExceptionHandler(&mgj_uncaught_exception_handler);
}

- (void)handleLastCrash
{
    NSData *crashData = [[NSData alloc] initWithData:[self.reporter loadPendingCrashReportData]];
    if (crashData) {
        PLCrashReport *report = [[PLCrashReport alloc] initWithData:crashData error:nil];
        if (report) {
            NSString *crashPath = [self crashReportDirectory];
            
            BOOL isDirectory = NO;
            
            if (![self.fileManager fileExistsAtPath:crashPath isDirectory:&isDirectory]) {
                return;
            }
            
            //写 crash 文件
            NSString *crashCacheFileName = [NSString stringWithFormat: @"%.0f%@",[NSDate timeIntervalSinceReferenceDate],CRASHFILE_SUFFIX];
            [crashData writeToFile:[crashPath stringByAppendingPathComponent:crashCacheFileName] atomically:YES];
            
            //写参数文件
            NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithContentsOfFile:self.liveParametersFilePath];
            if (parameters) {
                NSString *parameterFileName = [NSString stringWithFormat: @"%@%@", crashCacheFileName,PARAMETERFILE_SUFFIX];
                [parameters writeToFile:[crashPath stringByAppendingPathComponent:parameterFileName] atomically:YES];
                [self.fileManager removeItemAtPath:self.liveParametersFilePath error:nil];
            }
            
        }
    }
    [self.reporter purgePendingCrashReport];

}

- (void)sendCrashReport
{
    static NSInteger lastTimeInterval = 0;
    
    if ([[NSDate date] timeIntervalSince1970] - lastTimeInterval <= TIMEOFFSET) {
        return;
    }
    lastTimeInterval = [[NSDate date] timeIntervalSince1970];
    
    if ([self.fileManager fileExistsAtPath:[self crashReportDirectory]]) {
        NSString *file = nil;
        NSError *error = NULL;
        
        NSDirectoryEnumerator *dirEnum = [self.fileManager enumeratorAtPath: [self crashReportDirectory]];
        
        NSMutableArray *fileArray = [NSMutableArray array];
        
        while ((file = [dirEnum nextObject])) {
            NSDictionary *fileAttributes = [self.fileManager attributesOfItemAtPath:[self.crashReportDirectory stringByAppendingPathComponent:file] error:&error];
            if ([[fileAttributes objectForKey:NSFileSize] intValue] > 0 &&
                [file hasSuffix:CRASHFILE_SUFFIX] ) {
                [fileArray addObject:file];
            }
        }
        
        for (NSString *fileName in fileArray) {
            
            NSString *filePath = [self.crashReportDirectory stringByAppendingPathComponent:fileName];
            
            NSString *parameterPath = [filePath stringByAppendingString:PARAMETERFILE_SUFFIX];
            
            NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithContentsOfFile:parameterPath];
            
            if (!parameters) {
                parameters = [NSMutableDictionary dictionary];
            }
            [parameters mgj_setObject:[[[NSBundle mainBundle] bundleIdentifier] mgj_md5HashString] forKeyIfNotNil:@"token"];
            
            NSData *crashData = [NSData dataWithContentsOfFile:filePath];
            
            [self.httpManager POST:self.requestURL parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                [formData appendPartWithFileData:crashData name:@"data" fileName:@"data.crash" mimeType:@"text/plain"];
            } success:^(AFHTTPRequestOperation *operation, id responseObject) {
                [self.fileManager removeItemAtPath:filePath error:nil];
                [self.fileManager removeItemAtPath:parameterPath error:nil];
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                
            }];
        }

    }
}

- (void)setChannel:(NSString *)channel
{
    if (channel) {
        [[Crashlytics sharedInstance] setObjectValue:channel forKey:@"channel"];
        [self.customParameters setObject:channel forKey:@"channel"];
    }
}

- (void)setUserId:(NSString *)uid
{
    if (uid) {
        [[Crashlytics sharedInstance] setUserIdentifier:uid];
        [self.customParameters setObject:uid forKey:@"uid"];
    }
}

- (void)setUserName:(NSString *)uname
{
    if (uname) {
       [[Crashlytics sharedInstance] setUserName:uname];
        [self.customParameters setObject:uname forKey:@"uname"];
    }
}

- (void)crash
{
    [[NSArray array] objectAtIndex:1];
}

- (void)signal
{
#ifndef __clang_analyzer__
    int *a;
    *a = 0;
#endif
}

@end
