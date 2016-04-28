//
//  MGJAnalytics.m
//  MGJAnalytics
//
//  Created by limboy on 12/1/14.
//  Copyright (c) 2014 mogujie. All rights reserved.
//

#import "MGJAnalytics.h"
#import "MGJBatchRequesterStore.h"

#import <AFNetworking/AFNetworking.h>
#import <MGJFoundation.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import <MGJLog.h>
#import "UIDevice+MGJKit.h"
#import "UIApplication+MGJKit.h"
#import "NSString+MGJKit.h"
#import "MGJPTP.h"
#import <MGJFoundation/NSMutableDictionary+MGJKit.h>
#import <UIDevice+MGJKit.h>
#import <UrlEntity.h>
#import "MGJStorageService.h"

@implementation MGJPerformanceParameters
@end

@implementation MGJSocketPerformanceParameters
@end

/**
 *  需要记录的事件类型
 */
typedef NS_ENUM(NSInteger, MGJAnalyticsEventType){
    MGJAnalyticsEventTypeSocket = 's',
    MGJAnalyticsEventTypePage = 'p',
    MGJAnalyticsEventTypeEvent = 'e',
    MGJAnalyticsEventTypeNetwork = 'n',
    MGJAnalyticsEventTypeDevice = 'd',
};



/**
 *  支持的集中系统事件类型
 */
typedef NS_ENUM(NSInteger, MGJAnalyticsSystemEventType){
    /**
     *  系统启动
     */
    MGJAnalyticsSystemEventTypeStart = 's',
    /**
     *  系统进入后台
     */
    MGJAnalyticsSystemEventTypeBackground = 'b',
    /**
     *  系统进入前台
     */
    MGJAnalyticsSystemEventTypeForeground = 'f',
    /**
     *  系统将要被干死
     */
    MGJAnalyticsSystemEventTypeTerminate = 'q',
};

NSString * const MGJAnalyticsServerBaseURL = @"http://log.juangua.com/";
NSString * const MGJAnalyticsLogPrefix = @"Analytics";
NSInteger const MGJAnalyticsRefererCountToSend = 5;

/**
 *  用来标识是否已用正确的方式启动 (startWithAppName:channel:)
 */
static BOOL hasStarted;
static BOOL enableTrackingSocketPerformance = YES;

@interface MGJAnalytics () <MGJPTPDelegate>
@property (nonatomic, assign) MGJAnalyticsAppName appName;
@property (nonatomic, copy) NSString *channel;
@property (nonatomic) NSString *version;

@property (nonatomic, strong) NSMutableDictionary* timeConsumptions;
/**
 *  记录启动时间戳
 */
@property (nonatomic, assign) NSInteger launchTimestamp;

/**
 *  当文本文件的尺寸超过该大小 (Byte) 时，发送内容，默认为 1K, 对 Page / Event / Network 同时有效
 *  可以在 DataSource 中被重新设置
 */
@property (nonatomic, assign) float fileSizeThreshold;

/**
 *  每隔多长时间发送，这个跟 fileSizeThreshold 只要满足其中一个就会触发，默认为 10 秒
 *  可以在 DataSource 中被重新设置
 */
@property (nonatomic, assign) NSTimeInterval timeIntervalThreshold;

/**
 *  用户ID
 *  可以在 DataSource 中被重新设置
 */
@property (nonatomic, copy) NSString *userID;

/**
 *  本地时间与服务器传回来的时间的差值
 *  可以在 DataSource 中被重新设置
 */
@property (nonatomic, assign) double timeOffsetBetweenServerAndLocal;

@property (nonatomic) MGJBatchRequesterStore *eventPageStore;
@property (nonatomic) MGJBatchRequesterStore *networkStore;
@property (nonatomic) MGJBatchRequesterStore *deviceStore;
@property (nonatomic) AFHTTPRequestOperationManager *httpManager;
@property (nonatomic) NSOperationQueue *operationQueue;
@end

@implementation MGJAnalytics

#pragma mark - Public

