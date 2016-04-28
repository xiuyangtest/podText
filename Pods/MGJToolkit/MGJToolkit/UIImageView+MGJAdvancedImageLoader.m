//
//  UIImageView+MGJAdvancedImageLoader.m
//  Example
//
//  Created by Derek Chen on 7/6/15.
//  Copyright (c) 2015 juangua. All rights reserved.
//

#import "UIImageView+MGJAdvancedImageLoader.h"
#import <MGJFoundation/MGJFoundation.h>
#import <MGJUIKit/MGJUIKit.h>
#import <SDWebImage/UIView+WebCacheOperation.h>
#import "UIImage+MGJAdvancedImageLoader.h"
#import "UIView+MGJAdvancedImageLoader.h"

NSString * const key_MGJAdvImgLoader_UIImageView_WebImageURL = @"key_MGJAdvImgLoader_UIImageView_WebImageURL";
NSString * const key_MGJAdvImgLoader_UIImageView_WebHighlightedImageURL = @"key_MGJAdvImgLoader_UIImageView_WebHighlightedImageURL";

NSString * const key_MGJAdvImgLoader_UIImageView_WebImageLoadOperation = @"key_MGJAdvImgLoader_UIImageView_WebImageLoadOperation";
NSString * const key_MGJAdvImgLoader_UIImageView_WebHighlightedImageLoadOperation = @"key_MGJAdvImgLoader_UIImageView_WebHighlightedImageLoadOperation";

@implementation UIImageView (MGJAdvancedImageLoader)

#pragma mark - Web image
- (NSURL *)mgj_currentWebImageURL {
    return [[self getImageLocationStorage] objectForKey:key_MGJAdvImgLoader_UIImageView_WebImageURL];
}

- (void)mgj_setWebImageURL:(NSURL *)url {
    [[self getImageLocationStorage] setObject:url forKey:key_MGJAdvImgLoader_UIImageView_WebImageURL];
}

- (void)mgj_setWebImageLoadOperation:(id)operation {
    if (!MGJ_IS_EMPTY(operation)) {
        [self sd_setImageLoadOperation:operation forKey:key_MGJAdvImgLoader_UIImageView_WebImageLoadOperation];
    }
}

- (void)mgj_cancelCurrentWebImageLoadOperation {
    [self sd_cancelImageLoadOperationWithKey:key_MGJAdvImgLoader_UIImageView_WebImageLoadOperation];
}

- (void)mgj_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder completed:(MGJAdvImgLoaderLoadImageCompletionBlock)completion {
    [self mgj_setImageWithURL:url placeholderImage:placeholder resize:self.frame.size scale:[self mgj_screenScale] completed:completion];
}

- (void)mgj_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder resize:(CGSize)newSize scale:(CGFloat)scale completed:(MGJAdvImgLoaderLoadImageCompletionBlock)completion {
    [self mgj_setImageWithURL:url placeholderImage:placeholder options:0 customize:^NSDictionary *{
        NSMutableDictionary *result = [NSMutableDictionary dictionary];
        [result setObject:@(newSize.width) forKey:key_MGJAdvImgLoader_UIImage_ResizeWidth];
        [result setObject:@(newSize.height) forKey:key_MGJAdvImgLoader_UIImage_ResizeHeight];
        [result setObject:@(scale) forKey:key_MGJAdvImgLoader_UIImage_ResizeScale];
        return result;
    } progress:nil completed:completion];
}

- (void)mgj_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder cornerRadius:(CGFloat)cornerRadius completed:(MGJAdvImgLoaderLoadImageCompletionBlock)completion {
    @weakify(self);
    [self mgj_setImageWithURL:url placeholderImage:placeholder options:0 customize:^NSDictionary *{
        @strongify(self);
        NSMutableDictionary *result = [NSMutableDictionary dictionary];
        [result setObject:@([self width]) forKey:key_MGJAdvImgLoader_UIImage_ResizeWidth];
        [result setObject:@([self height]) forKey:key_MGJAdvImgLoader_UIImage_ResizeHeight];
        [result setObject:@([self mgj_screenScale]) forKey:key_MGJAdvImgLoader_UIImage_ResizeScale];
        [result setObject:@(cornerRadius) forKey:key_MGJAdvImgLoader_UIImage_CornerRadius];
        return result;
    } progress:nil completed:completion];
}

