//
//  HTTPDNS.m
//  Example
//
//  Created by limboy on 4/20/15.
//  Copyright (c) 2015 juangua. All rights reserved.
//

/**
 *  TODO 
 *  根据IP细分 wifi
 */

#import "MGJHTTPDNS.h"
#import "MGJRequestManager.h"
#import "NSString+MGJKit.h"
#import "UIDevice+MGJKit.h"
#import "MGJPing.h"
#import "UIDevice+MGJKit.h"
#import "UIApplication+MGJKit.h"
#import "NSObject+MGJKit.h"
#import "MGJEXTScope.h"
#import "MGJBatchRequesterStore.h"
#import <NetworkCheck.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

static NSInteger const SUCCESS_CODE = 1001;
static NSString * const HOSTKEY_FOR_USER_DEFAULTS = @"httpdns_host";
static NSString * const IPSERVICEIPSKEY_FOR_USER_DEFAULTS = @"httpdns_ipserviceips";

static MGJHTTPDNS *MGJHTTPDNS_INSTANCE;

#define NETWORK_CELLULAR_CHINA_MOBILE @"中国移动"
#define NETWORK_CELLULAR_CHINA_UNICOM @"中国联通"
#define NETWORK_CELLULAR_CHINA_TELECOM @"中国电信"

#define NETWORK_CELLULAR @"cellular"
#define NETWORK_WIFI @"wifi"
#define NETWORK_UNKOWN @"unknown"

@implementation MGJHTTPDNSIPSpec @end
@implementation MGJHTTPDNSDomainAndIPs @end
@implementation MGJHTTPDefaultDomainAndIPS @end

@interface MGJHTTPDNS()
@property (nonatomic, copy) NSString *ipServiceDefaultDomain;
@property (nonatomic) NSMutableArray *ipServiceIPs;
@property (nonatomic) NSMutableDictionary *hosts;

@property (nonatomic, assign) BOOL ipServiceIPsNotAvailable;
@property (nonatomic) NSMutableArray *hijackedDomains;

@property (nonatomic) NSString *networkStatus;
@property (nonatomic) MGJRequestManager *requestManager;
@property (nonatomic) NSString *wwanDetail;
@end

@implementation MGJHTTPDNS

- (void)dealloc
{
    [self.requestManager removeObserver:self forKeyPath:@"networkStatus"];
}

- (instancetype)initWithDefaultDomainAndIPs:(NSArray *)defaultDomainAndIPs ipServiceDefaultDomain:(NSString *)ipServiceDefaultDomain ipServiceDefaultIPs:(NSArray *)ipServiceDefaultIPs
{
    NSAssert(defaultDomainAndIPs.count, @"defaultDomainAndIPs 不能为空");
    NSAssert([defaultDomainAndIPs[0] isKindOfClass:[MGJHTTPDefaultDomainAndIPS class]], @" defaultDomainAndIPs 里的 item 必须是 MGJHTTPDefaultDomainAndIPS 的实例");
    if (self = [super init]) {
        self.requestManager = [[MGJRequestManager alloc] init];
        self.hosts = [self hostsInLocal] ? : [self parseDefaultDomainAndIPs:defaultDomainAndIPs];
        self.ipServiceIPs = [NSMutableArray arrayWithArray:[self ipServiceIPsInLocal] ? : ipServiceDefaultIPs];
        self.ipServiceDefaultDomain = ipServiceDefaultDomain;
        self.hijackedDomains = [NSMutableArray array];
        [self.requestManager addObserver:self forKeyPath:@"networkStatus" options:NSKeyValueObservingOptionNew context:nil];
        MGJHTTPDNS_INSTANCE = self;
        
        self.wwanDetail = @"";
        CTTelephonyNetworkInfo *telephonyInfo = [CTTelephonyNetworkInfo new];
        if ([telephonyInfo respondsToSelector:@selector(currentRadioAccessTechnology)]) {
            self.wwanDetail = [self mapTo2G3G4G:telephonyInfo.currentRadioAccessTechnology];
        }
        
        @weakify(self);
        [self mgj_observeNotification:CTRadioAccessTechnologyDidChangeNotification handler:^(NSNotification *notification) {
            @strongify(self);
            if ([telephonyInfo respondsToSelector:@selector(currentRadioAccessTechnology)]) {
                self.wwanDetail = [self mapTo2G3G4G:telephonyInfo.currentRadioAccessTechnology];
            }
        }];
        
    }
    return self;
}


