//
//  MGJRequestManager.h
//  MGJFoundation
//
//  Created by limboy on 12/10/14.
//  Copyright (c) 2014 juangua. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

@interface MGJResponse : NSObject
@property (nonatomic) NSError *error;
@property (nonatomic) id result;
@property (nonatomic) id userInfo;
@end

@interface MGJRequestManagerConfiguration : NSObject <NSCopying>
/**
 *  是否缓存GET请求，默认为是
 */
@property (nonatomic, assign) BOOL cacheGETResults;

/**
 *  如 http://api.mogujie.com
 */
@property (nonatomic, copy) NSString *baseURL;

/**
 *  默认使用 AFHTTPRequestSerializer
 */
@property (nonatomic) AFHTTPRequestSerializer *requestSerializer;

/**
 *  默认使用 AFHTTPResponseSerializer
 */
@property (nonatomic) AFHTTPResponseSerializer *responseSerializer;

/**
 * 可以对返回的数据做一些预处理
 * 如果设置 shouldStopProcessing 为 YES，那么 completionBlock 将不会被触发
 */
@property (nonatomic, copy) void (^responseHandler)(AFHTTPRequestOperation *operation, MGJResponse *response, BOOL *shouldStopProcessing);

/**
 *  发送数据之前可以做一些预处理，如果觉得可以取消此次发送，设置 *shouldStopProcessing 为 YES 即可
 */
@property (nonatomic, copy) void (^requestHandler)(AFHTTPRequestOperation *operation, id userInfo, BOOL *shouldStopProcessing);

/**
 *  此次请求可以附带的信息，会传给 preRequestHandler 和 postRequestHandler
 */
@property (nonatomic) id userInfo;

/**
 *  每次请求都要带上的一些参数
 */
@property (nonatomic) NSDictionary *builtinParameters;

/**
 *  发生 redirect 时可以对 request 做处理
 */
@property (nonatomic, copy) NSURLRequest * (^redirectResponseBlock)(NSURLConnection *connection, NSURLRequest *request, NSURLResponse *redirectResponse);
@end


typedef void (^MGJRequestManagerConfigurationHandler)(MGJRequestManagerConfiguration *configuration);

typedef void (^MGJRequestManagerCompletionHandler)(NSError *error, id result, BOOL isFromCache, AFHTTPRequestOperation *operation);

typedef void (^MGJRequestManagerPreRequestHandler)(AFHTTPRequestOperation *operation, id userInfo);

typedef void (^MGJRequestManagerPostRequestHandler)(NSError *error, AFHTTPRequestOperation *operation, id userInfo);

typedef NSDictionary *(^MGJRequestManagerParametersHandler)(NSDictionary *requestParameters, NSDictionary *builtinParameters);

typedef NSDictionary *(^MGJRequestManagerBuiltinParametersHandler)(NSDictionary *requestParameters, NSDictionary *builtinParameters);

@interface MGJRequestManager : NSObject

+ (instancetype)sharedInstance;

/**
 *  当前的网络状态
 */
@property (nonatomic) AFNetworkReachabilityStatus networkStatus;

/**
 * 缓存多长时间，单位为秒，默认缓存3天
 */
@property (nonatomic) NSInteger cacheDuration;

/**
 *  拿到 sharedInstance 后，可以设置这个 property，当 configuration 中的某几项有变动，
 *  并且要对全局做更改时，可以再次设置这个 property
 */
@property(nonatomic) MGJRequestManagerConfiguration *configuration;

/**
 *  正在发送的请求们，里面是一些 AFHTTPRequestOperation
 */
@property (nonatomic, readonly) NSArray *runningRequests;

/**
 *  可以对请求的参数做处理，比如去掉一些特殊字符、加密等
 */
@property (nonatomic, copy) MGJRequestManagerParametersHandler parametersHandler;

/**
 *  可以对 builtin 参数做最后的调整，比如算一个token
 */
@property (nonatomic, copy) MGJRequestManagerParametersHandler builtinParametersHandler;

/**
 * 手动往缓存中加入数据，取的时候，用相同的 key 取即可
 */
- (void)cacheData:(id<NSCoding>)data forKey:(NSString *)key;

/**
 *  将 Operation 放到某个 Chain 里，一次执行一个
 *
 *  @param chainName
 */
- (void)addOperation:(AFHTTPRequestOperation *)operation toChain:(NSString *)chain;

/**
 *  获取某个 Chain 里所有的 Operations
 *
 *  @param chainName
 */
