//
//  MGJPing.m
//  PingTester
//
//  Created by limboy on 4/21/15.
//
//

#import "MGJPing.h"
#import <AFNetworking/AFNetworking.h>
#import "MGJEXTScope.h"
#import "NSObject+MGJSingleton.h"
#include <arpa/inet.h>

static NSMutableArray *pingManagers;

@implementation MGJPingResult @end

@interface MGJPing () <Singleton>
@end

@implementation MGJPing

+ (void)pingAddress:(NSString *)address completion:(void (^)(MGJPingResult *result))completion
{
    [self pingAddress:address timeout:3 completion:completion];
}

+ (void)pingAddress:(NSString *)address timeout:(NSInteger)timeout completion:(void (^)(MGJPingResult *))completion
{
    if (!pingManagers) {
        pingManagers = [NSMutableArray array];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        struct sockaddr_in ipAddress;
        ipAddress.sin_len = sizeof(ipAddress);
        ipAddress.sin_family = AF_INET;
        ipAddress.sin_port = htons(80);
        ipAddress.sin_addr.s_addr = inet_addr([address UTF8String]);

        AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager managerForAddress:&ipAddress];
        
        NSDate *startDate = [NSDate date];
        @weakify(manager);
        [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            @strongify(manager);
            MGJPingResult *result = [[MGJPingResult alloc] init];
            if (status == AFNetworkReachabilityStatusReachableViaWiFi || status == AFNetworkReachabilityStatusReachableViaWWAN) {
                result.status = MGJPingStatusSuccess;
            } else if (status == AFNetworkReachabilityStatusNotReachable) {
                result.status = MGJPingStatusFail;
            } else {
                result.status = MGJPingStatusTimeout;
            }
            result.time = [[NSDate date] timeIntervalSinceDate:startDate];
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(result);
            });
            [manager stopMonitoring];
            [pingManagers removeObject:manager];
        }];
        [manager startMonitoring];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeout * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            // timeout
            @strongify(manager);
            if (manager) {
                [manager stopMonitoring];
                MGJPingResult *result = [[MGJPingResult alloc] init];
                result.status = MGJPingStatusTimeout;
                result.time = [[NSDate date] timeIntervalSinceDate:startDate];
                completion(result);
                [pingManagers removeObject:manager];
            }
        });
        [pingManagers addObject:manager];
    });
}

+ (void)pingRequest:(NSURLRequest *)request verifyString:(NSString *)verifyString completion:(void (^)(MGJPingResult *))completion
{
    static dispatch_queue_t connQueue;
    if (!connQueue) {
        connQueue = dispatch_queue_create("what.a.nice.day", DISPATCH_QUEUE_SERIAL);
    }
    
    dispatch_async(connQueue, ^{
        NSDate *startDate = [NSDate date];
        NSError *error;
        NSURLResponse *response;
        NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:(NSURLResponse **)&response error:&error];
        
        NSTimeInterval timeCost = [[NSDate date] timeIntervalSinceDate:startDate];
        MGJPingResult *pingResult = [[MGJPingResult alloc] init];
        pingResult.time = timeCost;
        
        if (!error) {
            pingResult.status = MGJPingStatusSuccess;
            
            if (verifyString.length) {
                NSString *response = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
                pingResult.status = [response isEqualToString:verifyString] ? MGJPingStatusSuccess : MGJPingStatusFail;
            }
        } else {
            pingResult.status = error.code == NSURLErrorTimedOut ? MGJPingStatusTimeout : MGJPingStatusFail;
        }
        
        completion(pingResult);
    });
}

@end