- (NSString *)mapTo2G3G4G:(NSString *)radioAccess
{
    NSString *result = @"";
    if (!radioAccess.length) {
        return result;
    }
    
    NSArray *network2G = @[CTRadioAccessTechnologyGPRS, CTRadioAccessTechnologyEdge, CTRadioAccessTechnologyCDMA1x];
    NSArray *network3G = @[CTRadioAccessTechnologyWCDMA, CTRadioAccessTechnologyHSDPA, CTRadioAccessTechnologyHSUPA, CTRadioAccessTechnologyCDMAEVDORev0, CTRadioAccessTechnologyCDMAEVDORevA, CTRadioAccessTechnologyCDMAEVDORevB, CTRadioAccessTechnologyeHRPD];
    NSArray *network4G = @[CTRadioAccessTechnologyLTE];
    
    if ([network2G containsObject:radioAccess]) {
        result = @"2G";
    } else if ([network3G containsObject:radioAccess]) {
        result = @"3G";
    } else if ([network4G containsObject:radioAccess]) {
        result = @"4G";
    }
    return result;
}

#pragma mark - Public

+ (void)findFastestIPForDomain:(NSString *)domain
{
    if (MGJHTTPDNS_INSTANCE) {
        
        if (![MGJHTTPDNS_INSTANCE.networkStatus isEqualToString: NETWORK_UNKOWN]) {
            if ([MGJHTTPDNS_INSTANCE.networkStatus isEqualToString:NETWORK_WIFI]) {
                MGJHTTPDNSIPSpec *ipSpec = (MGJHTTPDNSIPSpec *)MGJHTTPDNS_INSTANCE.hosts[domain][NETWORK_WIFI];
                if (ipSpec) {
                    [MGJHTTPDNS_INSTANCE testSpeedForIPSpec:ipSpec domain:domain];
                }
            } else {
                NSString *cellular = [UIDevice mgj_cellularProvider];
                NSDictionary *domainInfo = ((NSDictionary *)MGJHTTPDNS_INSTANCE.hosts[domain]);
                if ([domainInfo.allKeys containsObject:cellular]) {
                    MGJHTTPDNSIPSpec *ipSpec = (MGJHTTPDNSIPSpec *)MGJHTTPDNS_INSTANCE.hosts[domain][cellular];
                    if (ipSpec) {
                        [MGJHTTPDNS_INSTANCE testSpeedForIPSpec:ipSpec domain:domain];
                    }
                } else {
                    [MGJHTTPDNS_INSTANCE requestIPServiceWithIPsforNetwork:NETWORK_CELLULAR domains:@[domain]];
                }
            }
        }
    }
}

+ (void)reportIP:(NSString *)ip withDuration:(NSTimeInterval)duration
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        if (MGJHTTPDNS_INSTANCE && ip.length && [ip componentsSeparatedByString:@"."].count == 4) {
            [MGJHTTPDNS_INSTANCE postIPSpeedsToServer:@{ip: @(duration)} selectedIP:ip network:MGJHTTPDNS_INSTANCE.networkStatus];
        }
    });
}

+ (void)domainIsHijacked:(NSString *)domain
{
    if (MGJHTTPDNS_INSTANCE) {
        if (![MGJHTTPDNS_INSTANCE.hijackedDomains containsObject:domain]) {
            [MGJHTTPDNS_INSTANCE.hijackedDomains addObject:domain];
        }
    }
}

