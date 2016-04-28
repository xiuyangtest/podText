//
//  MGJRequestManager.m
//  MGJFoundation
//
//  Created by limboy on 12/10/14.
//  Copyright (c) 2014 juangua. All rights reserved.
//

#import "MGJRequestManager.h"
#import "NSString+MGJKit.h"
#import <TMCache/TMCache.h>
#import "NSObject+MGJKit.h"

static NSString * const MGJRequestManagerCacheDirectory = @"requestCacheDirectory";

@implementation MGJResponse @end

@implementation MGJRequestManagerConfiguration

- (instancetype)init
{
    self = [super init];
    if (self) {
        // 这个无法使用 lazy get，所以只能在 init 里面处理
        self.cacheGETResults = YES;
    }
    return self;
}

- (AFHTTPRequestSerializer *)requestSerializer
{
    return _requestSerializer ? : [AFHTTPRequestSerializer serializer];
}

- (AFHTTPResponseSerializer *)responseSerializer
{
    return _responseSerializer ? : [AFJSONResponseSerializer serializer];
}

- (instancetype)copyWithZone:(NSZone *)zone
{
    MGJRequestManagerConfiguration *configuration = [[MGJRequestManagerConfiguration alloc] init];
    configuration.requestSerializer = [self.requestSerializer copy];
    configuration.responseSerializer = [self.responseSerializer copy];
    configuration.baseURL = self.baseURL;
    configuration.cacheGETResults = self.cacheGETResults;
    configuration.builtinParameters = [self.builtinParameters copy];
    configuration.userInfo = [self.userInfo copy];
    // 下面这个必须注释掉，不然 copy 就有了 responseHandler 的默认实现了
    // 这往往是不必要且会带来麻烦的
    // configuration.responseHandler = self.responseHandler;
    return configuration;
}

@end

@interface MGJRequestManager ()
@property (nonatomic) AFHTTPRequestOperationManager *requestManager;
@property (nonatomic, copy) MGJRequestManagerPreRequestHandler preRequestHandler;
@property (nonatomic, copy) MGJRequestManagerPostRequestHandler postRequestHandler;
@property (nonatomic) TMCache *cache;
@property (nonatomic) NSMutableDictionary *chainedOperations;
@property (nonatomic) NSMapTable *completionBlocks;
@property (nonatomic) NSMapTable *operationMethodParameters;
@property (nonatomic) NSMutableArray *batchGroups;
@end

@implementation MGJRequestManager

+ (instancetype)sharedInstance
{
    static MGJRequestManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
        // 缓存保留 3 天
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.networkStatus = AFNetworkReachabilityStatusUnknown;
        self.chainedOperations = [[NSMutableDictionary alloc] init];
        self.completionBlocks = [NSMapTable mapTableWithKeyOptions:NSMapTableWeakMemory valueOptions:NSMapTableCopyIn];
        self.operationMethodParameters = [NSMapTable mapTableWithKeyOptions:NSMapTableWeakMemory valueOptions:NSMapTableStrongMemory];
        self.batchGroups = [[NSMutableArray alloc] init];
        [[AFNetworkReachabilityManager sharedManager] startMonitoring];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:AFNetworkingReachabilityDidChangeNotification object:nil];
    }
    return self;
}

- (void)cacheData:(id<NSCoding>)data forKey:(NSString *)key
{
    // 异步设置
    [self.cache setObject:data forKey:key block:^(TMCache *cache, NSString *key, id object) {
        
    }];
}

- (void)reachabilityChanged:(NSNotification *)notification
{
    self.networkStatus = [notification.userInfo[AFNetworkingReachabilityNotificationStatusItem] integerValue];
}

- (AFHTTPRequestOperation *)GET:(NSString *)URLString
                     parameters:(NSDictionary *)parameters
           configurationHandler:(MGJRequestManagerConfigurationHandler)configurationHandler
              completionHandler:(MGJRequestManagerCompletionHandler)completionHandler
               startImmediately:(BOOL)startImmediately
{
    return [self HTTPRequestOperationWithMethod:@"GET" URLString:URLString parameters:parameters constructingBodyWithBlock:nil configurationHandler:configurationHandler completionHandler:completionHandler startImmediately:startImmediately];
}

