//
//  MGJDownloadableComponentMetaInfo.h
//  Example
//
//  Created by limboy on 7/21/15.
//  Copyright (c) 2015 juangua. All rights reserved.
//

#import "MGJNativeComponentMetaInfo.h"

typedef NS_ENUM(NSUInteger, MGJDownloadableComponentState) {
    ComponentNotDownloaded,
    ComponentDownloading,
    ComponentDownloadedButNotInstalled,
    ComponentInstalled,
    ComponentInvalid
};

typedef NS_ENUM(NSUInteger, MGJDownloadableComponentType) {
    DownloadableComponentTypeHTML5,
    DownloadableComponentTypeReactNative,
};

@interface MGJDownloadableComponentMetaInfo : MGJNativeComponentMetaInfo

@property (nonatomic, assign) MGJDownloadableComponentState state;
@property (nonatomic, copy) NSString *md5; // 这里可以用更通用的 key
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSArray *clientURLs;
@end
