//
//  MGJAPIClient.m
//  Example
//
//  Created by Blank on 15/10/22.
//  Copyright © 2015年 juangua. All rights reserved.
//

#import "MGJRequestManagerFactory.h"
#import "NSObject+MGJKit.h"
#import "MGJApp.h"
#import "MGJHTTPDNS.h"
#import "MGJAnalytics.h"
#import "MGJURLToken.h"
#import <IMNetworkLib/NetworkCheck.h>
#import "NSMutableDictionary+MGJKit.h"
#import "MGJEXTScope.h"
#import "MGJLog.h"
#import "MGJBatchRequesterStore.h"

static MGJAPIManagerConfig *defaultConfig = nil;


@implementation MGJRequestManagerFactory
+ (BOOL)configRequestManager:(MGJAPIManagerConfig *)config
{
    if (!defaultConfig) {
        defaultConfig = config;
        return YES;
    }
    else {
        return NO;
    }
}

+ (MGJRequestManager *)requestManager
{
    static dispatch_once_t onceToken;
    static MGJRequestManager *instance = nil;
    dispatch_once(&onceToken, ^{
        if (!defaultConfig) {
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"没有配置默认的 MGJAPIManagerConfig，请先调用 setConfitForSharedInstance: 进行配置" userInfo:nil];
        }
        else {
            instance = [self requestManagerWithConfig:defaultConfig];
        }
    });
    return instance;
}

+ (MGJRequestManager *)requestManagerWithConfig:(MGJAPIManagerConfig *)config
{
    MGJRequestManager *requestManager = [[MGJRequestManager alloc] initWithAPIManagerConfig:config];
    return requestManager;
}

+ (MGJAPIManagerConfig *)configuration
{
    return [defaultConfig copy];
}
@end



static const NSTimeInterval slowResponseTime = 5;



@implementation MGJRequestManager (MGJRequestManagerFactory)

- (instancetype)initWithAPIManagerConfig:(MGJAPIManagerConfig *)config
{
    self = [self init];
    if (self) {
        self.apiManagerConfig = config;
        [self configRequestManagerWitiConfiguration:config];
    }
    return self;
}

- (MGJAPIManagerConfig *)apiManagerConfig
{
    return [self mgj_associatedValueForKey:"apiManagerConfig"];
}

- (void)setApiManagerConfig:(MGJAPIManagerConfig *)apiManagerConfig
{
    [self mgj_associateValue:apiManagerConfig withKey:"apiManagerConfig"];
}

