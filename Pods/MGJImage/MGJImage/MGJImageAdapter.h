//
//  MGJImageAdapter.h
//  Example
//
//  Created by Blank on 15/12/7.
//  Copyright © 2015年 Juangua. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


typedef NS_ENUM(NSInteger, MGJImageAdapterNetworkStatus){
    MGJImageAdapterNetworkStatusWWAN = 0,
    MGJImageAdapterNetworkStatusWiFi = 1,
};

@interface MGJImageAdapter : NSObject

+ (instancetype)sharedInstance;


/**
 *  更新图片规则
 *
 *  @param rules 图片规则数组，字典格式
 */
- (void)updateRules:(NSArray *)rules;


/**
 *  根据图片规则生成匹配后的图片地址，会根据 URL 中的参数计算出目标大小
 *
 *  @param imageURL 输入图片地址
 *
 *  @return 匹配后的图片地址
 */
- (NSString *)adaptImageURL:(NSString *)imageURL;

/**
 *  根据图片规则生成匹配后的图片地址，默认根据宽自适应，不切图
 *
 *  @param imageURL 输入图片地址
 *  @param size     图片尺寸（宽 pt）
 *
 *  @return 匹配后的图片地址
 */
- (NSString *)adaptImageURL:(NSString *)imageURL toSize:(NSInteger)size;


/**
 *  根据图片规则生成匹配后的图片地址
 *
 *  @param imageURL 输入图片地
 *  @param size     图片尺寸（宽 pt)
 *  @param needCrop 是否切图，如果需要裁剪，会返回方图。如果不裁剪，返回根据宽自适应的图。
 *
 *  @return 匹配后的图片地址
 */
- (NSString *)adaptImageURL:(NSString *)imageURL toSize:(NSInteger)size needCrop:(BOOL)needCrop;

@end
