//
//  MGJComponentInstallOperation.h
//  Example
//
//  Created by Blank on 15/7/22.
//  Copyright (c) 2015年 juangua. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MGJDownloadableComponentMetaInfo.h"

typedef void(^MGJComponentInstallCompletionHandler)(NSError *error, NSDictionary *urlMaps);

@interface MGJComponentInstallOperation : NSOperation
- (instancetype)initWithComponentInfo:(MGJDownloadableComponentMetaInfo *)componentInfo
                         downloadPath:(NSString *)downloadPath
                          installPath:(NSString *)installPath
                   completionHandler:(MGJComponentInstallCompletionHandler)completionHandler;

@end
