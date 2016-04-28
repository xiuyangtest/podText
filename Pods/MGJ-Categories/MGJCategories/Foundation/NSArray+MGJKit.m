//
//  NSArray+MGJKit.m
//  Example
//
//  Created by limboy on 12/19/14.
//  Copyright (c) 2014 juangua. All rights reserved.
//

#import "NSArray+MGJKit.h"

@implementation NSArray (MGJKit)

- (id)mgj_objectOrNilAtIndex:(NSUInteger)i {
    if(i >= [self count])
        return nil;
    return [self objectAtIndex:i];
}

@end