+ (void)reportURL:(NSString *)url withMethod:(NSString *)method type:(NSString *)type diagnosis:(NSDictionary *)diagnosis startImmediately:(BOOL)startImmediately
{
    if (MGJHTTPDNS_INSTANCE) {
        NSString *postURL = [NSString stringWithFormat:@"http://%@/ipservice?func=feedback&type=diagnosis&ua=ios&did=%@&version=%@", MGJHTTPDNS_INSTANCE.ipServiceTestIP ? : MGJHTTPDNS_INSTANCE.ipServiceDefaultDomain, [UIDevice mgj_uniqueID] ? : @"", [UIApplication mgj_appStoreVersion]];
        NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
        parameters[@"network"] = MGJHTTPDNS_INSTANCE.networkStatus;
        if ([MGJHTTPDNS_INSTANCE.networkStatus isEqualToString:NETWORK_CELLULAR]) {
            parameters[@"carrier"] = [NSString stringWithFormat:@"%@%@", [UIDevice mgj_cellularProvider], MGJHTTPDNS_INSTANCE.wwanDetail];
        }
        parameters[@"method"] = method;
        parameters[@"url"] = url;
        parameters[@"type"] = type;
        parameters[@"createdAt"] = @([[NSDate date] timeIntervalSince1970]);
        parameters[@"diagnosis"] = diagnosis;
        
        if (startImmediately) {
            [MGJHTTPDNS_INSTANCE.requestManager POST:postURL parameters:@{@"requests": @[parameters]} configurationHandler:^(MGJRequestManagerConfiguration *configuration) {
                configuration.requestSerializer = [AFJSONRequestSerializer serializer];
                configuration.builtinParameters = @{};
            } completionHandler:^(NSError *error, id result, BOOL isFromCache, AFHTTPRequestOperation *operation) {
                if (error) {
                    //MGJLog(@"error:%@", error);
                } else {
                    //MGJLog(@"result:%@", result);
                }
            } startImmediately:YES];
        } else {
            static MGJBatchRequesterStore *store;
            if (!store) {
                store = [[MGJBatchRequesterStore alloc] initWithFilePath:@"httpdns_report.log"];
            }
            NSData *data = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];
            NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            [store appendData:[NSString stringWithFormat:@"%@,", dataString]];
            if (store.timeIntervalSinceCreated > 60) {
                [store consumeDataWithHandler:^(NSString *content, MGJBatchRequesterStoreConsumeSuccessBlock successBlock, MGJBatchRequesterStoreConsumeFailureBlock failureBlock) {
                    NSString *arrayString = [NSString stringWithFormat:@"{\"requests\": [%@]}", content];
                    NSDictionary *parameters = [NSJSONSerialization JSONObjectWithData:[arrayString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
                    if (parameters) {
                        [MGJHTTPDNS_INSTANCE.requestManager POST:postURL parameters:parameters configurationHandler:^(MGJRequestManagerConfiguration *configuration) {
                            configuration.requestSerializer = [AFJSONRequestSerializer serializer];
                            configuration.builtinParameters = @{};
                        } completionHandler:^(NSError *error, id result, BOOL isFromCache, AFHTTPRequestOperation *operation) {
                            if (error) {
                                failureBlock();
                            } else {
                                successBlock();
                            }
                        } startImmediately:YES];
                        
                    }
                }
                 ];
            }
        }
    }
}

- (NSString *)hostForDomain:(NSString *)domain
{
    __block NSString *host = domain;
    
    // App 刚打开时，网络状况不明，这时已经有请求发送了，默认走 wifi
    NSString *networkStatus = [self.networkStatus isEqual: NETWORK_UNKOWN] ? NETWORK_WIFI : self.networkStatus;
    
    MGJHTTPDNSIPSpec *ipSpec;
    if ([networkStatus isEqualToString:NETWORK_WIFI]) {
        ipSpec = self.hosts[domain][NETWORK_WIFI];
        NSArray *ips = ipSpec ? ipSpec.ips : nil;
        host = ips.count ? ips[0] : domain;
    } else if ([networkStatus isEqualToString:NETWORK_CELLULAR]) {
        NSString *carrier = [UIDevice mgj_cellularProvider];
        ipSpec = self.hosts[domain][carrier];
        NSArray *ips = ipSpec ? ipSpec.ips : nil;
        host = ips.count ? ips[0] : domain;
        if (!ipSpec) {
            [self requestIPServiceWithIPsforNetwork:carrier domains:@[domain]];
        }
    }
    
    void (^requestForNewIPs)() = ^{
        
        [self requestIPServiceWithIPsforNetwork:networkStatus domains:@[domain]];
        // 有可能之前的请求正在执行，直接用 IP 也不会有什么风险，就算慢了，也会重新向 IP Service 去要
        //                if (![self.hijackedDomains containsObject:domain]) {
        //                    host = domain;
        //                }
    };
    
    if (ipSpec) {
        if (!ipSpec.date && !ipSpec.timeout) {
            requestForNewIPs();
        }
        else if (ipSpec.date && ipSpec.timeout) {
            if ([[NSDate date] timeIntervalSinceDate:ipSpec.date] > ipSpec.timeout) {
                requestForNewIPs();
            }
        }
    }
    
    return host;
}

#pragma mark - Utils

- (NSMutableDictionary *)parseDefaultDomainAndIPs:(NSArray *)defaultDomainAndIPs
{
    NSMutableDictionary *hosts = [[NSMutableDictionary alloc] init];
    [defaultDomainAndIPs enumerateObjectsUsingBlock:^(MGJHTTPDefaultDomainAndIPS *defaultDomainAndIP, NSUInteger idx, BOOL *stop) {
        NSAssert(defaultDomainAndIP.domain, @"domain 不能为空");
        NSMutableDictionary *host = [[NSMutableDictionary alloc] init];
        if (defaultDomainAndIP.chinaMobileIPs.count) {
            MGJHTTPDNSIPSpec *ipSpec = [[MGJHTTPDNSIPSpec alloc] init];
            ipSpec.ips = [NSMutableArray arrayWithArray:defaultDomainAndIP.chinaMobileIPs];
            ipSpec.network = NETWORK_CELLULAR_CHINA_MOBILE;
            host[NETWORK_CELLULAR_CHINA_MOBILE] = ipSpec;
        }
        if (defaultDomainAndIP.chinaUnicomIPs.count) {
            MGJHTTPDNSIPSpec *ipSpec = [[MGJHTTPDNSIPSpec alloc] init];
            ipSpec.ips = [NSMutableArray arrayWithArray:defaultDomainAndIP.chinaUnicomIPs];
            ipSpec.network = NETWORK_CELLULAR_CHINA_UNICOM;
            host[NETWORK_CELLULAR_CHINA_UNICOM] = ipSpec;
        }
        if (defaultDomainAndIP.chinaTelecomIPs.count) {
            MGJHTTPDNSIPSpec *ipSpec = [[MGJHTTPDNSIPSpec alloc] init];
            ipSpec.ips = [NSMutableArray arrayWithArray:defaultDomainAndIP.chinaTelecomIPs];
            ipSpec.network = NETWORK_CELLULAR_CHINA_TELECOM;
            host[NETWORK_CELLULAR_CHINA_TELECOM] = ipSpec;
        }
        if (defaultDomainAndIP.wifiIPs.count) {
            MGJHTTPDNSIPSpec *ipSpec = [[MGJHTTPDNSIPSpec alloc] init];
            ipSpec.ips = [NSMutableArray arrayWithArray:defaultDomainAndIP.wifiIPs];
            ipSpec.network = NETWORK_WIFI;
            host[NETWORK_WIFI] = ipSpec;
        }
        hosts[defaultDomainAndIP.domain] = host;
    }];
    return hosts;
}

- (NSArray *)ipServiceIPsInLocal
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults valueForKey:IPSERVICEIPSKEY_FOR_USER_DEFAULTS];
}