- (AFHTTPRequestOperation *)POST:(NSString *)URLString
                      parameters:(NSDictionary *)parameters
            configurationHandler:(MGJRequestManagerConfigurationHandler)configurationHandler
               completionHandler:(MGJRequestManagerCompletionHandler)completionHandler
                startImmediately:(BOOL)startImmediately
{
    return [self HTTPRequestOperationWithMethod:@"POST" URLString:URLString parameters:parameters constructingBodyWithBlock:nil configurationHandler:configurationHandler completionHandler:completionHandler startImmediately:startImmediately];
}

- (AFHTTPRequestOperation *)POST:(NSString *)URLString
                      parameters:(NSDictionary *)parameters
       constructingBodyWithBlock:(void (^)(id<AFMultipartFormData>))block
            configurationHandler:(MGJRequestManagerConfigurationHandler)configurationHandler
               completionHandler:(MGJRequestManagerCompletionHandler)completionHandler
                startImmediately:(BOOL)startImmediately
{
    return [self HTTPRequestOperationWithMethod:@"POST" URLString:URLString parameters:parameters constructingBodyWithBlock:block configurationHandler:configurationHandler completionHandler:completionHandler startImmediately:startImmediately];
}

- (AFHTTPRequestOperation *)PUT:(NSString *)URLString
                     parameters:(NSDictionary *)parameters
           configurationHandler:(MGJRequestManagerConfigurationHandler)configurationHandler
              completionHandler:(MGJRequestManagerCompletionHandler)completionHandler
               startImmediately:(BOOL)startImmediately
{
    return [self HTTPRequestOperationWithMethod:@"PUT" URLString:URLString parameters:parameters constructingBodyWithBlock:nil configurationHandler:configurationHandler completionHandler:completionHandler startImmediately:startImmediately];
}

- (AFHTTPRequestOperation *)DELETE:(NSString *)URLString
                        parameters:(NSDictionary *)parameters
              configurationHandler:(MGJRequestManagerConfigurationHandler)configurationHandler
                 completionHandler:(MGJRequestManagerCompletionHandler)completionHandler
                  startImmediately:(BOOL)startImmediately
{
    return [self HTTPRequestOperationWithMethod:@"DELETE" URLString:URLString parameters:parameters constructingBodyWithBlock:nil configurationHandler:configurationHandler completionHandler:completionHandler startImmediately:startImmediately];
}

