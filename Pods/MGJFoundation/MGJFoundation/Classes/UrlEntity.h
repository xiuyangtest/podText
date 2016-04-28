//
//  UrlEntity.h
//  Mogujie4iPad
//
//  Created by qimi on 13-3-8.
//  Copyright (c) 2013年 juangua. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MGJEntity.h"

/**
 *  URL 解析类
 */
@interface UrlEntity :NSObject

/**
 *  scheme
 */
@property (strong, nonatomic, readonly) NSString *scheme;

/**
 *  host
 */
@property (strong, nonatomic, readonly) NSString *host;

/**
 *  path
 */
@property (strong, nonatomic, readonly) NSString *path;

/**
 *  URL 中的参数列表
 */
@property (strong, nonatomic, readonly) NSDictionary *params;

/**
 *  URL String
 */
@property (strong, nonatomic, readonly) NSString *absoluteString;

/**
 *  从 URL 字符串创建 URLEntity
 *
 *  @param urlString url
 *
 *  @return 对应的 URLEntity
 */
+ (instancetype)URLWithString:(NSString * _Nonnull)urlString;
@end
