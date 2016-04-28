//
//  MGJStorageService.h
//  MGJiPhoneSDK
//
//  Created by kunka on 14/6/22.
//  Copyright (c) 2014年 juangua. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 *  公用存储服务
 */
@interface MGJStorageService : NSObject

/**
 *  存储对象到内存
 *
 *  @param Object 对象
 *  @param aKey   key
 */
+ (void)setObjectToMemory:(id)Object forKey:(NSString *)aKey;

/**
 *  内存中的某个对象
 *
 *  @param aKey key
 *
 *  @return
 */
+ (id)objectFromMemoryForKey:(NSString *)aKey;

/**
 *  从内存中移除某个对象
 *
 *  @param aKey key
 */
+ (void)removeObjectFromMemoryForKey:(NSString *)aKey;

/**
 *  存储对象到本地缓存
 *
 *  @param Object   对象，需要实现 nscoding
 *  @param aKey     key
 */
+ (void)setObjectToLocalCache:(id)Object forKey:(NSString *)aKey;

/**
 *  读取本地缓存中的对象
 *
 *  @param aKey   key
 *
 *  @return
 */
+ (id)objectFromLocalCacheForKey:(NSString *)aKey;

/**
 *  移除本地缓存中的对象
 *
 *  @param aKey  key
 */
+ (void)removeObjectFromLocalCacheForKey:(NSString *)aKey;

@end

