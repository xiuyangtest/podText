//
//  NSMutableArray+MGJKit.m
//  Example
//
//  Created by limboy on 12/19/14.
//  Copyright (c) 2014 juangua. All rights reserved.
//

#import "NSMutableArray+MGJKit.h"
#import "MGJMacros.h"

//  Created by Matthias Tretter on 31.10.10.
//  Copyright 2010 YellowSoft. All rights reserved.
// Unbiased random rounding thingy.
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


@implementation NSMutableArray (MGJKit)

- (void)mgj_addObjectIfNotNil:(id)anObject {
    if (anObject) {
        [self addObject:anObject];
    }
}

- (BOOL)mgj_addObjectsFromArrayIfNotNil:(NSArray *)otherArray {
    if (!MGJ_IS_EMPTY(otherArray) && [otherArray isKindOfClass:[NSArray class]]) {
        [self addObjectsFromArray:otherArray];
        return YES;
    }
    return NO;
}

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