- (instancetype)init
{
    self = [super init];
    if (self) {
        _ptpRef = @"";
        _ptpCnt = @"";
        _ptpURL = @"";
        [MGJPTP setDelegate:self];
        _operationQueue = [[NSOperationQueue alloc] init];
        _operationQueue.maxConcurrentOperationCount = 1;
        _refererArray = [NSMutableArray arrayWithObjects:@"", @"", @"", @"", @"", nil];
    }
    return self;
}

+ (instancetype)sharedInstance
{
    NSAssert(hasStarted, @"亲，先调用 startWithAppName:channel:version: 方法哦");
    
    static MGJAnalytics *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

+ (void)enableTrackingSocketPerformance:(BOOL)enabled
{
    enableTrackingSocketPerformance = enabled;
}

+ (void)startWithAppName:(MGJAnalyticsAppName)appName channel:(NSString *)channel version:(NSInteger)version
{
    return [self startWithAppName:appName channel:channel];
}

+ (void)startWithAppName:(MGJAnalyticsAppName)appName channel:(NSString *)channel
{
    NSAssert(!hasStarted, @"亲，不要多次调用此方法哦");
    hasStarted = YES;
    
    MGJAnalytics *analytics = [self sharedInstance];
    analytics.appName = appName;
    analytics.channel = channel;
    analytics.version = [UIApplication mgj_appStoreVersion];
    analytics.launchTimestamp = (NSInteger)[[NSDate date] timeIntervalSince1970];
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    
    [analytics performSelector:@selector(trackDeviceLaunch) withObject:nil afterDelay:3];
}

+ (void)trackTimeExpend:(void (^)())block event:(NSString *)event timeKey:(NSString *)key parameters:(NSDictionary *)parameters
{
    CFTimeInterval begin = CFAbsoluteTimeGetCurrent();
    if (block) {
        block();
    }
    CFTimeInterval end = CFAbsoluteTimeGetCurrent();
    NSInteger duration = (end - begin) * 1000;
    
    NSMutableDictionary *mutableParameters = [[NSMutableDictionary alloc] initWithDictionary:parameters];
    [mutableParameters mgj_setObject:@(duration) forKeyIfNotNil:key ? : @"time"];
    [self trackEvent:event parameters:mutableParameters];
}

+ (void)trackEvent:(NSString *)event parameters:(NSDictionary *)parameters
{
    MGJLog(@"[event]:%@ parameters:%@", event, parameters);
    NSInteger currentTimestamp = (NSInteger)[[NSDate date] timeIntervalSince1970];
    NSMutableDictionary *extraInfomation = [[NSMutableDictionary alloc] initWithObjectsAndKeys:event ? : @"", @"eventid", nil];
    [extraInfomation addEntriesFromDictionary:parameters];
    
    MGJAnalytics *instance = [MGJAnalytics sharedInstance];
    
    NSMutableDictionary *mutableParameters = [[NSMutableDictionary alloc] initWithDictionary:extraInfomation];
    
    // parameters 里的优先
    mutableParameters[@"ptp_url"] = parameters[@"ptp_url"] ? : ([MGJAnalytics sharedInstance].ptpURL ? : @"");
    mutableParameters[@"ptp_cnt"] = parameters[@"ptp_cnt"] ? : ([MGJAnalytics sharedInstance].ptpCnt ? : @"");
    mutableParameters[@"ptp_ref"] = parameters[@"ptp_ref"] ? : ([MGJAnalytics sharedInstance].ptpRef ? : @"");
    MGJLog(@"PTPEvent:%@", mutableParameters);
    
    mutableParameters[@"ver"] = [MGJAnalytics sharedInstance].version;
    
    NSArray *eventArray = @[
                            @(instance.appName), // App编号
                            [NSString mgj_convertToStringWithChar:MGJAnalyticsEventTypeEvent], // 事件类型
                            [UIDevice mgj_uniqueID], // did
                            @(instance.launchTimestamp), // 启动时间戳
                            instance.userID, // 用户ID
                            instance.refererURL, // referer
                            instance.currentURL, // url
                            @(currentTimestamp), // 当前时间戳
                            @(currentTimestamp + instance.timeOffsetBetweenServerAndLocal), // 修正时间戳
                            [instance generateJSONStringFromDictionary:mutableParameters], // extra
                            ];
    [instance appendDataArray:eventArray withEventType:MGJAnalyticsEventTypeEvent];
    
    [self checkIfShouldSendToTestURLWithData:eventArray];
}

+ (void)checkIfShouldSendToTestURLWithData:(NSArray *)dataArray
{
    NSString *url = [MGJStorageService objectFromMemoryForKey:@"test_log_url"];
    if (url) {
        NSString *separator = @"\t";
        NSString *data = [dataArray componentsJoinedByString:separator];
        
        [[MGJAnalytics sharedInstance].httpManager POST:url parameters:@{@"v": @2, @"data": data} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        }];
    }
}

