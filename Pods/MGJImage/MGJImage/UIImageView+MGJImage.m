//
//  UIImageView+MGJImage.m
//  Example
//
//  Created by 昆卡 on 16/1/4.
//  Copyright © 2016年 Juangua. All rights reserved.
//

#import "UIImageView+MGJImage.h"
#import "MGJImageAdapter.h"
#import "MGJImageConfigManager.h"


@implementation UIImageView (MGJImage)
- (void)mgj_setImageWithURL:(NSString *)url
{
    [self mgj_setImageWithURL:url placeholderImage:nil];
}

- (void)mgj_setImageWithURL:(NSString *)url placeholderImage:(UIImage *)placeholder
{
    [self mgj_setImageWithURL:url expectSize:0 placeholderImage:placeholder];
}

- (void)mgj_setImageWithURL:(NSString *)url expectSize:(NSInteger)expectSize placeholderImage:(UIImage *)placeholder
{
    [self mgj_setImageWithURL:url expectSize:expectSize needCrop:NO placeholderImage:placeholder];
}

- (void)mgj_setImageWithURL:(NSString *)url expectSize:(NSInteger)expectSize needCrop:(BOOL)needCrop placeholderImage:(UIImage *)placeholder
{
    [self mgj_setImageWithURL:url expectSize:expectSize needCrop:needCrop placeholderImage:placeholder options:SDWebImageRetryFailed progress:nil completed:nil];
}

- (void)mgj_setImageWithURL:(NSString *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options progress:(SDWebImageDownloaderProgressBlock)progressBlock completed:(SDWebImageCompletionBlock)completedBlock {
    [self mgj_setImageWithURL:url expectSize:0 needCrop:NO placeholderImage:placeholder options:options progress:progressBlock completed:completedBlock];
}

- (void)mgj_setImageWithURL:(NSString *)url placeholderImage:(UIImage *)placeholder animated:(BOOL)animated
{
    self.clipsToBounds = YES;
    self.contentMode = UIViewContentModeScaleAspectFill;
    __weak typeof(self) wself = self;
    
    [self mgj_setImageWithURL:url placeholderImage:placeholder options:SDWebImageRetryFailed progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (image && !error) {
            if (animated && !placeholder) {
                wself.alpha = 0;
                [UIView animateWithDuration:0.7f animations:^{
                    wself.alpha = 1.f;
                }];
            }
        }
    }];
}

- (void)mgj_setImageWithURL:(NSString *)url complete:(void (^)(UIImage *image))completedBlock {
    self.clipsToBounds = YES;
    self.contentMode = UIViewContentModeScaleAspectFill;
    [self mgj_setImageWithURL:url expectSize:0 needCrop:NO placeholderImage:nil options:SDWebImageRetryFailed progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (image && !error) {
            if (completedBlock) {
                completedBlock(image);
            }
        }
    }];
}


- (void)mgj_setImageWithURL:(NSString *)url expectSize:(NSInteger)expectSize needCrop:(BOOL)needCrop placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options progress:(SDWebImageDownloaderProgressBlock)progressBlock completed:(SDWebImageCompletionBlock)completedBlock {
    
    NSString *downloadURLString = url;
    
    //万一传进来的类型不对，做个保护
    if ([url isKindOfClass:[NSURL class]]) {
        downloadURLString = ((NSURL *)url).absoluteString;
    }
    
    //匹配图片规则，替换 URL
    if (expectSize > 0) {
        downloadURLString = [[MGJImageAdapter sharedInstance] adaptImageURL:downloadURLString toSize:expectSize needCrop:needCrop];
    }
    
    
    NSURL *downloadURL = [NSURL URLWithString:downloadURLString];
    
    UIViewContentMode currentMode = self.contentMode;
    
    if (placeholder) {
        self.contentMode = UIViewContentModeCenter;
    }
    
    __weak typeof(self) wself = self;
    
    NSTimeInterval beginTime = [[NSDate date] timeIntervalSince1970];
    
    [self sd_setImageWithURL:downloadURL placeholderImage:placeholder options:options progress:progressBlock completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
        __strong typeof(self) strongSelf = wself;
        
        // 对于图像 size 为 0 的以 error 处理
        if (!image.size.height || !image.size.width) {
            image = nil;
            error = [NSError errorWithDomain:@"图像为空" code:-1024 userInfo:nil];
            [[SDImageCache sharedImageCache] removeImageForKey:[[SDWebImageManager sharedManager] cacheKeyForURL:downloadURL]];
        }
        
        if (!image || error) {
            
            if ([MGJImageConfigManager downloadImageFailureBlock]) {
                [MGJImageConfigManager downloadImageFailureBlock](error,imageURL.absoluteString);
            }
        }
        else
        {
            if ([MGJImageConfigManager downloadImageSuccessBlock]) {
                NSTimeInterval finishTime = [[NSDate date] timeIntervalSince1970];
                NSTimeInterval duration = finishTime - beginTime;
                [MGJImageConfigManager downloadImageSuccessBlock](cacheType,duration,imageURL.absoluteString);
            }
            strongSelf.contentMode = currentMode;
        }
        
        if (completedBlock) {
            completedBlock(image, error, cacheType, imageURL);
        }
        
    }];
}

@end
