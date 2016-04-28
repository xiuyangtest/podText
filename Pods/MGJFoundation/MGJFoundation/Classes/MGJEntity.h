//
//  MGJEntity.h
//  MGJiPhoneSDK
//
//  Created by kunka on 14-8-25.
//  Copyright (c) 2013年 juangua. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AutoCoding/AutoCoding.h>


/**
 *  所有实体类的基类，包含了实体序列化、反序列化的方法
 */
@interface MGJEntity : NSObject<NSCopying>


#pragma mark - class method

/**
 *  从字典创建实体类,默认会转数组
 *
 *  @param dict 字典
 *
 *  @return 实体类
 */
+ (id)entityWithDictionary:(NSDictionary *)dict;

/**
 *  从字典创建实体类
 *
 *  @param dict          字典
 *  @param parseArray 是否解析数组
 *
 *  @return 实体类
 */
+ (id)entityWithDictionary:(NSDictionary *)dict parseArray:(BOOL)parseArray;

/**
 *  字典数组转成实体数组
 *
 *  @param array 字典数组
 *  @param type  数组中的元素类型
 *
 *  @return 实体数组
 */
+ (NSArray *)parseToEntityArray:(NSArray *)array withType:(Class)type;

/**
 *  实体数组转成
 *
 *  @param array 实体数组
 *
 *  @return 字典数组
 */
+ (NSArray *)parseToDictionaryArray:(NSArray *)array;

#pragma mark - init method
/**
 *  从字典创建实体类,默认转数组
 *
 *  @param dict 字典
 *
 *  @return 实体类
 */
- (id)initWithDictionary:(NSDictionary *)dict;

/**
 *  从字典创建实体类
 *
 *  @param dict       字典
 *  @param parseArray 是否解析数组
 *
 *  @return 实体类
 */
- (id)initWithDictionary:(NSDictionary *)dict parseArray:(BOOL)parseArray;

/**
 *  实体转字典
 *
 *  @return
 */
- (NSDictionary *)entityToDictionary;

/**
 *  从字典填充数据到当前实体
 *
 *  @param dict       字典
 *  @param parseArray 是否解析数组
 */
- (void)parseValueFromDic:(NSDictionary *)dict parseArray:(BOOL)parseArray;

#pragma mark - map
/**
 *  字段名映射，key 为实体的字段, value 为字典中的字段
 *
 *  @return
 */
- (NSDictionary *)keyMapDictionary;

/**
 *  数组中的实体类型映射，key 为数组变量名，value 为数组中的元素类型
 *
 *  @return
 */
- (NSDictionary *)entityMapForArray;

#pragma mark - others
/**
 *  开始解析前调用
 */
- (void)willParseValue;

/**
 *  解析完成后调用
 */
- (void)didParseValue;

@end
