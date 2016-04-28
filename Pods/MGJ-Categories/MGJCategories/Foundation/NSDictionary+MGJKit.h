//
//  NSDictionary+MGJKit.h
//  Pods
//
//  Created by limboy on 12/19/14.
//
//

#import <Foundation/Foundation.h>

@interface NSDictionary (MGJKit)

- (CGPoint)mgj_pointForKey:(NSString *)key;
- (CGSize)mgj_sizeForKey:(NSString *)key;
- (CGRect)mgj_rectForKey:(NSString *)key;

/**
 *  @author kongkong
 *
 *  @brief 字典数据转化为json
 *
 *  @return json串
 */
- (NSString*)mgj_ConvertJSONString;
@end
