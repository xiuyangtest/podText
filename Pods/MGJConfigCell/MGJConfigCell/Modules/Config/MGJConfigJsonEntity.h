//
//  MGJConfigJsonEntity.h
//  MGJConfigCell
//
//  Created by 鬼马 on 16/4/27.
//  Copyright © 2016年 鬼马. All rights reserved.
//

#import "MGJEntity.h"

@interface MGJConfigJsonModuleEntity : MGJEntity

@property (nonatomic) NSString *serverName;
@property (nonatomic) NSString *marginTop;

@end

@interface MGJConfigJsonPageEntity : MGJEntity

@property (nonatomic) NSString *page;
@property (nonatomic) NSArray  *views;    // <MGJConfigJsonModuleEntity *>
@property (nonatomic) NSString *reqUrl;
@property (nonatomic) NSString *cKey;     // 新增配置字段
@property (nonatomic) NSString *mwpapi;
@property (nonatomic) NSString *apiversion;

@end

@interface MGJConfigJsonEntity : MGJEntity

@property (nonatomic) NSArray *configs;   // <MGJConfigJsonPageEntity *>
@end
