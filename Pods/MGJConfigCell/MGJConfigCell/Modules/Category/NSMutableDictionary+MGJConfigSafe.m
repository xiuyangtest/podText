//
//  NSMutableDictionary+MGJConfigSafe.m
//  MGJConfigCell
//
//  Created by 鬼马 on 16/4/27.
//  Copyright © 2016年 鬼马. All rights reserved.
//

#import "NSMutableDictionary+MGJConfigSafe.h"

@implementation NSMutableDictionary (MGJConfigSafe)

- (void)mgj_setObject:(id)anObject forKeyIfNotNil:(id)aKey {
    if (aKey && anObject) {
        [self setObject:anObject forKey:aKey];
    }
}

- (BOOL)mgj_containKey:(NSString *)key
{
    return [[self allKeys]containsObject:key];
}

- (id)mgj_safeDataForKey:(NSString *)key
{
    if ([self mgj_containKey:key]) {
        id value = [self objectForKey:key];
        return value;
    }
    
    return nil;
}

@end
