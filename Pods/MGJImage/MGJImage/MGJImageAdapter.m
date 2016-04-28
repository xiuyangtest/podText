//
//  MGJImageAdapter.m
//  Example
//
//  Created by Blank on 15/12/7.
//  Copyright © 2015年 Juangua. All rights reserved.
//

#import "MGJImageAdapter.h"
#import "MGJImageAdapterRule.h"
#import <libkern/OSAtomic.h>
#import "MGJImageMetaInfo.h"
#import <MGJ-Categories/NSString+MGJKit.h>
#import <AFNetworking/AFNetworkReachabilityManager.h>
#import <SDWebImage/SDWebImageManager.h>
#import "MGJImageConfigManager.h"

NSInteger const MGJImageRuleHeightAutoAdapt = 999;
NSString * const MGJDebugImageServer = @"ops.mogujie.org/storage/testimg";
NSString * const MGJImageRuleCacheKeyWifi = @"wifi";
NSString * const MGJImageRuleCacheKeyWWAN = @"wwan";
NSString * const MGJImageRuleCodeForCrop = @"v1cOK";
NSString * const MGJImageRuleCodeForAdapt = @"v1c96";
NSString * const MGJImageRuleKeyReturnOriginURL = @"forceOriginURL=1";


@interface MGJImageAdapter ()
@property (atomic, strong) NSArray *rules;
@property (nonatomic, strong) NSMutableDictionary *adaptationCache;
@end

static OSSpinLock lock;

@implementation MGJImageAdapter
+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static MGJImageAdapter *instance = nil;
    
    dispatch_once(&onceToken, ^{
        lock = OS_SPINLOCK_INIT;
        instance = [MGJImageAdapter new];
        NSData *data = [NSData dataWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"mgjimage.bundle/rule" ofType:@"json"]];
        if (data) {
            NSArray * rules = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            [instance updateRules:rules];
        }
    });
    return instance;
}


- (NSMutableDictionary *)adaptationCache
{
    if (!_adaptationCache) {
        _adaptationCache = [NSMutableDictionary dictionary];
    }
    return _adaptationCache;
}

- (void)updateRules:(NSArray *)rules
{
    OSSpinLockLock(&lock);
    self.rules = [MGJEntity parseToEntityArray:rules withType:[MGJImageAdapterRule class]];
    [self.adaptationCache removeAllObjects];
    OSSpinLockUnlock(&lock);
}

- (NSString *)adaptImageURL:(NSString *)imageURL
{
    return imageURL;
}

- (NSString *)adaptImageURL:(NSString *)imageURL toSize:(NSInteger)size
{
    return [self adaptImageURL:imageURL toSize:size needCrop:NO];
}


- (NSString *)adaptImageURL:(NSString *)imageURL toSize:(NSInteger)size needCrop:(BOOL)needCrop
{
    MGJImageAdapterNetworkStatus networkStatus = MGJImageAdapterNetworkStatusWiFi;
    if ([AFNetworkReachabilityManager sharedManager].reachableViaWWAN) {
        networkStatus = MGJImageAdapterNetworkStatusWWAN;
    }
    return [self adaptImageURL:imageURL toPixelSize:size * [UIScreen mainScreen].scale needCrop:needCrop onNetworkStatus:networkStatus];
}


