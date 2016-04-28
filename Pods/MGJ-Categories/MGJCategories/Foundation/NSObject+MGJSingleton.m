//
//  NSObject+MGJSingleton.m
//  Example
//
//  Created by limboy on 2/28/15.
//  Copyright (c) 2015 juangua. All rights reserved.
//

#import "NSObject+MGJSingleton.h"
#import <objc/runtime.h>

@implementation NSObject (MGJSingleton)

+ (instancetype)mgj_sharedInstance
{
    if (![self conformsToProtocol:@protocol(Singleton)])
    {
        [self doesNotRecognizeSelector:_cmd];
    }
    
    @synchronized (self)
    {
        id instance = objc_getAssociatedObject(self, _cmd);
        if (!instance)
        {
            instance = [[self alloc] init];
            objc_setAssociatedObject(self, _cmd, instance, OBJC_ASSOCIATION_RETAIN);
        }
        return instance;
    }
}

@end