+ (void)trackPageWithRequestURL:(NSString *)requestURL parameters:(NSDictionary *)parameters
{
    MGJLog(@"[page]:%@ parameters:%@", requestURL, parameters);
    NSMutableDictionary *mutableParameters = [[NSMutableDictionary alloc] initWithDictionary:parameters];
    
    // 避免 parameters 的 value 里出现无法 json 化的 object，导致 crash
    [parameters enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id<NSObject>  _Nonnull obj, BOOL * _Nonnull stop) {
        if (![obj isKindOfClass:[NSString class]]) {
            mutableParameters[key] = [obj description];
        }
    }];
    
    mutableParameters[@"ptp_url"] = [MGJAnalytics sharedInstance].ptpURL ? : @"";
    mutableParameters[@"ptp_cnt"] = [MGJPTP generatePageTemplateWithRequestURL:requestURL] ? : @"";
    [MGJAnalytics sharedInstance].ptpCnt = mutableParameters[@"ptp_cnt"];
    mutableParameters[@"ptp_ref"] = [MGJAnalytics sharedInstance].ptpRef ? : @"";
    if ([MGJAnalytics sharedInstance].ptpFrom.length) {
        mutableParameters[@"ptp_from"] = [MGJAnalytics sharedInstance].ptpFrom;
        [MGJAnalytics sharedInstance].ptpFrom = @"";
    }
    MGJLog(@"PTPPage:%@", mutableParameters);

    mutableParameters[@"ver"] = [MGJAnalytics sharedInstance].version;
   
    //只发送最近 5 个 referer, 不足 5 个用 @"" 补齐
    if ([MGJAnalytics sharedInstance].sendRefererURLChain && [MGJAnalytics sharedInstance].refererArray.count > 0) {
        NSInteger refererCount = MIN([MGJAnalytics sharedInstance].refererArray.count, MGJAnalyticsRefererCountToSend);
        mutableParameters[@"refs"] = [[MGJAnalytics sharedInstance].refererArray subarrayWithRange:NSMakeRange([MGJAnalytics sharedInstance].refererArray.count - refererCount, refererCount)];
    }
    
    [self trackPTPWithParameters:mutableParameters requestURL:requestURL];
}

