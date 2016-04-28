//
//  MGJAnalyticsViewController.m
//  MGJAnalytics
//
//  Created by limboy on 12/3/14.
//  Copyright (c) 2014 mogujie. All rights reserved.
//

#import "MGJAnalyticsViewController.h"
#import "MGJAnalytics.h"
#import "MGJPTP.h"
#import <UrlEntity.h>
#import <NSString+MGJKit.h>
#import "MGJMacros.h"
#import <MGJLog.h>

static NSString *requestURLForAnalytics;

static NSDictionary *requestParametersForAnalytics;

@interface MGJAnalyticsViewController () <MGJPagePerformanceDelegate>
/**
 *  记录当前页面是否第一次出现
 */
@property (nonatomic, assign) BOOL hasAppeared;

/**
 *  记录当前页面的 refer ，当前页面重新出现时使用
 */
@property (nonatomic) NSString *referURL;

/**
 *  每个页面的 ptpRef 不变，所以需要记录下
 */
@property (nonatomic) NSString *ptpRef;

/**
 *  每个页面的 ptpCnt 不变
 */
@property (nonatomic) NSString *ptpCnt;

/**
 *  当前页面在 refer 链路中的位置
 */
@property (nonatomic) NSInteger indexInReferChain;

@property (nonatomic, readwrite) MGJPagePerformance *pagePerformance;

@end

