//
//  NSObject+MGJConfigMapRule.m
//  MGJConfigCell
//
//  Created by 鬼马 on 16/4/27.
//  Copyright © 2016年 鬼马. All rights reserved.
//

#import "NSObject+MGJConfigMapRule.h"

@implementation NSObject (MGJConfigMapRule)

// cell Class
- (Class)getClassFromConfigsWithKey:(NSString *)key
{
    if (!key) {
        return nil;
    }
    
    return [self getClassForKey:key prefix:@"MGJConfig" suffix:@"Cell"];
}

// data Class
- (Class)getDataClassFromConfigsWithKey:(NSString *)key
{
    if (!key) {
        return nil;
    }
    
    return [self getClassForKey:key prefix:@"MGJConfig" suffix:@"Entity"];
}

// viewModel Class
- (Class)getViewModelClassFromConfigsWithKey:(NSString *)key
{
    if (!key) {
        return nil;
    }
    
    return [self getClassForKey:key prefix:@"MGJConfig" suffix:@"ViewModel"];
}

- (Class)getClassForKey:(NSString *)key prefix:(NSString *)prefix suffix:(NSString *)suffix
{
    NSString *firstName = [key substringToIndex:1];
    NSString *dataName = [NSString stringWithFormat:@"%@%@",[firstName uppercaseString], [key substringFromIndex:1]];
    NSString *className = [NSString stringWithFormat:@"%@%@%@",prefix,dataName,suffix];
    Class cls = NSClassFromString(className);
    return cls;
}

@end
