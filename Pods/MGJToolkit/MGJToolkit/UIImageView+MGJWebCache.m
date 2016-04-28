//
//  UIImageView+MGJ.m
//  Mogujie4iPhone
//
//  Created by kunka on 13-6-17.
//  Copyright (c) 2013年 juangua. All rights reserved.
//

#import "UIImageView+MGJWebCache.h"
#import "objc/runtime.h"
#import "UIView+WebCacheOperation.h"
#import <MGJUIKit/UIImage+MGJKit.h>

static mgj_sd_downloadImageSuccessBlock successBlock;
static mgj_sd_downloadImageFailureBlock failureBlock;

@implementation UIImageView (MGJWebCache)

+(void)setDownloadImageSuccessBlock:(mgj_sd_downloadImageSuccessBlock)success FailureBlock:(mgj_sd_downloadImageFailureBlock)failure{
    successBlock = success;
    failureBlock = failure;
}

- (void)mgj_setImageWithURL:(NSString *)url
{
    [self mgj_setImageWithURL:url placeholderImage:nil];
}

- (void)mgj_setImageWithURL:(NSString *)url placeholderImage:(UIImage *)placeholder
{
    [self mgj_setImageWithURL:url placeholderImage:placeholder animated:NO];
}

- (void)mgj_setImageWithURL:(NSString *)url placeholderImage:(UIImage *)placeholder animated:(BOOL)animated
{
    self.clipsToBounds = YES;
    self.contentMode = UIViewContentModeScaleAspectFill;
    __weak typeof(self) wself = self;
    
    [self mgj_setImageWithURL:[NSURL URLWithString:url] placeholderImage:placeholder options:SDWebImageRetryFailed resizeImage:NO progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
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
    [self mgj_setImageWithURL:[NSURL URLWithString:url] placeholderImage:nil options:SDWebImageRetryFailed resizeImage:NO progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (image && !error) {
            if (completedBlock) {
                completedBlock(image);
            }
        }
    }];
}


- (void)mgj_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options resizeImage:(BOOL)resizeImage progress:(SDWebImageDownloaderProgressBlock)progressBlock completed:(SDWebImageCompletionBlock)completedBlock {
    
    NSURL *downloadURL = url;
    NSURL *resizedImageURL = nil;
    BOOL existResizedImage = NO;
    UIViewContentMode currentMode = self.contentMode;
    
    if (url && resizeImage) {
        resizedImageURL = [self urlForResizeImage:url contentMode:currentMode newSize:self.frame.size];
        existResizedImage = [[SDWebImageManager sharedManager].imageCache diskImageExistsWithKey:[[SDWebImageManager sharedManager] cacheKeyForURL:resizedImageURL]];
        
        if (existResizedImage) {
            downloadURL = resizedImageURL;
        }
    }
    
    if (placeholder) {
        self.contentMode = UIViewContentModeCenter;
    }
        
    __weak typeof(self) wself = self;
    
    NSTimeInterval beginTime = [[NSDate date] timeIntervalSince1970];
    
    [self sd_setImageWithURL:downloadURL placeholderImage:placeholder options:options progress:progressBlock completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
        // 对于图像 size 为 0 的以 error 处理
        if (!image.size.height || !image.size.width) {
            image = nil;
            error = [NSError errorWithDomain:@"图像为空" code:-1024 userInfo:nil];
            [[SDImageCache sharedImageCache] removeImageForKey:[downloadURL absoluteString]];
        }
        
        if (!image || error) {
            
            if (failureBlock) {
                failureBlock(error,imageURL.absoluteString);
            }
        }
        else
        {
            if (successBlock) {
                NSTimeInterval finishTime = [[NSDate date] timeIntervalSince1970];
                NSTimeInterval duration = finishTime - beginTime;
                successBlock(cacheType,duration,imageURL.absoluteString);
            }
            
            if (resizeImage && !existResizedImage) {
                wself.image = placeholder;
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    UIImage *resizedImage = [image resizeToSize:wself.frame.size contentMode:currentMode];
                    [[SDWebImageManager sharedManager].imageCache storeImage:resizedImage forKey:[[SDWebImageManager sharedManager] cacheKeyForURL:resizedImageURL]];
                    
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        if ([wself.sd_imageURL.absoluteString isEqualToString:imageURL.absoluteString]) {
                            wself.image = resizedImage;
                            wself.contentMode = currentMode;
                            [wself setNeedsLayout];
                            if (completedBlock) {
                                completedBlock(resizedImage, error, cacheType, imageURL);
                            }
                            return;
                        }
                        
                    });
                });
            }
        }
        wself.contentMode = currentMode;
        if (completedBlock) {
            completedBlock(image, error, cacheType, imageURL);
        }
        
    }];
}

- (NSURL *)urlForResizeImage:(NSURL *)originURL contentMode:(UIViewContentMode)contentMode newSize:(CGSize)size
{
    NSString *urlComponent = [NSString stringWithFormat:@"%.fx%.f_%ld%@", size.width, size.height, contentMode, (([UIScreen mainScreen].scale > 1) ? [NSString stringWithFormat:@"@%.fx", [UIScreen mainScreen].scale] :@"")];
    return [[[originURL URLByDeletingPathExtension] URLByAppendingPathComponent:urlComponent] URLByAppendingPathExtension:originURL.pathExtension];
}
@end