- (AFHTTPRequestOperation *)HTTPRequestOperationWithMethod:(NSString *)method
                                                 URLString:(NSString *)URLString
                                                parameters:(NSDictionary *)parameters
                                 constructingBodyWithBlock:(void (^)(id<AFMultipartFormData>))block
                                      configurationHandler:(MGJRequestManagerConfigurationHandler)configurationHandler
                                         completionHandler:(MGJRequestManagerCompletionHandler)completionHandler
                                          startImmediately:(BOOL)startImmediately
{
    [self configureCache];
    // 拿到 configuration 的副本，然后让调用方自定义该 configuration
    MGJRequestManagerConfiguration *configuration = [self.configuration copy];
    if (configurationHandler) {
        configurationHandler(configuration);
    }
    self.requestManager.requestSerializer = configuration.requestSerializer;
    self.requestManager.responseSerializer = configuration.responseSerializer;
    
    if (self.builtinParametersHandler) {
        configuration.builtinParameters = self.builtinParametersHandler(parameters, configuration.builtinParameters);
    }
    
    if (self.parametersHandler) {
        parameters = self.parametersHandler(parameters, configuration.builtinParameters);
    }
    
    NSString *combinedURL = [NSString mgj_combineURLWithBaseURL:URLString parameters:configuration.builtinParameters];
    NSMutableURLRequest *request;
    
    if (block) {
        request = [self.requestManager.requestSerializer multipartFormRequestWithMethod:@"POST" URLString:[[NSURL URLWithString:combinedURL relativeToURL:[NSURL URLWithString:configuration.baseURL]] absoluteString] parameters:parameters constructingBodyWithBlock:block error:nil];
    } else {
        request = [self.requestManager.requestSerializer requestWithMethod:method URLString:[[NSURL URLWithString:combinedURL relativeToURL:[NSURL URLWithString:configuration.baseURL]] absoluteString] parameters:parameters error:nil];
    }
    
    // 如果设置为使用缓存，那么先去缓存里看一下
    if (configuration.cacheGETResults && [method isEqualToString:@"GET"]) {
        NSString *urlKey = [NSString mgj_combineURLWithBaseURL:URLString parameters:parameters];
        //NSString *requestKey = [request.URL.absoluteString mgj_md5HashString];
        id result = [self.cache objectForKey:[urlKey mgj_md5HashString]];
        if (result) {
            completionHandler(nil, result, YES, nil);
        }
    }
    
    AFHTTPRequestOperation *operation = [self createOperationWithConfiguration:configuration request:request];
    if (configuration.userInfo) {
        [operation mgj_associateValue:configuration.userInfo withKey:@"userInfo"];
    }
    
    
    // 记录下 Operation 的相关信息
    NSMutableDictionary *methodParameters = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                            @"method": method,
                                                                                            @"URLString": URLString,
                                                                                            }];
    if (parameters) {
        methodParameters[@"parameters"] = parameters;
    }
    if (block) {
        methodParameters[@"constructingBodyWithBlock"] = block;
    }
    if (configurationHandler) {
        methodParameters[@"configurationHandler"] = configurationHandler;
    }
    if (completionHandler) {
        methodParameters[@"completionHandler"] = completionHandler;
    }
    
    [self.operationMethodParameters setObject:methodParameters forKey:operation];
    
    
    
    __weak typeof(self) weakSelf = self;
    
    void (^checkIfShouldDoChainOperation)(AFHTTPRequestOperation *) = ^(AFHTTPRequestOperation *operation){
        // TODO 不用每次都去找一下 ChainedOperations
        AFHTTPRequestOperation *nextOperation = [weakSelf findNextOperationInChainedOperationsBy:operation];
        if (nextOperation) {
            NSDictionary *methodParameters = [weakSelf.operationMethodParameters objectForKey:nextOperation];
            if (methodParameters) {
                [weakSelf HTTPRequestOperationWithMethod:methodParameters[@"method"]
                                                 URLString:methodParameters[@"URLString"]
                                                parameters:methodParameters[@"parameters"]
                                 constructingBodyWithBlock:methodParameters[@"constructingBodyWithBlock"]
                                      configurationHandler:methodParameters[@"configurationHandler"]
                                         completionHandler:methodParameters[@"completionHandler"]
                                        startImmediately:YES];
                [weakSelf.operationMethodParameters removeObjectForKey:nextOperation];
            } else {
                [weakSelf.requestManager.operationQueue addOperation:nextOperation];
            }
        }
    };
    
    // 对拿到的 response 再做一层处理
    BOOL (^handleResponse)(AFHTTPRequestOperation *, MGJResponse *, MGJRequestManagerConfiguration *) =  ^BOOL (AFHTTPRequestOperation *operation, MGJResponse *response, MGJRequestManagerConfiguration *configuration) {
        BOOL shouldStopProcessing = NO;
        
        // 先调用默认的处理
        if (weakSelf.configuration.responseHandler) {
            weakSelf.configuration.responseHandler(operation, response, &shouldStopProcessing);
        }
        
        // 如果客户端有定义过 responseHandler
        if (configuration.responseHandler) {
            configuration.responseHandler(operation, response, &shouldStopProcessing);
        }
        return shouldStopProcessing;
    };
    
    // 对 request 再做一层处理
    BOOL (^handleRequest)(AFHTTPRequestOperation *, id userInfo, MGJRequestManagerConfiguration *) =  ^BOOL (AFHTTPRequestOperation *operation, id userInfo, MGJRequestManagerConfiguration *configuration) {
        BOOL shouldStopProcessing = NO;
        
        // 先调用默认的处理
        if (weakSelf.configuration.requestHandler) {
            weakSelf.configuration.requestHandler(operation, userInfo, &shouldStopProcessing);
        }
        
        // 如果客户端有定义过 responseHandler
        if (configuration.requestHandler) {
            configuration.requestHandler(operation, userInfo, &shouldStopProcessing);
        }
        return shouldStopProcessing;
    };
    
    void (^handleFailure)(AFHTTPRequestOperation *, NSError *) = ^(AFHTTPRequestOperation *theOperation, NSError *error) {
        if (weakSelf.postRequestHandler) {
            weakSelf.postRequestHandler(error, theOperation, [theOperation mgj_associatedValueForKey:@"userInfo"]);
        }
        
        MGJResponse *response = [[MGJResponse alloc] init];
        response.error = error;
        response.result = nil;
        // ╮(╯▽╰)╭ 设计上的失误
        response.userInfo = [theOperation mgj_associatedValueForKey:@"userInfo"];
        
        BOOL shouldStopProcessing = handleResponse(theOperation, response, configuration);
        if (shouldStopProcessing) {
            [weakSelf.completionBlocks removeObjectForKey:theOperation];
            return ;
        }
       
        if (completionHandler) {
            completionHandler(response.error, response.result, NO, theOperation);
        }
        
        // 及时移除，避免循环引用
        [weakSelf.completionBlocks removeObjectForKey:theOperation];
        [weakSelf.operationMethodParameters removeObjectForKey:theOperation];
        
        checkIfShouldDoChainOperation(theOperation);
    };
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *theOperation, id responseObject){
        if (weakSelf.postRequestHandler) {
            weakSelf.postRequestHandler(nil, theOperation, [theOperation mgj_associatedValueForKey:@"userInfo"]);
        }
        
        MGJResponse *response = [[MGJResponse alloc] init];
        response.error = nil;
        response.result = responseObject;
        response.userInfo = [theOperation mgj_associatedValueForKey:@"userInfo"];
        BOOL shouldStopProcessing = handleResponse(theOperation, response, configuration);
        if (shouldStopProcessing) {
            [weakSelf.completionBlocks removeObjectForKey:theOperation];
            return ;
        }
        
        // 如果使用缓存，就把结果放到缓存中方便下次使用
        if (configuration.cacheGETResults && [method isEqualToString:@"GET"] && !response.error) {
            // 不使用 builtinParameters
            NSString *urlKey = [NSString mgj_combineURLWithBaseURL:URLString parameters:parameters];
            [weakSelf.cache setObject:response.result forKey:[urlKey mgj_md5HashString] block:^(TMCache *cache, NSString *key, id object) {
                
            }];
        }
        completionHandler(response.error, response.result, NO, theOperation);
        // 及时移除，避免循环引用
        [weakSelf.completionBlocks removeObjectForKey:theOperation];
        [weakSelf.operationMethodParameters removeObjectForKey:theOperation];
        
        checkIfShouldDoChainOperation(theOperation);
    } failure:^(AFHTTPRequestOperation *theOperation, NSError *error){
        handleFailure(theOperation, error);
    }];
   
    [operation setRedirectResponseBlock:configuration.redirectResponseBlock];
    
    if (startImmediately) {
        if (!handleRequest(operation, configuration.userInfo, configuration)) {
            [self.requestManager.operationQueue addOperation:operation];
            if (self.preRequestHandler) {
                self.preRequestHandler(operation, [operation mgj_associatedValueForKey:@"userInfo"]);
            }
        } else {
            NSError *error = [NSError errorWithDomain:@"取消请求" code:-1 userInfo:nil];
            handleFailure(operation, error);
        }
    }
    
    [self.completionBlocks setObject:operation.completionBlock forKey:operation];
    
    return operation;
}