- (NSMutableDictionary *)hostsInLocal
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *data;
    // 做一下保护，避免其中的数据有问题，导致频繁 Crash
    @try {
        data = [defaults objectForKey:HOSTKEY_FOR_USER_DEFAULTS];
    }
    @catch (NSException *exception) {
        data = nil;
    }
    @finally {
        
    }
    return data ? [NSKeyedUnarchiver unarchiveObjectWithData:data] : nil;
}

- (void)saveHostsToLocal
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.hosts];
    [defaults setObject:data forKey:HOSTKEY_FOR_USER_DEFAULTS];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [defaults synchronize];
    });
}

- (void)saveIPServiceIPsToLocal
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.ipServiceIPs forKey:IPSERVICEIPSKEY_FOR_USER_DEFAULTS];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [defaults synchronize];
    });
}

- (NSString *)networkStatus
{
    MGJRequestManager *requestManager = self.requestManager;
    _networkStatus = NETWORK_UNKOWN;
    if (requestManager.networkStatus == AFNetworkReachabilityStatusReachableViaWiFi) {
        _networkStatus = NETWORK_WIFI;
    } else if (requestManager.networkStatus == AFNetworkReachabilityStatusReachableViaWWAN) {
        _networkStatus = NETWORK_CELLULAR;
    }
    return _networkStatus;
}

