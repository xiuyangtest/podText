//
//  UIImageView+MGJAdvancedImageLoader.h
//  Example
//
//  Created by Derek Chen on 7/6/15.
//  Copyright (c) 2015 juangua. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+MGJAdvancedImageLoader.h"

extern NSString * const key_MGJAdvImgLoader_UIImageView_WebImageURL;
extern NSString * const key_MGJAdvImgLoader_UIImageView_WebHighlightedImageURL;

extern NSString * const key_MGJAdvImgLoader_UIImageView_WebImageLoadOperation;
extern NSString * const key_MGJAdvImgLoader_UIImageView_WebHighlightedImageLoadOperation;

@interface UIImageView (MGJAdvancedImageLoader)

#pragma mark - Web image
- (NSURL *)mgj_currentWebImageURL;
- (void)mgj_setWebImageURL:(NSURL *)url;

- (void)mgj_setWebImageLoadOperation:(id)operation;
- (void)mgj_cancelCurrentWebImageLoadOperation;

- (void)mgj_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder completed:(MGJAdvImgLoaderLoadImageCompletionBlock)completion;
- (void)mgj_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder resize:(CGSize)newSize scale:(CGFloat)scale completed:(MGJAdvImgLoaderLoadImageCompletionBlock)completion;
- (void)mgj_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder cornerRadius:(CGFloat)cornerRadius completed:(MGJAdvImgLoaderLoadImageCompletionBlock)completion;
- (void)mgj_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor completed:(MGJAdvImgLoaderLoadImageCompletionBlock)completion;
- (void)mgj_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder cornerRadius:(CGFloat)cornerRadius borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor completed:(MGJAdvImgLoaderLoadImageCompletionBlock)completion;
- (void)mgj_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder applyBlurWithRadius:(CGFloat)radius tintColor:(UIColor *)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor maskImage:(UIImage *)maskImage completed:(MGJAdvImgLoaderLoadImageCompletionBlock)completion;

- (void)mgj_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options customize:(MGJAdvImgLoaderCustomizeBlock)customization progress:(SDWebImageDownloaderProgressBlock)progress completed:(MGJAdvImgLoaderLoadImageCompletionBlock)completion;

#pragma mark - Web highlighted image
- (NSURL *)mgj_currentWebHighlightedImageURL;
- (void)mgj_setWebHighlightedImageURL:(NSURL *)url;

- (void)mgj_setWebHighlightedImageLoadOperation:(id)operation;
- (void)mgj_cancelCurrentWebHighlightedImageLoadOperation;

- (void)mgj_setHighlightedImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder completed:(MGJAdvImgLoaderLoadImageCompletionBlock)completion;
- (void)mgj_setHighlightedImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder resize:(CGSize)newSize scale:(CGFloat)scale completed:(MGJAdvImgLoaderLoadImageCompletionBlock)completion;
- (void)mgj_setHighlightedImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder cornerRadius:(CGFloat)cornerRadius completed:(MGJAdvImgLoaderLoadImageCompletionBlock)completion;
- (void)mgj_setHighlightedImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor completed:(MGJAdvImgLoaderLoadImageCompletionBlock)completion;
- (void)mgj_setHighlightedImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder cornerRadius:(CGFloat)cornerRadius borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor completed:(MGJAdvImgLoaderLoadImageCompletionBlock)completion;
- (void)mgj_setHighlightedImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder applyBlurWithRadius:(CGFloat)radius tintColor:(UIColor *)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor maskImage:(UIImage *)maskImage completed:(MGJAdvImgLoaderLoadImageCompletionBlock)completion;

- (void)mgj_setHighlightedImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options customize:(MGJAdvImgLoaderCustomizeBlock)customization progress:(SDWebImageDownloaderProgressBlock)progress completed:(MGJAdvImgLoaderLoadImageCompletionBlock)completion;

#pragma mark - Action
- (void)mgj_cleanAllImageLocations;
- (void)mgj_cancelAllImageLoadOperations;

@end
