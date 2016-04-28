//
//  UIButton+MGJAdvancedImageLoader.m
//  Example
//
//  Created by Derek Chen on 9/2/15.
//  Copyright (c) 2015 juangua. All rights reserved.
//

#import "UIButton+MGJAdvancedImageLoader.h"
#import <MGJFoundation/MGJFoundation.h>
#import <MGJUIKit/MGJUIKit.h>
#import "UIImage+MGJAdvancedImageLoader.h"
#import "UIView+MGJAdvancedImageLoader.h"
#import <objc/runtime.h>

NSString * const key_MGJAdvImgLoader_UIButton_WebImageURLStorage = @"key_MGJAdvImgLoader_UIButton_WebImageURLStorage";
NSString * const key_MGJAdvImgLoader_UIButton_WebBackgroundImageURLStorage = @"key_MGJAdvImgLoader_UIButton_WebBackgroundImageURLStorage";

NSString * const key_MGJAdvImgLoader_UIButton_WebImageLoadOperation = @"key_MGJAdvImgLoader_UIButton_WebImageLoadOperation";
NSString * const key_MGJAdvImgLoader_UIButton_WebBackgroundImageLoadOperation = @"key_MGJAdvImgLoader_UIButton_WebBackgroundImageLoadOperation";

@implementation UIButton (MGJAdvancedImageLoader)
- (NSString *)mgj_createKeyForButtonLoadImageWithPrefix:(NSString *)prefix andState:(UIControlState)state {
    NSString *result = nil;
    if (!MGJ_IS_EMPTY(prefix)) {
        result = [NSString stringWithFormat:@"%@%@", prefix, @(state)];
    }
    return result;
}

