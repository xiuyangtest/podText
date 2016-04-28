//
//  MGJConfigYellowViewModel.m
//  MGJConfigCell
//
//  Created by 鬼马 on 16/4/27.
//  Copyright © 2016年 鬼马. All rights reserved.
//

#import "MGJConfigYellowViewModel.h"

@implementation MGJConfigYellowViewModel

- (CGFloat)cellForHeight
{
    if (!self.entity.title.length) {
        return 0;
    }
    return 150;
}

- (void)updateForViewModel
{
    self.title = self.entity.title;
}

@end
