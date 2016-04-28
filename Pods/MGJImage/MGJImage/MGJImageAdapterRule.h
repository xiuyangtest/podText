//
//  MGJImageAdapterRule.h
//  Example
//
//  Created by Blank on 15/12/9.
//  Copyright © 2015年 Juangua. All rights reserved.
//

#import <MGJFoundation/MGJFoundation.h>
#import "MGJImageAdapterRuleItem.h"

@interface MGJImageAdapterRule : MGJEntity
@property (nonatomic, assign) NSInteger size;

@property (nonatomic, strong) MGJImageAdapterRuleItem *wwan;

@property (nonatomic, strong) MGJImageAdapterRuleItem *wifi;

@end