- (void)startOperation:(AFHTTPRequestOperation *)operation
{
    NSDictionary *methodParameters = [self.operationMethodParameters objectForKey:operation];
    AFHTTPRequestOperation *newOperation = operation;
    if (methodParameters) {
        newOperation = [self HTTPRequestOperationWithMethod:methodParameters[@"method"]
                                                  URLString:methodParameters[@"URLString"]
                                                 parameters:methodParameters[@"parameters"]
                                  constructingBodyWithBlock:methodParameters[@"constructingBodyWithBlock"]
                                       configurationHandler:methodParameters[@"configurationHandler"]
                                          completionHandler:methodParameters[@"completionHandler"]
                                           startImmediately:YES];
        [self.operationMethodParameters removeObjectForKey:operation];
    } else {
        if (!operation.isFinished && !operation.isCancelled) {
            [self.requestManager.operationQueue addOperation:operation];
        }
    }
}

- (void)preRequestWithHandler:(MGJRequestManagerPreRequestHandler)preRequestHandler
{
    self.preRequestHandler = preRequestHandler;
}

- (void)postRequestWithHandler:(MGJRequestManagerPostRequestHandler)postRequestHandler
{
    self.postRequestHandler = postRequestHandler;
}

- (NSArray *)runningRequests
{
    return self.requestManager.operationQueue.operations;
}