+ (void)trackPTPURL:(NSString *)ptpURL andPTPCnt:(NSString *)ptpCnt
{
    ptpURL = ptpURL ? : @"";
    ptpCnt = ptpCnt ? : @"";
    NSMutableArray *ptpURLComponents = [NSMutableArray arrayWithArray:[ptpURL componentsSeparatedByString:@"."]];
    NSMutableArray *ptpCntComponents = [NSMutableArray arrayWithArray:[ptpCnt componentsSeparatedByString:@"."]];
    MGJAnalytics *instance = [MGJAnalytics sharedInstance];
    
    if (ptpURLComponents.count >= 5 && [ptpURLComponents[4] isEqualToString:@"0"]) {
        if ([ptpURLComponents[0] isEqualToString:@"0"]) {
            ptpURLComponents[0] = @(instance.appName);
        }
        if ([ptpURLComponents[1] isEqualToString:@"0"]) {
            NSArray *currentPTPURLComponents = [instance.ptpURL componentsSeparatedByString:@"."];
            if (currentPTPURLComponents.count >= 2) {
                ptpURLComponents[1] = currentPTPURLComponents[1];
            }
        }
        if ([ptpURLComponents[4] isEqualToString:@"0"]) {
            NSArray *currentPTPCntComponents = [instance.ptpCnt componentsSeparatedByString:@"."];
            if (currentPTPCntComponents.count >= 5) {
                ptpURLComponents[4] = currentPTPCntComponents[4];
            }
        }
        
        ptpURL = [ptpURLComponents componentsJoinedByString:@"."];
    }
    
    if (ptpCntComponents.count >= 5 && [ptpCntComponents[4] isEqualToString:@"0"]) {
        if ([ptpCntComponents[0] isEqualToString:@"0"]) {
            ptpCntComponents[0] = @(instance.appName);
        }
        if ([ptpCntComponents[4] isEqualToString:@"0"]) {
            ptpCntComponents[4] = [MGJPTP verifyCode];
        }
        
        ptpCnt = [ptpCntComponents componentsJoinedByString:@"."];
    }
    
    [MGJAnalytics sharedInstance].ptpURL = ptpURL;
    [MGJAnalytics sharedInstance].ptpCnt = ptpCnt;
    [MGJAnalytics sharedInstance].ptpRef = ptpURL ? : @"";
}

+ (void)trackPTPWithParameters:(NSMutableDictionary *)parameters requestURL:(NSString *)requestURL
{
    NSInteger currentTimestamp = (NSInteger)[[NSDate date] timeIntervalSince1970];
    
    MGJAnalytics *instance = [MGJAnalytics sharedInstance];
    NSArray *pageArray = @[
                           @(instance.appName), // App编号
                           [NSString mgj_convertToStringWithChar:MGJAnalyticsEventTypePage], // 事件类型
                           [UIDevice mgj_uniqueID], // did
                           @(instance.launchTimestamp), // 启动时间戳
                           instance.userID, // 用户ID
                           instance.refererURL, // referer
                           requestURL ? : @"", // url
                           @(currentTimestamp), // 当前时间戳
                           @(currentTimestamp + instance.timeOffsetBetweenServerAndLocal), // 修正时间戳
                           [instance generateJSONStringFromDictionary:parameters], // extra
                           ];
    [instance appendDataArray:pageArray withEventType:MGJAnalyticsEventTypePage];
    
    [self checkIfShouldSendToTestURLWithData:pageArray];
}

+ (void)trackNetworkPerformanceWithHandler:(MGJPerformanceParametersHandler)handler
{
    MGJPerformanceParameters *performanceParameters = [[MGJPerformanceParameters alloc] init];
    handler(performanceParameters);
    
    MGJAnalytics *instance = [MGJAnalytics sharedInstance];
    
    NSInteger currentTimestamp = (NSInteger)[[NSDate date] timeIntervalSince1970];
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
    mutableParameters[@"ver"] = [MGJAnalytics sharedInstance].version;
    mutableParameters[@"network"] = @([instance networkStatus]);
    
    // 只记录 0 和 4xx/5xx 情况
    if (performanceParameters.statusCode == 0 ||
        (performanceParameters.statusCode >= 400 && performanceParameters.statusCode < 600)) {
        mutableParameters[@"ip"] = performanceParameters.ip ? : @"";
        mutableParameters[@"host"] = performanceParameters.host ? : @"";
        mutableParameters[@"zServer"] = performanceParameters.zServer ? : @"";
        mutableParameters[@"zProxy"] = performanceParameters.zProxy ? : @"";
        mutableParameters[@"server"] = performanceParameters.server ? : @"";
        mutableParameters[@"backend"] = performanceParameters.backend ? : @"";
    }
    
    MGJLog(@"networkParameters:%@", mutableParameters);
    
    NSArray *performanceArray = @[
                                  @(instance.appName), // App编号
                                  [NSString mgj_convertToStringWithChar:MGJAnalyticsEventTypeNetwork], // 事件类型
                                  [UIDevice mgj_uniqueID], // did
                                  @(instance.launchTimestamp), // 启动时间戳
                                  performanceParameters.requestPath ? : @"", // 请求URL
                                  @(performanceParameters.statusCode), // 状态码
                                  @(performanceParameters.requestTime), // 响应时间
                                  @(currentTimestamp), // 当前时间戳
                                  @(currentTimestamp + instance.timeOffsetBetweenServerAndLocal), // 修正时间戳
                                  @(performanceParameters.requestSize), // 请求 Size
                                  @(performanceParameters.responsSize), // 返回 Size
                                  @(performanceParameters.resultCode), // 业务码
                                  [instance generateJSONStringFromDictionary:mutableParameters], // extra
                                  ];
    [instance appendDataArray:performanceArray withEventType:MGJAnalyticsEventTypeNetwork];
}