- (void)mgj_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor completed:(MGJAdvImgLoaderLoadImageCompletionBlock)completion {
    @weakify(self);
    [self mgj_setImageWithURL:url placeholderImage:placeholder options:0 customize:^NSDictionary *{
        @strongify(self);
        NSMutableDictionary *result = [NSMutableDictionary dictionary];
        [result setObject:@([self width]) forKey:key_MGJAdvImgLoader_UIImage_ResizeWidth];
        [result setObject:@([self height]) forKey:key_MGJAdvImgLoader_UIImage_ResizeHeight];
        [result setObject:@([self mgj_screenScale]) forKey:key_MGJAdvImgLoader_UIImage_ResizeScale];
        [result setObject:@(borderWidth) forKey:key_MGJAdvImgLoader_UIImage_BorderWidth];
        [result setObject:borderColor forKey:key_MGJAdvImgLoader_UIImage_BorderColor];
        return result;
    } progress:nil completed:completion];
}

- (void)mgj_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder cornerRadius:(CGFloat)cornerRadius borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor completed:(MGJAdvImgLoaderLoadImageCompletionBlock)completion {
    @weakify(self);
    [self mgj_setImageWithURL:url placeholderImage:placeholder options:0 customize:^NSDictionary *{
        @strongify(self);
        NSMutableDictionary *result = [NSMutableDictionary dictionary];
        [result setObject:@([self width]) forKey:key_MGJAdvImgLoader_UIImage_ResizeWidth];
        [result setObject:@([self height]) forKey:key_MGJAdvImgLoader_UIImage_ResizeHeight];
        [result setObject:@([self mgj_screenScale]) forKey:key_MGJAdvImgLoader_UIImage_ResizeScale];
        [result setObject:@(cornerRadius) forKey:key_MGJAdvImgLoader_UIImage_CornerRadius];
        [result setObject:@(borderWidth) forKey:key_MGJAdvImgLoader_UIImage_BorderWidth];
        [result setObject:borderColor forKey:key_MGJAdvImgLoader_UIImage_BorderColor];
        return result;
    } progress:nil completed:completion];
}

- (void)mgj_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder applyBlurWithRadius:(CGFloat)radius tintColor:(UIColor *)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor maskImage:(UIImage *)maskImage completed:(MGJAdvImgLoaderLoadImageCompletionBlock)completion {
    @weakify(self);
    [self mgj_setImageWithURL:url placeholderImage:placeholder options:0 customize:^NSDictionary *{
        @strongify(self);
        NSMutableDictionary *result = [NSMutableDictionary dictionary];
        [result setObject:@([self width]) forKey:key_MGJAdvImgLoader_UIImage_ResizeWidth];
        [result setObject:@([self height]) forKey:key_MGJAdvImgLoader_UIImage_ResizeHeight];
        [result setObject:@([self mgj_screenScale]) forKey:key_MGJAdvImgLoader_UIImage_ResizeScale];
        [result setObject:@(radius) forKey:key_MGJAdvImgLoader_UIImage_BlurRadius];
        [result setObject:tintColor forKey:key_MGJAdvImgLoader_UIImage_BlurTintColor];
        [result setObject:@(saturationDeltaFactor) forKey:key_MGJAdvImgLoader_UIImage_BlurSaturationDeltaFactor];
        [result setObject:maskImage forKey:key_MGJAdvImgLoader_UIImage_BlurMaskImage];
        return result;
    } progress:nil completed:completion];
}

- (void)mgj_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options customize:(MGJAdvImgLoaderCustomizeBlock)customization progress:(SDWebImageDownloaderProgressBlock)progress completed:(MGJAdvImgLoaderLoadImageCompletionBlock)completion {
    @weakify(self);
    
    if (MGJ_IS_EMPTY(url)) {
        return;
    }
    
    [self mgj_cancelAllImageLoadOperations];
    [self mgj_cleanAllImageLocations];
    
    [self mgj_setWebImageURL:url];
    
    if (!(options & SDWebImageDelayPlaceholder) && placeholder) {
        [NSThread runInMain:^{
            @strongify(self);
            self.image = placeholder;
            [self setNeedsLayout];
        }];
    }
    
    [self mgj_loadImageWithURL:url placeholderImage:placeholder options:options customize:customization uiRender:^(UIImage *image, NSError *error, NSString *imagePath, NSURL *imageURL) {
        @strongify(self);
        self.image = image;
        [self setNeedsLayout];
    } operationHandler:^(id<SDWebImageOperation> operation, NSString *imagePath, NSURL *imageURL) {
        @strongify(self);
        [self mgj_setWebImageLoadOperation:operation];
    } progress:progress completed:completion];
}

