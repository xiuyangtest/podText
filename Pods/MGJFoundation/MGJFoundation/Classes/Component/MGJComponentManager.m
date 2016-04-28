//
//  MGJComponentManager.m
//  Example
//
//  Created by limboy on 7/21/15.
//  Copyright (c) 2015 juangua. All rights reserved.
//

#import "MGJComponentManager.h"
#import "MGJRouter.h"
#import "MGJComponent.h"
#import "MGJComponentDownloader.h"
#import "MGJComponentInstaller.h"
#import "MGJNativeComponentMetaInfo.h"
#import "MGJDownloadableComponentMetaInfo.h"
#import "MGJLog.h"
#import "NSString+MGJKit.h"

static NSString * const componentsPath = @"c0mp0nents";

@interface MGJComponentManager ()
/**
 *  url 和 文件路径的映射关系
 */
@property (nonatomic, strong) NSMutableDictionary *urlMaps;

/**
 *  key:组件 id, value: 组件信息
 */
@property (nonatomic, strong) NSMutableDictionary *components;
@end

@implementation MGJComponentManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.urlMaps = [NSMutableDictionary dictionary];
        self.components = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)registerComponentsWithLocalMetaInfoURL:(NSString *)localMetaInfoURL remoteMetaInfoURL:(NSString *)remoteMetaInfoURL
{
    [self handleLocalMetaInfoWithURL:localMetaInfoURL];
    [self handleRemoteMetaInfoWithURL:remoteMetaInfoURL];
}

- (void)registerScheme:(NSString *)scheme withDownloadableComponent:(MGJDownloadableComponentType)componentType handler:(void (^)(MGJDownloadableComponentMetaInfo *, MGJDownloadableRouterInfo *))handler
{
    
    [MGJRouter registerURLPattern:scheme toHandler:^(NSDictionary *routerParameters) {
        
        NSString *originURL = routerParameters[MGJRouterParameterURL];
        MGJDownloadableComponentMetaInfo *componentInfo = [self downloadableComponentForURL:originURL];
        NSString *fileURL = nil;
        if (componentInfo.state != ComponentInvalid) {
            fileURL = [self filePathForURL:originURL];
        }
        
        MGJDownloadableRouterInfo *routerInfo = [MGJDownloadableRouterInfo new];
        routerInfo.fileURL = fileURL;
        routerInfo.originURL = originURL;
       
        //不管组件状态，全都交给调用方去决定下一步操作
        handler(componentInfo, routerInfo);
    
    }];
}

- (void)installDownloadableComponent:(MGJDownloadableComponentMetaInfo *)componentInfo progress:(NSProgress * __autoreleasing *)progress completionHandler:(void (^)(NSError *error))completionHandler
{
    @weakify(self);
    [[MGJComponentDownloader mgj_sharedInstance] downloadComponent:componentInfo progress:progress completionHandler:^(MGJDownloadableComponentMetaInfo *componentInfo, NSURL *url, NSError *error) {
        if (error) {
            if (completionHandler) {
                completionHandler(error);
            }
        }
        else {
            [self updateState:ComponentDownloadedButNotInstalled forComponent:componentInfo];
            [[MGJComponentInstaller mgj_sharedInstance] installComponent:componentInfo withDownloadPath:url.path completionHandler:^(NSError *error, NSDictionary *urlMaps) {
                @strongify(self);
                [self updateURLMaps:urlMaps forComponent:componentInfo];
                [self updateState:ComponentInstalled forComponent:componentInfo];
                if (completionHandler) {
                    completionHandler(error);
                }
            }];
        }
    }];
}

- (void)cancelInstallingComponent:(MGJDownloadableComponentMetaInfo *)componentInfo
{
    [[MGJComponentDownloader mgj_sharedInstance] cancelDownloadWithComponentInfo:componentInfo];
}

- (NSString *)filePathForURL:(NSString *)urlString
{
    NSURLComponents *urlComponents = [[NSURLComponents alloc] initWithString:urlString];
    NSString *urlWithoutParameters = [NSString stringWithFormat:@"%@://%@", urlComponents.scheme, urlComponents.host];
    
    NSString *filePath = self.urlMaps[urlWithoutParameters][@"filePath"];
    return filePath;
}


