//
//  MGJAPIClient.h
//  Example
//
//  Created by Blank on 15/10/22.
//  Copyright © 2015年 juangua. All rights reserved.
//

#import "MGJAPIManagerConfig.h"
#import "MGJRequestManager.h"

@interface MGJRequestManagerFactory : NSObject
/**
 *  设置用于生成默认 RequestManager 的 Configuration
 *
 *  @param config config
 *
 *  @return 只能配置一次，如果多次配置，返回 NO
 */
+ (BOOL)configRequestManager:(MGJAPIManagerConfig *)config;

/**
 *  当前已配置的默认 Configuration
 *
 *  @return
 */
+ (MGJAPIManagerConfig *)configuration;

/**
 *  使用默认配置生成的 RequestManager 单例
 *
 *  @return
 */
+ (MGJRequestManager *)requestManager;

/**
 *  使用指定的 Config 生成 RequestManager
 *
 *  @param config config
 *
 *  @return 
 */
+ (MGJRequestManager *)requestManagerWithConfig:(MGJAPIManagerConfig *)config;
@end

@interface MGJRequestManager (MGJRequestManagerFactory)
- (instancetype)initWithAPIManagerConfig:(MGJAPIManagerConfig *)config;
@property (nonatomic, strong, readonly) MGJAPIManagerConfig *apiManagerConfig;
@end