+ (void)trackSocketPerformanceWithParameters:(MGJSocketPerformanceParameters *)parameters
{
    if (!enableTrackingSocketPerformance) {
        return;
    }
    
    MGJAnalytics *instance = [MGJAnalytics sharedInstance];
    
    NSInteger currentTimestamp = (NSInteger)[[NSDate date] timeIntervalSince1970];
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
    mutableParameters[@"ver"] = [MGJAnalytics sharedInstance].version;
    mutableParameters[@"network"] = @([instance networkStatus]);
    mutableParameters[@"serverip"] = parameters.ip;
    mutableParameters[@"apiver"] = parameters.apiver;
    mutableParameters[@"port"] = @(parameters.port);
    
    NSString *requestPath = parameters.sid ? : @"";
    
    if (parameters.cid) {
        requestPath = [requestPath stringByAppendingFormat:@"/%@",parameters.cid];
    }
    
    NSArray *performanceArray = @[
                                  @(instance.appName), // App编号
                                  [NSString mgj_convertToStringWithChar:MGJAnalyticsEventTypeSocket], // 事件类型
                                  [UIDevice mgj_uniqueID], // did
                                  @(instance.launchTimestamp), // 启动时间戳
                                  requestPath, //
                                  @(parameters.statusCode), // 状态码
                                  @(parameters.requestTime), // 响应时间
                                  @(currentTimestamp), // 当前时间戳
                                  @(currentTimestamp + instance.timeOffsetBetweenServerAndLocal), // 修正时间戳
                                  @(parameters.requestSize), // 请求 Size
                                  @(parameters.responseSize), // 返回 Size
                                  @(parameters.resultCode), // 业务码
                                  [instance generateJSONStringFromDictionary:mutableParameters], // extra
                                  ];
    [instance appendDataArray:performanceArray withEventType:MGJAnalyticsEventTypeNetwork];
}

+ (void)startTrackTimeConsumptionWithEvent:(NSString *)event{
    @synchronized(self){
        CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
        NSString* key = [MGJAnalytics getTimeConsumptionKeyWithEvent:event];
        [[MGJAnalytics sharedInstance].timeConsumptions setObject:[NSNumber numberWithDouble:startTime] forKey:key];
    }
}

+ (void)stopTrackTimeConsumptionWithEvent:(NSString *)event parameters:(NSDictionary *)parameters{
    @synchronized(self){
        CFAbsoluteTime stopTime = CFAbsoluteTimeGetCurrent();
        NSString* key = [MGJAnalytics getTimeConsumptionKeyWithEvent:event];
        
        CFAbsoluteTime startTime = [[[MGJAnalytics sharedInstance].timeConsumptions objectForKey:key] doubleValue];
        
        if (0 != startTime) {
            NSInteger diffTime = (NSInteger)((stopTime - startTime) * 1000);
            //发送事件
            NSMutableDictionary* param = [[NSMutableDictionary alloc] initWithDictionary:parameters];
            [param setObject:[NSNumber numberWithInteger:diffTime] forKey:@"time"];
            
            [MGJAnalytics trackEvent:event parameters:param];
            
            //移除这个key
            [[MGJAnalytics sharedInstance].timeConsumptions removeObjectForKey:key];
        }
    }
}