#pragma mark - Web image
- (NSMutableDictionary *)mgj_webImageURLStorage {
    NSMutableDictionary *storage = [[self getImageLocationStorage] objectForKey:key_MGJAdvImgLoader_UIButton_WebImageURLStorage];
    if (!storage) {
        storage = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, &key_MGJAdvImgLoader_UIButton_WebImageURLStorage, storage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return storage;
}

- (NSURL *)mgj_currentWebImageURL {
    NSURL *url = [self mgj_webImageURLStorage][@(self.state)];
    
    if (!url) {
        url = [self mgj_webImageURLStorage][@(UIControlStateNormal)];
    }
    
    return url;
}

- (NSURL *)mgj_webImageURLForState:(UIControlState)state {
    return [self mgj_webImageURLStorage][@(state)];
}

- (void)mgj_setWebImageURL:(NSURL *)url forState:(UIControlState)state {
    if (MGJ_IS_EMPTY(url)) {
        return;
    }
    NSMutableDictionary *storage = [self mgj_webImageURLStorage];
    if (MGJ_IS_EMPTY(storage)) {
        return;
    }
    [storage setObject:url forKey:@(state)];
}

- (void)mgj_setWebImageLoadOperation:(id <SDWebImageOperation>)operation forState:(UIControlState)state {
    if (!MGJ_IS_EMPTY(operation)) {
        [self sd_setImageLoadOperation:operation forKey:[self mgj_createKeyForButtonLoadImageWithPrefix:key_MGJAdvImgLoader_UIButton_WebImageLoadOperation andState:state]];
    }
}

- (void)mgj_cancelWebImageLoadOperationForState:(UIControlState)state {
    [self sd_cancelImageLoadOperationWithKey:[self mgj_createKeyForButtonLoadImageWithPrefix:key_MGJAdvImgLoader_UIButton_WebImageLoadOperation andState:state]];
}

- (void)mgj_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder forState:(UIControlState)state completed:(MGJAdvImgLoaderLoadImageCompletionBlock)completion {
    [self mgj_setImageWithURL:url placeholderImage:placeholder forState:state resize:self.frame.size scale:[self mgj_screenScale] completed:completion];
}

- (void)mgj_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder forState:(UIControlState)state resize:(CGSize)newSize scale:(CGFloat)scale completed:(MGJAdvImgLoaderLoadImageCompletionBlock)completion {
    [self mgj_setImageWithURL:url placeholderImage:placeholder forState:state options:0 customize:^NSDictionary *{
        NSMutableDictionary *result = [NSMutableDictionary dictionary];
        [result setObject:@(newSize.width) forKey:key_MGJAdvImgLoader_UIImage_ResizeWidth];
        [result setObject:@(newSize.height) forKey:key_MGJAdvImgLoader_UIImage_ResizeHeight];
        [result setObject:@(scale) forKey:key_MGJAdvImgLoader_UIImage_ResizeScale];
        return result;
    } progress:nil completed:completion];
}

- (void)mgj_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder forState:(UIControlState)state cornerRadius:(CGFloat)cornerRadius completed:(MGJAdvImgLoaderLoadImageCompletionBlock)completion {
    @weakify(self);
    [self mgj_setImageWithURL:url placeholderImage:placeholder forState:state options:0 customize:^NSDictionary *{
        @strongify(self);
        NSMutableDictionary *result = [NSMutableDictionary dictionary];
        [result setObject:@([self width]) forKey:key_MGJAdvImgLoader_UIImage_ResizeWidth];
        [result setObject:@([self height]) forKey:key_MGJAdvImgLoader_UIImage_ResizeHeight];
        [result setObject:@([self mgj_screenScale]) forKey:key_MGJAdvImgLoader_UIImage_ResizeScale];
        [result setObject:@(cornerRadius) forKey:key_MGJAdvImgLoader_UIImage_CornerRadius];
        return result;
    } progress:nil completed:completion];
}

- (void)mgj_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder forState:(UIControlState)state borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor completed:(MGJAdvImgLoaderLoadImageCompletionBlock)completion {
    @weakify(self);
    [self mgj_setImageWithURL:url placeholderImage:placeholder forState:state options:0 customize:^NSDictionary *{
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

- (void)mgj_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder forState:(UIControlState)state cornerRadius:(CGFloat)cornerRadius borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor completed:(MGJAdvImgLoaderLoadImageCompletionBlock)completion {
    @weakify(self);
    [self mgj_setImageWithURL:url placeholderImage:placeholder forState:state options:0 customize:^NSDictionary *{
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

- (void)mgj_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder forState:(UIControlState)state applyBlurWithRadius:(CGFloat)radius tintColor:(UIColor *)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor maskImage:(UIImage *)maskImage completed:(MGJAdvImgLoaderLoadImageCompletionBlock)completion {
    @weakify(self);
    [self mgj_setImageWithURL:url placeholderImage:placeholder forState:state options:0 customize:^NSDictionary *{
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

- (void)mgj_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder forState:(UIControlState)state options:(SDWebImageOptions)options customize:(MGJAdvImgLoaderCustomizeBlock)customization progress:(SDWebImageDownloaderProgressBlock)progress completed:(MGJAdvImgLoaderLoadImageCompletionBlock)completion {
    @weakify(self);
    
    if (MGJ_IS_EMPTY(url)) {
        return;
    }
    
    [self mgj_cancelWebImageLoadOperationForState:state];
    
    [self mgj_setWebImageURL:url forState:state];
    
    if (!(options & SDWebImageDelayPlaceholder) && placeholder) {
        [NSThread runInMain:^{
            @strongify(self);
            [self setImage:placeholder forState:state];
            [self setNeedsLayout];
        }];
    }
    
    [self mgj_loadImageWithURL:url placeholderImage:placeholder options:options customize:customization uiRender:^(UIImage *image, NSError *error, NSString *imagePath, NSURL *imageURL) {
        @strongify(self);
        [self setImage:image forState:state];
        [self setNeedsLayout];
    } operationHandler:^(id<SDWebImageOperation> operation, NSString *imagePath, NSURL *imageURL) {
        @strongify(self);
        [self mgj_setWebImageLoadOperation:operation forState:state];
    } progress:progress completed:completion];
}

#pragma mark - Web background image
- (NSMutableDictionary *)mgj_webBackgroundImageURLStorage {
    NSMutableDictionary *storage = [[self getImageLocationStorage] objectForKey:key_MGJAdvImgLoader_UIButton_WebBackgroundImageURLStorage];
    if (!storage) {
        storage = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, &key_MGJAdvImgLoader_UIButton_WebBackgroundImageURLStorage, storage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return storage;
}

- (NSURL *)mgj_currentWebBackgroundImageURL {
    NSURL *url = [self mgj_webBackgroundImageURLStorage][@(self.state)];
    
    if (!url) {
        url = [self mgj_webBackgroundImageURLStorage][@(UIControlStateNormal)];
    }
    
    return url;
}

- (NSURL *)mgj_webBackgroundImageURLForState:(UIControlState)state {
    return [self mgj_webBackgroundImageURLStorage][@(state)];
}

- (void)mgj_setWebBackgroundImageURL:(NSURL *)url forState:(UIControlState)state {
    if (MGJ_IS_EMPTY(url)) {
        return;
    }
    NSMutableDictionary *storage = [self mgj_webBackgroundImageURLStorage];
    if (MGJ_IS_EMPTY(storage)) {
        return;
    }
    [storage setObject:url forKey:@(state)];
}

- (void)mgj_setWebBackgroundImageLoadOperation:(id <SDWebImageOperation>)operation forState:(UIControlState)state {
    if (!MGJ_IS_EMPTY(operation)) {
        [self sd_setImageLoadOperation:operation forKey:[self mgj_createKeyForButtonLoadImageWithPrefix:key_MGJAdvImgLoader_UIButton_WebBackgroundImageLoadOperation andState:state]];
    }
}

- (void)mgj_cancelWebBackgroundImageLoadOperationForState:(UIControlState)state {
    [self sd_cancelImageLoadOperationWithKey:[self mgj_createKeyForButtonLoadImageWithPrefix:key_MGJAdvImgLoader_UIButton_WebBackgroundImageLoadOperation andState:state]];
}

- (void)mgj_setBackgroundImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder forState:(UIControlState)state completed:(MGJAdvImgLoaderLoadImageCompletionBlock)completion {
    [self mgj_setBackgroundImageWithURL:url placeholderImage:placeholder forState:state resize:self.frame.size scale:[self mgj_screenScale] completed:completion];
}

- (void)mgj_setBackgroundImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder forState:(UIControlState)state resize:(CGSize)newSize scale:(CGFloat)scale completed:(MGJAdvImgLoaderLoadImageCompletionBlock)completion {
    [self mgj_setBackgroundImageWithURL:url placeholderImage:placeholder forState:state options:0 customize:^NSDictionary *{
        NSMutableDictionary *result = [NSMutableDictionary dictionary];
        [result setObject:@(newSize.width) forKey:key_MGJAdvImgLoader_UIImage_ResizeWidth];
        [result setObject:@(newSize.height) forKey:key_MGJAdvImgLoader_UIImage_ResizeHeight];
        [result setObject:@(scale) forKey:key_MGJAdvImgLoader_UIImage_ResizeScale];
        return result;
    } progress:nil completed:completion];
}

- (void)mgj_setBackgroundImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder forState:(UIControlState)state cornerRadius:(CGFloat)cornerRadius completed:(MGJAdvImgLoaderLoadImageCompletionBlock)completion {
    @weakify(self);
    [self mgj_setBackgroundImageWithURL:url placeholderImage:placeholder forState:state options:0 customize:^NSDictionary *{
        @strongify(self);
        NSMutableDictionary *result = [NSMutableDictionary dictionary];
        [result setObject:@([self width]) forKey:key_MGJAdvImgLoader_UIImage_ResizeWidth];
        [result setObject:@([self height]) forKey:key_MGJAdvImgLoader_UIImage_ResizeHeight];
        [result setObject:@([self mgj_screenScale]) forKey:key_MGJAdvImgLoader_UIImage_ResizeScale];
        [result setObject:@(cornerRadius) forKey:key_MGJAdvImgLoader_UIImage_CornerRadius];
        return result;
    } progress:nil completed:completion];
}

- (void)mgj_setBackgroundImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder forState:(UIControlState)state borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor completed:(MGJAdvImgLoaderLoadImageCompletionBlock)completion {
    @weakify(self);
    [self mgj_setBackgroundImageWithURL:url placeholderImage:placeholder forState:state options:0 customize:^NSDictionary *{
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

- (void)mgj_setBackgroundImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder forState:(UIControlState)state cornerRadius:(CGFloat)cornerRadius borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor completed:(MGJAdvImgLoaderLoadImageCompletionBlock)completion {
    @weakify(self);
    [self mgj_setBackgroundImageWithURL:url placeholderImage:placeholder forState:state options:0 customize:^NSDictionary *{
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

- (void)mgj_setBackgroundImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder forState:(UIControlState)state applyBlurWithRadius:(CGFloat)radius tintColor:(UIColor *)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor maskImage:(UIImage *)maskImage completed:(MGJAdvImgLoaderLoadImageCompletionBlock)completion {
    @weakify(self);
    [self mgj_setBackgroundImageWithURL:url placeholderImage:placeholder forState:state options:0 customize:^NSDictionary *{
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

- (void)mgj_setBackgroundImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder forState:(UIControlState)state options:(SDWebImageOptions)options customize:(MGJAdvImgLoaderCustomizeBlock)customization progress:(SDWebImageDownloaderProgressBlock)progress completed:(MGJAdvImgLoaderLoadImageCompletionBlock)completion {
    @weakify(self);
    
    if (MGJ_IS_EMPTY(url)) {
        return;
    }
    
    [self mgj_cancelWebBackgroundImageLoadOperationForState:state];
    
    [self mgj_setWebBackgroundImageURL:url forState:state];
    
    if (!(options & SDWebImageDelayPlaceholder) && placeholder) {
        [NSThread runInMain:^{
            @strongify(self);
            [self setBackgroundImage:placeholder forState:state];
            [self setNeedsLayout];
        }];
    }
    
    [self mgj_loadImageWithURL:url placeholderImage:placeholder options:options customize:customization uiRender:^(UIImage *image, NSError *error, NSString *imagePath, NSURL *imageURL) {
        @strongify(self);
        [self setBackgroundImage:image forState:state];
        [self setNeedsLayout];
    } operationHandler:^(id<SDWebImageOperation> operation, NSString *imagePath, NSURL *imageURL) {
        @strongify(self);
        [self mgj_setWebBackgroundImageLoadOperation:operation forState:state];
    } progress:progress completed:completion];
}

@end