- (void)configRequestManagerWitiConfiguration:(MGJAPIManagerConfig *)config
{
    MGJRequestManagerConfiguration *configuration = [[MGJRequestManagerConfiguration alloc] init];
    self.configuration = configuration;
    configuration.baseURL = config.baseURL;
    configuration.builtinParameters = config.builtinParameters;
    configuration.requestSerializer = config.requestSerializer;
    configuration.requestSerializer.timeoutInterval = config.timeoutInterval;
    configuration.responseSerializer = config.responseSerializer;
    configuration.cacheGETResults = config.cacheGETResults;
    configuration.requestHandler = config.requestHandler;
    
    NSString *userAgent = config.userAgent ? : ([MGJApp currentApp].customRequestUserAgent ? : @"");
    if (userAgent.length) {
        [configuration.requestSerializer setValue:userAgent forHTTPHeaderField:@"User-Agent"];
    }
    
    configuration.responseHandler = ^(AFHTTPRequestOperation *operation, MGJResponse *response, BOOL *shouldStopProcessing){
        
        //此时如果有 error , 一定是网络请求的 error
        if (response.error && config.responseHTTPErrorHandler) {
            BOOL shouldReturn = config.responseHTTPErrorHandler(operation, response, shouldStopProcessing);
            if (shouldReturn) {
                return;
            }
        }
        
        if (response.result[@"status"]) {
            NSDictionary *status = response.result[@"status"];
            if ([status[@"code"] intValue] == 1022 && config.responseAccessTokenExpiredHandler) {
                BOOL shouldReturn = config.responseAccessTokenExpiredHandler(operation, response, shouldStopProcessing);
                if (shouldReturn) {
                    return;
                }
            }
            
            if ([status[@"code"] intValue] == 4021) {
                
                [self startOperation:[self reAssembleOperation:operation]];
                return;
            }
            
            if([status[@"code"] intValue] == 4023 && config.responseRelaxSometimeHandler){
                BOOL shouldReturn = config.responseRelaxSometimeHandler(operation, response, shouldStopProcessing);
                if (shouldReturn) {
                    return;
                }
            }
           
            if ([status[@"code"] intValue] == 4019 && config.responseInvalidTokenHandler) {
                config.responseInvalidTokenHandler(operation);
            }

            
            if (![@[@1001 /* 正常返回 */, @4021 /* 需要重试 */] containsObject:status[@"code"]]) {
                // userInfo 添加了一个字段：serverError，表示这个 error 是服务端传过来的
                response.error = [NSError errorWithDomain:status[@"msg"] code:[status[@"code"] intValue] userInfo:@{@"serverError": @YES}];
            }
            
            if (response.result[@"result"] && response.result != [NSNull null]) {
                response.result = response.result[@"result"];
            }
        }
    };
    
    // 对请求参数算一个token
    @weakify(self);
    self.builtinParametersHandler = ^ NSDictionary *(NSDictionary *requestParameters, NSDictionary *builtinParameters){
        @strongify(self);
        NSMutableDictionary *totalParameters = [[NSMutableDictionary alloc] init];
        NSMutableDictionary *mutableBultinParameters = [NSMutableDictionary dictionaryWithDictionary:builtinParameters];
        
        if (requestParameters) {
            [totalParameters addEntriesFromDictionary:requestParameters];
        }
        if (builtinParameters) {
            [config.addtionalBuiltinParameterHandlers enumerateObjectsUsingBlock:^(MGJAddtionalBuiltinParametersHandler handler, NSUInteger idx, BOOL * _Nonnull stop) {
                NSDictionary *result = handler();
                if (result && [result isKindOfClass:[NSDictionary class]]) {
                    [mutableBultinParameters addEntriesFromDictionary:result];
                }
            }];
            
            //时间戳
            NSString *timestamp = [NSString stringWithFormat:@"%0.f",[[NSDate date] timeIntervalSince1970]];
            [mutableBultinParameters setValue:timestamp forKey:@"_t"];
            
            //网络状况
            [mutableBultinParameters mgj_setObject:[NSString stringWithFormat:@"%ld",(long)self.networkStatus] forKeyIfNotNil:@"_network"];
            
            [mutableBultinParameters setValue:[[NSLocale currentLocale] localeIdentifier] forKey:@"_lang"];
            
            //省流量模式
            [mutableBultinParameters setValue:[NSString stringWithFormat:@"%d",self.networkStatus != AFNetworkReachabilityStatusReachableViaWiFi] forKey:@"_saveMode"];
            
            [totalParameters addEntriesFromDictionary:mutableBultinParameters];
        }
        
        //key 排序
        NSArray *keys = [totalParameters allKeys];
        NSArray *sortedkeys = [keys sortedArrayUsingSelector:@selector(compare:)];
        
        //拼接参数
        NSMutableString *parametersString = [NSMutableString string];
        
        for (NSString *key in sortedkeys) {
            id object = [totalParameters objectForKey:key];
            // 对 Dictionary 也要过滤
            if (![object isKindOfClass:[NSArray class]] && ![object isKindOfClass:[NSDictionary class]]) {
                [parametersString appendFormat:@"%@", object];
            }
        }
        
        char token[17];
        generate_url_token([config.appToken UTF8String], [parametersString UTF8String], token);
        
        NSString *tokenString = [NSString stringWithUTF8String:token];
        
        if (tokenString) {
            mutableBultinParameters[@"_at"] = tokenString;
        }
        return mutableBultinParameters;
    };
    
    [self preRequestWithHandler:^(AFHTTPRequestOperation *operation, id userInfo) {
        // 统计耗时用
        [operation mgj_associateValue:@([NSDate timeIntervalSinceReferenceDate]) withKey:@"beginTime"];
    }];
    
    [self postRequestWithHandler:^(NSError *error, AFHTTPRequestOperation *operation, id userInfo) {
        NSTimeInterval responseTime = [NSDate timeIntervalSinceReferenceDate];
        NSTimeInterval duration = (responseTime - [[operation mgj_associatedValueForKey:@"beginTime"] doubleValue]) * 1000 ;
        NSDictionary *responseObject = operation.responseObject;
        
        NSInteger code = -1;
        NSString *msg = @"";
        
        if (responseObject[@"status"]) {
            NSDictionary *status = responseObject[@"status"];
            code = [status[@"code"] intValue];
            msg = status[@"msg"];
        }
        if (error) {
            //根据上下文判断，此处如果 error 存在，一定是非 HTTP 错误，因此传入真实的 code
            code = error.code;
            
            // 没有找到系统预定义的 ERROR NAME，只能通过 Int 匹配
            if (error.code == 3840 && operation.response.statusCode == 200) {
                if (config.responseParseErrorHandler) {
                    config.responseParseErrorHandler(operation);
                }
            }
        }
        
        NSString *urlWithOutParameters = [NSString stringWithFormat:@"%@://%@%@", operation.request.URL.scheme, operation.request.URL.host, operation.request.URL.path];
        
        [self trackNetworkPerformanceWithURLString:urlWithOutParameters duration:duration operation:operation code:code message:msg configuration:config];
    }];
}

