//
//  NSBundle+MGJBundleSupport.m
//  Example
//
//  Created by Derek Chen on 3/3/15.
//  Copyright (c) 2015 juangua. All rights reserved.
//

#import "NSBundle+MGJKit.h"
#import "MGJMacros.h"

@implementation NSBundle (MGJKit)

+ (NSBundle *)mgj_libraryResourcesBundle:(NSString *)libraryName {
    NSBundle *libraryResourcesBundle = nil;
    do {
        if (MGJ_IS_EMPTY(libraryName)) {
            libraryResourcesBundle = [NSBundle mainBundle];
        }
        else{
            NSURL* pathUrl = [[NSBundle mainBundle] URLForResource:libraryName withExtension:@"bundle"];
            
            //pathUrl 不能为空
            if (pathUrl) {
                libraryResourcesBundle = [NSBundle bundleWithURL:pathUrl];
            }
        }
        
#ifdef MGJBOUNDLESUPPORT_DISABLE
        libraryResourcesBundle = [NSBundle mainBundle];
#endif
        
    } while (NO);
    return libraryResourcesBundle;
}

@end
