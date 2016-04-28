//
//  MGJWebBundleSignValidator.h
//  MGJH5ContainerDemo
//
//  Created by xinba on 4/24/14.
//  Copyright (c) 2014年 juangua. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+MGJSingleton.h"


@interface MGJComponentValidator : NSObject<Singleton>

@property(nonatomic, strong) NSString *certFileName;


/**
 * 根据包路径验证包
 * @param NSString bundleAmrPath
 */
- (BOOL)validateBundle:(NSString *)bundleAmrPath;


@end