- (void)findFastestIPServiceIP
{
    if ([self.networkStatus isEqualToString:NETWORK_WIFI] || [self.networkStatus isEqualToString:NETWORK_CELLULAR]) {
        __block NSInteger successCount = 0;
        __block NSInteger failedCount = 0;
        __block NSInteger index = 0;
        NSInteger ipCount = self.ipServiceIPs.count;
        
        static BOOL isFinding;
        if (isFinding) {
            return;
        }
        isFinding = YES;
        
        NSMutableDictionary *ipSpeeds = [[NSMutableDictionary alloc] init];
        
        // quick fix
        // 基本不会出现这个问题，保险起见
        if (![self.ipServiceIPs respondsToSelector:@selector(removeObject:)]) {
            self.ipServiceIPs = [NSMutableArray arrayWithArray:self.ipServiceIPs];
        }
        
        @weakify(self);
        [[self.ipServiceIPs copy] enumerateObjectsUsingBlock:^(NSString *ip, NSUInteger idx, BOOL *stop) {
            [MGJPing pingAddress:ip completion:^(MGJPingResult *result) {
                ipSpeeds[ip] = @((int)(result.time * 1000) / 1000.f);
                @strongify(self);
                if (result.status == MGJPingStatusSuccess) {
                    [self.ipServiceIPs removeObject:ip];
                    if (self.ipServiceIPs.count >= successCount) {
                        [self.ipServiceIPs insertObject:ip atIndex:successCount++];
                    }
                    self.ipServiceIPsNotAvailable = NO;
                } else if (result.status == MGJPingStatusTimeout) {
                    failedCount++;
                }
                
                if (failedCount == ipCount) {
                    self.ipServiceIPsNotAvailable = YES;
                }
                
                if (++index >= ipCount) {
                    // 手动排下序
                    NSMutableArray *sortedIPs = [NSMutableArray arrayWithArray:@[]];
                    [ipSpeeds enumerateKeysAndObjectsUsingBlock:^(NSString *ip, NSNumber *time, BOOL *stop) {
                        if (sortedIPs.count <= 0) {
                            [sortedIPs addObject:ip];
                        } else {
                            CGFloat firstTime = [ipSpeeds[sortedIPs[0]] floatValue];
                            if (firstTime > [time floatValue]) {
                                [sortedIPs insertObject:ip atIndex:0];
                            } else {
                                [sortedIPs addObject:ip];
                            }
                        }
                    }];
                    self.ipServiceIPs = [sortedIPs mutableCopy];
                    isFinding = NO;
                }
            }];
        }];
    }
}

- (void)testSpeedForIPSpec:(MGJHTTPDNSIPSpec *)ipSpec domain:(NSString *)domain
{
    __block NSInteger timeoutIPCount = 0;
    __block NSInteger successIPCount = 0;
    __block NSInteger index = 0;
    NSInteger ipsCount = ipSpec.ips.count;
    
    NSString *networkStatus = self.networkStatus;
    NSMutableDictionary *ipSpeeds = [[NSMutableDictionary alloc] init];
    
    @weakify(ipSpec);
    [[ipSpec.ips copy] enumerateObjectsUsingBlock:^(NSString *ip, NSUInteger idx, BOOL *stop) {
        NSString *url = [NSString stringWithFormat:@"http://%@/ipavailable.html?ts=%.3f", ip, [[NSDate date] timeIntervalSince1970]];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]
                                                                    cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                                timeoutInterval:3];
        [request setValue:domain forHTTPHeaderField:@"Host"];
        
        [MGJPing pingRequest:request verifyString:@"1001" completion:^(MGJPingResult *result) {
            @strongify(ipSpec);
            if (result.status == MGJPingStatusSuccess) {
                [ipSpec.ips removeObject:ip];
                if (ipSpec.ips.count >= successIPCount) {
                    [ipSpec.ips insertObject:ip atIndex:successIPCount++];
                }
            } else if (result.status == MGJPingStatusTimeout) {
                [ipSpec.ips removeObject:ip];
                timeoutIPCount++;
            }
            
            if (ipsCount == timeoutIPCount) {
                // 10秒后向服务端再要一次
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self requestIPServiceWithIPsforNetwork:self.networkStatus domains:domain.length ? @[domain] : nil];
                });
            }
            
            ipSpeeds[ip] = @((int)(result.time * 1000) / 1000.f);
            
            if (++index >= ipsCount) {
                
                // 手动排下序，只要保证第一个是最小的就好
                NSMutableArray *sortedIPs = [NSMutableArray arrayWithArray:@[]];
                [ipSpeeds enumerateKeysAndObjectsUsingBlock:^(NSString *ip, NSNumber *time, BOOL *stop) {
                    if (sortedIPs.count <= 0) {
                        [sortedIPs addObject:ip];
                    } else {
                        CGFloat firstTime = [ipSpeeds[sortedIPs[0]] floatValue];
                        if (firstTime > [time floatValue]) {
                            [sortedIPs insertObject:ip atIndex:0];
                        } else {
                            [sortedIPs addObject:ip];
                        }
                    }
                }];
                
                ipSpec.ips = sortedIPs;
                
                NSString *selectedIP = ipSpec.ips.count > 0 ? ipSpec.ips[0] : @"";
                [self postIPSpeedsToServer:ipSpeeds selectedIP:selectedIP network:networkStatus];
            }
        }];
    }];
}

