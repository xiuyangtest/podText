//
//  UIImage+MGJAdvancedImageLoader.h
//  Example
//
//  Created by Derek Chen on 9/2/15.
//  Copyright (c) 2015 juangua. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+MGJAdvancedImageLoader.h"

extern NSString * const key_MGJAdvImgLoader_UIImage_ResizeWidth;  // NSNumber
extern NSString * const key_MGJAdvImgLoader_UIImage_ResizeHeight;  // NSNumber
extern NSString * const key_MGJAdvImgLoader_UIImage_ResizeScale;  // NSNumber
extern NSString * const key_MGJAdvImgLoader_UIImage_CornerRadius;  // NSNumber
extern NSString * const key_MGJAdvImgLoader_UIImage_BorderColor;  // UIColor
extern NSString * const key_MGJAdvImgLoader_UIImage_BorderWidth;  // NSNumber
extern NSString * const key_MGJAdvImgLoader_UIImage_BlurEdgeInsets;  // NSValue(UIEdgeInsets)
extern NSString * const key_MGJAdvImgLoader_UIImage_BlurRadius;  // NSNumber
extern NSString * const key_MGJAdvImgLoader_UIImage_BlurTintColor;  // UIColor
extern NSString * const key_MGJAdvImgLoader_UIImage_BlurSaturationDeltaFactor;  // NSNumber
extern NSString * const key_MGJAdvImgLoader_UIImage_BlurMaskImage;  // UIImage

extern NSString * const MGJAdvImgLoaderErrorDomain;

@interface UIImage (MGJAdvancedImageLoader)

#pragma mark - customize
+ (instancetype)mgj_customizeImage:(UIImage *)image withParams:(NSDictionary *)paramsDic contentMode:(UIViewContentMode)contentMode;

+ (NSString *)mgj_layerContentsGravityFromViewContentMode:(UIViewContentMode)viewContentMode;

+ (NSString *)mgj_imageSignature:(NSDictionary *)dic;

#pragma mark - load local image
- (void)mgj_resize:(CGSize)newSize scale:(CGFloat)scale contentMode:(UIViewContentMode)contentMode completed:(MGJAdvImgLoaderLoadImageCompletionBlock)completion;
- (void)mgj_resize:(CGSize)newSize scale:(CGFloat)scale contentMode:(UIViewContentMode)contentMode cornerRadius:(CGFloat)cornerRadius completed:(MGJAdvImgLoaderLoadImageCompletionBlock)completion;
- (void)mgj_resize:(CGSize)newSize scale:(CGFloat)scale contentMode:(UIViewContentMode)contentMode borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor completed:(MGJAdvImgLoaderLoadImageCompletionBlock)completion;
- (void)mgj_resize:(CGSize)newSize scale:(CGFloat)scale contentMode:(UIViewContentMode)contentMode cornerRadius:(CGFloat)cornerRadius borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor completed:(MGJAdvImgLoaderLoadImageCompletionBlock)completion;
- (void)mgj_resize:(CGSize)newSize scale:(CGFloat)scale contentMode:(UIViewContentMode)contentMode applyBlurWithRadius:(CGFloat)radius tintColor:(UIColor *)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor maskImage:(UIImage *)maskImage completed:(MGJAdvImgLoaderLoadImageCompletionBlock)completion;

- (void)mgj_customize:(MGJAdvImgLoaderCustomizeBlock)customization contentMode:(UIViewContentMode)contentMode completed:(MGJAdvImgLoaderLoadImageCompletionBlock)completion;

@end
