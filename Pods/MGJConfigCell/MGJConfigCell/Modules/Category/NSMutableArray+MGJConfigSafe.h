//
//  NSMutableArray+MGJConfigSafe.h
//  MGJConfigCell
//
//  Created by 鬼马 on 16/4/28.
//  Copyright © 2016年 鬼马. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (MGJConfigSafe)

- (void)mgj_addObjectIfNotNil:(id)anObject;

- (void)mgj_shuffle;

- (id)mgj_objectOrNilAtIndex:(NSUInteger)index;

@end
