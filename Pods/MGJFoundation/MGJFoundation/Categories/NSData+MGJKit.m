//
//  NSData+MGJBundleSupport.m
//  Example
//
//  Created by Derek Chen on 3/3/15.
//  Copyright (c) 2015 juangua. All rights reserved.
//

#import "NSData+MGJKit.h"
#import "NSBundle+MGJKit.h"
#import "MGJMacros.h"

@implementation NSData (MGJKit)

+ (instancetype)mgj_dataInLibrary:(NSString *)libraryName withBundleResource:(NSString *)resourceName ofType:(NSString *)type {
    id result = nil;
    do {
        if (MGJ_IS_EMPTY(libraryName) || MGJ_IS_EMPTY(resourceName) || MGJ_IS_EMPTY(type)) {
            break;
        }
#ifdef MGJBOUNDLESUPPORT_DISABLE
        NSString *filePathInMainBundle = [[NSBundle mainBundle] pathForResource:resourceName ofType:type];
        result = [self dataWithContentsOfFile:filePathInMainBundle];
#else
        NSString *filePathInLibraryBundle = [[NSBundle mgj_libraryResourcesBundle:libraryName] pathForResource:resourceName ofType:type];
        result = [self dataWithContentsOfFile:filePathInLibraryBundle];
#endif
    } while (NO);
    return result;
}

+ (instancetype)mgj_dataInLibrary:(NSString *)libraryName withBundleResource:(NSString *)resourceName ofType:(NSString *)type options:(NSDataReadingOptions)readOptionsMask error:(NSError *__autoreleasing *)errorPtr {
    id result = nil;
    do {
        if (MGJ_IS_EMPTY(libraryName) || MGJ_IS_EMPTY(resourceName) || MGJ_IS_EMPTY(type)) {
            break;
        }
#ifdef MGJBOUNDLESUPPORT_DISABLE
        NSString *filePathInMainBundle = [[NSBundle mainBundle] pathForResource:resourceName ofType:type];
        result = [self dataWithContentsOfFile:filePathInMainBundle options:readOptionsMask error:errorPtr];
#else
        NSString *filePathInLibraryBundle = [[NSBundle mgj_libraryResourcesBundle:libraryName] pathForResource:resourceName ofType:type];
        result = [self dataWithContentsOfFile:filePathInLibraryBundle options:readOptionsMask error:errorPtr];
#endif
    } while (NO);
    return result;
}

@end
