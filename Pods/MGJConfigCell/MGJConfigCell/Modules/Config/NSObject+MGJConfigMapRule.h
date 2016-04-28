//
//  NSObject+MGJConfigMapRule.h
//  MGJConfigCell
//
//  Created by 鬼马 on 16/4/27.
//  Copyright © 2016年 鬼马. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (MGJConfigMapRule)

// cell Class
- (Class)getClassFromConfigsWithKey:(NSString *)key;
// cell Class
- (Class)getDataClassFromConfigsWithKey:(NSString *)key;
// viewmodel Class
- (Class)getViewModelClassFromConfigsWithKey:(NSString *)key;

@end