- (void)postIPSpeedsToServer:(NSDictionary *)ipSpeeds selectedIP:(NSString *)selectedIP network:(NSString *)network
{
    NSString *postURL = [NSString stringWithFormat:@"http://%@/ipservice?func=feedback&type=serverdelay&ua=ios&did=%@&version=%@", self.ipServiceTestIP ? : self.ipServiceDefaultDomain, [UIDevice mgj_uniqueID] ? : @"", [UIApplication mgj_appStoreVersion]];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    parameters[@"network"] = network;
    if ([network isEqualToString:NETWORK_CELLULAR]) {
        parameters[@"carrier"] = [NSString stringWithFormat:@"%@%@", [UIDevice mgj_cellularProvider], self.wwanDetail];
    }
    parameters[@"ipsTimeout"] = ipSpeeds;
    parameters[@"selectedIP"] = selectedIP;
    
    [self.requestManager POST:postURL parameters:parameters configurationHandler:^(MGJRequestManagerConfiguration *configuration) {
        configuration.requestSerializer = [AFJSONRequestSerializer serializer];
        configuration.builtinParameters = @{};
    } completionHandler:^(NSError *error, id result, BOOL isFromCache, AFHTTPRequestOperation *operation) {
        if (error) {
            //MGJLog(@"error:%@", error);
        } else {
            //MGJLog(@"result:%@", result);
        }
    } startImmediately:YES];
}

- (void)requestIPServiceWithIPsforNetwork:(NSString *)network domains:(NSArray *)domains
{
    if (!self.ipServiceIPsNotAvailable) {
        [self requestIPServiceWithHost:self.ipServiceIPs[0] network:network domains:domains];
    } else {
        [self requestIPServiceWithDomainForNetwork:network domains:domains];
    }
}

- (void)requestIPServiceWithDomainForNetwork:(NSString *)network domains:(NSArray *)domains
{
    [self requestIPServiceWithHost:self.ipServiceDefaultDomain network:network domains:domains];
}

