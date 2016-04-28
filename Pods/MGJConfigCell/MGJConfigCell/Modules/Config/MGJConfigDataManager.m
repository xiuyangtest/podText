//
//  MGJConfigDataManager.m
//  MGJConfigCell
//
//  Created by 鬼马 on 16/4/27.
//  Copyright © 2016年 鬼马. All rights reserved.
//

#import "MGJConfigDataManager.h"

@interface MGJConfigDataManager ()

@property (nonatomic, copy) NSString *configPath;
@property (nonatomic, copy) NSString *requestConfigPath; //存放服务器请求的json数据

@end

static inline BOOL MGJ_IS_EMPTY(id thing) {
    return thing == nil ||
    ([thing isEqual:[NSNull null]]) ||
    ([thing respondsToSelector:@selector(length)] && [(NSData *)thing length] == 0) ||
    ([thing respondsToSelector:@selector(count)]  && [(NSArray *)thing count] == 0);
}

@implementation MGJConfigDataManager

- (NSDictionary *)getConfigDic
{
    NSData *jsonData = [NSData dataWithContentsOfFile:self.requestConfigPath];
    if(MGJ_IS_EMPTY(jsonData)){
        jsonData = [NSData dataWithContentsOfFile:self.configPath];
    }
    NSDictionary *configDic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil];
    return configDic;
}

- (MGJConfigJsonEntity *)updateConfigFileWithJson:(NSDictionary *)dict
{
    [self writeToFile:dict];
    
    NSDictionary *configDic = [self getConfigDic];
    if (MGJ_IS_EMPTY(configDic)) {
        return nil;
    }
    MGJConfigJsonEntity *configEntity = [[MGJConfigJsonEntity alloc]initWithDictionary:configDic];
    return configEntity;
}

- (void)writeToFile:(NSDictionary *)dict
{
    if (!MGJ_IS_EMPTY(dict)) {
        NSError *jsonError;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&jsonError];
        if (jsonData) {
            NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            NSError *writeToFileError;
            [jsonString writeToFile:self.requestConfigPath atomically:YES encoding:NSUTF8StringEncoding error:&writeToFileError];
            if (writeToFileError) {
                NSLog(@"write config to disk error: %@", writeToFileError);
            }
        } else {
            NSLog(@"write config to dict error: %@", jsonError);
        }
    }
}

- (NSString *)configPath
{
    if (!_configPath) {
        _configPath = [[NSBundle mainBundle]pathForResource:@"config" ofType:@"json"];
    }
    return _configPath;
}

- (NSString *)requestConfigPath
{
    if (!_requestConfigPath) {
        _requestConfigPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]  stringByAppendingPathComponent:@"freemarket"];
        
        NSFileManager *fileManager= [NSFileManager defaultManager];
        BOOL isDirectory = NO;
        if (![fileManager fileExistsAtPath:_requestConfigPath isDirectory:&isDirectory]) {
            [fileManager createDirectoryAtPath:_requestConfigPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        _requestConfigPath = [_requestConfigPath stringByAppendingPathComponent:@"config.json"];
        if(![fileManager fileExistsAtPath:_requestConfigPath]){
            [fileManager createFileAtPath:_requestConfigPath contents:nil attributes:nil];
        }
    }
    return _requestConfigPath;
}

@end