//保证返回的Key不为空
+(NSString*)getTimeConsumptionKeyWithEvent:(NSString*)event{
    return [NSString stringWithFormat:@"timeConsumption_%@",event];
}

+ (MGJAnalyticsNetworkStatus)networkStatus
{
    return [MGJAnalytics sharedInstance].networkStatus;
}

/**
 *  当设备启动时发送事件，包括从后台进到前台
 */
- (void)trackDeviceLaunch
{
    NSArray *launchArray = @[
                             @(self.appName), // App编号
                             self.channel, // 渠道
                             [MGJAnalytics sharedInstance].version, // app version
                             [UIDevice mgj_uniqueID], // did
                             [UIDevice mgj_deviceName], // 设备名称
                             [UIDevice mgj_systemVersion], // 操作系统版本
                             @([UIDevice mgj_isJailbroken]), // 是否越狱
                             [NSString stringWithFormat:@"%ld*%ld", (long)[UIDevice mgj_screenPixelSize].height, (long)[UIDevice mgj_screenPixelSize].width],
                             [UIDevice mgj_cellularProvider], // 运营商
                             @([self networkStatus]), // 联网方式
                             [UIDevice mgj_ipAddress], // ip 地址
                             @(self.launchTimestamp), // 启动时间戳
                             [[MGJAnalytics sharedInstance] generateJSONStringFromDictionary:nil], // extra
                             ];
    [self appendDataArray:launchArray withEventType:MGJAnalyticsEventTypeDevice];
}

#pragma mark - MGJPTPDelegate

- (void)didGeneratedPTP:(NSString *)ptp
{
    if (self.ptpCnt.length > 0 && ptp.length > 0) {
        // 把 cnt 最后的字段给 url
        // 通常用在页面跳转的 event 上
        NSString *cntLastComponent = [[self.ptpCnt componentsSeparatedByString:@"."] lastObject];
        NSMutableArray *ptpSections = [NSMutableArray arrayWithArray:[ptp componentsSeparatedByString:@"."]];
        [ptpSections removeLastObject];
        [ptpSections addObject:cntLastComponent];
        ptp = [ptpSections componentsJoinedByString:@"."];
    }
    [MGJAnalytics sharedInstance].ptpURL = ptp;
}

#pragma mark - Utils

- (NSString *)ptpCntWithPageRequestURL:(NSString *)pageRequestURL
{
    return [MGJPTP generatePageTemplateWithRequestURL:pageRequestURL];
}