#pragma mark - Web highlighted image
- (NSURL *)mgj_currentWebHighlightedImageURL {
    return [[self getImageLocationStorage] objectForKey:key_MGJAdvImgLoader_UIImageView_WebHighlightedImageURL];
}

- (void)mgj_setWebHighlightedImageURL:(NSURL *)url {
    [[self getImageLocationStorage] setObject:url forKey:key_MGJAdvImgLoader_UIImageView_WebHighlightedImageURL];
}

- (void)mgj_setWebHighlightedImageLoadOperation:(id)operation {
    if (!MGJ_IS_EMPTY(operation)) {
        [self sd_setImageLoadOperation:operation forKey:key_MGJAdvImgLoader_UIImageView_WebHighlightedImageLoadOperation];
    }
}

- (void)mgj_cancelCurrentWebHighlightedImageLoadOperation {
    [self sd_cancelImageLoadOperationWithKey:key_MGJAdvImgLoader_UIImageView_WebHighlightedImageLoadOperation];
}

- (void)mgj_setHighlightedImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder completed:(MGJAdvImgLoaderLoadImageCompletionBlock)completion {
    [self mgj_setHighlightedImageWithURL:url placeholderImage:placeholder resize:self.frame.size scale:[self mgj_screenScale] completed:completion];
}

- (void)mgj_setHighlightedImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder resize:(CGSize)newSize scale:(CGFloat)scale completed:(MGJAdvImgLoaderLoadImageCompletionBlock)completion {
    [self mgj_setHighlightedImageWithURL:url placeholderImage:placeholder options:0 customize:^NSDictionary *{
        NSMutableDictionary *result = [NSMutableDictionary dictionary];
        [result setObject:@(newSize.width) forKey:key_MGJAdvImgLoader_UIImage_ResizeWidth];
        [result setObject:@(newSize.height) forKey:key_MGJAdvImgLoader_UIImage_ResizeHeight];
        [result setObject:@(scale) forKey:key_MGJAdvImgLoader_UIImage_ResizeScale];
        return result;
    } progress:nil completed:completion];
}

- (void)mgj_setHighlightedImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder cornerRadius:(CGFloat)cornerRadius completed:(MGJAdvImgLoaderLoadImageCompletionBlock)completion {
    @weakify(self);
    [self mgj_setHighlightedImageWithURL:url placeholderImage:placeholder options:0 customize:^NSDictionary *{
        @strongify(self);
        NSMutableDictionary *result = [NSMutableDictionary dictionary];
        [result setObject:@([self width]) forKey:key_MGJAdvImgLoader_UIImage_ResizeWidth];
        [result setObject:@([self height]) forKey:key_MGJAdvImgLoader_UIImage_ResizeHeight];
        [result setObject:@([self mgj_screenScale]) forKey:key_MGJAdvImgLoader_UIImage_ResizeScale];
        [result setObject:@(cornerRadius) forKey:key_MGJAdvImgLoader_UIImage_CornerRadius];
        return result;
    } progress:nil completed:completion];
}

- (void)mgj_setHighlightedImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor completed:(MGJAdvImgLoaderLoadImageCompletionBlock)completion {
    @weakify(self);
    [self mgj_setHighlightedImageWithURL:url placeholderImage:placeholder options:0 customize:^NSDictionary *{
        @strongify(self);
        NSMutableDictionary *result = [NSMutableDictionary dictionary];
        [result setObject:@([self width]) forKey:key_MGJAdvImgLoader_UIImage_ResizeWidth];
        [result setObject:@([self height]) forKey:key_MGJAdvImgLoader_UIImage_ResizeHeight];
        [result setObject:@([self mgj_screenScale]) forKey:key_MGJAdvImgLoader_UIImage_ResizeScale];
        [result setObject:@(borderWidth) forKey:key_MGJAdvImgLoader_UIImage_BorderWidth];
        [result setObject:borderColor forKey:key_MGJAdvImgLoader_UIImage_BorderColor];
        return result;
    } progress:nil completed:completion];
}

