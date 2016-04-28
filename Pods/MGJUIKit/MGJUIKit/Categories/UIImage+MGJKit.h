//
//  UIImage+MGJKit.h
//  MGJFoundation
//
//  Created by limboy on 12/3/14.
//  Copyright (c) 2014 juangua. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (MGJKit)

/**
 *  根据颜色生成图像
 */
+ (instancetype)mgj_imageWithSolidColor:(UIColor *)color size:(CGSize)size;

+ (instancetype)mgj_imageNamed:(NSString *)imageName;

+ (instancetype)mgj_imageNamed:(NSString *)imageName inLibrary:(NSString *)libraryName;

- (UIImage *)resizeToSize:(CGSize)newSize contentMode:(UIViewContentMode)contentMode;

#pragma UIImage Swizzing to fix iOS9 stupid BUG
+ (void)mgj_swizzleUIImageWithImageNamed;


#pragma mark - Decode
- (UIImage *)mgj_decodedImage;

#pragma mark - Resize
- (instancetype)mgj_applyResizeToSize:(CGSize)newSize withContentMode:(UIViewContentMode)contentMode;

#pragma mark - Corner Radius

- (UIImage *)mgj_imageWithCornerRadius:(CGSize)fitSize radius:(CGFloat)radius contentMode:(UIViewContentMode)contentMode;

#pragma mark - Blur
- (instancetype)mgj_applyBlurWithRadius:(CGFloat)blurRadius tintColor:(UIColor *)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor maskImage:(UIImage *)maskImage;

- (instancetype)mgj_applyBlurWithRadius:(CGFloat)blurRadius tintColor:(UIColor *)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor maskImage:(UIImage *)maskImage didCancel:(BOOL (^)())didCancel;

- (instancetype)mgj_applyBlurForEdgeInsets:(UIEdgeInsets)edgeInsets withRadius:(CGFloat)blurRadius tintColor:(UIColor *)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor maskImage:(UIImage *)maskImage didCancel:(BOOL (^)())didCancel;

- (instancetype)mgj_applyGaussianBlurWithRadius:(CGFloat)blurRadius;

- (UIImage *)mgj_blurredImageWithRadius:(CGFloat)radius iterations:(NSUInteger)iterations tintColor:(UIColor *)tintColor;

/**
 * 添加图片水印
 */
- (UIImage *)mgj_applyWaterMarkWithImage:(UIImage*)image;


- (UIImage *)mgj_applyWaterMarkWithText:(NSString *)text;
@end
