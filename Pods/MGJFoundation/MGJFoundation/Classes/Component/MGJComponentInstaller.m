//
//  MGJComponentInstaller.m
//  Example
//
//  Created by Blank on 15/7/22.
//  Copyright (c) 2015年 juangua. All rights reserved.
//

#import "MGJComponentInstaller.h"
#import "MGJComponentInstallOperation.h"
#import "MGJLog.h"
#import "MGJEXTScope.h"


@interface MGJComponentInstaller ()
@property (nonatomic, strong) NSMutableDictionary *operations;
@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, strong) NSFileManager *fileManager;
@end

@implementation MGJComponentInstaller

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.fileManager = [NSFileManager defaultManager];
        
        self.operations = [NSMutableDictionary dictionary];
        
        self.installDirectory = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.component.install", [[[NSBundle mainBundle] infoDictionary] objectForKey:(__bridge NSString *)kCFBundleIdentifierKey]]];

        self.queue = [[NSOperationQueue alloc] init];
        self.queue.maxConcurrentOperationCount = 1;
    }
    return self;
}

- (void)setInstallDirectory:(NSString *)installDirectory
{
    _installDirectory = installDirectory;
    [self checkDirectory];
}

- (void)checkDirectory
{
    NSError *error;
    [self.fileManager createDirectoryAtPath:self.installDirectory withIntermediateDirectories:YES attributes:nil error:&error];
    if (error) {
        MGJLogError(@"安装目录创建失败");
    }
}

- (NSString *)installPathForComponent:(MGJDownloadableComponentMetaInfo *)component
{
    return [self.installDirectory stringByAppendingPathComponent:component.id];
}

- (NSString *)configPathForComponent:(MGJDownloadableComponentMetaInfo *)component
{
    return [[self installPathForComponent:component] stringByAppendingPathComponent:@"config.json"];
}

- (void)installComponent:(MGJDownloadableComponentMetaInfo *)componentInfo withDownloadPath:(NSString *)path completionHandler:(MGJComponentInstallCompletionHandler)completionHandler
{
    @synchronized(self) {
       
        MGJComponentInstallOperation *operation = self.operations[componentInfo.id];
        
        if (operation) {
            return;
        }
        
        @weakify(self);
        operation = [[MGJComponentInstallOperation alloc] initWithComponentInfo:componentInfo downloadPath:path installPath:[self installPathForComponent:componentInfo] completionHandler:^(NSError *error, NSDictionary *urlMaps) {
            @strongify(self);
            if (completionHandler) {
                completionHandler(error, urlMaps);
            }
            [self.operations removeObjectForKey:componentInfo.id];
        }];
        [self.operations setObject:operation forKey:componentInfo.id];
        [self.queue addOperation:operation];

    }
}
@end