- (NSString *)generateJSONStringFromDictionary:(NSDictionary *)object
{
    // 用于跟踪客户端发送的数据是否成功发送到服务端
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger snum = [defaults integerForKey:@"snum"];
    NSDictionary *autoIncrement = @{@"snum": @(snum++)};
    [defaults setInteger:snum forKey:@"snum"];
    
    if (!object) {
        object = @{};
    }
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:object];
    [dictionary addEntriesFromDictionary:autoIncrement];
    
    if (![NSJSONSerialization isValidJSONObject:dictionary]) {
        return @"{}";
    }
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&error];
    NSString *jsonString = error ? @"{}" : [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    if (error && self.enableDebug) {
        NSLog(@"%@ parse object (%@) to JSON failed", MGJAnalyticsLogPrefix, object);
    }
    return [jsonString stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
}

- (MGJAnalyticsNetworkStatus)networkStatus
{
    MGJAnalyticsNetworkStatus result = MGJAnalyticsNetworkStatusUnknown;
    if ([[AFNetworkReachabilityManager sharedManager] isReachableViaWiFi]) {
        result = MGJAnalyticsNetworkStatusWiFi;
    }else if([[AFNetworkReachabilityManager sharedManager] isReachable]){
        if ([[UIDevice mgj_systemVersion] floatValue] >= 7) {
            CTTelephonyNetworkInfo *networkInfo = [CTTelephonyNetworkInfo new];
            NSString *radioType = networkInfo.currentRadioAccessTechnology;
            if ([radioType isEqualToString:CTRadioAccessTechnologyGPRS] || [radioType isEqualToString:CTRadioAccessTechnologyEdge] || [radioType isEqualToString:CTRadioAccessTechnologyCDMA1x]) {
                result = MGJAnalyticsNetworkStatus2G;
            }
            else if ( [radioType isEqualToString:CTRadioAccessTechnologyWCDMA] || [radioType isEqualToString:CTRadioAccessTechnologyHSDPA] ||[radioType isEqualToString:CTRadioAccessTechnologyHSUPA] ||[radioType isEqualToString:CTRadioAccessTechnologyCDMAEVDORev0] ||[radioType isEqualToString:CTRadioAccessTechnologyCDMAEVDORevA] ||[radioType isEqualToString:CTRadioAccessTechnologyCDMAEVDORevB] ||[radioType isEqualToString:CTRadioAccessTechnologyeHRPD]) {
                result = MGJAnalyticsNetworkStatus3G;
            }
            else if ([radioType isEqualToString:CTRadioAccessTechnologyLTE])
            {
                result = MGJAnalyticsNetworkStatus4G;
            }
        }
        else {
            result = MGJAnalyticsNetworkStatusWWAN;
        }
    }
    return result;
}

/**
 *  查看 Store 是否已经处于可以发送状态，如果可以的话，将已经存储的内容发送到服务端
 *
 *  @param store     对应的 store instance
 *  @param eventType 对应的 event type
 */
- (void)sendDataIfNeededWithStore:(MGJBatchRequesterStore *)store eventType:(MGJAnalyticsEventType)eventType
{
    if (store.timeIntervalSinceCreated > self.timeIntervalThreshold || store.fileSize > self.fileSizeThreshold) {
        __weak typeof(self) weakSelf = self;
        
        [store consumeDataWithHandler:^(NSString *content, MGJBatchRequesterStoreConsumeSuccessBlock successBlock, MGJBatchRequesterStoreConsumeFailureBlock failureBlock) {
            
            // 对拿到的content先做一层判断
            if (content) {
                NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
                parameters[@"v"] = @3;
                NSString *propertyName = [self propertyNameWithEventType:eventType];
                parameters[propertyName] = content;
                
                [weakSelf.httpManager POST:@"mlogs.php" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    successBlock();
                    if (weakSelf.enableDebug) {
                        NSLog(@"%@ request sent succsessful with content: %@", MGJAnalyticsLogPrefix, content);
                    }
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    failureBlock();
                    if (weakSelf.enableDebug) {
                        NSLog(@"%@ request sent failed with error:%@ content: %@", MGJAnalyticsLogPrefix, error, content);
                    }
                }];
            }
        }];
    }
}

/**
 *  根据 eventType 向特定的 Store Append 数据，同时检查是否可以发送
 *
 *  @param data      要添加到 Store 的数据
 *  @param eventType 事件类型
 */
- (void)appendDataArray:(NSArray *)dataArray withEventType:(MGJAnalyticsEventType)eventType
{
    __weak typeof(self) wself = self;
    
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        NSString *separator = eventType == MGJAnalyticsEventTypeDevice ? @"|" : @"\t";
        NSString *dataString = [dataArray componentsJoinedByString:separator];
        dataString = [NSString stringWithFormat:@"%@\n", dataString];
        
        if (wself.enableDebug) {
            NSLog(@"%@ event:%@, data:%@", MGJAnalyticsLogPrefix, [NSString mgj_convertToStringWithChar:eventType], dataString);
        }
        
        MGJBatchRequesterStore *store;
        switch (eventType) {
            case MGJAnalyticsEventTypeNetwork:
                store = wself.networkStore;
                break;
            case MGJAnalyticsEventTypeDevice:
                store = wself.deviceStore;
                break;
            default:
                store = wself.eventPageStore;
                break;
        }
        
        [store appendData:dataString];
        [wself sendDataIfNeededWithStore:store eventType:eventType];
    }];
    [self.operationQueue addOperation:operation];
}

