//
//  NSMutableDictionary+MGJKit.m
//  Example
//
//  Created by limboy on 12/19/14.
//  Copyright (c) 2014 juangua. All rights reserved.
//

#import "NSMutableDictionary+MGJKit.h"

@implementation NSMutableDictionary (MGJKit)

- (void)mgj_setObject:(id)anObject forKeyIfNotNil:(id)aKey {
    if (aKey && anObject) {
        [self setObject:anObject forKey:aKey];
    }
}

- (void)mgj_setPoint:(CGPoint)value forKey:(NSString *)key
{
    NSDictionary *dictionary = (NSDictionary *)CFBridgingRelease(CGPointCreateDictionaryRepresentation(value));
    [self setValue:dictionary forKey:key];
    dictionary = nil;
}

- (void)mgj_setSize:(CGSize)value forKey:(NSString *)key
{
    NSDictionary *dictionary = (NSDictionary *)CFBridgingRelease(CGSizeCreateDictionaryRepresentation(value));
    [self setValue:dictionary forKey:key];
    dictionary = nil;
}

- (void)mgj_setRect:(CGRect)value forKey:(NSString *)key
{
    NSDictionary *dictionary = (NSDictionary *)CFBridgingRelease(CGRectCreateDictionaryRepresentation(value));
    [self setValue:dictionary forKey:key];
    dictionary = nil;
}

@end
