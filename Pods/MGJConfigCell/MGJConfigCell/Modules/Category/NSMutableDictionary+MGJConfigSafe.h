//
//  NSMutableDictionary+MGJConfigSafe.h
//  MGJConfigCell
//
//  Created by 鬼马 on 16/4/27.
//  Copyright © 2016年 鬼马. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (MGJConfigSafe)

- (void)mgj_setObject:(id)anObject forKeyIfNotNil:(id)aKey;
- (id)mgj_safeDataForKey:(NSString*)key;
-(BOOL)mgj_containKey:(NSString*)key;

@end
