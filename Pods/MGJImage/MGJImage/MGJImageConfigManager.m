//
//  MGJImageConfigManager.m
//  Example
//
//  Created by 昆卡 on 16/1/4.
//  Copyright © 2016年 Juangua. All rights reserved.
//

#import "MGJImageConfigManager.h"

static mgj_sd_downloadImageSuccessBlock successBlock;
static mgj_sd_downloadImageFailureBlock failureBlock;

static BOOL imageAdapterEnabled;
static BOOL debugModeForImageAdapterEnabled;

@implementation MGJImageConfigManager

+ (void)enableDebugModeForImageAdapter:(BOOL)enabled
{
    debugModeForImageAdapterEnabled = enabled;
}

+ (BOOL)debugModeForImageAdapterEnabled
{
    return debugModeForImageAdapterEnabled;
}

+ (void)setDownloadImageSuccessBlock:(mgj_sd_downloadImageSuccessBlock)success FailureBlock:(mgj_sd_downloadImageFailureBlock)failure
{
    successBlock = success;
    failureBlock = failure;
}

+ (mgj_sd_downloadImageSuccessBlock)downloadImageSuccessBlock
{
    return successBlock;
}


+ (mgj_sd_downloadImageFailureBlock)downloadImageFailureBlock
{
    return failureBlock;
}

@end
