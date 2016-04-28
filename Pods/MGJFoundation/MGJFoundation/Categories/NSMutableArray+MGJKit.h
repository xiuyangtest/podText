//
//  NSMutableArray+MGJKit.h
//  Example
//
//  Created by limboy on 12/19/14.
//  Copyright (c) 2014 juangua. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (MGJKit)

- (void)mgj_addObjectIfNotNil:(id)anObject;

- (BOOL)mgj_addObjectsFromArrayIfNotNil:(NSArray *)otherArray;

- (void)mgj_shuffle;

- (id)mgj_objectOrNilAtIndex:(NSUInteger)index;

@end