/**
 *  根据 eventType 获取发送到服务端所需的属性名称
 *
 *  @param eventType
 *
 *  @return 属性名称
 */
- (NSString *)propertyNameWithEventType:(MGJAnalyticsEventType)eventType
{
    NSString *propertyName;
    switch (eventType) {
        case MGJAnalyticsEventTypeNetwork:
            propertyName = @"network";
            break;
            
        case MGJAnalyticsEventTypeDevice:
            propertyName = @"device";
            break;
            
        default:
            propertyName = @"data";
            break;
    }
    return propertyName;
}

#pragma mark - Synthesizer

-(NSMutableDictionary *)timeConsumptions{
    if (!_timeConsumptions) {
        _timeConsumptions = [[NSMutableDictionary alloc] initWithCapacity:0];
    }
    return _timeConsumptions;
}

- (float)fileSizeThreshold
{
    if (!_fileSizeThreshold) {
        _fileSizeThreshold = 1024;
    }
    if ([self.dataSource respondsToSelector:@selector(analyticsFilesizeThreshold)]) {
        _fileSizeThreshold = [self.dataSource analyticsFilesizeThreshold];
    }
    return _fileSizeThreshold;
}

- (NSTimeInterval)timeIntervalThreshold
{
    if (!_timeIntervalThreshold) {
        _timeIntervalThreshold = 10;
    }
    if ([self.dataSource respondsToSelector:@selector(analyticsTimeIntervalThreshold)]) {
        _timeIntervalThreshold = [self.dataSource analyticsTimeIntervalThreshold];
    }
    return _timeIntervalThreshold;
}

- (NSString *)userID
{
    if (!_userID) {
        _userID = @"";
    }
    if ([self.dataSource respondsToSelector:@selector(analyticsUserID)]) {
        _userID = [self.dataSource analyticsUserID];
    }
    return _userID;
}

- (double)timeOffsetBetweenServerAndLocal
{
    if (!_timeOffsetBetweenServerAndLocal) {
        _timeOffsetBetweenServerAndLocal = 0;
    }
    if ([self.dataSource respondsToSelector:@selector(analyticsTimeOffsetBetweenServerAndLocal)]) {
        _timeOffsetBetweenServerAndLocal = [self.dataSource analyticsTimeOffsetBetweenServerAndLocal];
    }
    return _timeOffsetBetweenServerAndLocal;
}


- (NSString *)refererURL
{
    if (!_refererURL) {
        _refererURL = @"";
    }
    return _refererURL;
}

- (NSString *)currentURL
{
    if (!_currentURL) {
        _currentURL = @"";
    }
    return _currentURL;
}

- (MGJBatchRequesterStore *)eventPageStore
{
    if (!_eventPageStore) {
        _eventPageStore = [[MGJBatchRequesterStore alloc] initWithFilePath:@"analytics/event-page.log"];
    }
    return _eventPageStore;
}

- (MGJBatchRequesterStore *)deviceStore
{
    if (!_deviceStore) {
        _deviceStore = [[MGJBatchRequesterStore alloc] initWithFilePath:@"analytics/device.log"];
    }
    return _deviceStore;
}

- (MGJBatchRequesterStore *)networkStore
{
    if (!_networkStore) {
        _networkStore = [[MGJBatchRequesterStore alloc] initWithFilePath:@"analytics/network.log"];
    }
    return _networkStore;
}

- (NSString *)serverBaseURL
{
    if (!_serverBaseURL) {
        _serverBaseURL = MGJAnalyticsServerBaseURL;
    }
    return _serverBaseURL;
}

- (AFHTTPRequestOperationManager *)httpManager
{
    if (!_httpManager) {
        _httpManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:self.serverBaseURL]];
        _httpManager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    }
    return _httpManager;
}

@end
