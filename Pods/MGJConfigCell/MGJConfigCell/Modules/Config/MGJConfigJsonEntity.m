//
//  MGJConfigJsonEntity.m
//  MGJConfigCell
//
//  Created by 鬼马 on 16/4/27.
//  Copyright © 2016年 鬼马. All rights reserved.
//

#import "MGJConfigJsonEntity.h"

@implementation MGJConfigJsonEntity

- (NSDictionary *)entityMapForArray
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:[super entityMapForArray]];
    [dict setValue:@"MGJConfigJsonPageEntity" forKey:@"configs"];
    return dict;
}

@end

@implementation MGJConfigJsonPageEntity

- (NSDictionary *)entityMapForArray
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:[super entityMapForArray]];
    [dict setValue:@"MGJConfigJsonModuleEntity" forKey:@"views"];
    return dict;
}

@end

@implementation MGJConfigJsonModuleEntity


@end