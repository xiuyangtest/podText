//
//  MGJPTPHash.h
//  Example
//
//  Created by limboy on 1/12/15.
//  Copyright (c) 2015 juangua. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MGJPTPHash : NSObject

/**
 *  返回指定位数的随机字符串
 *
 *  @param length 字符串的长度
 *
 *  @return
 */
+ (NSString *)randomStringWithLength:(NSInteger)length;

/**
 *  计算 PTP 的 哈希值，除非要自定义 factor，不然调用这个方法就可以了
 *
 *  @param inputString 要计算哈希值的字符串
 *  @param length      生成的哈希值长度
 *
 *  @return hash 后的字符串
 */
+ (NSString *)hashWithInputString:(NSString *)inputString length:(NSInteger)length;

/**
 *  计算 PTP 的 哈希值
 *
 *  @param inputString 要计算哈希值的字符串
 *  @param factor      质数因子，0 < factor < 2^8
 *  @param length      生成的哈希值长度
 *
 *  @return hash 后的字符串
 */
+ (NSString *)hashWithInputString:(NSString *)inputString factor:(NSInteger)factor length:(NSInteger)length;

/**
 *  给字符串增加校验位
 *
 *  @param inputString 目标字符串
 *
 *  @return 原字符串 + 校验位
 */
+ (NSString *)attachVerifyToString:(NSString *)inputString;

/**
 *  删除字符串的校验位，如果校验不通过，返回空字符串
 *
 *  @param inputString 带有校验位的字符串
 *
 *  @return 删除校验位的字符串
 */
+ (NSString *)removeVerifyFromString:(NSString *)inputString;

/**
 *  page 的 hash 算法
 *
 *  @param urlString url page，PTP 中的 b 字段, 该参数必须由 ASCII 码表范围内的字符组成
 *
 *  @return 编码之后的结果. 为了减少碰撞, 前4位采用31为质数因子计算hash, 后4位采用33为质数因子计算hash
 */
+ (NSString *)pageHashWithURL:(NSString *)urlString;

@end
