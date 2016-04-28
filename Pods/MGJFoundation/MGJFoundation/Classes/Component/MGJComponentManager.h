//
//  MGJComponentManager.h
//  Example
//
//  Created by limboy on 7/21/15.
//  Copyright (c) 2015 juangua. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+MGJSingleton.h"
#import "MGJDownloadableComponentMetaInfo.h"
#import "MGJDownloadableRouterInfo.h"
#import <CoreGraphics/CGBase.h>

@interface MGJComponentManager : NSObject <Singleton>

- (void)registerComponentsWithLocalMetaInfoURL:(NSString *)localMetaInfoURL remoteMetaInfoURL:(NSString *)remoteMetaInfoURL;

- (void)registerScheme:(NSString *)scheme
withDownloadableComponent:(MGJDownloadableComponentType)componentType
               handler:(void (^)(MGJDownloadableComponentMetaInfo *componentInfo, MGJDownloadableRouterInfo *routerInfo))handler;

- (void)installDownloadableComponent:(MGJDownloadableComponentMetaInfo *)componentInfo
                                   progress:(NSProgress * __autoreleasing *)progress
                                 completionHandler:(void (^)(NSError *error))completionHandler;


- (void)cancelInstallingComponent:(MGJDownloadableComponentMetaInfo *)componentInfo;
@end