- (NSString *)adaptImageURL:(NSString *)imageURL toPixelSize:(NSInteger)size needCrop:(BOOL)needCrop onNetworkStatus:(MGJImageAdapterNetworkStatus)status
{
    
    //验证参数合法性
    if (!imageURL) {
        return imageURL;
    }
    
    NSURL *url = [NSURL URLWithString:imageURL];
    if (!url) {
        return imageURL;
    }
  
    //给个机会可以绕过图片规则直接给原图
    if (url.query && [url.query rangeOfString:MGJImageRuleKeyReturnOriginURL].location != NSNotFound) {
        return [NSString stringWithFormat:@"%@://%@%@", url.scheme, url.host, url.path];
    }
    
    //域名验证
    __block BOOL isInDomainList = NO;
    [@[@"mogujie.cn", @"mogucdn.com"] enumerateObjectsUsingBlock:^(NSString *host, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([url.host hasSuffix:host]) {
            isInDomainList = YES;
            *stop = YES;
        }
    }];
    
    
    if (!isInDomainList) {
        return imageURL;
    }
    
    //验证后缀名
    if (![@[@"jpg", @"png", @"webp", @"gif", @"jpeg"] containsObject:url.pathExtension]){
        return imageURL;
    }
    
    MGJImageMetaInfo *metaInfo = [MGJImageMetaInfo metaInfoWithURL:imageURL];
    if (!metaInfo) {
        return imageURL;
    }
    
    //传入尺寸验证
    if (size <= 0) {
        return imageURL;
    }
    
    //先从缓存找
    NSString *cacheKey = [self cacheKeyForPixelSize:size needCrop:needCrop];
    
    OSSpinLockLock(&lock);
    id suffixDictionary = self.adaptationCache[cacheKey];
    OSSpinLockUnlock(&lock);
   
    //之前已经找过，没有匹配的规则
    if (suffixDictionary == [NSNull null]) {
        return imageURL;
    }
    
    if (!suffixDictionary) {
        //最终匹配的规则
        MGJImageAdapterRule *matchedRule = nil;
        
        
        //宽的差值
        CGFloat diff = CGFLOAT_MAX;
       
        OSSpinLockLock(&lock);
        NSArray *rules = [self.rules copy];
        OSSpinLockUnlock(&lock);
        
        for (MGJImageAdapterRule *rule in rules) {
            
            //排除不合法的规则
            if (![rule isKindOfClass:[MGJImageAdapterRule class]]) {
                continue;
            }
            
            if (rule.size <= 0 || (!rule.wwan && !rule.wifi)) {
                continue;
            }
            
            //计算插值
            CGFloat currentDiff = labs(rule.size - size);
            if (currentDiff < diff || (currentDiff == diff && rule.size < matchedRule.size)) {
                //最接近的规则
                matchedRule = rule;
                diff = currentDiff;
            }
            
            
        }
        
        //如果没有匹配的规则，也缓存一下
        if (!matchedRule) {
            OSSpinLockLock(&lock);
            self.adaptationCache[cacheKey] = [NSNull null];
            OSSpinLockUnlock(&lock);
            return imageURL;
        }
        
        
        //生成两种环境下的 URL 后缀
        MGJImageAdapterRuleItem *itemForWifi = matchedRule.wifi;
        MGJImageAdapterRuleItem *itemForWWAN= matchedRule.wwan;
       
        NSString *suffixForWifi = nil;
        NSString *suffixForWWAN = nil;
        
        NSString *code = needCrop ? MGJImageRuleCodeForCrop : MGJImageRuleCodeForAdapt;
        NSInteger height = needCrop ? matchedRule.size : MGJImageRuleHeightAutoAdapt;
        
        
        suffixForWifi = [NSString stringWithFormat:@"_%ldx%ld.%@.%ld.%@", (long)matchedRule.size, (long)height, code, (long)itemForWifi.quality, ([url.pathExtension isEqualToString:@"jpg"] ) ? itemForWifi.extention : @"webp"];
        suffixForWWAN = [NSString stringWithFormat:@"_%ldx%ld.%@.%ld.%@", (long)matchedRule.size, (long)height, code, (long)itemForWWAN.quality,  ([url.pathExtension isEqualToString:@"jpg"] ) ? itemForWWAN.extention : @"webp"];
        
        
        suffixDictionary = @{MGJImageRuleCacheKeyWifi:suffixForWifi, MGJImageRuleCacheKeyWWAN:suffixForWWAN};
        
        OSSpinLockLock(&lock);
        self.adaptationCache[cacheKey] = suffixDictionary;
        OSSpinLockUnlock(&lock);
    }
   
    //找到原图地址
    NSString *originURL = metaInfo.originURL;
    
    
    NSString *urlForWifi = [originURL stringByAppendingString:suffixDictionary[MGJImageRuleCacheKeyWifi]];
    NSString *urlForWWAN = [originURL stringByAppendingString:suffixDictionary[MGJImageRuleCacheKeyWWAN]];
    
    //调试模式下，替换域名
#ifdef DEBUG
    if ([MGJImageConfigManager debugModeForImageAdapterEnabled]) {
        urlForWifi = [urlForWifi stringByReplacingOccurrencesOfString:url.host withString:MGJDebugImageServer];
        urlForWWAN = [urlForWWAN stringByReplacingOccurrencesOfString:url.host withString:MGJDebugImageServer];
    }
#endif
    
    NSString *adaptedURL = urlForWifi;
    
    //3g 可以用 wifi 的图，wifi 不能用 3g 的图
    if (status == MGJImageAdapterNetworkStatusWiFi) {
        adaptedURL = urlForWifi;
    }
    else
    {
        if ([[SDWebImageManager sharedManager] cachedImageExistsForURL:[NSURL URLWithString:urlForWifi]]) {
            adaptedURL = urlForWifi;
        }
        else
        {
            adaptedURL = urlForWWAN;
        }
    }
    
    //调试模式下，替换域名
#ifdef DEBUG
    if ([MGJImageConfigManager debugModeForImageAdapterEnabled]) {
        adaptedURL = [adaptedURL stringByReplacingOccurrencesOfString:url.host withString:MGJDebugImageServer];
    }
#endif
    
    //拼接图片地址
    return adaptedURL;
}

- (NSString *)cacheKeyForPixelSize:(NSInteger)pixelSize needCrop:(BOOL)needCrop
{
    NSInteger width = pixelSize;
    NSInteger height = needCrop ? pixelSize: MGJImageRuleHeightAutoAdapt;
    
    return [NSString stringWithFormat:@"%ldx%ld", (long)width, (long)height];
}

@end
