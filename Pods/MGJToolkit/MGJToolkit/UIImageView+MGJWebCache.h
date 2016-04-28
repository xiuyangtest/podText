//
//  UIImageView+MGJ.h
//  Mogujie4iPhone
//
//  Created by kunka on 13-6-17.
//  Copyright (c) 2013年 juangua. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SDWebImage/UIImageView+WebCache.h>


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
typedef void (^mgj_sd_downloadImageFailureBlock)(NSError *error,NSString *imageURLString);;

/**
 *  UIImageView 扩展
 */
@interface UIImageView (MGJWebCache)

/**
 *  设置block
 *
 *  @param success mgj_sd_downloadImageSuccessBlock
 *  @param failure mgj_sd_downloadImageFailureBlock
 */
+(void)setDownloadImageSuccessBlock:(mgj_sd_downloadImageSuccessBlock)success FailureBlock:(mgj_sd_downloadImageFailureBlock)failure;

/**
 *  设置网络图片
 *
 *  @param url 图片地址
 */
- (void)mgj_setImageWithURL:(NSString*)url;

/**
 *  设置网络图片
 *
 *  @param url              图片地址
 *  @param placeHolderImage 占位的默认图
 */
- (void)mgj_setImageWithURL:(NSString*)url placeholderImage:(UIImage *)placeholder;

/**
 *  设置图片
 *
 *  @param url              图片地址
 *  @param placeHolderImage 占位图
 *  @param animated         是否显示动画
 */
- (void)mgj_setImageWithURL:(NSString*)url placeholderImage:(UIImage *)placeholder animated:(BOOL)animated;

/**
 *  设置网络图片
 *
 *  @param url              图片地址
 *  @param completedBlock   图片下载完成后的操作
 */
- (void)mgj_setImageWithURL:(NSString *)url complete:(void (^)(UIImage *image))completedBlock;


- (void)mgj_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options resizeImage:(BOOL)resizeImage progress:(SDWebImageDownloaderProgressBlock)progressBlock completed:(SDWebImageCompletionBlock)completedBlock;
@end
