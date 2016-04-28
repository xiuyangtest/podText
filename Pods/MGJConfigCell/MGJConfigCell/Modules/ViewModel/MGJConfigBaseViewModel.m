//
//  MGJConfigBaseViewModel.m
//  MGJConfigCell
//
//  Created by 鬼马 on 16/4/27.
//  Copyright © 2016年 鬼马. All rights reserved.
//

#import "MGJConfigBaseViewModel.h"

@implementation MGJConfigBaseViewModel

- (instancetype)initWithEntity:(MGJConfigBaseEntity *)aEntity
{
    self = [super init];
    if (self) {
        if (aEntity) {
            self.entity = aEntity;
        }
    }
    return self;
}

- (void)updateForViewModel{}

- (CGFloat)cellForHeight
{
    return 0;
}

@end
