//
//  NSThread+MGJKit.h
//  Example
//
//  Created by Derek Chen on 4/4/15.
//  Copyright (c) 2015 juangua. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSThread (MGJKit)

+ (void)runInMain:(void (^)(void))block;

+ (void)runInBackground:(void (^)(void))block;

@end