- (void)trackNetworkPerformanceWithURLString:(NSString *)urlString
                                    duration:(NSTimeInterval)duration
                                   operation:(AFHTTPRequestOperation *)operation
                                        code:(NSInteger)code
                                     message:(NSString *)message
                               configuration:(MGJAPIManagerConfig *)config
{
    NSDictionary *headerFields = [operation.request allHTTPHeaderFields];
    NSEnumerator *enumerator = [headerFields keyEnumerator];
    id key;
    long long requestSize = 0;
    
    // request head
    while ((key = [enumerator nextObject])) {
        requestSize += [(NSString *)key length];
        requestSize += [headerFields[key] length];
    }
    // request body
    requestSize += [operation.request.HTTPBody length];
    
    // response head
    long long responseSize = 0;
    headerFields = nil;
    headerFields = [operation.response allHeaderFields];
    enumerator = [headerFields keyEnumerator];
    while ((key = [enumerator nextObject])) {
        responseSize += [(NSString *)key length];
        responseSize += [headerFields[key] length];
    }
    // response content length
    responseSize += [operation.response expectedContentLength];
    
    NSInteger statusCode = [operation.response statusCode];
    
    NSString *url = urlString.length ? urlString : operation.request.URL.absoluteString;
    
    if (code == NSURLErrorTimedOut || duration > (slowResponseTime * 1000)) {
        if (config.slowNetworkHandler) {
            config.slowNetworkHandler(url, duration);
        }
    }
    
    [MGJAnalytics trackNetworkPerformanceWithHandler:^(MGJPerformanceParameters *performanceParameters) {
        performanceParameters.requestPath = (statusCode == 200 || statusCode == 0) ? urlString : operation.request.URL.absoluteString;
        performanceParameters.statusCode = statusCode;
        performanceParameters.requestTime = duration;
        performanceParameters.requestSize = requestSize;
        performanceParameters.responsSize = responseSize;
        performanceParameters.resultCode = code;
        performanceParameters.errorMessage = message;
        
        if (operation.response) {
            NSDictionary *headers = [operation.response allHeaderFields];
            performanceParameters.server = headers[@"Server"] ? : @"";
            performanceParameters.zProxy = headers[@"Z-Proxy"] ? : @"";
            performanceParameters.zServer = headers[@"Z-Server"] ? : @"";
            performanceParameters.ip = operation.request.URL.host ? : @"";
            performanceParameters.host = operation.request.allHTTPHeaderFields[@"Host"] ? : @"";
            performanceParameters.backend = headers[@"backend"] ? : @"";
        }
        
        NSString *path = url.length ? [[[NSURL URLWithString:url] pathComponents] componentsJoinedByString:@"/"] : nil;
        MGJLog(@"request url:%@%@, status:%ld, duration:%.3f", [NSURL URLWithString:url].host, path, (long)statusCode, duration);
    }];
}