- (void)mgj_setHighlightedImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder cornerRadius:(CGFloat)cornerRadius borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor completed:(MGJAdvImgLoaderLoadImageCompletionBlock)completion {
    @weakify(self);
    [self mgj_setHighlightedImageWithURL:url placeholderImage:placeholder options:0 customize:^NSDictionary *{
        @strongify(self);
        NSMutableDictionary *result = [NSMutableDictionary dictionary];
        [result setObject:@([self width]) forKey:key_MGJAdvImgLoader_UIImage_ResizeWidth];
        [result setObject:@([self height]) forKey:key_MGJAdvImgLoader_UIImage_ResizeHeight];
        [result setObject:@([self mgj_screenScale]) forKey:key_MGJAdvImgLoader_UIImage_ResizeScale];
        [result setObject:@(cornerRadius) forKey:key_MGJAdvImgLoader_UIImage_CornerRadius];
        [result setObject:@(borderWidth) forKey:key_MGJAdvImgLoader_UIImage_BorderWidth];
        [result setObject:borderColor forKey:key_MGJAdvImgLoader_UIImage_BorderColor];
        return result;
    } progress:nil completed:completion];
}

- (void)mgj_setHighlightedImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder applyBlurWithRadius:(CGFloat)radius tintColor:(UIColor *)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor maskImage:(UIImage *)maskImage completed:(MGJAdvImgLoaderLoadImageCompletionBlock)completion {
    @weakify(self);
    [self mgj_setHighlightedImageWithURL:url placeholderImage:placeholder options:0 customize:^NSDictionary *{
        @strongify(self);
        NSMutableDictionary *result = [NSMutableDictionary dictionary];
        [result setObject:@([self width]) forKey:key_MGJAdvImgLoader_UIImage_ResizeWidth];
        [result setObject:@([self height]) forKey:key_MGJAdvImgLoader_UIImage_ResizeHeight];
        [result setObject:@([self mgj_screenScale]) forKey:key_MGJAdvImgLoader_UIImage_ResizeScale];
        [result setObject:@(radius) forKey:key_MGJAdvImgLoader_UIImage_BlurRadius];
        [result setObject:tintColor forKey:key_MGJAdvImgLoader_UIImage_BlurTintColor];
        [result setObject:@(saturationDeltaFactor) forKey:key_MGJAdvImgLoader_UIImage_BlurSaturationDeltaFactor];
        [result setObject:maskImage forKey:key_MGJAdvImgLoader_UIImage_BlurMaskImage];
        return result;
    } progress:nil completed:completion];
}

- (void)mgj_setHighlightedImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options customize:(MGJAdvImgLoaderCustomizeBlock)customization progress:(SDWebImageDownloaderProgressBlock)progress completed:(MGJAdvImgLoaderLoadImageCompletionBlock)completion {
    @weakify(self);
    
    if (MGJ_IS_EMPTY(url)) {
        return;
    }
    
    [self mgj_cancelAllImageLoadOperations];
    [self mgj_cleanAllImageLocations];
    
    [self mgj_setWebHighlightedImageURL:url];
    
    if (!(options & SDWebImageDelayPlaceholder) && placeholder) {
        [NSThread runInMain:^{
            @strongify(self);
            self.highlightedImage = placeholder;
            [self setNeedsLayout];
        }];
    }
    
    [self mgj_loadImageWithURL:url placeholderImage:placeholder options:options customize:customization uiRender:^(UIImage *image, NSError *error, NSString *imagePath, NSURL *imageURL) {
        @strongify(self);
        self.highlightedImage = image;
        [self setNeedsLayout];
    } operationHandler:^(id<SDWebImageOperation> operation, NSString *imagePath, NSURL *imageURL) {
        @strongify(self);
        [self mgj_setWebHighlightedImageLoadOperation:operation];
    } progress:progress completed:completion];
}

#pragma mark - Action
- (void)mgj_cleanAllImageLocations {
    [[self getImageLocationStorage] removeObjectForKey:key_MGJAdvImgLoader_UIImageView_WebImageURL];
    [[self getImageLocationStorage] removeObjectForKey:key_MGJAdvImgLoader_UIImageView_WebHighlightedImageURL];
}

- (void)mgj_cancelAllImageLoadOperations {
    [self mgj_cancelCurrentWebImageLoadOperation];
    [self mgj_cancelCurrentWebHighlightedImageLoadOperation];
}

@end
