//
//  MGJImageConfigManager.h
//  Example
//
//  Created by 昆卡 on 16/1/4.
//  Copyright © 2016年 Juangua. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <SDWebImage/SDImageCache.h>

/**
 *  下载图片成功后的block
 *
 *  @param cacheType SDImageCacheType
 *  @param duration  duration 下载图片用时
 *  @param imageURLString imageURLString
 */
typedef void (^mgj_sd_downloadImageSuccessBlock)(SDImageCacheType cacheType, NSTimeInterval duration, NSString *imageURLString);

/**
 *  下载图片失败后调用的block
 *
 *  @param error          error
 *  @param imageURLString imageURLString
 */
typedef void (^mgj_sd_downloadImageFailureBlock)(NSError *error,NSString *imageURLString);



@interface MGJImageConfigManager : NSObject

/**
 *  启用调试模式，此时会把 cdn 域名切到测试服务器，可用于测试为上线的图片尺寸
 *
 *  @param enabled enabled
 */
+ (void)enableDebugModeForImageAdapter:(BOOL)enabled;

/**
 *  调试模式是否开启
 *
 *  @return
 */
+ (BOOL)debugModeForImageAdapterEnabled;

/**
 *  设置block
 *
 *  @param success mgj_sd_downloadImageSuccessBlock
 *  @param failure mgj_sd_downloadImageFailureBlock
 */
+ (void)setDownloadImageSuccessBlock:(mgj_sd_downloadImageSuccessBlock)success FailureBlock:(mgj_sd_downloadImageFailureBlock)failure;

/**
 *  获取图片加载完成后的回调
 *
 *  @return
 */
+ (mgj_sd_downloadImageSuccessBlock)downloadImageSuccessBlock;


/**
 *  获取图片加载失败的回调
 *
 *  @return
 */
+ (mgj_sd_downloadImageFailureBlock)downloadImageFailureBlock;
@end
