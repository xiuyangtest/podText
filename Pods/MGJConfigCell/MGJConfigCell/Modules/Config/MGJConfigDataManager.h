//
//  MGJConfigDataManager.h
//  MGJConfigCell
//
//  Created by 鬼马 on 16/4/27.
//  Copyright © 2016年 鬼马. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MGJConfigJsonEntity.h"

@interface MGJConfigDataManager : NSObject

/**
 *  更新配置文件
 *
 *  @param dict 服务器请求的新数据
 */
- (MGJConfigJsonEntity *)updateConfigFileWithJson:(NSDictionary *)dict;
@end