- (void)requestIPServiceWithHost:(NSString *)host network:(NSString *)network domains:(NSArray *)domains
{
    if (![network isEqualToString:NETWORK_WIFI] && ![network isEqualToString:NETWORK_CELLULAR]) {
        return;
    }
    
    static NSInteger failedRequests = 0;
    
    static BOOL isRequesting;
    if (isRequesting) {
        return;
    }
    
    isRequesting = YES;
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:@{@"func": @"dns_resolver"}];
    parameters[@"network"] = [network isEqualToString:NETWORK_WIFI] ? @"wifi" : @"cellular";
    if ([network isEqualToString:NETWORK_CELLULAR]) {
        parameters[@"carrier"] = [UIDevice mgj_cellularProvider];
    }
    domains = domains ? : self.hosts.allKeys;
    parameters[@"domains"] = [domains componentsJoinedByString:@","];
    parameters[@"ua"] = @"ios";
    parameters[@"did"] = [UIDevice mgj_uniqueID] ? : @"";
    parameters[@"version"] = [UIApplication mgj_appStoreVersion];
    
    NSString *networkKey = parameters[@"carrier"] ? : parameters[@"network"];
    __weak typeof(self) weakSelf = self;
    
    [self.requestManager GET:[NSString stringWithFormat:@"http://%@/ipservice", host]
                  parameters:parameters
        configurationHandler:^(MGJRequestManagerConfiguration *configuration) {
            configuration.cacheGETResults = NO;
            configuration.builtinParameters = @{};
        }
           completionHandler:^(NSError *error, id result, BOOL isFromCache, AFHTTPRequestOperation *operation) {
               isRequesting = NO;
               NSDictionary *status = result[@"status"];
               if (status) {
                   if ([status[@"code"] intValue] == SUCCESS_CODE) {
                       failedRequests = 0;
                       
                       NSArray *dns = result[@"result"][@"dns"];
                       [dns enumerateObjectsUsingBlock:^(NSDictionary *domainInfo, NSUInteger idx, BOOL *stop) {
                           NSString *domain = domainInfo[@"domain"];
                           NSArray *ips = domainInfo[@"ips"];
                           if (domain && weakSelf.hosts[domain]) {
                               MGJHTTPDNSIPSpec *ipSpec = weakSelf.hosts[domain][networkKey];
                               if (!ipSpec) {
                                   ipSpec = [[MGJHTTPDNSIPSpec alloc] init];
                                   ipSpec.ips = [NSMutableArray arrayWithArray:ips];
                               } else {
                                   NSMutableArray *tempIPs = [NSMutableArray arrayWithArray:ips];
                                   [tempIPs addObjectsFromArray:ipSpec.ips];
                                   ipSpec.ips = [NSMutableArray arrayWithArray:[tempIPs valueForKeyPath:@"@distinctUnionOfObjects.self"]];
                                   NSInteger maxItems = [domainInfo[@"maxItems"] intValue];
                                   if (maxItems && ipSpec.ips.count > maxItems) {
                                       ipSpec.ips = [NSMutableArray arrayWithArray:[ipSpec.ips subarrayWithRange:NSMakeRange(0, maxItems)]];
                                   }
                               }
                               ipSpec.date = [NSDate date];
                               ipSpec.timeout = [domainInfo[@"timeout"] intValue];
                               ipSpec.network = networkKey;
                               
                               weakSelf.hosts[domain][networkKey] = ipSpec;
                               [weakSelf saveHostsToLocal];
                               [weakSelf.class findFastestIPForDomain:domain];
                           }
                       }];
                       
                       NSArray *ipServiceIPs = result[@"result"][@"ipservice"];
                       if (ipServiceIPs.count) {
                           weakSelf.ipServiceIPs = [NSMutableArray arrayWithArray:ipServiceIPs];
                           [weakSelf saveIPServiceIPsToLocal];
                           [weakSelf findFastestIPServiceIP];
                       }
                   }
               }
               if (error && ++failedRequests < 2) {
                   [weakSelf findFastestIPServiceIP];
               }
           }
            startImmediately:YES];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"networkStatus"]) {
        AFNetworkReachabilityStatus status = [change[NSKeyValueChangeNewKey] intValue];
        if (status == AFNetworkReachabilityStatusReachableViaWWAN || status == AFNetworkReachabilityStatusReachableViaWiFi) {
            // 看下，如果没有过期，就不再发送请求了
            NSString *currentNetwork = status == AFNetworkReachabilityStatusReachableViaWiFi ? NETWORK_WIFI : [UIDevice mgj_cellularProvider];
            NSMutableArray *domains = [[NSMutableArray alloc] init];
            
            [self.hosts enumerateKeysAndObjectsUsingBlock:^(NSString *domain, NSDictionary *ipSpecs, BOOL *stop) {
                [ipSpecs enumerateKeysAndObjectsUsingBlock:^(NSString *network, MGJHTTPDNSIPSpec *ipSpec, BOOL *stop) {
                    if ([currentNetwork isEqualToString:network]) {
                        if ([[NSDate date] timeIntervalSinceDate:ipSpec.date] > ipSpec.timeout) {
                            [domains addObject:domain];
                        }
                        *stop = YES;
                    }
                }];
            }];
            if (domains.count) {
                [self requestIPServiceWithIPsforNetwork:self.networkStatus domains:domains];
            }
        }
    }
}

@end
