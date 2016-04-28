//
//  MGJEntity.h
//  MGJiPhoneSDK
//
//  Created by kunka on 14-8-25.
//  Copyright (c) 2013年 juangua. All rights reserved.
//

#import "MGJEntity.h"
#import <objc/runtime.h>

@interface MGJEntity ()
- (void)parseValueFromDic:(NSDictionary *)dict toClass:(Class)class parseArray:(BOOL)parseArray;
- (void)parseValueToDic:(NSMutableDictionary *)dict fromClass:(Class)class;
- (NSString *)getClassNameFromAttributeString:(NSString *)attributeString;
@end

@implementation MGJEntity

#pragma mark - class method

+ (id)entityWithDictionary:(NSDictionary *)dict
{
    return [self entityWithDictionary:dict parseArray:YES];
}

+ (id)entityWithDictionary:(NSDictionary *)dict parseArray:(BOOL)parseArray
{
    return [[[self class] alloc] initWithDictionary:dict parseArray:parseArray];
}

+ (NSArray *)parseToEntityArray:(NSArray *)array withType:(Class)type
{
    if (!array || ![array isKindOfClass:[NSArray class]] || !type) {
        return nil;
    }
    
    NSMutableArray *entityArray = [NSMutableArray array];
    
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        //元素为字典，并且目标类型为 MGJEntity 子类的时候，进行解析
        if ([obj isKindOfClass:[NSDictionary class]] && [type isSubclassOfClass:[MGJEntity class]]) {
            MGJEntity *entity = [type entityWithDictionary:obj];
            if (entity) {
                [entityArray addObject:entity];
            }
        }
        //目标类型和元素类型相同时，直接赋值
        else if ([obj isKindOfClass: type])
        {
            [entityArray addObject:obj];
        }
    }];
    
    return entityArray;
}

+ (NSArray *)parseToDictionaryArray:(NSArray *)array
{
    if (!array || ![array isKindOfClass:[NSArray class]]) {
        return nil;
    }
    
    NSMutableArray *dicArray = [NSMutableArray array];
    
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[MGJEntity class]]) {
            NSDictionary *dictionary = [obj entityToDictionary];
            if (dictionary) {
                [dicArray addObject:dictionary];
            }
        }
        else
        {
            [dicArray addObject:obj];
        }
    }];
    
    return dicArray;
}

#pragma mark - init method

- (id)initWithDictionary:(NSDictionary *)dict
{
    return [self initWithDictionary:dict parseArray:YES];
}

- (id)initWithDictionary:(NSDictionary *)dict parseArray:(BOOL)parseArray
{
    if (!dict || ![dict isKindOfClass:[NSDictionary class]] || dict.count == 0) {
        return nil;
    }
    self = [super init];
    if (self) {
        [self willParseValue];
        [self parseValueFromDic:dict parseArray:parseArray];
        [self didParseValue];
    }
    return self;
}

#pragma mark - parse method
- (void)parseValueFromDic:(NSDictionary *)dict toClass:(Class)class parseArray:(BOOL)parseArray
{
    unsigned int propertyCount;
    
    objc_property_t *properties = class_copyPropertyList(class, &propertyCount);
    
    NSDictionary *keyMapDictionary = [self keyMapDictionary];
    NSDictionary *entityMapDictionary = [self entityMapForArray];
    
    for (int i = 0; i < propertyCount; i++) {
        objc_property_t property = properties[i];
        
        //取属性名称
        NSString *propertyName = [NSString stringWithUTF8String:property_getName(property)];
        
        NSString *key = propertyName;
        
        //key映射
        if ([keyMapDictionary.allKeys containsObject:propertyName]) {
            key = keyMapDictionary[propertyName];
        }
        
        id value = dict[key];
        
        //字典中如果没有当前字段，则进入下一个循环
        if (!value) {
            continue;
        }
        
        NSString *attributeString = [NSString stringWithUTF8String:property_getAttributes(property)];
        NSString *typeString = [[attributeString componentsSeparatedByString:@","] objectAtIndex:0];
        
        //类名，非基础类型
        NSString *classNameString = [self getClassNameFromAttributeString:typeString];;
        
        //基础类型
        if ([value isKindOfClass:[NSNumber class]]) {
            //当对应的属性为基础类型或者 NSNumber 时才处理
            if ([typeString isEqualToString:@"Td"] || [typeString isEqualToString:@"Ti"] || [typeString isEqualToString:@"Tf"] || [typeString isEqualToString:@"Tl"] || [typeString isEqualToString:@"Tc"] || [typeString isEqualToString:@"Ts"] || [typeString isEqualToString:@"TI"]|| [typeString isEqualToString:@"Tq"] || [typeString isEqualToString:@"TQ"] || [typeString isEqualToString:@"TB"] ||[classNameString isEqualToString:@"NSNumber"]) {
                [self setValue:value forKey:propertyName];
            }
            else {
                if ([classNameString isEqualToString:@"NSString"]) {
                    [self setValue:[value stringValue] forKey:propertyName];
                }
                else{
                    NSLog(@"type error -- name:%@ attribute:%@ ", propertyName, typeString);
                }
            }
        }
        //字符串
        else if ([value isKindOfClass:[NSString class]]) {
            if ([classNameString isEqualToString:@"NSString"]) {
                [self setValue:value forKey:propertyName];
            }
            else if ([classNameString isEqualToString:@"NSMutableString"]) {
                [self setValue:[NSMutableString stringWithString:value] forKey:propertyName];
            }
            //对应的属性为基础类型时，先转成 nsnumber
            else if ([typeString isEqualToString:@"Td"] || [typeString isEqualToString:@"Ti"] || [typeString isEqualToString:@"Tf"] || [typeString isEqualToString:@"Tl"] || [typeString isEqualToString:@"Tc"] || [typeString isEqualToString:@"Ts"] || [typeString isEqualToString:@"TI"]|| [typeString isEqualToString:@"Tq"] || [typeString isEqualToString:@"TQ"] || [typeString isEqualToString:@"TB"]) {
                
                NSNumberFormatter *formater = [[NSNumberFormatter alloc] init];
                NSNumber *number = [formater numberFromString:value];
                if (number)
                {
                    [self setValue:number forKey:propertyName];
                }
            }
        }
        //字典（对象）
        else if ([value isKindOfClass:[NSDictionary class]]) {
            if ([classNameString isEqualToString:@"NSDictionary"]) {
                [self setValue:value forKey:propertyName];
            }
            else if ([classNameString isEqualToString:@"NSMutableDictionary"]) {
                [self setValue:[NSMutableDictionary dictionaryWithDictionary:value] forKey:propertyName];
            }
            else if ([NSClassFromString(classNameString) isSubclassOfClass:[MGJEntity class]])
            {
                [self setValue:[NSClassFromString(classNameString) entityWithDictionary:value parseArray:parseArray] forKey:propertyName];
            }
        }
        //数组
        else if ([value isKindOfClass:[NSArray class]]) {
            NSString *entityTypeStringForArray = entityMapDictionary[propertyName];
            Class entityTypeForArray = NSClassFromString(entityTypeStringForArray);
            
            if ([classNameString isEqualToString:@"NSArray"]) {
                if (parseArray && entityTypeForArray) {
                    [self setValue:[[self class] parseToEntityArray:value withType:entityTypeForArray] forKey:propertyName];
                }
                else
                {
                    [self setValue:value forKey:propertyName];
                }
            }
            else if ([classNameString isEqualToString:@"NSMutableArray"]) {
                if (parseArray && entityTypeForArray) {
                    [self setValue:[[self class] parseToEntityArray:value withType:entityTypeForArray] forKey:propertyName];
                }
                else
                {
                    [self setValue:[NSMutableArray arrayWithArray:value] forKey:propertyName];
                }
            }
        }
        //空
        else if ([value isKindOfClass:[NSNull class]]) {
            continue;
        }
        //其它不处理
        else
        {
            continue;
        }
        
    }
    
    free(properties);
    
    Class superClass = class_getSuperclass(class);
    
    //如果有父类 则继续解析
    if (superClass != class && superClass != [NSObject class]) {
        [self parseValueFromDic:dict toClass:superClass parseArray:parseArray];
    }
}

