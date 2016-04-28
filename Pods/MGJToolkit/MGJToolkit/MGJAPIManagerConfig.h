//
//  MGJAPIManager.h
//  Example
//
//  Created by limboy on 9/7/15.
//  Copyright (c) 2015 juangua. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MGJRequestManager.h>

@class AFHTTPResponseSerializer;
@class AFHTTPRequestSerializer;
@class AFHTTPRequestOperation;
@class MGJResponse;

typedef BOOL (^MGJAPIResponseHandler)(AFHTTPRequestOperation *operation, MGJResponse *response, BOOL *shouldStopProcessing);

typedef void (^MGJAPIRequestHandler)(AFHTTPRequestOperation *operation, id userInfo, BOOL *shouldStopProcessing);

typedef NSDictionary *(^MGJAddtionalBuiltinParametersHandler)();

@interface MGJAPIManagerConfig : NSObject<NSCopying>

+ (instancetype)defaultConfig;

/**
 *  自定义 UA
 */
@property (nonatomic, copy) NSString *userAgent;

/**
 *  内置的系统参数
 */
@property (nonatomic, readonly) NSDictionary* builtinParameters;

/**
 *  请求的超时时间
 */
@property (nonatomic, assign) NSTimeInterval timeoutInterval;

/**
 *  请求的 Hanlder
 */
@property (nonatomic) AFHTTPRequestSerializer *requestSerializer;

/**
 *  请求结果的 Hanlder
 */
@property (nonatomic) AFHTTPResponseSerializer *responseSerializer;

/**
 *  当出现 HTTP 请求错误时的 Handler
 */
@property (nonatomic, copy) MGJAPIResponseHandler responseHTTPErrorHandler;

/**
 *  比如某些接口忽然有大量的请求，此时服务端会返回特定的 Code，让客户端一段时间内不要再向该接口发请求
 */
@property (nonatomic, copy) MGJAPIResponseHandler responseRelaxSometimeHandler;

@property (nonatomic, copy) MGJAPIRequestHandler requestHandler;

/**
 *  是否默认缓存 GET 请求
 */
@property (nonatomic, assign) BOOL cacheGETResults;

/**
 *  当出现请求错误时，是否要诊断一下网络
 *  如果是的话，会用底层的网络库重发请求，然后将请求结果上报给 HTTPDNS
 */
@property (nonatomic, assign) BOOL shouldDiagnoseRequestWhenHTTPError;

// 以下属性各个 App 需要单独设置
@property (nonatomic, copy) NSString *appToken;
@property (nonatomic, copy) NSString *baseURL;
@property (nonatomic, copy) NSString *noNetWorkMessage;
@property (nonatomic, copy) NSString *requestFailedMessage;

/**
 *  当用户的 AccessToken 过期时的处理
 */
@property (nonatomic, copy) MGJAPIResponseHandler responseAccessTokenExpiredHandler;

/**
 *  当出现解析出错时的处理，比如被运营商劫持，本该拿到 messagePack 的，结果拿到了 html
 */
@property (nonatomic, copy) void (^responseParseErrorHandler)(AFHTTPRequestOperation *operation);

/**
 *  当网速比较慢时的处理
 */
@property (nonatomic, copy) void (^slowNetworkHandler)(NSString *url, NSTimeInterval duration);

/**
 *  当出现 Token 验证失败时的处理
 */
@property (nonatomic, copy) void (^responseInvalidTokenHandler)(AFHTTPRequestOperation *operation);

/**
 *  可以向 builtinParameters 添加新的内容，内部是一个数组保存了每个 block
 */
- (void)addAddtionalBuiltinParameters:(MGJAddtionalBuiltinParametersHandler)addtionalBuiltinParameters;


- (NSArray *)addtionalBuiltinParameterHandlers;

@end

