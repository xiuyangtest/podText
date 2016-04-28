//
//  NSMutableDictionary+MGJKit.h
//  Example
//
//  Created by limboy on 12/19/14.
//  Copyright (c) 2014 juangua. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (MGJKit)
- (void)mgj_setObject:(id)anObject forKeyIfNotNil:(id)aKey;

- (void)mgj_setPoint:(CGPoint)value forKey:(NSString *)key;
- (void)mgj_setSize:(CGSize)value forKey:(NSString *)key;
- (void)mgj_setRect:(CGRect)value forKey:(NSString *)key;
@end
