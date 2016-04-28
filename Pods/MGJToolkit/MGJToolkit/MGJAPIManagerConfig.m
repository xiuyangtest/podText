//
//  MGJAPIManager.m
//  Example
//
//  Created by limboy on 9/7/15.
//  Copyright (c) 2015 juangua. All rights reserved.
//

#import "MGJAPIManagerConfig.h"
#import <MGJFoundation.h>
#import "MGJStorageService.h"
#import "MGJApp.h"
#import "MGJAnalytics.h"
#import "MGJURLToken.h"
#import <IMNetworkLib/NetworkCheck.h>

static const NSTimeInterval defaultTimeoutInterval = 15;


@interface MGJAPIManagerConfig ()
@property (nonatomic, weak) MGJRequestManager *requestManager;
@property (nonatomic, readwrite) NSMutableDictionary* builtinParameters;
@property (nonatomic, readwrite) NSArray *addtionalBuiltinParameterHandlers;
@end

@implementation MGJAPIManagerConfig

- (id)copyWithZone:(NSZone *)zone
{
    id copy = [[[self class] alloc] init];
    for (NSString *key in [self codableProperties])
    {
        [copy setValue:[self valueForKey:key] forKey:key];
    }
    return copy;
}

+ (instancetype)defaultConfig
{
    return [[MGJAPIManagerConfig alloc] init];
}

- (NSArray *)addtionalBuiltinParameterHandlers
{
    if (!_addtionalBuiltinParameterHandlers) {
        _addtionalBuiltinParameterHandlers = [[NSArray alloc] init];
    }
    return _addtionalBuiltinParameterHandlers;
}

- (void)addAddtionalBuiltinParameters:(MGJAddtionalBuiltinParametersHandler)addtionalBuiltinParameters
{
    @synchronized(self) {
        NSMutableArray *mutableArray = [self.addtionalBuiltinParameterHandlers mutableCopy];
        [mutableArray addObject:addtionalBuiltinParameters];
        self.addtionalBuiltinParameterHandlers = [NSArray arrayWithArray:mutableArray];
    }
}

- (NSDictionary *)builtinParameters
{
    NSMutableDictionary *mutableBuiltinParameters = [[NSMutableDictionary alloc] init];
    
    //应用类型
    [mutableBuiltinParameters mgj_setObject:[MGJApp currentApp].appName forKeyIfNotNil:@"_app"];
    
    //应用名称
    [mutableBuiltinParameters mgj_setObject:[MGJApp currentApp].appType forKeyIfNotNil:@"_atype"];
    
    //设备唯一 id
    [mutableBuiltinParameters mgj_setObject:[UIDevice mgj_uniqueID] forKeyIfNotNil:@"_did"];
    
    //第一次安装的来源
    [mutableBuiltinParameters mgj_setObject:[MGJApp currentApp].firstInstallSource forKeyIfNotNil:@"_fs"];
    
    //屏幕宽度
    NSString* swidth = [NSString stringWithFormat:@"%.0f",[UIDevice mgj_screenPixelSize].width];
    [mutableBuiltinParameters mgj_setObject:swidth forKeyIfNotNil:@"_swidth"];
    
    //版本号
    [mutableBuiltinParameters mgj_setObject:[NSString stringWithFormat:@"%ld",(long)[MGJApp currentApp].appVersion] forKeyIfNotNil:@"_av"];
    
    //传build
    [mutableBuiltinParameters mgj_setObject:[UIApplication mgj_buildVersion] forKeyIfNotNil:@"_ab"];
    
    //完整版本号
    [mutableBuiltinParameters mgj_setObject:[UIApplication mgj_appStoreVersion] forKeyIfNotNil:@"_version"];
    
    //渠道
    [mutableBuiltinParameters mgj_setObject:[MGJApp currentApp].appChannel forKeyIfNotNil:@"_channel"];
    
    // 系统型号
    [mutableBuiltinParameters mgj_setObject:[UIDevice mgj_deviceName] forKeyIfNotNil:@"minfo"];
    
    // 系统版本
    [mutableBuiltinParameters mgj_setObject:[UIDevice mgj_systemVersion] forKeyIfNotNil:@"_sdklevel"];
    
    return [mutableBuiltinParameters copy];
}

- (NSString *)noNetWorkMessage
{
    if (!_noNetWorkMessage) {
        _noNetWorkMessage = @"菇凉，你的网络好像不是很给力哦";
    }
    return _noNetWorkMessage;
}

- (NSString *)requestFailedMessage
{
    if (!_requestFailedMessage) {
        _requestFailedMessage = @"服务器繁忙，请稍后再试~";
    }
    return _requestFailedMessage;
}

- (NSTimeInterval)timeoutInterval
{
    return _timeoutInterval ? : defaultTimeoutInterval;
}

- (AFHTTPRequestSerializer *)requestSerializer
{
    if (!_requestSerializer) {
        _requestSerializer = [AFHTTPRequestSerializer serializer];
    }
    return _requestSerializer;
}

- (AFHTTPResponseSerializer *)responseSerializer
{
    if (!_responseSerializer) {
        _responseSerializer = [AFHTTPResponseSerializer serializer];
    }
    return _responseSerializer;
}

- (MGJAPIResponseHandler)responseHTTPErrorHandler
{
    MGJAPIResponseHandler responseHandler = ^BOOL (AFHTTPRequestOperation *operation, MGJResponse *response, BOOL *shouldStopProcessing) {
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:response.error.userInfo];
        userInfo[@"httpError"] = @YES;
        
        if (response.error.code == NSURLErrorNotConnectedToInternet) {
            response.error = [NSError errorWithDomain:self.noNetWorkMessage code:response.error.code userInfo:userInfo];
        }
        else {
            response.error = [NSError errorWithDomain:self.requestFailedMessage code:response.error.code userInfo:userInfo];
        }
        
        if (self.shouldDiagnoseRequestWhenHTTPError) {
            [self diagnoseRequestWithOperation:operation];
        }
        return YES;
    };
    
    return responseHandler;
}


- (MGJAPIResponseHandler)responseRelaxHandler
{
    MGJAPIResponseHandler responseHandler = ^BOOL (AFHTTPRequestOperation *operation, MGJResponse *response, BOOL *shouldStopProcessing)  {
        NSString *timestamp = [NSString stringWithFormat:@"%0.f",[[NSDate date] timeIntervalSince1970]];
        
        //这边的操作是 4023的code 下 记录当前的时间戳与请求的接口
        
        [MGJStorageService setObjectToMemory:timestamp forKey:@"protected_4023_time"];
        
        [MGJStorageService setObjectToMemory:[operation.response.URL path] forKey:@"protected_4023_url"];
        return NO;
    };
    return responseHandler;
}

- (MGJAPIRequestHandler)requestHandler
{
    MGJAPIRequestHandler requestHandler = ^(AFHTTPRequestOperation *operation, id userInfo, BOOL *shouldStopProcessing) {
        NSString *timestamp = [NSString stringWithFormat:@"%0.f",[[NSDate date] timeIntervalSince1970]];
        
        NSString *recordTimestamp = [MGJStorageService objectFromMemoryForKey:@"protected_4023_time"];
        
        NSString *recordUrl = [MGJStorageService objectFromMemoryForKey:@"protected_4023_url"];
        
        if(recordTimestamp&&[timestamp intValue]-[recordTimestamp intValue]<5&&[recordUrl isEqualToString:[operation.request.URL path]]){
            *shouldStopProcessing = YES;
        }
    };
    
    return requestHandler;
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
