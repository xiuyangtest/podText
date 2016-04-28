//
//  MGJComponentInstallOperation.m
//  Example
//
//  Created by Blank on 15/7/22.
//  Copyright (c) 2015年 juangua. All rights reserved.
//

#import "MGJComponentInstallOperation.h"
#import "MGJComponentValidator.h"
#import "MGJLog.h"
#import "MGJEXTScope.h"
#import "MGJComponentError.h"
#import "MGJZipArchive.h"

@interface MGJComponentInstallOperation ()
@property (nonatomic, strong) NSError *error;
@property (nonatomic, strong) MGJDownloadableComponentMetaInfo *componentInfo;
@property (nonatomic, copy) MGJComponentInstallCompletionHandler completionHandler;
@property (nonatomic, copy) NSString *downloadPath;
@property (nonatomic, copy) NSString *installPath;
@property (nonatomic, strong) NSMutableDictionary *urlMaps;

@end

@implementation MGJComponentInstallOperation
- (instancetype)initWithComponentInfo:(MGJDownloadableComponentMetaInfo *)componentInfo downloadPath:(NSString *)path installPath:(NSString *)installPath completionHandler:(MGJComponentInstallCompletionHandler)completionHandler
{
    self = [super init];
    if (self) {
        self.completionHandler = completionHandler;
        self.componentInfo = componentInfo;
        self.downloadPath = path;
        self.installPath = installPath;
        @weakify(self);
        self.completionBlock = ^(){
            dispatch_async(dispatch_get_main_queue(), ^{
                @strongify(self);
                if (self.completionHandler) {
                    self.completionHandler(self.error, self.urlMaps);
                }
            });
        };
    }
    return self;
}

- (void)main
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:self.downloadPath]) {
        self.error = [NSError errorWithDomain:MGJComponentErrorDomain code:MGJComponentErrorBundleNotExistInPath userInfo:nil];
        return;
    }
   
    MGJLogDebug(@"准备开始验证安装包:%@", self.downloadPath);
    if (![[MGJComponentValidator mgj_sharedInstance] validateBundle:self.downloadPath]) {
        self.error = [NSError errorWithDomain:MGJComponentErrorDomain code:MGJComponentErrorValidateFailed userInfo:nil];
        return;
    }
   
    BOOL installSuccess = [MGJZipArchive unzipFileAtPath:self.downloadPath toDestination:self.installPath];
    if (installSuccess) {
        MGJLogDebug(@"id 为 %@的 组件安装包安装成功，加载bundleInfo", self.componentInfo.id);
        
        if ([fileManager fileExistsAtPath:[self configPath]]) {
            NSDictionary *config = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:[self configPath]] options:0 error:nil];
            self.urlMaps = [NSMutableDictionary dictionary];
            
            [config[@"maps"] enumerateKeysAndObjectsUsingBlock:^(NSString *url, NSString *pagePath, BOOL *stop1) {
                NSString *pageFullPath = nil;
                if ([pagePath hasPrefix:@"http://"]) {//if pagePath is url,directly set it to full path
                    pageFullPath = pagePath;
                }
                else {//or append with parent folder to generate the absolute path
                    pageFullPath = [[self.installPath stringByAppendingPathComponent:@"www"] stringByAppendingPathComponent:pagePath];
                    pageFullPath = [NSURL fileURLWithPath:pageFullPath].absoluteString;
                }
                
                if (pageFullPath) {
                    [self.urlMaps setObject:pageFullPath forKey:url];
                }
            }];
            
        }
        [fileManager removeItemAtPath:self.downloadPath error:nil];
    }
    else {
        self.error = [NSError errorWithDomain:MGJComponentErrorDomain code:MGJComponentErrorBundleUnzipFailed userInfo:nil];
    }
}

- (NSString *)configPath
{
    return [self.installPath stringByAppendingPathComponent:@"config.json"];
}
@end
