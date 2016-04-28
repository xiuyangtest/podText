//
//  MGJWebBundleSignValidator.m
//  MGJH5ContainerDemo
//
//  Created by xinba on 4/24/14.
//  Copyright (c) 2014年 juangua. All rights reserved.
//

#import "MGJZipArchive.h"
#import "MGJComponentValidator.h"
#import "MGJComponentRSAUtil.h"
#import <FileMD5Hash/FileHash.h>
#import "MGJLog.h"
#import "NSMutableDictionary+MGJKit.h"

NSString *const MGJComponentTempUnzipFolderName = @"MGJ_BUNDLE_UNZIP";
NSString *const MGJComponentCertFileName = @"cert.json";


@implementation MGJComponentValidator {

}

- (id)init {
    self = [super init];
    if (self) {
        // 设置验证文件名称
        self.certFileName = MGJComponentCertFileName;
    }

    return self;
}

/**
 * 根据包路径验证包
 * @param NSString bundleAmrPath
 */
- (BOOL)validateBundle:(NSString *)bundleAmrPath {
    // 路径不存在的话直接返回
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (!bundleAmrPath || ![fileManager fileExistsAtPath:bundleAmrPath]) {
        return NO;
    }

    MGJLogDebug(@"路径 为 %@的H5安装包开始校验签名", bundleAmrPath);
    return [self validateBundleSign:bundleAmrPath];
}

- (BOOL)validateBundleSign:(NSString *)bundleAmrPath {

    // 先解压到临时目录
    [self unZipBundleToTmp:bundleAmrPath];
    BOOL validateSuccess = [self validateBundleFileSigns:[self getTmpBundleFolderUnzipPath:bundleAmrPath]];
    if (!validateSuccess) {
        [self cleanTmpBundle:bundleAmrPath];
    }
    return validateSuccess;
}


- (void)cleanTmpBundle:(NSString *)bundlePath {
    NSString *tmpBundlePath = [self getTmpBundleFolderUnzipPath:bundlePath];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:bundlePath]) {
        return;
    }

    [fileManager removeItemAtPath:tmpBundlePath error:nil];
}

/**
 * 解压到临时目录
 */
- (void)unZipBundleToTmp:(NSString *)bundlePath {
    // 获得临时目录
    NSString *tmpBundlePath = [self getTmpBundleFolderUnzipPath:bundlePath];

    // 如果解压文件不存在直接烦返回
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:bundlePath]) {
        return;
    }
    // 如果临时目录已经存在文件，则先删除
    if ([fileManager fileExistsAtPath:tmpBundlePath]) {
        //remove tmp bundle folder if it exist before(there exist old version)
        [fileManager removeItemAtPath:tmpBundlePath error:nil];
    }
    // 真正的解压操作
    [MGJZipArchive unzipFileAtPath:bundlePath toDestination:tmpBundlePath];
}


#pragma mark Verify

- (BOOL)validateBundleFileSigns:(NSString *)bundlePath {

    // 这么多的临时字段干嘛不放到实例变量里，到处取有没有节操！！
    NSString *bundleTmpPath = [self getTmpBundleFolderUnzipPath:bundlePath];

    // bundle目录中文件的实际签名
    NSDictionary *realFilesMD5 = [self fetchBundleFilesMD5:bundleTmpPath];

    // bundle期望的文件签名
    NSDictionary *exceptedFilesSign = [self parseBundleFileSigns:bundleTmpPath];

    if (!realFilesMD5.count || !exceptedFilesSign.count || realFilesMD5.count != exceptedFilesSign.count) {
        MGJLogDebug(@"路径 为 %@的H5安装包签名中文件数量与实际文件数量不服，校验失败", bundlePath);
        return NO;
    }

    __block BOOL isValidated = YES;
    [exceptedFilesSign enumerateKeysAndObjectsUsingBlock:^(id key, NSString *value, BOOL *stop) {
        NSString *realFileMD5 = [realFilesMD5 valueForKey:key];
        // 比对加密字符串和期望值，如果不相同，设置验证失败 isValidated = NO;
        if (![self verifyEncryptedContent:value exceptedValue:realFileMD5]) {
            MGJLogDebug(@"路径 为 %@的H5安装包签名中文件签名错误，校验失败", bundlePath);
            isValidated = NO;
            *stop = YES;
        }
    }];
    return isValidated;
}


/**
 * 比对加密字符串和期望值，如果相同返回YES，否则返回NO
 */
- (BOOL)verifyEncryptedContent:(NSString *)encryptedContent exceptedValue:(NSString *)exceptedValue {
    if (!encryptedContent || !exceptedValue) {
        return NO;
    }

    NSString *decryptedContent = [[MGJComponentRSAUtil shareInstance] decryptByRsa:encryptedContent withKeyType:KeyTypePublic];
    if (!decryptedContent) {
        return NO;
    }

    return [decryptedContent isEqualToString:exceptedValue];
}


#pragma mark Folders

- (NSDictionary *)fetchBundleFilesMD5:(NSString *)bundleTmpPath {
    NSFileManager *fileManager = [NSFileManager defaultManager];

    NSMutableDictionary *hashDictionary = [NSMutableDictionary dictionary];
    NSDirectoryEnumerator *dicEnum = [fileManager enumeratorAtPath:bundleTmpPath];
    NSString *file = nil;

    while ((file = [dicEnum nextObject])) {
        if ([[file lastPathComponent] isEqualToString:self.certFileName]) {
            //cert.json needn't calculate md5
            continue;
        }
        BOOL isDirectory = NO;
        NSString *absoluteFilePath = [bundleTmpPath stringByAppendingPathComponent:file];
        //directory needn't calculate md5
        if (![fileManager fileExistsAtPath:absoluteFilePath isDirectory:&isDirectory] || isDirectory) {
            continue;
        }
        hashDictionary[file] = [FileHash md5HashOfFileAtPath:absoluteFilePath];
    }

    return hashDictionary;
}

- (NSDictionary *)parseBundleFileSigns:(NSString *)bundleTmpPath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *certFilePath = [bundleTmpPath stringByAppendingPathComponent:self.certFileName];
    if (![fileManager fileExistsAtPath:certFilePath]) {
        return nil;
    }

    NSString *certJsonString = [NSString stringWithContentsOfFile:certFilePath
                                                         encoding:NSUTF8StringEncoding
                                                            error:nil];
    if (!certJsonString) {
        return nil;
    }

    NSError *error = nil;
    NSArray *certSignsArray = [NSJSONSerialization JSONObjectWithData:[certJsonString dataUsingEncoding:NSUTF8StringEncoding]
                                                              options:NSJSONReadingAllowFragments error:&error];
    if (![certSignsArray isKindOfClass:[NSArray class]] || error) {//parse failed
        return nil;
    }

    NSMutableDictionary *certSignsDic = [NSMutableDictionary dictionaryWithCapacity:certSignsArray.count];
    [certSignsArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *fileSign = [obj valueForKey:@"md5"];
        if (!fileSign) {
            //something wrong happened,let it go
            *stop = YES;
        }
        [certSignsDic mgj_setObject:fileSign forKeyIfNotNil:[obj valueForKey:@"file"]];
    }];

    return certSignsDic;

}


- (NSString *)getTmpBundleFolderUnzipPath:bundlePath {
    // 路径为空时直接返回
    if (!bundlePath) {
        return nil;
    }
    NSString *amrName = [bundlePath lastPathComponent];
    return [[NSTemporaryDirectory() stringByAppendingPathComponent:MGJComponentTempUnzipFolderName]
            stringByAppendingPathComponent:amrName];
}

@end
