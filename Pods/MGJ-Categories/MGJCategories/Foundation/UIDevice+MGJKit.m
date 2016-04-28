//
//  UIDevice+MGJKit.m
//
//  Created by limboy on 12/2/14.
//  Copyright (c) 2014 mogujie. All rights reserved.
//

#if TARGET_OS_IOS

#import "UIDevice+MGJKit.h"
#import "NSString+MGJKit.h"
#import <AFNetworking/AFNetworkReachabilityManager.h>
#import <AdSupport/AdSupport.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import <SSKeychain/SSKeychain.h>
#import <sys/sysctl.h>
#import <mach/mach.h>

static NSString * mgjFakeUniqueID = @"";
static CADisplayLink *displayLink;
static CFTimeInterval lastTimeStamp;
static CGFloat fps;

@implementation UIDevice (MGJKit)

+ (NSString *)mgj_deviceName
{
    static NSString *deviceName = nil;
    
    if (!deviceName) {
        size_t size;
        sysctlbyname("hw.machine", NULL, &size, NULL, 0);
        char *name = malloc(size);
        sysctlbyname("hw.machine", name, &size, NULL, 0);
        
        deviceName = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
        free(name);
        
        if( [@"i386" isEqualToString:deviceName] || [@"x86_64" isEqualToString:deviceName] ) {
            deviceName = @"iOS_Simulator";
        }
    }
    
    return deviceName;
}

+ (void)mgj_simulateUniqueIDWithString:(NSString *)fakeUniqueID
{
    mgjFakeUniqueID = fakeUniqueID;
}

+ (NSString *)mgj_uniqueID
{
    if (mgjFakeUniqueID.length) {
        return mgjFakeUniqueID;
    }
    
    static NSString *kMGJUniqueIDAccountName = @"com.juangua.mogujie.idfa";
    static NSString *kMGJUniqueIDServiceName = @"mgj_unique_key";
    
    static dispatch_once_t onceToken;
    static NSString * uniqueId = nil;
    dispatch_once(&onceToken, ^{
        
        uniqueId = [SSKeychain passwordForService:kMGJUniqueIDServiceName account:kMGJUniqueIDAccountName];
        
        if (uniqueId.length == 0) {
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
                uniqueId = [self mgj_IDFA];
                
                if (uniqueId.length == 0) {//不存在说明用户关闭了广告跟踪
                    NSString *timeString = [NSString stringWithFormat:@"%.5f",[[NSDate date] timeIntervalSince1970]];
                    NSString *randomString = [NSString stringWithFormat:@"%d", arc4random() % 10000/*0-9999*/];
                    uniqueId = [[timeString stringByAppendingString:randomString] mgj_md5HashString];
                }
            }
            else
            {
                uniqueId = [[self mgj_macAddress] mgj_md5HashString];
            }
            
            [SSKeychain setPassword:uniqueId forService:kMGJUniqueIDServiceName account:kMGJUniqueIDAccountName];
        }
        
    });
    
    return uniqueId;
}

+ (BOOL)mgj_isJailbroken
{
    BOOL jailbroken = NO;
    NSString *cydiaPath = @"/Applications/Cydia.app";
    NSString *aptPath = @"/private/var/lib/apt/";
    if ([[NSFileManager defaultManager] fileExistsAtPath:cydiaPath]) {
        jailbroken = YES;
    }
    if ([[NSFileManager defaultManager] fileExistsAtPath:aptPath]) {
        jailbroken = YES;
    }
    return jailbroken;
}

+ (NSString *)mgj_systemVersion
{
    return [[UIDevice currentDevice] systemVersion];
}

+ (NSString *)mgj_cellularProvider
{
    CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = info.subscriberCellularProvider;
    NSString *carrierName = [carrier carrierName];
    return carrierName ? : @"";
}

+ (NSString *)mgj_IDFA
{
    NSString *idfa = nil;
    if (NSClassFromString(@"ASIdentifierManager")) {
        if ([ASIdentifierManager sharedManager].isAdvertisingTrackingEnabled) {
            idfa = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
        }
    }
    return idfa;
}

