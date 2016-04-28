//
//  UIImageView+MGJImage.h
//  Example
//
//  Created by 昆卡 on 16/1/4.
//  Copyright © 2016年 Juangua. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SDWebImage/UIImageView+WebCache.h>


@interface UIImageView (MGJImage)
/**
 *  加载指定 URL 的图片。对 URL 不做任何处理
 *
 *  @param url 图片地址
 */
- (void)mgj_setImageWithURL:(NSString *)url;

/**
 *  加载指定 URL 的图片。对 URL 不做任何处理
 *
 *  @param url 图片地址
 *  @param placeholder 占位图
 */
- (void)mgj_setImageWithURL:(NSString *)url placeholderImage:(UIImage *)placeholder;

/**
 *  加载指定 URL 的图片。根据传入的尺寸匹配到图片规则。根据宽自适应、不切图。
 *
 *  @param url 图片地址
 *  @param expectSize 预期的图片尺寸（pt）
 *  @param placeholder 占位图
 */
- (void)mgj_setImageWithURL:(NSString *)url expectSize:(NSInteger)expectSize placeholderImage:(UIImage *)placeholder;

/**
 *  加载指定 URL 的图片。根据传入的尺寸匹配到图片规则。
 *
 *  @param url 图片地址
 *  @param expectSize 预期的图片尺寸（pt）
 *  @param needCrop 是否切图。如果切图，返回的为方图；如果不切图，根据宽度自适应。
 *  @param placeholder 占位图
 */
- (void)mgj_setImageWithURL:(NSString *)url expectSize:(NSInteger)expectSize needCrop:(BOOL)needCrop placeholderImage:(UIImage *)placeholder;


/**
 *  加载指定 URL 的图片。对 URL 不做任何处理
 *
 *  @param url            图片地址
 *  @param placeholder    占位图
 *  @param options        options
 *  @param progressBlock  progressBlock
 *  @param completedBlock completedBlock
 */
- (void)mgj_setImageWithURL:(NSString *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options progress:(SDWebImageDownloaderProgressBlock)progressBlock completed:(SDWebImageCompletionBlock)completedBlock;

/**
 *  加载指定 URL 的图片。对 URL 不做任何处理
 *
 *  @param url         图片地址
 *  @param placeholder 占位图
 *  @param animated    图片加载后是否需要渐变动画
 */
- (void)mgj_setImageWithURL:(NSString *)url placeholderImage:(UIImage *)placeholder animated:(BOOL)animated;

/**
 *  加载指定 URL 的图片。默认会从 URL 中取缩略图的尺寸，对 URL 不做任何处理
 *
 *  @param url            图片地址
 *  @param completedBlock completedBlock
 */
- (void)mgj_setImageWithURL:(NSString *)url complete:(void (^)(UIImage *image))completedBlock;

/**
 *  加载指定 URL 的图片。根据传入的尺寸匹配到图片规则。
 *
 *  @param url 图片地址
 *  @param expectSize 预期的图片尺寸（pt）
 *  @param needCrop 是否切图。如果切图，返回的为方图；如果不切图，根据宽度自适应。
 *  @param placeholder 占位图
 *  @param options        options
 *  @param progressBlock  progressBlock
 *  @param completedBlock completedBlock
 */
- (void)mgj_setImageWithURL:(NSString *)url expectSize:(NSInteger)expectSize needCrop:(BOOL)needCrop placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options progress:(SDWebImageDownloaderProgressBlock)progressBlock completed:(SDWebImageCompletionBlock)completedBlock;

@end