- (void)parseValueToDic:(NSMutableDictionary *)dict fromClass:(Class)class
{
    if (!dict) {
        return;
    }
    
    unsigned int propertyCount;
    
    objc_property_t *properties = class_copyPropertyList(class, &propertyCount);
    
    NSDictionary *keyMapDictionary = [self keyMapDictionary];
    
    for (int i = 0; i < propertyCount; i++) {
        objc_property_t property = properties[i];
        
        //取属性名称
        NSString *propertyName = [NSString stringWithUTF8String:property_getName(property)];

        NSString *key = propertyName;
        
        //key映射
        if ([keyMapDictionary.allKeys containsObject:propertyName]) {
            key = keyMapDictionary[propertyName];
        }
        
        id val = [self valueForKey:propertyName];
        
        if (val) {
            if ([val isKindOfClass:[MGJEntity class]]) {
                [dict setObject:[val entityToDictionary] forKey:key];
            }
            else if ([val isKindOfClass:[NSArray class]]) {
                NSArray *dictArray = [[self class] parseToDictionaryArray:val];
                if (dictArray) {
                    [dict setValue:dictArray forKey:key];
                }
            }
            else
            {
                [dict setValue:val forKey:key];
            }
        }
        
    }
    
    free(properties);
    
    Class superClass = class_getSuperclass(class);
    
    //如果有父类 则继续解析
    if (superClass != class && superClass != [NSObject class]) {
        [self parseValueToDic:dict fromClass:superClass];
    }
}

- (NSString *)getClassNameFromAttributeString:(NSString *)attributeString
{
    NSString *className = nil;
    
    NSScanner *scanner = [NSScanner scannerWithString: attributeString];
    
    [scanner scanUpToString:@"T" intoString: nil];
    [scanner scanString:@"T" intoString:nil];
    
    if ([scanner scanString:@"@\"" intoString: &className]) {
        
        [scanner scanUpToCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"\"<"]
                                intoString:&className];
    }
    
    return className;
}

- (void)parseValueFromDic:(NSDictionary *)dict parseArray:(BOOL)parseArray
{
    [self parseValueFromDic:dict toClass:[self class] parseArray:parseArray];
}

- (NSDictionary *)entityToDictionary
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    [self parseValueToDic:dict fromClass:[self class]];
    
    return dict;
}

#pragma mark - map
- (NSDictionary *)keyMapDictionary
{
    return nil;
}

- (NSDictionary *)entityMapForArray
{
    return nil;
}

#pragma mark - other
- (void)willParseValue
{
    
}

- (void)didParseValue
{
    
}

#pragma mark - kvc
- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
}

- (id)valueForUndefinedKey:(NSString *)key {
    return nil;
}

#pragma NSCopying
- (id)copyWithZone:(NSZone *)zone
{
    id copy = [[[self class] alloc] init];
    for (NSString *key in [self codableProperties])
    {
        [copy setValue:[self valueForKey:key] forKey:key];
    }
    return copy;
}
@end