- (NSArray *)operationsInChain:(NSString *)chain;

/**
 *  移除某个 Chain 里的某个 Operation
 *
 *  @param operation
 *  @param chain     
 */
- (void)removeOperation:(AFHTTPRequestOperation *)operation inChain:(NSString *)chain;

/**
 *  并行执行一些列Operation
 *
 *  @param operations      待执行的operations
 *  @param progressBlock
 *  @param completionBlock
 */
- (void)batchOfRequestOperations:(NSArray *)operations
                        progressBlock:(void (^)(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations))progressBlock
                      completionBlock:(void (^)(NSArray *operations))completionBlock;

/**
 *  开始执行 Operation，这个 Operation 可以是之前设置 startImmediately 为 NO 的
 *
 *  @param operation 
 */
- (void)startOperation:(AFHTTPRequestOperation *)operation;

/**
 *  取消所有正在发送的请求
 */
- (void)cancelAllRequest;

/**
 *  取消某个/些正在发送的请求
 *
 *  @param method                可以是 GET/POST/DELETE/PUT
 *  @param url                   要取消的 url
 */
- (void)cancelHTTPOperationsWithMethod:(NSString *)method url:(NSString *)url;

/**
 *  在发送请求之前会调用这个方法，可以结合 mgj_asscotiatedValue
 */
- (void)preRequestWithHandler:(MGJRequestManagerPreRequestHandler)preRequestHandler;

/**
 *  这个方法厉害了！正常的话，一个 Operation 如果已经完成，那么 completionBlock 就会被设为空
 *  使用 `[operation copy]` 虽然可以拿到一个初始状态的 operation，但是之前设置的
 *  completionBlock 是不会被触发的。使用这个方法可以让之前的 completionBlock 依旧被触发
 *
 *  @param operation 已经处于完成状态的 Operation
 *
 *  @return 一个新的 Operation
 */
- (AFHTTPRequestOperation *)reAssembleOperation:(AFHTTPRequestOperation *)operation;

/**
 *  在请求发送完成后会调用这个方法，可以结合 mgj_asscotiatedValue
 */
- (void)postRequestWithHandler:(MGJRequestManagerPostRequestHandler)postRequestHandler;


- (AFHTTPRequestOperation *)GET:(NSString *)URLString
                     parameters:(NSDictionary *)parameters
             configurationHandler:(MGJRequestManagerConfigurationHandler)configurationHandler
              completionHandler:(MGJRequestManagerCompletionHandler)completionHandler
               startImmediately:(BOOL)startImmediately;

- (AFHTTPRequestOperation *)POST:(NSString *)URLString
                      parameters:(NSDictionary *)parameters
              configurationHandler:(MGJRequestManagerConfigurationHandler)configurationHandler
               completionHandler:(MGJRequestManagerCompletionHandler)completionHandler
                startImmediately:(BOOL)startImmediately;

/**
 *  上传文件
 */
- (AFHTTPRequestOperation *)POST:(NSString *)URLString
                      parameters:(NSDictionary *)parameters
       constructingBodyWithBlock:(void (^)(id<AFMultipartFormData>))block
              configurationHandler:(MGJRequestManagerConfigurationHandler)configurationHandler
               completionHandler:(MGJRequestManagerCompletionHandler)completionHandler
                startImmediately:(BOOL)startImmediately;

- (AFHTTPRequestOperation *)PUT:(NSString *)URLString
                     parameters:(NSDictionary *)parameters
             configurationHandler:(MGJRequestManagerConfigurationHandler)configurationHandler
              completionHandler:(MGJRequestManagerCompletionHandler)completionHandler
               startImmediately:(BOOL)startImmediately;

- (AFHTTPRequestOperation *)DELETE:(NSString *)URLString
                        parameters:(NSDictionary *)parameters
                configurationHandler:(MGJRequestManagerConfigurationHandler)configurationHandler
                 completionHandler:(MGJRequestManagerCompletionHandler)completionHandler
                  startImmediately:(BOOL)startImmediately;

- (AFHTTPRequestOperation *)HTTPRequestOperationWithMethod:(NSString *)method
                                                 URLString:(NSString *)URLString
                                                parameters:(NSDictionary *)parameters
                                 constructingBodyWithBlock:(void (^)(id<AFMultipartFormData>))block
                                      configurationHandler:(MGJRequestManagerConfigurationHandler)configurationHandler
                                         completionHandler:(MGJRequestManagerCompletionHandler)completionHandler
                                          startImmediately:(BOOL)startImmediately;

@end
