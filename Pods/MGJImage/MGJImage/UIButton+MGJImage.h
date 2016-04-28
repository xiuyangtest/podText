//
//  UIButton+MGJImage.h
//  Example
//
//  Created by 昆卡 on 16/1/4.
//  Copyright © 2016年 Juangua. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SDWebImage/UIButton+WebCache.h>

@interface UIButton (MGJImage)
/**
 *  设置 BackgroundImage。对 URL 不做任何处理
 *
 *  @param url            图片地址
 *  @param state          UIControlState
 *  @param placeholder    占位图
 *  @param options        option
 *  @param completedBlock completedBlock
 */
- (void)mgj_setBackgroundImageWithURL:(NSURL *)url forState:(UIControlState)state placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options completed:(SDWebImageCompletionBlock)completedBlock;

/**
 *  设置 BackgroundImage。根据传入的尺寸匹配到图片规则。默认根据宽自适应，不切图。
 *
 *  @param url            图片地址
 *  @param expectSize    预期的图片尺寸（pt）
 *  @param state          UIControlState
 *  @param placeholder    占位图
 *  @param options        option
 *  @param completedBlock completedBlock
 */
- (void)mgj_setBackgroundImageWithURL:(NSURL *)url expectSize:(NSInteger)expectSize forState:(UIControlState)state placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options completed:(SDWebImageCompletionBlock)completedBlock;

/**
 *  设置 BackgroundImage。根据传入的尺寸匹配到图片规则。
 *
 *  @param url            图片地址
 *  @param expectSize    预期的图片尺寸（pt）
 *  @param needCrop       是否切图。如果切图，返回的为方图；如果不切图，根据宽度自适应。
 *  @param state          UIControlState
 *  @param placeholder    占位图
 *  @param options        option
 *  @param completedBlock completedBlock
 */
- (void)mgj_setBackgroundImageWithURL:(NSURL *)url expectSize:(NSInteger)expectSize needCrop:(BOOL)needCrop forState:(UIControlState)state placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options completed:(SDWebImageCompletionBlock)completedBlock;

/**
 *  设置 Image。对 URL 不做任何处理
 *
 *  @param url            图片地址
 *  @param state          UIControlState
 *  @param placeholder    占位图
 *  @param options        option
 *  @param completedBlock completedBlock
 */
- (void)mgj_setImageWithURL:(NSURL *)url forState:(UIControlState)state placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options completed:(SDWebImageCompletionBlock)completedBlock;


/**
 *  设置 Image。根据传入的尺寸匹配到图片规则。默认根据宽自适应，不切图。
 *
 *  @param url            图片地址
 *  @param expectSize    预期的图片尺寸（pt）
 *  @param state          UIControlState
 *  @param placeholder    占位图
 *  @param options        option
 *  @param completedBlock completedBlock
 */

- (void)mgj_setImageWithURL:(NSURL *)url expectSize:(NSInteger)expectSize forState:(UIControlState)state placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options completed:(SDWebImageCompletionBlock)completedBlock;

/**
 *  设置 Image。根据传入的尺寸匹配到图片规则。
 *
 *  @param url            图片地址
 *  @param expectSize    预期的图片尺寸（pt）
 *  @param needCrop       是否切图。如果切图，返回的为方图；如果不切图，根据宽度自适应。
 *  @param state          UIControlState
 *  @param placeholder    占位图
 *  @param options        option
 *  @param completedBlock completedBlock
 */
- (void)mgj_setImageWithURL:(NSURL *)url expectSize:(NSInteger)expectSize needCrop:(BOOL)needCrop forState:(UIControlState)state placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options completed:(SDWebImageCompletionBlock)completedBlock;
@end