#pragma mark Private Methods

- (void)updateURLMaps:(NSDictionary *)urlMaps forComponent:(MGJDownloadableComponentMetaInfo *)componentInfo
{
    // 卸载原先的 URLs
    if (self.components[componentInfo.id]) {
        MGJDownloadableComponentMetaInfo *metaInfo = (MGJDownloadableComponentMetaInfo *)self.components[componentInfo.id];
        [metaInfo.clientURLs enumerateObjectsUsingBlock:^(NSString *url, NSUInteger idx, BOOL *stop) {
            [self.urlMaps removeObjectForKey:url];
        }];
    }
    
    self.components[componentInfo.id] = componentInfo;
    
    [urlMaps enumerateKeysAndObjectsUsingBlock:^(NSString *url, id obj, BOOL *stop) {
        self.urlMaps[url] = @{@"filePath": urlMaps[url], @"componentID": componentInfo.id};
    }];
    [self updateLocalConfigWithMetaInfo:componentInfo];
}

- (void)updateState:(MGJDownloadableComponentState)state forComponent:(MGJDownloadableComponentMetaInfo *)componentInfo
{
    MGJDownloadableComponentMetaInfo *component = self.components[componentInfo.id];
    component.state = state;
}

- (void)updateLocalConfigWithMetaInfo:(MGJDownloadableComponentMetaInfo *)metaInfo
{
    NSDictionary *metaInfoDict = [metaInfo entityToDictionary];
    NSError *jsonError;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:metaInfoDict options:0 error:&jsonError];
    if (jsonData) {
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSString *componentPath = [self generateFilepathWithCompoenentInfo:metaInfo];
        NSError *writeToFileError;
        [jsonString writeToFile:componentPath atomically:YES encoding:NSUTF8StringEncoding error:&writeToFileError];
        if (writeToFileError) {
            MGJLogError(@"write config to disk error: %@", writeToFileError);
        }
    } else {
        MGJLogError(@"write config to dict error: %@", jsonError);
    }
}

- (MGJDownloadableComponentMetaInfo *)downloadableComponentForURL:(NSString *)urlString
{
    // 这里如果用 NSURLComponents 去转的话，会出现 path 被吃掉的现象，因为这个 URL 很可能不符合 RFC 1808
    // NSURLComponents *urlComponents = [[NSURLComponents alloc] initWithString:urlString];
    // NSString *urlWithOutParameters = [NSString stringWithFormat:@"%@://%@", urlComponents.scheme, urlComponents.path];
    NSString *urlWithOutParameters = [urlString componentsSeparatedByString:@"?"][0];
    if (!self.urlMaps[urlWithOutParameters][@"componentID"]) {
        MGJLogError(@"can't find component by url:%@", urlWithOutParameters);
    }
    return self.components[self.urlMaps[urlWithOutParameters][@"componentID"]];
}

- (NSString *)generateFilepathWithCompoenentInfo:(MGJDownloadableComponentMetaInfo *)metaInfo
{
    NSString *componentFilename = [NSString stringWithFormat:@"%@.json", metaInfo.id];
    NSString *componentsDir = [[NSString mgj_documentsPath] stringByAppendingPathComponent:componentsPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:componentsDir]) {
        NSError *dirCreateError;
        [fileManager createDirectoryAtPath:componentsDir withIntermediateDirectories:YES attributes:nil error:&dirCreateError];
        if (dirCreateError) {
            MGJLogError(@"components dir create error :%@", componentsDir);
        }
    }
    
    return [componentsDir stringByAppendingPathComponent:componentFilename];
}

/**
 *  处理可被下载的组件的安装
 *
 *  @param metaInfo
 */
