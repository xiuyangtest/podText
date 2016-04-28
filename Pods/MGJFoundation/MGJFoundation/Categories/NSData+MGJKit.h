//
//  NSData+MGJBundleSupport.h
//  Example
//
//  Created by Derek Chen on 3/3/15.
//  Copyright (c) 2015 juangua. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (MGJKit)

+ (instancetype)mgj_dataInLibrary:(NSString *)libraryName withBundleResource:(NSString *)resourceName ofType:(NSString *)type options:(NSDataReadingOptions)readOptionsMask error:(NSError **)errorPtr;
+ (instancetype)mgj_dataInLibrary:(NSString *)libraryName withBundleResource:(NSString *)resourceName ofType:(NSString *)type;

@end
