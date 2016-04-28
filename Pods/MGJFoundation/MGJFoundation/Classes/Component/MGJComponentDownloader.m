//
//  MGJComponentDownloader.m
//  Example
//
//  Created by Blank on 15/7/22.
//  Copyright (c) 2015年 juangua. All rights reserved.
//

#import "MGJComponentDownloader.h"
#import <AFNetworking/AFNetworking.h>
#import "MGJLog.h"

@interface MGJComponentDownloader ()
@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;
@property (nonatomic, strong) NSFileManager *fileManager;
@property (nonatomic, strong) NSMutableDictionary *tasks;
@end

@implementation MGJComponentDownloader

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.fileManager = [NSFileManager defaultManager];
        
        self.sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:nil];
        self.sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/html", nil];
        
        self.downloadDirectory = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.component.download", [[[NSBundle mainBundle] infoDictionary] objectForKey:(__bridge NSString *)kCFBundleIdentifierKey]]];
        
        self.tasks = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)setDownloadDirectory:(NSString *)downloadDirectory
{
    _downloadDirectory = downloadDirectory;
    [self checkDirectory];
}

- (void)checkDirectory
{
    NSError *error;
    [self.fileManager createDirectoryAtPath:self.downloadDirectory withIntermediateDirectories:YES attributes:nil error:&error];
    if (error) {
        MGJLogError(@"下载目录创建失败");
    }
}

- (void)downloadComponent:(MGJDownloadableComponentMetaInfo *)componentInfo progress:(NSProgress *__autoreleasing *)progress completionHandler:(MGJComponentDownloaderCompletionHandler)completionHandler
{
    @synchronized(self) {
        
        NSURLSessionDownloadTask *downloadTask = self.tasks[componentInfo.url];
        
        NSString *downloadPath = [self downloadPathForComponent:componentInfo];
        
        if (downloadTask) {
            return;
        }
        else if ([self.fileManager fileExistsAtPath:downloadPath]) {
            if (completionHandler) {
                completionHandler(componentInfo, [NSURL fileURLWithPath:downloadPath], nil);
            }
        }
        else {
            NSURLRequest *downloadRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:componentInfo.url]];
            
            @weakify(self);
            downloadTask = [self.sessionManager downloadTaskWithRequest:downloadRequest progress:progress destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
                return [NSURL fileURLWithPath:downloadPath];
            } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
                @strongify(self);
                [self.tasks removeObjectForKey:componentInfo.url];
                if (completionHandler) {
                    completionHandler(componentInfo, filePath, error);
                }
            }];
            [self.tasks setObject:downloadTask forKey:componentInfo.url];
            [downloadTask resume];
        }
    }
}

- (NSString *)downloadPathForComponent:(MGJDownloadableComponentMetaInfo *)component
{
    return [self.downloadDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-%@.amr", component.id, component.md5]];
}

- (void)cancelDownloadWithComponentInfo:(MGJDownloadableComponentMetaInfo *)componentInfo
{
    @synchronized(self) {
        NSURLSessionDownloadTask *downloadTask = self.tasks[componentInfo.url];
        if (downloadTask) {
            [downloadTask cancel];
            [self.tasks removeObjectForKey:componentInfo.url];
        }
    }
}
@end