- (void)handleDownloadableComponentMetaInfo:(MGJDownloadableComponentMetaInfo *)componentInfo
{
    // 如果该文件不存在，说明是第一次打开，直接从本地安装
    NSString *componentPath = [self generateFilepathWithCompoenentInfo:componentInfo];
    if (![[NSFileManager defaultManager] fileExistsAtPath:componentPath]) {
        [self installLocalComponentWithComponentInfo:componentInfo];
    } else {
        NSData *fileData = [[NSFileManager defaultManager] contentsAtPath:componentPath];
        NSError *jsonError;
        NSDictionary *localComponentInfo = [NSJSONSerialization JSONObjectWithData:fileData options:NSJSONReadingAllowFragments error:&jsonError];
        if (!localComponentInfo) {
            MGJLogError(@"error occurs when transforming data to dict :%@", jsonError);
            return;
        }
        
        // 如果两个版本不一致，以传入的 metaInfo 为准
        if ([localComponentInfo[@"version"] intValue] != [componentInfo.version intValue]) {
            // TODO 如果在下载过程中用户打开了H5页面？
            [self installDownloadableComponent:componentInfo progress:nil completionHandler:nil];
        } else {
            [self installLocalComponentWithComponentInfo:componentInfo];
        }
    }
}

- (void)handleLocalMetaInfoWithURL:(NSString *)localMetaInfoURL
{
    if (!localMetaInfoURL) {
        MGJLogError(@"local meta url empty");
        return;
    }
    NSData *data = [NSData dataWithContentsOfFile:localMetaInfoURL];
    NSDictionary *modules = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    [self handleModulesMetaInfo:modules];
}

- (void)handleRemoteMetaInfoWithURL:(NSString *)remoteMetaInfoURL
{
    if (!remoteMetaInfoURL) {
        MGJLogError(@"remote meta url empty");
        return;
    }
    
    NSURLSessionConfiguration * sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    [sessionConfig setHTTPAdditionalHeaders:@{@"Accept": @"application/json"}];
    sessionConfig.timeoutIntervalForRequest = 15;
    NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:sessionConfig];
    
    NSURLSessionDataTask *dataTask = [urlSession dataTaskWithURL:[NSURL URLWithString:remoteMetaInfoURL] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error && data.length) {
            NSError *jsonError;
            NSDictionary *modules = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
            if (modules) {
                if ([modules[@"status"] intValue] == 1001 && modules[@"result"]) {
                    [self handleModulesMetaInfo:modules[@"result"]];
                }
            } else {
                MGJLogError(@"parse meta info data error:%@", jsonError);
            }
        } else {
            MGJLogError(@"fetch remote meta info error:%@", error);
        }
    }];
    [dataTask resume];
}

- (void)handleModulesMetaInfo:(NSDictionary *)modules
{
    [modules[@"modules"] enumerateObjectsUsingBlock:^(NSDictionary *module, NSUInteger idx, BOOL *stop) {
        if (module[@"type"]) {
            if ([module[@"type"] isEqualToString:@"native"]) {
                MGJNativeComponentMetaInfo *nativeComponent = [[MGJNativeComponentMetaInfo alloc] initWithDictionary:module];
                Class componentEntry = NSClassFromString(nativeComponent.category);
                if ([componentEntry isSubclassOfClass:[MGJComponent class]]) {
                    [[componentEntry mgj_sharedInstance] register];
                }
            } else {
                MGJDownloadableComponentMetaInfo *downloadableComponent = [[MGJDownloadableComponentMetaInfo alloc] initWithDictionary:module];
                [self handleDownloadableComponentMetaInfo:downloadableComponent];
            }
        }
    }];
}

- (void)installLocalComponentWithComponentInfo:(MGJDownloadableComponentMetaInfo *)componentInfo
{
    static NSArray *localBundlePaths;
    if (!localBundlePaths) {
        localBundlePaths = [NSBundle pathsForResourcesOfType:@"amr" inDirectory:[[NSBundle mainBundle] bundlePath]];
    }
    NSString *componentPattern = [NSString stringWithFormat:@"%@-%@", componentInfo.id, componentInfo.md5];
    [localBundlePaths enumerateObjectsUsingBlock:^(NSString *componentPath, NSUInteger idx, BOOL *stop) {
        if ([componentPath rangeOfString:componentPattern].location != NSNotFound) {
            [[MGJComponentInstaller mgj_sharedInstance] installComponent:componentInfo withDownloadPath:componentPath completionHandler:^(NSError *error, NSDictionary *urlMaps) {
                [self updateURLMaps:urlMaps forComponent:componentInfo];
                [self updateState:ComponentInstalled forComponent:componentInfo];
            }];
        }
    }];
}

@end
