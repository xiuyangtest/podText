//
//  NSObject+MGJKit.h
//  MGJFoundation
//
//  Created by limboy on 12/10/14.
//  Copyright (c) 2014 juangua. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (MGJKit)

/**
 * 使用这个属性，可以更清晰、全面地看到一个 object 包含了那些属性
 */
@property (nonatomic, readonly) NSString *mgj_description;

- (void)mgj_associateValue:(id)value withKey:(void *)key;

- (void)mgj_weaklyAssociateValue:(id)value withKey:(void *)key;

- (void)mgj_copyAssociateValue:(id)value withKey:(void *)key;

- (id)mgj_associatedValueForKey:(void *)key;

- (void)mgj_observeNotification:(NSString *)notificationName handler:(void(^)(NSNotification *notification))handler;

- (void)mgj_observe:(id)target keyPath:(NSString *)keyPath block:(void (^)(id obj))block;

- (void)mgj_unobserve:(id)target keyPath:(NSString *)keyPath;

@end

