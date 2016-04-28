//
//  UIView+MGJAdvancedImageLoader.m
//  Example
//
//  Created by Derek Chen on 7/6/15.
//  Copyright (c) 2015 juangua. All rights reserved.
//

#import "UIView+MGJAdvancedImageLoader.h"
#import "UIImage+MGJAdvancedImageLoader.h"
#import <MGJFoundation/MGJFoundation.h>
#import <MGJUIKit/MGJUIKit.h>
#import <objc/runtime.h>

NSString * const key_MGJAdvImgLoader_UIView_ImageLocationStorage = @"key_MGJAdvImgLoader_UIView_ImageLocationStorage";

@implementation UIView (MGJAdvancedImageLoader)

#pragma mark - AdvancedImageLoader

- (NSMutableDictionary *)getImageLocationStorage {
    NSMutableDictionary *result = objc_getAssociatedObject(self, (__bridge const void *)(key_MGJAdvImgLoader_UIView_ImageLocationStorage));
    if (!result) {
        result = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, (__bridge const void *)(key_MGJAdvImgLoader_UIView_ImageLocationStorage), result, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return result;
}

- (CGFloat)mgj_screenScale {
    return [UIScreen mainScreen].scale;
}

- (void)mgj_loadImageFormCacheForKey:(NSString *)key fromDisk:(BOOL)fromDisk completed:(MGJAdvImgLoaderLoadImageFromCacheCompletionBlock)completion {
    __block UIImage *loadedImage = nil;
    NSError *error = nil;
    __block SDImageCacheType cacheType = SDImageCacheTypeNone;
    
    if (MGJ_IS_EMPTY(key)) {
        error = [NSError errorWithDomain:MGJAdvImgLoaderErrorDomain code:(-1002) userInfo:@{NSLocalizedDescriptionKey : @"MGJ_IS_EMPTY(key)"}];
        if (completion) {
            completion(loadedImage, error, key, cacheType);
        }
    } else {
        loadedImage = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:key];
        if (loadedImage) {
            cacheType = SDImageCacheTypeMemory;
            if (completion) {
                completion(loadedImage, error, key, cacheType);
            }
        } else {
            if (fromDisk) {
                [NSThread runInBackground:^{
                    loadedImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:key];
                    if (loadedImage) {
                        cacheType = SDImageCacheTypeDisk;
                    }
                    if (completion) {
                        completion(loadedImage, error, key, cacheType);
                    }
                }];
            } else {
                if (completion) {
                    completion(loadedImage, error, key, cacheType);
                }
            }
        }
    }
}

- (void)mgj_loadImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options customize:(MGJAdvImgLoaderCustomizeBlock)customization uiRender:(MGJAdvImgLoaderUIRenderBlock)uiRender operationHandler:(MGJAdvImgLoaderOperationHandlerBlock)operationHandler progress:(SDWebImageDownloaderProgressBlock)progress completed:(MGJAdvImgLoaderLoadImageCompletionBlock)completion {
    if (!MGJ_IS_EMPTY(url)) {
        NSString *customizedImageKey = nil;
        NSDictionary *customizeParamsDic = nil;
        if (customization) {
            customizeParamsDic = customization();
        }
        customizedImageKey = [NSString stringWithFormat:@"%@_%@", url, [UIImage mgj_imageSignature:customizeParamsDic]];
        @weakify(self);
        [self mgj_loadImageFormCacheForKey:customizedImageKey fromDisk:YES completed:^(UIImage *image, NSError *error, NSString *key, SDImageCacheType cacheType) {
            if (error && !MGJ_IS_EMPTY(key)) {
                [NSThread runInMain:^{
                    if (completion) {
                        completion(nil, error, nil, url, SDImageCacheTypeNone);
                    }
                }];
                return;
            }
            
            if (!MGJ_IS_EMPTY(image)) {  // use cached image
                [NSThread runInMain:^{
                    if (uiRender) {
                        uiRender(image, error, nil, url);
                    }
                    if (completion) {
                        completion(image, error, nil, url, cacheType);
                    }
                }];
                return;
            }
            
            id <SDWebImageOperation> operation = [SDWebImageManager.sharedManager downloadImageWithURL:url options:options progress:progress completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                @strongify(self);
                if (MGJ_IS_EMPTY(image)) {
                    if ((options & SDWebImageDelayPlaceholder) && placeholder) {
                        if (uiRender) {
                            uiRender(placeholder, error, nil, url);
                        }
                        if (completion && finished) {
                            completion(image, error, nil, url, cacheType);
                        }
                    }
                } else {
                    if (MGJ_IS_EMPTY(customizeParamsDic)) {  // use origin image
                        if (uiRender) {
                            uiRender(image, error, nil, url);
                        }
                        if (completion && finished) {
                            completion(image, error, nil, url, cacheType);
                        }
                    } else {  // use customized image
                        [NSThread runInBackground:^{
                            UIImage *customizedImage = [UIImage mgj_customizeImage:image withParams:customizeParamsDic contentMode:self.contentMode];
                            if (customizedImage) {
                                BOOL cacheOnDisk = !(options & SDWebImageCacheMemoryOnly);
                                
                                if (customizedImage && finished) {
                                    [[SDImageCache sharedImageCache] storeImage:customizedImage recalculateFromImage:NO imageData:nil forKey:customizedImageKey toDisk:cacheOnDisk];
                                }
                                
                                [NSThread runInMain:^{
                                    if (uiRender) {
                                        uiRender(customizedImage, error, nil, url);
                                    }
                                    if (completion && finished) {
                                        completion(customizedImage, error, nil, url, cacheType);
                                    }
                                }];
                            }
                        }];
                    }
                }
            }];
            if (operationHandler) {
                operationHandler(operation, nil, url);
            }
        }];
    } else {
        [NSThread runInMain:^{
            NSError *error = [NSError errorWithDomain:@"SDWebImageErrorDomain" code:(-1) userInfo:@{NSLocalizedDescriptionKey : @"Trying to load a nil url"}];
            if (completion) {
                completion(nil, error, nil, url, SDImageCacheTypeNone);
            }
        }];
    }
}

@end