- (void)cancelAllRequest
{
    [self.requestManager.operationQueue cancelAllOperations];
}

- (void)cancelHTTPOperationsWithMethod:(NSString *)method url:(NSString *)url
{
    NSError *error;
    
    NSString *pathToBeMatched = [[[self.requestManager.requestSerializer requestWithMethod:method URLString:[[NSURL URLWithString:url] absoluteString] parameters:nil error:&error] URL] path];
    
    for (NSOperation *operation in [self.requestManager.operationQueue operations]) {
        if (![operation isKindOfClass:[AFHTTPRequestOperation class]]) {
            continue;
        }
        BOOL hasMatchingMethod = !method || [method  isEqualToString:[[(AFHTTPRequestOperation *)operation request] HTTPMethod]];
        BOOL hasMatchingPath = [[[[(AFHTTPRequestOperation *)operation request] URL] path] isEqual:pathToBeMatched];
        
        if (hasMatchingMethod && hasMatchingPath) {
            [operation cancel];
        }
    }
}

- (void)addOperation:(AFHTTPRequestOperation *)operation toChain:(NSString *)chain
{
    NSString *chainName = chain ? : @"";
    if (!self.chainedOperations[chainName]) {
        self.chainedOperations[chainName] = [[NSMutableArray alloc] init];
    }
    [self.chainedOperations[chainName] addObject:operation];
    if (((NSMutableArray *)self.chainedOperations[chainName]).count == 1) {
        if (self.preRequestHandler) {
            self.preRequestHandler(operation, [operation mgj_associatedValueForKey:@"userInfo"]);
        }
        [self.requestManager.operationQueue addOperation:operation];
    }
}

- (NSArray *)operationsInChain:(NSString *)chain
{
    return self.chainedOperations[chain];
}

- (void)removeOperation:(AFHTTPRequestOperation *)operation inChain:(NSString *)chain
{
    NSString *chainName = chain ? : @"";
    if (self.chainedOperations[chainName]) {
        NSMutableArray *chainedOperations = self.chainedOperations[chainName];
        [chainedOperations removeObject:operation];
    }
}

