//
//  NSObject+MGJKit.m
//  MGJFoundation
//
//  Created by limboy on 12/10/14.
//  Copyright (c) 2014 juangua. All rights reserved.
//

#import "NSObject+MGJKit.h"
#import <FXNotifications/FXNotifications.h>
#import <KVOController/FBKVOController.h>
#import <objc/runtime.h>

@implementation NSObject (MGJKit)

- (void)mgj_associateValue:(id)value withKey:(void *)key
{
    objc_setAssociatedObject(self, key, value, OBJC_ASSOCIATION_RETAIN);
}

- (void)mgj_weaklyAssociateValue:(id)value withKey:(void *)key
{
    objc_setAssociatedObject(self, key, value, OBJC_ASSOCIATION_ASSIGN);
}

- (void)mgj_copyAssociateValue:(id)value withKey:(void *)key
{
    objc_setAssociatedObject(self, key, value, OBJC_ASSOCIATION_COPY);
}

- (id)mgj_associatedValueForKey:(void *)key
{
    return objc_getAssociatedObject(self, key);
}

- (void)mgj_observeNotification:(NSString *)notificationName handler:(void (^)(NSNotification *))handler
{
    [[NSNotificationCenter defaultCenter] addObserver:self forName:notificationName object:nil queue:nil usingBlock:^(NSNotification *note, id observer) {
        handler(note);
    }];
}

- (void)mgj_observe:(id)target keyPath:(NSString *)keyPath block:(void (^)(id))block
{
    [self.KVOController observe:target keyPath:keyPath options:NSKeyValueObservingOptionNew block:^(id observer, id object, NSDictionary *change) {
        block(change[NSKeyValueChangeNewKey]);
    }];
}

- (void)mgj_unobserve:(id)target keyPath:(NSString *)keyPath
{
    keyPath.length ? [self.KVOController unobserve:target keyPath:keyPath] : [self.KVOController unobserve:target];
}

- (NSString *)mgj_description
{
    return [NSString stringWithFormat:@"[%@ {%@}]", NSStringFromClass([self class]), [self autoDescriptionForClassType:[self class]]];
}

- (NSString *)autoDescriptionForClassType:(Class)classType {
    
    NSMutableString * result = [NSMutableString string];
    
    unsigned int property_count;
    objc_property_t * property_list = class_copyPropertyList(classType, &property_count); // Must Free, later
    
    [result appendFormat:@"\n<%@>\n", classType];
    
    for (int i = property_count - 1; i >= 0; --i) {
        objc_property_t property = property_list[i];
        
        const char * property_name = property_getName(property);
        
        NSString * propertyName = [NSString stringWithCString:property_name encoding:NSASCIIStringEncoding];
        if (propertyName) {
            // 去掉私有属性，并再做一次判断，有时会出现该属性虽然存在但并不响应该属性的情况
            if (![[propertyName substringToIndex:1] isEqualToString: @"_"] && [self respondsToSelector:NSSelectorFromString(propertyName)]) {
                id<NSObject> value = [self valueForKey:propertyName];
                
                [result appendFormat:@"  [%@] = %@; \n", propertyName, value ? value.description : @"<nil>"];
            }
        }
    }
    
    [result appendFormat:@"<%@ />\n", classType];
    
    free(property_list);
    
    Class superClass  = class_getSuperclass(classType);
    if  ( superClass != nil && ![superClass isEqual:[NSObject class]])
    {
        [result appendString:[self autoDescriptionForClassType:superClass]];
    }
    
    return result;
}

@end
