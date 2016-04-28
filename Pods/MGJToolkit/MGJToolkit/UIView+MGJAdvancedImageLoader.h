//
//  UIView+MGJAdvancedImageLoader.h
//  Example
//
//  Created by Derek Chen on 7/6/15.
//  Copyright (c) 2015 juangua. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SDWebImage/SDWebImageManager.h>

typedef void(^MGJAdvImgLoaderLoadImageCompletionBlock)(UIImage *image, NSError *error, NSString *imagePath, NSURL *imageURL, SDImageCacheType cacheType);
typedef void(^MGJAdvImgLoaderLoadImageFromCacheCompletionBlock)(UIImage *image, NSError *error, NSString *key, SDImageCacheType cacheType);
typedef NSDictionary *(^MGJAdvImgLoaderCustomizeBlock)();
typedef void(^MGJAdvImgLoaderUIRenderBlock)(UIImage *image, NSError *error, NSString *imagePath, NSURL *imageURL);
typedef void(^MGJAdvImgLoaderOperationHandlerBlock)(id<SDWebImageOperation> operation, NSString *imagePath, NSURL *imageURL);

extern NSString * const key_MGJAdvImgLoader_UIView_ImageLocationStorage;

@interface UIView (MGJAdvancedImageLoader)

#pragma mark - AdvancedImageLoader
- (NSMutableDictionary *)getImageLocationStorage;

- (CGFloat)mgj_screenScale;

- (void)mgj_loadImageFormCacheForKey:(NSString *)key fromDisk:(BOOL)fromDisk completed:(MGJAdvImgLoaderLoadImageFromCacheCompletionBlock)completion;

- (void)mgj_loadImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options customize:(MGJAdvImgLoaderCustomizeBlock)customization uiRender:(MGJAdvImgLoaderUIRenderBlock)uiRender operationHandler:(MGJAdvImgLoaderOperationHandlerBlock)operationHandler progress:(SDWebImageDownloaderProgressBlock)progress completed:(MGJAdvImgLoaderLoadImageCompletionBlock)completion;

@end
