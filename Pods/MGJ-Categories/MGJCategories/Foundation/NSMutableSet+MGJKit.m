//
//  NSMutableSet+MGJKit.m
//  Example
//
//  Created by limboy on 12/19/14.
//  Copyright (c) 2014 juangua. All rights reserved.
//

#import "NSMutableSet+MGJKit.h"

@implementation NSMutableSet (MGJKit)

- (void)mgj_addObjectIfNotNil:(id)anObject {
    if (anObject) {
        [self addObject:anObject];
    }
}

@end