- (void)batchOfRequestOperations:(NSArray *)operations
                   progressBlock:(void (^)(NSUInteger, NSUInteger))progressBlock
                 completionBlock:(void (^)(NSArray *))completionBlock
{
    __block dispatch_group_t group = dispatch_group_create();
    [self.batchGroups addObject:group];
    __block NSInteger finishedOperationsCount = 0;
    NSInteger totalOperationsCount = operations.count;
    
    [operations enumerateObjectsUsingBlock:^(AFHTTPRequestOperation *operation, NSUInteger idx, BOOL *stop) {
        NSMutableDictionary *operationMethodParameters = [NSMutableDictionary dictionaryWithDictionary:[self.operationMethodParameters objectForKey:operation]];
        if (operationMethodParameters) {
            dispatch_group_enter(group);
            MGJRequestManagerCompletionHandler originCompletionHandler = [(MGJRequestManagerCompletionHandler) operationMethodParameters[@"completionHandler"] copy];
            
            MGJRequestManagerCompletionHandler newCompletionHandler = ^(NSError *error, id result, BOOL isFromCache, AFHTTPRequestOperation *theOperation) {
                if (!isFromCache) {
                    if (progressBlock) {
                        progressBlock(++finishedOperationsCount, totalOperationsCount);
                    }
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (originCompletionHandler) {
                        originCompletionHandler(error, result, isFromCache, theOperation);
                    }
                    dispatch_group_leave(group);
                });
            };
            operationMethodParameters[@"completionHandler"] = newCompletionHandler;
            
            [self.operationMethodParameters setObject:operationMethodParameters forKey:operation];
            [self startOperation:operation];
            
        }
    }];
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        [self.batchGroups removeObject:group];
        if (completionBlock) {
            completionBlock(nil);
        }
    });
}

- (AFHTTPRequestOperation *)reAssembleOperation:(AFHTTPRequestOperation *)operation
{
    AFHTTPRequestOperation *newOperation = [operation copy];
    newOperation.completionBlock = [self.completionBlocks objectForKey:operation];
    // 及时移除，避免循环引用
    [self.completionBlocks removeObjectForKey:operation];
    return newOperation;
}

#pragma mark - Utils

- (void)configureCache
{
    static BOOL hasConfiguredCache;
    if (!hasConfiguredCache) {
        [self.cache trimToDate:[[NSDate date] dateByAddingTimeInterval:-self.cacheDuration] block:^(TMCache *cache) {
            
        }];
        hasConfiguredCache = YES;
    }
}

- (TMCache *)cache
{
    if (!_cache) {
        _cache = [[TMCache alloc] initWithName:MGJRequestManagerCacheDirectory];
    }
    return _cache;
}

- (AFHTTPRequestOperation *)findNextOperationInChainedOperationsBy:(AFHTTPRequestOperation *)operation
{
    // 这个实现有优化的空间
    __block AFHTTPRequestOperation *theOperation;
    __weak typeof(self) weakSelf = self;
    
    [self.chainedOperations enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSMutableArray *chainedOperations, BOOL *stop) {
        [chainedOperations enumerateObjectsUsingBlock:^(AFHTTPRequestOperation *requestOperation, NSUInteger idx, BOOL *stop) {
            if (requestOperation == operation) {
                if (idx < chainedOperations.count - 1) {
                    theOperation = chainedOperations[idx + 1];
                    *stop = YES;
                }
                [chainedOperations removeObject:requestOperation];
            }
        }];
        if (chainedOperations) {
            *stop = YES;
        }
        if (!chainedOperations.count) {
            [weakSelf.chainedOperations removeObjectForKey:key];
        }
    }];
    
    return theOperation;
}

- (NSInteger)cacheDuration
{
    return _cacheDuration ? : 3 * 24 * 60 * 60;
}

- (AFHTTPRequestOperationManager *)requestManager
{
    if (!_requestManager) {
        _requestManager = [AFHTTPRequestOperationManager manager] ;
    }
    return _requestManager;
}

- (MGJRequestManagerConfiguration *)configuration
{
    if (!_configuration) {
        _configuration = [[MGJRequestManagerConfiguration alloc] init];
    }
    return _configuration;
}

- (AFHTTPRequestOperation *)createOperationWithConfiguration:(MGJRequestManagerConfiguration *)configuration request:(NSURLRequest *)request
{
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = self.requestManager.responseSerializer;
    operation.shouldUseCredentialStorage = self.requestManager.shouldUseCredentialStorage;
    operation.credential = self.requestManager.credential;
    operation.securityPolicy = self.requestManager.securityPolicy;
    operation.completionQueue = self.requestManager.completionQueue;
    operation.completionGroup = self.requestManager.completionGroup;
    return operation;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