- (void)diagnoseRequestWithOperation:(AFHTTPRequestOperation *)operation
{
    if (!operation.request.URL) {
        return;
    }
    
    // 不统计 https 请求
    if ([[operation.request.URL.scheme lowercaseString] isEqualToString:@"https"]) {
        return;
    }
    
    static MGJBatchRequesterStore *store;
    // 上传诊断信息的通道
    static dispatch_queue_t postQueue;
    if (!store) {
        store = [[MGJBatchRequesterStore alloc] initWithFilePath:@"net_diagnosis.log"];
    }
    if (!postQueue) {
        postQueue = dispatch_queue_create("com.mogujie.httpdns_post", DISPATCH_QUEUE_SERIAL);
    }
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:operation.request.URL];
    
    NSString *path = operation.request.URL.absoluteString;
    
    NSArray *urlComponents = [operation.request.URL.absoluteString componentsSeparatedByString:@"://"];
    if (urlComponents.count >= 2) {
        urlComponents = [urlComponents[1] componentsSeparatedByString:@"/"];
        NSMutableArray *mutableURLComponents = [NSMutableArray arrayWithArray:urlComponents];
        if (mutableURLComponents.count) {
            [mutableURLComponents removeObjectAtIndex:0];
        }
        if (mutableURLComponents.count) {
            path = [mutableURLComponents componentsJoinedByString:@"/"];
            path = [NSString stringWithFormat:@"/%@", path];
        }
    }
    
    NSMutableArray *requestArray = [NSMutableArray arrayWithArray:@[]];
    [requestArray addObject:[NSString stringWithFormat:@"%@ %@ HTTP/1.1", operation.request.HTTPMethod, path]];
    
    [requestArray addObject:@"Cache-Control: max-age=0"];
    [requestArray addObject:@"Connection: close"];
    
    // 设置 Host
    NSString *host = [operation.request valueForHTTPHeaderField:@"Host"];
    if (!host.length) {
        host = operation.request.URL.host;
    }
    [requestArray addObject:[NSString stringWithFormat:@"Host: %@", host]];
    
    // 获取依附在 operation.request 上的 headers
    [operation.request.allHTTPHeaderFields enumerateKeysAndObjectsUsingBlock:^(NSString *headerKey, NSString *headerValue, BOOL *stop) {
        [requestArray addObject:[NSString stringWithFormat:@"%@: %@", headerKey, headerValue]];
    }];
    
    // 把 Cookie 拿出来
    __block NSString *cookieString = @"";
    [cookies enumerateObjectsUsingBlock:^(NSHTTPCookie *cookie, NSUInteger idx, BOOL *stop) {
        cookieString = [cookieString stringByAppendingString:[NSString stringWithFormat:@"%@=%@; ", cookie.name, cookie.value]];
    }];
    
    if (cookieString.length) {
        [requestArray addObject:[NSString stringWithFormat:@"Cookie: %@", cookieString]];
    }
    
    // 如果是 POST，手动算一下 Content-Length
    if (operation.request.HTTPBody) {
        NSInteger contentLength = operation.request.HTTPBody.length;
        [requestArray addObject:[NSString stringWithFormat:@"Content-Length: %ld", (long)contentLength]];
    }
    
    [requestArray addObject:@"\r\n\r\n"];
    
    if (operation.request.HTTPBody) {
        NSString *httpBody = [[NSString alloc] initWithData:operation.request.HTTPBody encoding:NSUTF8StringEncoding];
        // 如果不移除的话，就会出现 3 个 \r\n
        [requestArray removeLastObject];
        [requestArray addObject:@"\r\n"];
        [requestArray addObject:httpBody];
    }
    
    NSString *rawRequest = [requestArray componentsJoinedByString:@"\r\n"];
    NSData *rawRequestData = [rawRequest dataUsingEncoding:NSUTF8StringEncoding];
    
    dispatch_async(postQueue, ^{
        int port = operation.request.URL.port ? [operation.request.URL.port intValue] : 80;
        NSString *result = [NetworkCheck netcheck:host port:port data:rawRequestData];
        NSData *resultData = [result dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *diagnosis = [NSJSONSerialization JSONObjectWithData:resultData options:0 error:nil];
        if (diagnosis) {
            [MGJHTTPDNS reportURL:operation.request.URL.absoluteString withMethod:operation.request.HTTPMethod type:@"requestFailed" diagnosis:diagnosis startImmediately:NO];
        }
    });
}
@end