@implementation MGJAnalyticsViewController
@synthesize requestURLForAnalytics = _requestURLForAnalytics;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.pagePerformance = [[MGJPagePerformance alloc] init];
    self.pagePerformance.delegate = self;
    [self.pagePerformance begin];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (!self.requestURLForAnalytics && requestURLForAnalytics) {
        self.requestURLForAnalytics = requestURLForAnalytics;
    }
    
    if (self.requestURLForAnalytics && ![self.requestURLForAnalytics isEqualToString:requestURLForAnalytics]) {
        UrlEntity *myRequestURLEntity = [UrlEntity URLWithString:self.requestURLForAnalytics];
        UrlEntity *globalRequestURLEntity = [UrlEntity URLWithString:requestURLForAnalytics];
        // 如果 host 不一致，就不处理了
        if ([myRequestURLEntity.host isEqualToString:globalRequestURLEntity.host]) {
            // 把两个 url 的 parameters 合起来
            NSMutableDictionary *finalParameters = [NSMutableDictionary dictionaryWithDictionary:globalRequestURLEntity.params];
            [finalParameters addEntriesFromDictionary:myRequestURLEntity.params];
            
            NSString *path = myRequestURLEntity.path ? [NSString stringWithFormat:@"/%@", myRequestURLEntity.path] : @"";
            NSString *baseURL = [NSString stringWithFormat:@"%@://%@%@", myRequestURLEntity.scheme, myRequestURLEntity.host, path];
            self.requestURLForAnalytics = [NSString mgj_combineURLWithBaseURL:baseURL parameters:finalParameters];
        }
    }
    
    if (!self.requestParametersForAnalytics && requestParametersForAnalytics) {
        self.requestParametersForAnalytics = [NSMutableDictionary dictionaryWithDictionary:requestParametersForAnalytics];
    }
    
    requestParametersForAnalytics = nil;
    requestURLForAnalytics = nil;
    
    
    // 对于一些 VC Container，可以设置该属性为 YES，这样就不会统计该 VC 的页面访问
    // 除非设置 enableTrackPageAnalyticsAfterViewWillDisappear，不然以下代码只会执行一次
    if (!self.disableTrackPageAnalytics && !([[MGJAnalytics sharedInstance].excludedClassNames containsObject:NSStringFromClass(self.class)])) {
        
        MGJShouldProcessThisObject shouldProcessThisObject = [MGJAnalytics sharedInstance].shouldProcessThisObject;
        if (shouldProcessThisObject) {
            BOOL shouldProcess = shouldProcessThisObject(self);
            if (!shouldProcess) {
                return;
            }
        }
        
        //第一次出现，或者设置了 enableTrackPageAnalyticsAfterViewWillDisappear 时，需要记录 refer，并发送页面事件
        if (!self.hasAppeared || self.enableTrackPageAnalyticsAfterViewWillDisappear) {
            
            self.referURL = [MGJAnalytics sharedInstance].refererURL = [MGJAnalytics sharedInstance].currentURL;
            [[MGJAnalytics sharedInstance].refererArray addObject:self.referURLWithoutParameters];
            self.indexInReferChain = [MGJAnalytics sharedInstance].refererArray.count;
            
            if ([MGJAnalytics sharedInstance].enableDebug) {
                NSLog(@"Analytics viewWillAppear %@ referer:%@ current:%@",  self.class, [MGJAnalytics sharedInstance].refererURL, self.requestURLForAnalytics);
            }
            
            NSMutableArray *ptpURLComponents;
            NSString *query = [[NSURL URLWithString:self.requestURLForAnalytics] query];
            NSArray *parameters = [query componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"=&"]];
            NSMutableDictionary *keyValueParameters = [NSMutableDictionary dictionary];
            
            if (parameters.count) {
                for (int i = 0; i < parameters.count; i+=2) {
                    NSString *value = parameters.count > i+1 ? [parameters objectAtIndex:i+1] : @"";
                    if (value.length) {
                        [keyValueParameters setObject:value forKey:[parameters objectAtIndex:i]];
                    }
                }
            }
            
            if ([MGJAnalytics sharedInstance].ptpURL.length) {
                // 把 ptpURL 最后的verifyCode 变成 ptpCnt 的
                NSString *ptpCntVerifyCode = [[[MGJAnalytics sharedInstance].ptpCnt componentsSeparatedByString:@"."] lastObject];
                ptpURLComponents = [NSMutableArray arrayWithArray:[[MGJAnalytics sharedInstance].ptpURL componentsSeparatedByString:@"."]];
                [ptpURLComponents removeLastObject];
                [ptpURLComponents addObject:ptpCntVerifyCode];
                
                if (ptpURLComponents.count == 5) {
                    NSString *cValue = ptpURLComponents[2];
                    if (self.requestURLForAnalytics) {
                        if (keyValueParameters.allKeys.count) {
                            // 接入麦田
                            if (keyValueParameters[@"mt"]) {
                                // 对 mt 做处理
                                NSMutableArray *mtComponents = [NSMutableArray arrayWithArray:[keyValueParameters[@"mt"] componentsSeparatedByString:@"."]];
                                if (mtComponents.count) {
                                    mtComponents[0] = @"_mt";
                                    cValue = [mtComponents componentsJoinedByString:@"-"];
                                }
                            }
                            ptpURLComponents[2] = cValue;
                        }
                    }
                }
            }
            
            // url_ptp 优先级最高，这个是从通知那里来的
            if (keyValueParameters[@"url_ptp"]) {
                ptpURLComponents = [NSMutableArray arrayWithArray:@[@"0", @"0", @"0", @"0", @"0"]];
                NSMutableArray *ptpURL = [NSMutableArray arrayWithArray:[keyValueParameters[@"url_ptp"] componentsSeparatedByString:@"."]];
                [ptpURL enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    if (![((NSString *)obj) isEqualToString:@"0"]) {
                        ptpURLComponents[idx] = obj;
                    }
                }];
            }
            
            [MGJAnalytics sharedInstance].ptpURL = [ptpURLComponents componentsJoinedByString:@"."];
            [MGJAnalytics trackPageWithRequestURL:self.requestURLForAnalytics parameters:self.requestParametersForAnalytics];
            
            // 同时设置 ptp-ref = ptp-url，供下次调用时使用
            [MGJAnalytics sharedInstance].ptpRef = [MGJAnalytics sharedInstance].ptpURL;
            self.ptpRef = [MGJAnalytics sharedInstance].ptpURL;
            self.ptpCnt = [MGJAnalytics sharedInstance].ptpCnt;
        }
        else //第二次出现，并且不需要记录页面事件时，只改动当前的 refer
        {
            //移除 referer 数组中，当前页面及之后的所有 referer
            if (self.indexInReferChain < [MGJAnalytics sharedInstance].refererArray.count) {
               [[MGJAnalytics sharedInstance].refererArray removeObjectsInRange:NSMakeRange(self.indexInReferChain, [MGJAnalytics sharedInstance].refererArray.count - self.indexInReferChain)];
            }
            
            [MGJAnalytics sharedInstance].refererURL = self.referURL;
            [MGJAnalytics sharedInstance].ptpRef = self.ptpRef;
            [MGJAnalytics sharedInstance].ptpCnt = self.ptpCnt;
        }
        
        //无论如何都要改变 currentURL
        [MGJAnalytics sharedInstance].currentURL = self.requestURLForAnalytics;
    }
    self.hasAppeared = YES;
}

