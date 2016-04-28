//
//  MGJConfigBaseViewModel.h
//  MGJConfigCell
//
//  Created by 鬼马 on 16/4/27.
//  Copyright © 2016年 鬼马. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "MGJConfigBaseEntity.h"

@protocol MGJConfigViewModelMoudleProtocol <NSObject>

- (CGFloat)cellForHeight;
- (void)updateForViewModel;

@end

@interface MGJConfigBaseViewModel : NSObject<MGJConfigViewModelMoudleProtocol>

@property (nonatomic , strong) MGJConfigBaseEntity *entity;
@property (nonatomic , assign) NSInteger top;
@property (nonatomic , copy  ) NSString * title;

- (instancetype)initWithEntity:(MGJConfigBaseEntity *)aEntity;

@end
