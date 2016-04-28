//
//  HTTPDNS.h
//  Example
//
//  Created by limboy on 4/20/15.
//  Copyright (c) 2015 juangua. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MGJHTTPDNSIPSpec : NSObject
@property (nonatomic) NSString *network;
@property (nonatomic) NSMutableArray *ips;
@property (nonatomic) NSInteger timeout;
@property (nonatomic) NSDate *date;
@end

@interface MGJHTTPDNSDomainAndIPs : NSObject
@property (nonatomic, copy) NSString *domain;
@property (nonatomic) NSArray *ipSpecs;
@end

@interface MGJHTTPDefaultDomainAndIPS : NSObject
@property (nonatomic) NSString *domain;
@property (nonatomic) NSArray *chinaMobileIPs;
@property (nonatomic) NSArray *chinaUnicomIPs;
@property (nonatomic) NSArray *chinaTelecomIPs;
@property (nonatomic) NSArray *wifiIPs;
@end

@interface MGJHTTPDNS : NSObject

- (instancetype)initWithDefaultDomainAndIPs:(NSArray *)defaultDomainAndIPs ipServiceDefaultDomain:(NSString *)ipServiceDefaultDomain ipServiceDefaultIPs:(NSArray *)ipServiceDefaultIPs;

@property (nonatomic, copy) NSString *ipServiceTestIP;

/**
 *  根据传过来的 domain 返回对应的 ip
 */
- (NSString *)hostForDomain:(NSString *)domain;

/**
 *  当访问缓慢时，可以调用这个方法
 */
+ (void)findFastestIPForDomain:(NSString *)domain;

/**
 *  上报某个 URL 的具体诊断信息
 */
+ (void)reportURL:(NSString *)url
       withMethod:(NSString *)method
             type:(NSString *)type // 可选的 type 为 requestFailed / monitor
        diagnosis:(NSDictionary *)diagnosis
 startImmediately:(BOOL)startImmediately;

/**
 *  当发现某个域名被劫持时，调用此方法
 */
+ (void)domainIsHijacked:(NSString *)domain;

@end
