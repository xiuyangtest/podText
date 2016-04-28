//
//  NSThread+MGJKit.m
//  Example
//
//  Created by Derek Chen on 4/4/15.
//  Copyright (c) 2015 juangua. All rights reserved.
//

#import "NSThread+MGJKit.h"

@implementation NSThread (MGJKit)

+ (void)runInMain:(void (^)(void))block {
    if (block) {
        if ([NSThread isMainThread]) {
            block();
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                block();
            });
        }
    }
}

+ (void)runInBackground:(void (^)(void))block {
    if (block) {
        if (![NSThread isMainThread]) {
            block();
        } else {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                block();
            });
        }
    }
}

@end
