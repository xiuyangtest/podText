//
//  UIButton+MGJAdvancedImageLoader.h
//  Example
//
//  Created by Derek Chen on 9/2/15.
//  Copyright (c) 2015 juangua. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+MGJAdvancedImageLoader.h"
#import <SDWebImage/UIView+WebCacheOperation.h>

extern NSString * const key_MGJAdvImgLoader_UIButton_WebImageURLStorage;
extern NSString * const key_MGJAdvImgLoader_UIButton_WebBackgroundImageURLStorage;

extern NSString * const key_MGJAdvImgLoader_UIButton_WebImageLoadOperation;
extern NSString * const key_MGJAdvImgLoader_UIButton_WebBackgroundImageLoadOperation;

@interface UIButton (MGJAdvancedImageLoader)

- (NSString *)mgj_createKeyForButtonLoadImageWithPrefix:(NSString *)prefix andState:(UIControlState)state;

#pragma mark - Web image
- (NSMutableDictionary *)mgj_webImageURLStorage;
- (NSURL *)mgj_currentWebImageURL;
- (NSURL *)mgj_webImageURLForState:(UIControlState)state;
- (void)mgj_setWebImageURL:(NSURL *)url forState:(UIControlState)state;

- (void)mgj_setWebImageLoadOperation:(id <SDWebImageOperation>)operation forState:(UIControlState)state;
- (void)mgj_cancelWebImageLoadOperationForState:(UIControlState)state;

- (void)mgj_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder forState:(UIControlState)state completed:(MGJAdvImgLoaderLoadImageCompletionBlock)completion;
- (void)mgj_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder forState:(UIControlState)state resize:(CGSize)newSize scale:(CGFloat)scale completed:(MGJAdvImgLoaderLoadImageCompletionBlock)completion;
- (void)mgj_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder forState:(UIControlState)state cornerRadius:(CGFloat)cornerRadius completed:(MGJAdvImgLoaderLoadImageCompletionBlock)completion;
- (void)mgj_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder forState:(UIControlState)state borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor completed:(MGJAdvImgLoaderLoadImageCompletionBlock)completion;
- (void)mgj_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder forState:(UIControlState)state cornerRadius:(CGFloat)cornerRadius borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor completed:(MGJAdvImgLoaderLoadImageCompletionBlock)completion;
- (void)mgj_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder forState:(UIControlState)state applyBlurWithRadius:(CGFloat)radius tintColor:(UIColor *)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor maskImage:(UIImage *)maskImage completed:(MGJAdvImgLoaderLoadImageCompletionBlock)completion;

- (void)mgj_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder forState:(UIControlState)state options:(SDWebImageOptions)options customize:(MGJAdvImgLoaderCustomizeBlock)customization progress:(SDWebImageDownloaderProgressBlock)progress completed:(MGJAdvImgLoaderLoadImageCompletionBlock)completion;

#pragma mark - Web background image
- (NSMutableDictionary *)mgj_webBackgroundImageURLStorage;
- (NSURL *)mgj_currentWebBackgroundImageURL;
- (NSURL *)mgj_webBackgroundImageURLForState:(UIControlState)state;
- (void)mgj_setWebBackgroundImageURL:(NSURL *)url forState:(UIControlState)state;

- (void)mgj_setWebBackgroundImageLoadOperation:(id <SDWebImageOperation>)operation forState:(UIControlState)state;
- (void)mgj_cancelWebBackgroundImageLoadOperationForState:(UIControlState)state;

- (void)mgj_setBackgroundImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder forState:(UIControlState)state completed:(MGJAdvImgLoaderLoadImageCompletionBlock)completion;
- (void)mgj_setBackgroundImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder forState:(UIControlState)state resize:(CGSize)newSize scale:(CGFloat)scale completed:(MGJAdvImgLoaderLoadImageCompletionBlock)completion;
- (void)mgj_setBackgroundImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder forState:(UIControlState)state cornerRadius:(CGFloat)cornerRadius completed:(MGJAdvImgLoaderLoadImageCompletionBlock)completion;
- (void)mgj_setBackgroundImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder forState:(UIControlState)state borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor completed:(MGJAdvImgLoaderLoadImageCompletionBlock)completion;
- (void)mgj_setBackgroundImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder forState:(UIControlState)state cornerRadius:(CGFloat)cornerRadius borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor completed:(MGJAdvImgLoaderLoadImageCompletionBlock)completion;
- (void)mgj_setBackgroundImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder forState:(UIControlState)state applyBlurWithRadius:(CGFloat)radius tintColor:(UIColor *)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor maskImage:(UIImage *)maskImage completed:(MGJAdvImgLoaderLoadImageCompletionBlock)completion;

- (void)mgj_setBackgroundImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder forState:(UIControlState)state options:(SDWebImageOptions)options customize:(MGJAdvImgLoaderCustomizeBlock)customization progress:(SDWebImageDownloaderProgressBlock)progress completed:(MGJAdvImgLoaderLoadImageCompletionBlock)completion;

@end
