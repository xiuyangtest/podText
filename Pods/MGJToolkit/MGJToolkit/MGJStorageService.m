//
//  MGJStorageService.m
//  MGJiPhoneSDK
//
//  Created by kunka on 14/6/22.
//  Copyright (c) 2014年 juangua. All rights reserved.
//

#import "MGJStorageService.h"
#import <Objective-LevelDB/LevelDB.h>
#import "MGJAnalytics.h"

#define LEVELDB_NAME @"mgj_main.ldb"

#define EVENT_ARCHIVE @"91004"
#define EVENT_UNARCHIVE @"91005"

@interface MGJStorageService ()
@property(nonatomic, strong) NSMutableDictionary *memoryStorageDict;
@property(nonatomic, strong) LevelDB *levelDB;
@end

@implementation MGJStorageService

+ (MGJStorageService *)sharedInstance
{
    static dispatch_once_t onceToken;
    static MGJStorageService *service = nil;
    dispatch_once(&onceToken, ^{
        service = [[MGJStorageService alloc] init];
    });
    return service;
    
}

- (id)init
{
    self = [super init];
    if (self) {
        self.memoryStorageDict = [NSMutableDictionary dictionary];
        self.levelDB = [LevelDB databaseInLibraryWithName:LEVELDB_NAME];
        
        self.levelDB.encoder = ^ NSData *(LevelDBKey *key, id object) {
            __block NSData *result = nil;
            
            [MGJAnalytics trackTimeExpend:^{
                result = [NSKeyedArchiver archivedDataWithRootObject:object];
            } event:EVENT_ARCHIVE timeKey:nil parameters:@{@"key": [NSString stringWithCString:key->data encoding:NSUTF8StringEncoding]}];
            
            return result;
        };
        
        self.levelDB.decoder = ^ id (LevelDBKey *key, NSData *data) {
            __block id result = nil;
            
            [MGJAnalytics trackTimeExpend:^{
                result = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            } event:EVENT_UNARCHIVE timeKey:nil parameters:@{@"key": [NSString stringWithCString:key->data encoding:NSUTF8StringEncoding], @"size":@(data.length)}];
            
            return result;
        };
    }
    return self;
}

#pragma mark - memory storage
+ (void)setObjectToMemory:(id)Object forKey:(NSString *)aKey
{
    @synchronized(self) {
        if (aKey && Object) {
            [[self sharedInstance].memoryStorageDict setObject:Object forKey:aKey];
        }
    }
}

+ (id)objectFromMemoryForKey:(NSString *)aKey
{
    @synchronized(self) {
        return [[self sharedInstance].memoryStorageDict objectForKey:aKey];
    }
}

+ (void)removeObjectFromMemoryForKey:(NSString *)aKey
{
    @synchronized(self) {
        [[self sharedInstance].memoryStorageDict removeObjectForKey:aKey];
    }
}

#pragma mark - local storage
+ (void)setObjectToLocalCache:(id)Object forKey:(NSString *)aKey
{
    [[MGJStorageService sharedInstance].levelDB setObject:Object forKey:aKey];
}

+ (id)objectFromLocalCacheForKey:(NSString *)aKey
{
    return [[MGJStorageService sharedInstance].levelDB objectForKey:aKey];
}

+ (void)removeObjectFromLocalCacheForKey:(NSString *)aKey
{
    [[self sharedInstance].levelDB removeObjectForKey:aKey];
}



@end