+ (NSString *)mgj_ipAddress
{
    NSString *address = nil;
    NSString *wifiAddress = nil;
    NSString *wwanAddress = nil;
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            if( temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                // Check if interface is pdp_ip0 which is the wwan connection on the iPhone
                NSString *ifaName = [NSString stringWithUTF8String:temp_addr->ifa_name];
                if ([ifaName isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    wifiAddress = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                } else if ([ifaName isEqualToString:@"pdp_ip0"]) {
                    // Get NSString from C String
                    wwanAddress = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            
            temp_addr = temp_addr->ifa_next;
            
        }
    }
    if (wifiAddress) {
        address = wifiAddress;
    } else if (wwanAddress) {
        address = wwanAddress;
    }
    
    // Free memory
    freeifaddrs(interfaces);
    
    return address ? : @"";
}

+ (MGJNetworkStatus)mgj_networkStatus
{
    if (AFNetworkReachabilityStatusNotReachable == [[AFNetworkReachabilityManager sharedManager] networkReachabilityStatus]){
        return MGJNetworkStatusNotReachable;
    }
    
    MGJNetworkStatus result = MGJNetworkStatusUnknown;
    if ([[AFNetworkReachabilityManager sharedManager] isReachableViaWiFi]) {
        result = MGJNetworkStatusWiFi;
    }else if([[AFNetworkReachabilityManager sharedManager] isReachable]){
        if ([[UIDevice mgj_systemVersion] floatValue] >= 7) {
            CTTelephonyNetworkInfo *networkInfo = [CTTelephonyNetworkInfo new];
            NSString *radioType = networkInfo.currentRadioAccessTechnology;
            if ([radioType isEqualToString:CTRadioAccessTechnologyGPRS] || [radioType isEqualToString:CTRadioAccessTechnologyEdge] || [radioType isEqualToString:CTRadioAccessTechnologyCDMA1x]) {
                result = MGJNetworkStatus2G;
            }
            else if ( [radioType isEqualToString:CTRadioAccessTechnologyWCDMA] || [radioType isEqualToString:CTRadioAccessTechnologyHSDPA] ||[radioType isEqualToString:CTRadioAccessTechnologyHSUPA] ||[radioType isEqualToString:CTRadioAccessTechnologyCDMAEVDORev0] ||[radioType isEqualToString:CTRadioAccessTechnologyCDMAEVDORevA] ||[radioType isEqualToString:CTRadioAccessTechnologyCDMAEVDORevB] ||[radioType isEqualToString:CTRadioAccessTechnologyeHRPD]) {
                result = MGJNetworkStatus3G;
            }
            else if ([radioType isEqualToString:CTRadioAccessTechnologyLTE])
            {
                result = MGJNetworkStatus4G;
            }
        }
        else {
            result = MGJNetworkStatusWWAN;
        }
    }
    return result;
}

+ (CGSize)mgj_screenPixelSize
{
    CGSize size = [[UIScreen mainScreen] bounds].size;
    size = CGSizeMake(size.width * [UIScreen mainScreen].scale, size.height * [UIScreen mainScreen].scale);
    return size;
}

+ (NSString *)mgj_macAddress
{
    int                 mib[6];
    size_t              len;
    char                *buf;
    unsigned char       *ptr;
    struct if_msghdr    *ifm;
    struct sockaddr_dl  *sdl;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
    if ((mib[5] = if_nametoindex("en0")) == 0) {
        printf("Error: if_nametoindex error\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 1\n");
        return NULL;
    }
    
    if ((buf = malloc(len)) == NULL) {
        printf("Could not allocate memory. error!\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 2");
        free(buf);
        return NULL;
    }
    
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);
    NSString *outstring = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                           *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    free(buf);
    
    return outstring;
}

+ (CGFloat)mgj_availableMemory
{
    vm_statistics_data_t vmStats;
    mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
    kern_return_t kernReturn = host_statistics(mach_host_self(),
                                               HOST_VM_INFO,
                                               (host_info_t)&vmStats,
                                               &infoCount);
    
    if (kernReturn != KERN_SUCCESS) {
        return NSNotFound;
    }
    
    return ((vm_page_size *vmStats.free_count) / 1024.0) / 1024.0;
}

