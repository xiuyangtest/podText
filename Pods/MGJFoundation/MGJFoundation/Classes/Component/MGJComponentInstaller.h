//
//  MGJComponentInstaller.h
//  Example
//
//  Created by Blank on 15/7/22.
//  Copyright (c) 2015年 juangua. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MGJDownloadableComponentMetaInfo.h"
#import "MGJComponentInstallOperation.h"
#import "NSObject+MGJSingleton.h"


@interface MGJComponentInstaller : NSObject<Singleton>
@property (nonatomic, copy) NSString *installDirectory;
- (void)installComponent:(MGJDownloadableComponentMetaInfo *)componentInfo
        withDownloadPath:(NSString *)path
       completionHandler:(MGJComponentInstallCompletionHandler)completionHandler;

- (NSString *)installPathForComponent:(MGJDownloadableComponentMetaInfo *)component;
- (NSString *)configPathForComponent:(MGJDownloadableComponentMetaInfo *)component;
@end
