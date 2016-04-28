//
//  MGJComponentDownloader.h
//  Example
//
//  Created by Blank on 15/7/22.
//  Copyright (c) 2015年 juangua. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+MGJSingleton.h"
#import "MGJDownloadableComponentMetaInfo.h"
#import "MGJEXTScope.h"

typedef void(^MGJComponentDownloaderCompletionHandler)(MGJDownloadableComponentMetaInfo *componentInfo, NSURL *url, NSError *error);

@interface MGJComponentDownloader : NSObject<Singleton>

@property (nonatomic, copy) NSString *downloadDirectory;

- (void)downloadComponent:(MGJDownloadableComponentMetaInfo *)componentInfo
                 progress:(NSProgress * __autoreleasing *)progress
        completionHandler:(MGJComponentDownloaderCompletionHandler)completionHandler;

- (void)cancelDownloadWithComponentInfo:(MGJDownloadableComponentMetaInfo *)componentInfo;
@end
