//
//  MGJPTPHash.m
//  Example
//
//  Created by limboy on 1/12/15.
//  Copyright (c) 2015 juangua. All rights reserved.
//

#import "MGJPTPHash.h"

static NSString * const hashBaseString = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

@implementation MGJPTPHash

+ (NSString *)randomStringWithLength:(NSInteger)length
{
    NSMutableString *randomString = [[NSMutableString alloc] init];
    for (NSInteger i = 0 ; i < length; i++) {
        [randomString appendString:[hashBaseString substringWithRange:NSMakeRange(arc4random_uniform((UInt32)hashBaseString.length), 1)]];
    }
    return [randomString copy];
}

+ (NSString *)hashWithInputString:(NSString *)inputString length:(NSInteger)length
{
    return [self hashWithInputString:inputString factor:31 length:length];
}

+ (NSString *)hashWithInputString:(NSString *)inputString factor:(NSInteger)factor length:(NSInteger)length
{
    if (!inputString || length < 1) {
        return @"";
    }
    
    NSMutableString *result = [[NSMutableString alloc] init];
    NSInteger code = [self codeWithInputString:inputString factor:factor];
    NSInteger quotient;
    NSInteger mod = 0;
    
    while (result.length < length) {
        quotient = code / hashBaseString.length;
        mod = (NSInteger) (code % hashBaseString.length);
        [result appendString:[hashBaseString substringWithRange:NSMakeRange(mod, 1)]];
        if (quotient == 0) {
            break;
        }
        code = quotient;
    }
    return [result copy];
}

+ (NSString *)attachVerifyToString:(NSString *)inputString
{
    return [inputString stringByAppendingString:[self verifyString:inputString]];
}

+ (NSString *)removeVerifyFromString:(NSString *)inputString
{
    if (inputString) {
        NSString *verifyString = [inputString substringFromIndex:inputString.length - 1];
        NSString *originString = [inputString substringToIndex:inputString.length - 1];
        NSString *computedVerifyString = [self verifyString:originString];
        if ([verifyString isEqualToString:computedVerifyString]) {
            return originString;
        }
        return @"";
    }
    return @"";
}

+ (NSString *)pageHashWithURL:(NSString *)urlString
{
    return [NSString stringWithFormat:@"%@%@", [self hashWithInputString:urlString factor:31 length:4],
                                               [self hashWithInputString:urlString factor:33 length:4]];
}

#pragma mark - Utils

/**
 *  计算字符串的 code 值
 *
 *  @param inputString 目标字符串
 *  @param factor      质数因子
 *
 *  @return 字符串的 code 值
 */
+ (NSInteger)codeWithInputString:(NSString *)inputString factor:(NSInteger)factor
{
    NSInteger code = 0;
    const char *characters = [inputString UTF8String];
    for (NSInteger i = 0; i < strlen(characters); i++) {
        NSInteger value = characters[i];
        if (value < 0 || value > 127) {
            value = 0;
        }
        code = code & 0x00ffffff;
        code = factor * code + value;
    }
    return code;
}

/**
 *  获取校验位字符: 将字符串各个字符的 ASCII 码值相加, 取模后得到校验位
 *
 *  @param inputString 需要校验的字符
 *
 *  @return 校验字符
 */
+ (NSString *)verifyString:(NSString *)inputString
{
    //return [hashBaseString substringWithRange:NSMakeRange(([self codeWithInputString:inputString factor:31] % hashBaseString.length), 1)];
    NSInteger index = 0;
    const char *characters = [inputString UTF8String];
    for (NSInteger i = 0; i < strlen(characters); i++) {
        index += characters[i];
    }
    index %= hashBaseString.length;
    return [hashBaseString substringWithRange:NSMakeRange(index, 1)];
}

@end
