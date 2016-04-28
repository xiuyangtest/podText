//
//  NSObject+MGJSingleton.h
//  Example
//
//  Created by limboy on 2/28/15.
//  Copyright (c) 2015 juangua. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol Singleton
@optional

+ (instancetype)mgj_sharedInstance;

@end

@interface NSObject (MGJSingleton)

@end