+ (CGFloat)mgj_usedMemory
{
    task_basic_info_data_t taskInfo;
    mach_msg_type_number_t infoCount = TASK_BASIC_INFO_COUNT;
    kern_return_t kernReturn = task_info(mach_task_self(),
                                         TASK_BASIC_INFO,
                                         (task_info_t)&taskInfo,
                                         &infoCount);
    
    if (kernReturn != KERN_SUCCESS
        ) {
        return NSNotFound;
    }
    
    return taskInfo.resident_size;
}

+ (CGFloat)mgj_currentFPS
{
    return fps;
}

+ (void)mgj_beginFPS
{
    if (!displayLink) {
        displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(handleDisplayLink)];
        displayLink.paused = NO;
        [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
}

+ (void)mgj_endFPS
{
    if (displayLink) {
        displayLink.paused = YES;
    }
}

+ (void)handleDisplayLink
{
    if (lastTimeStamp > 0) {
        fps = (CGFloat)(1 / (displayLink.timestamp - lastTimeStamp));
    }
    lastTimeStamp = displayLink.timestamp;
}

+ (CGFloat)mgj_cpuUsage
{
    kern_return_t kr;
    task_info_data_t tinfo;
    mach_msg_type_number_t task_info_count;
    
    task_info_count = TASK_INFO_MAX;
    kr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)tinfo, &task_info_count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }
    
    task_basic_info_t      basic_info;
    thread_array_t         thread_list;
    mach_msg_type_number_t thread_count;
    
    thread_info_data_t     thinfo;
    mach_msg_type_number_t thread_info_count;
    
    thread_basic_info_t basic_info_th;
    uint32_t stat_thread = 0; // Mach threads
    
    basic_info = (task_basic_info_t)tinfo;
    
    // get threads in the task
    kr = task_threads(mach_task_self(), &thread_list, &thread_count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }
    if (thread_count > 0)
        stat_thread += thread_count;
    
    long tot_sec = 0;
    long tot_usec = 0;
    CGFloat tot_cpu = 0.f;
    int j;
    
    for (j = 0; j < thread_count; j++)
    {
        thread_info_count = THREAD_INFO_MAX;
        kr = thread_info(thread_list[j], THREAD_BASIC_INFO,
                         (thread_info_t)thinfo, &thread_info_count);
        if (kr != KERN_SUCCESS) {
            return -1;
        }
        
        basic_info_th = (thread_basic_info_t)thinfo;
        
        if (!(basic_info_th->flags & TH_FLAGS_IDLE)) {
            tot_sec = tot_sec + basic_info_th->user_time.seconds + basic_info_th->system_time.seconds;
            tot_usec = tot_usec + basic_info_th->user_time.microseconds + basic_info_th->system_time.microseconds;
            tot_cpu = tot_cpu + basic_info_th->cpu_usage / (float)TH_USAGE_SCALE * 100.0;
        }
        
    } // for each thread
    
    kr = vm_deallocate(mach_task_self(), (vm_offset_t)thread_list, thread_count * sizeof(thread_t));
    assert(kr == KERN_SUCCESS);
    
    return tot_cpu;
}

+ (BOOL)isSimulator
{
	if ([[UIDevice currentDevice].name hasSuffix:@"Simulator"]) {
		return YES;
	}
	return NO;
}

+ (BOOL)isVPNConnected
{
	struct ifaddrs *interfaces = NULL;
	struct ifaddrs *temp_addr = NULL;
	int success = 0;

	success = getifaddrs(&interfaces);
	if (success == 0) {
		// Loop through linked list of interfaces
		temp_addr = interfaces;
		while (temp_addr != NULL) {
			NSString *string = [NSString stringWithFormat:@"%s" , temp_addr->ifa_name];
			if ([string rangeOfString:@"tap"].location != NSNotFound ||
					[string rangeOfString:@"tun"].location != NSNotFound ||
					[string rangeOfString:@"ppp"].location != NSNotFound ||
                    [string rangeOfString:@"ipsec"].location != NSNotFound ){
				return YES;
			}

			temp_addr = temp_addr->ifa_next;
		}
	}

	// Free memory
	freeifaddrs(interfaces);
	return NO; 
}

@end
#endif