- (NSString *)requestURLForAnalytics
{
    return _requestURLForAnalytics ? : @"null";
}

- (void)setRequestURLForAnalytics:(NSString *)requestURLForAnalytics
{
    // URL 有可能存在未排序的情况，统一处理下
    if (!MGJ_IS_EMPTY(requestURLForAnalytics)) {
        UrlEntity *urlEntity = [UrlEntity URLWithString:requestURLForAnalytics];
        NSString *path = !MGJ_IS_EMPTY(urlEntity.path) ? [@"/" stringByAppendingString:urlEntity.path] : @"";
        NSString *baseURL = [NSString stringWithFormat:@"%@://%@%@", urlEntity.scheme, urlEntity.host, path];
        _requestURLForAnalytics = [NSString mgj_combineURLWithBaseURL:baseURL parameters:urlEntity.params];
    }
    else {
        _requestURLForAnalytics = @"null";
    }
}

- (NSString *)requestURLForAnalyticsWithoutParameters
{
    NSString * requestURLForAnalyticsWithoutParameters = self.requestURLForAnalytics;
    NSRange range = [requestURLForAnalyticsWithoutParameters rangeOfString:@"?"];
    if (range.location != NSNotFound) {
        requestURLForAnalyticsWithoutParameters = [requestURLForAnalyticsWithoutParameters substringToIndex:range.location];
    }
    return requestURLForAnalyticsWithoutParameters;
}

- (NSString *)referURLWithoutParameters
{
    NSString * referURLWithoutParameters = self.referURL;
    NSRange range = [referURLWithoutParameters rangeOfString:@"?"];
    if (range.location != NSNotFound) {
        referURLWithoutParameters = [referURLWithoutParameters substringToIndex:range.location];
    }
    return referURLWithoutParameters;
}

+ (void)setRequestURLForAnalytics:(NSString *)requestURL
{
    requestURLForAnalytics = requestURL;
}

+ (void)setRequestURLParametersForAnalytics:(NSDictionary *)requestParams
{
    requestParametersForAnalytics = requestParams;
}

- (void)didRecordedPagePerformanceWithEventID:(NSString *)eventID stage1:(CFTimeInterval)stage1 stage2:(CFTimeInterval)stage2 stage3:(CFTimeInterval)stage3
{
    if (self.requestURLForAnalytics) {
        UrlEntity *entity = [UrlEntity URLWithString:self.requestURLForAnalytics];
        NSString *url = [NSString stringWithFormat:@"%@:%@/%@", entity.scheme, entity.host, entity.path];
        MGJLog(@"page: %@ url: %@ duration: %f", self.class, url, stage1 + stage2 + stage3);
        NSInteger wifi = [MGJAnalytics networkStatus] == MGJAnalyticsNetworkStatusWiFi ? 1 : 0;
        [MGJAnalytics trackEvent:eventID parameters:@{@"url": url,
                                                      @"wifi": @(wifi),
                                                      @"stage1": @(stage1),
                                                      @"stage2": @(stage2),
                                                      @"stage3": @(stage3)}];
    }
}

@end
