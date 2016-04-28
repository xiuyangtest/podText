//
//  NSMutableArray+MGJConfigSafe.m
//  MGJConfigCell
//
//  Created by 鬼马 on 16/4/28.
//  Copyright © 2016年 鬼马. All rights reserved.
//

#import "NSMutableArray+MGJConfigSafe.h"

static NSUInteger random_below(NSUInteger n) {
    NSUInteger m = 1;
    
    do {
        m <<= 1;
    } while(m < n);
    
    NSUInteger ret;
    
    do {
        ret = arc4random() % m;
    } while(ret >= n);
    
    return ret;
}

@implementation NSMutableArray (MGJConfigSafe)

- (void)mgj_addObjectIfNotNil:(id)anObject {
    if (anObject) {
        [self addObject:anObject];
    }
}

//- (BOOL)mgj_addObjectsFromArrayIfNotNil:(NSArray *)otherArray {
//    if (!MGJ_IS_EMPTY(otherArray) && [otherArray isKindOfClass:[NSArray class]]) {
//        [self addObjectsFromArray:otherArray];
//        return YES;
//    }
//    return NO;
//}

//  Created by Matthias Tretter on 31.10.10.
//  Copyright 2010 YellowSoft. All rights reserved.
- (void)mgj_shuffle {
    // http://en.wikipedia.org/wiki/Knuth_shuffle
    
    for(NSUInteger i = [self count]; i > 1; i--) {
        NSUInteger j = random_below(i);
        [self exchangeObjectAtIndex:i-1 withObjectAtIndex:j];
    }
}

- (id)mgj_objectOrNilAtIndex:(NSUInteger)i {
    if(i >= [self count])
        return nil;
    return [self objectAtIndex:i];
}

@end
