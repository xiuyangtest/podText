//
//  UIImage+MGJAdvancedImageLoader.m
//  Example
//
//  Created by Derek Chen on 9/2/15.
//  Copyright (c) 2015 juangua. All rights reserved.
//

#import "UIImage+MGJAdvancedImageLoader.h"
#import <MGJFoundation.h>
#import <MGJUIKit.h>

NSString * const key_MGJAdvImgLoader_UIImage_ResizeWidth = @"key_MGJAdvImgLoader_UIImage_ResizeWidth";  // NSNumber
NSString * const key_MGJAdvImgLoader_UIImage_ResizeHeight = @"key_MGJAdvImgLoader_UIImage_ResizeHeight";  // NSNumber
NSString * const key_MGJAdvImgLoader_UIImage_ResizeScale = @"key_MGJAdvImgLoader_UIImage_ResizeScale";  // NSNumber
NSString * const key_MGJAdvImgLoader_UIImage_CornerRadius = @"key_MGJAdvImgLoader_UIImage_CornerRadius";  // NSNumber
NSString * const key_MGJAdvImgLoader_UIImage_BorderColor = @"key_MGJAdvImgLoader_UIImage_BorderColor";  // UIColor
NSString * const key_MGJAdvImgLoader_UIImage_BorderWidth = @"key_MGJAdvImgLoader_UIImage_BorderWidth";  // NSNumber
NSString * const key_MGJAdvImgLoader_UIImage_BlurEdgeInsets = @"key_MGJAdvImgLoader_UIImage_BlurEdgeInsets";  // DCHImageBlurRatioRect
NSString * const key_MGJAdvImgLoader_UIImage_BlurRadius = @"key_MGJAdvImgLoader_UIImage_BlurRadius";  // NSNumber
NSString * const key_MGJAdvImgLoader_UIImage_BlurTintColor = @"key_MGJAdvImgLoader_UIImage_BlurTintColor";  // UIColor
NSString * const key_MGJAdvImgLoader_UIImage_BlurSaturationDeltaFactor = @"key_MGJAdvImgLoader_UIImage_BlurSaturationDeltaFactor";  // NSNumber
NSString * const key_MGJAdvImgLoader_UIImage_BlurMaskImage = @"key_MGJAdvImgLoader_UIImage_BlurMaskImage";  // UIImage

NSString * const MGJAdvImgLoaderErrorDomain = @"MGJAdvImgLoaderErrorDomain";

@implementation UIImage (MGJAdvancedImageLoader)

+ (instancetype)mgj_customizeImage:(UIImage *)image withParams:(NSDictionary *)paramsDic contentMode:(UIViewContentMode)contentMode {
    if (MGJ_IS_EMPTY(image) || MGJ_IS_EMPTY(paramsDic)) {
        return nil;
    }
    UIImage *result = nil;
    NSNumber *resizeWidth = [paramsDic objectForKey:key_MGJAdvImgLoader_UIImage_ResizeWidth];
    NSNumber *resizeHeight = [paramsDic objectForKey:key_MGJAdvImgLoader_UIImage_ResizeHeight];
    NSNumber *resizeScale = [paramsDic objectForKey:key_MGJAdvImgLoader_UIImage_ResizeScale];
    
    NSNumber *cornerRadius = [paramsDic objectForKey:key_MGJAdvImgLoader_UIImage_CornerRadius];
    
    NSNumber *borderWidth = [paramsDic objectForKey:key_MGJAdvImgLoader_UIImage_BorderWidth];
    UIColor *borderColor = [paramsDic objectForKey:key_MGJAdvImgLoader_UIImage_BorderColor];
    
    NSValue *blurEdgeInsetsValue = [paramsDic objectForKey:key_MGJAdvImgLoader_UIImage_BlurEdgeInsets];
    NSNumber *blurRadius = [paramsDic objectForKey:key_MGJAdvImgLoader_UIImage_BlurRadius];
    UIColor *blurTintColor = [paramsDic objectForKey:key_MGJAdvImgLoader_UIImage_BlurTintColor];
    NSNumber *blurSaturationDeltaFactor = [paramsDic objectForKey:key_MGJAdvImgLoader_UIImage_BlurSaturationDeltaFactor];
    UIImage *blurMaskImage = [paramsDic objectForKey:key_MGJAdvImgLoader_UIImage_BlurMaskImage];
    
    CGSize targetSize = image.size;
    CGFloat scale = image.scale;
    
    // Resize
    if (!MGJ_IS_EMPTY(resizeWidth) && !MGJ_IS_EMPTY(resizeHeight) && !MGJ_IS_EMPTY(resizeScale)) {
        CGSize size = CGSizeMake(resizeWidth.floatValue, resizeHeight.floatValue);
        if (!CGSizeEqualToSize(size, CGSizeZero)) {
            targetSize = CGSizeMake(resizeWidth.floatValue, resizeHeight.floatValue);
            scale = resizeScale.floatValue;
        }
    }
    
    UIGraphicsBeginImageContextWithOptions(targetSize, NO, scale);
    CGContextRef context1 = UIGraphicsGetCurrentContext();
    CALayer *layer1 = [CALayer layer];
    layer1.frame = (CGRect){CGPointZero, targetSize};
    layer1.contentsGravity = [UIImage mgj_layerContentsGravityFromViewContentMode:contentMode];
    layer1.contents = (__bridge id)(image.CGImage);
    [layer1 renderInContext:context1];
    result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // Blur
    if (!MGJ_IS_EMPTY(blurRadius) && !MGJ_IS_EMPTY(blurSaturationDeltaFactor)) {
        if (MGJ_IS_EMPTY(blurEdgeInsetsValue)) {
            result = [result mgj_applyBlurWithRadius:blurRadius.floatValue tintColor:blurTintColor saturationDeltaFactor:blurSaturationDeltaFactor.floatValue maskImage:blurMaskImage];
        } else {
            UIEdgeInsets edgeInsets = [blurEdgeInsetsValue UIEdgeInsetsValue];
            result = [result mgj_applyBlurForEdgeInsets:edgeInsets withRadius:blurRadius.floatValue tintColor:blurTintColor saturationDeltaFactor:blurSaturationDeltaFactor.floatValue maskImage:blurMaskImage didCancel:nil];
        }
        
    }
    
    // Corner and Border
    UIGraphicsBeginImageContextWithOptions(targetSize, NO, scale);
    CGContextRef context2 = UIGraphicsGetCurrentContext();
    CALayer *layer2 = [CALayer layer];
    layer2.frame = (CGRect){CGPointZero, targetSize};
    layer2.contentsGravity = [UIImage mgj_layerContentsGravityFromViewContentMode:contentMode];
    layer2.contents = (__bridge id)(result.CGImage);
    if (!MGJ_IS_EMPTY(cornerRadius)) {
        layer2.cornerRadius = cornerRadius.floatValue;
    }
    if (!MGJ_IS_EMPTY(borderWidth) && !MGJ_IS_EMPTY(borderColor)) {
        layer2.borderWidth = borderWidth.floatValue;
        layer2.borderColor = borderColor.CGColor;
    }
    layer2.masksToBounds = YES;
    [layer2 renderInContext:context2];
    result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
}

+ (NSString *)mgj_layerContentsGravityFromViewContentMode:(UIViewContentMode)viewContentMode {
    NSString *result = kCAGravityResize;
    switch (viewContentMode) {
        case UIViewContentModeCenter: {
            result = kCAGravityCenter;
        }
            break;
        case UIViewContentModeTop: {
            result = kCAGravityTop;
        }
            break;
        case UIViewContentModeBottom: {
            result = kCAGravityBottom;
        }
            break;
        case UIViewContentModeLeft: {
            result = kCAGravityLeft;
        }
            break;
        case UIViewContentModeRight: {
            result = kCAGravityRight;
        }
            break;
        case UIViewContentModeTopLeft: {
            result = kCAGravityTopLeft;
        }
            break;
        case UIViewContentModeTopRight: {
            result = kCAGravityRight;
        }
            break;
        case UIViewContentModeBottomLeft:
            result = kCAGravityBottomLeft;
            break;
        case UIViewContentModeBottomRight: {
            result = kCAGravityBottomRight;
        }
            break;
        case UIViewContentModeScaleAspectFit: {
            result = kCAGravityResizeAspect;
        }
            break;
        case UIViewContentModeScaleAspectFill: {
            result = kCAGravityResizeAspectFill;
        }
            break;
        case UIViewContentModeScaleToFill:
        default: {
            result = kCAGravityResize;
        }
            break;
    }
    return result;
}

+ (NSString *)mgj_imageSignature:(NSDictionary *)dic {
    if (MGJ_IS_EMPTY(dic)) {
        return nil;
    }
    
    NSMutableString *tmp = [NSMutableString string];
    NSNumber *resizeWidth = [dic objectForKey:key_MGJAdvImgLoader_UIImage_ResizeWidth];
    NSNumber *resizeHeight = [dic objectForKey:key_MGJAdvImgLoader_UIImage_ResizeHeight];
    NSNumber *resizeScale = [dic objectForKey:key_MGJAdvImgLoader_UIImage_ResizeScale];
    if (resizeWidth && resizeHeight && resizeScale) {
        [tmp appendFormat:@"ResizeW%fH%fS%f", [resizeWidth floatValue], [resizeHeight floatValue], [resizeScale floatValue]];
    }
    
    NSNumber *cornerRadius = [dic objectForKey:key_MGJAdvImgLoader_UIImage_CornerRadius];
    if (cornerRadius) {
        [tmp appendFormat:@"CornerRadius%f", [cornerRadius floatValue]];
    }
    
    UIColor *borderColor = [dic objectForKey:key_MGJAdvImgLoader_UIImage_BorderColor];
    NSNumber *borderWidth = [dic objectForKey:key_MGJAdvImgLoader_UIImage_BorderWidth];
    if (borderColor && borderWidth) {
        CGFloat components[4] = {0.0, 0.0, 0.0, 0.0};
        [borderColor getRed:&components[0] green:&components[1] blue:&components[2] alpha:&components[3]];
        [tmp appendFormat:@"BorderColorR%fG:%fB:%fA:%fWidth%f", components[0], components[1], components[2], components[3], [borderWidth floatValue]];
    }
    
    NSValue *blurEdgeInsetsValue = [dic objectForKey:key_MGJAdvImgLoader_UIImage_BlurEdgeInsets];
    UIColor *blurTintColor = [dic objectForKey:key_MGJAdvImgLoader_UIImage_BlurTintColor];
    NSNumber *blurRadius = [dic objectForKey:key_MGJAdvImgLoader_UIImage_BlurRadius];
    NSNumber *blurSaturationDeltaFactor = [dic objectForKey:key_MGJAdvImgLoader_UIImage_BlurSaturationDeltaFactor];
    NSUInteger blurMaskImageHash = [[dic objectForKey:key_MGJAdvImgLoader_UIImage_BlurMaskImage] hash];
    if (blurRadius && blurSaturationDeltaFactor) {
        [tmp appendFormat:@"BlurRadius%fSaturationDeltaFactor%fMaskImageHash%lu", [blurRadius floatValue], [blurSaturationDeltaFactor floatValue], (unsigned long)blurMaskImageHash];
        if (blurTintColor) {
            CGFloat components[4] = {0.0, 0.0, 0.0, 0.0};
            [blurTintColor getRed:&components[0] green:&components[1] blue:&components[2] alpha:&components[3]];
            [tmp appendFormat:@"ColorR%fG:%fB:%fA:%f", components[0], components[1], components[2], components[3]];
        }
        if (blurEdgeInsetsValue) {
            UIEdgeInsets edgeInsets = [blurEdgeInsetsValue UIEdgeInsetsValue];
            [tmp appendFormat:@"RatioRectT%fB%fL%fR%f", edgeInsets.top, edgeInsets.bottom, edgeInsets.left, edgeInsets.right];
        }
    }
    
    return [tmp mgj_md5HashString];
}

- (void)mgj_resize:(CGSize)newSize scale:(CGFloat)scale contentMode:(UIViewContentMode)contentMode completed:(MGJAdvImgLoaderLoadImageCompletionBlock)completion {
    [self mgj_customize:^NSDictionary *{
        NSMutableDictionary *result = [NSMutableDictionary dictionary];
        [result setObject:@(newSize.width) forKey:key_MGJAdvImgLoader_UIImage_ResizeWidth];
        [result setObject:@(newSize.height) forKey:key_MGJAdvImgLoader_UIImage_ResizeHeight];
        [result setObject:@(scale) forKey:key_MGJAdvImgLoader_UIImage_ResizeScale];
        return result;
    } contentMode:contentMode completed:completion];
}

- (void)mgj_resize:(CGSize)newSize scale:(CGFloat)scale contentMode:(UIViewContentMode)contentMode cornerRadius:(CGFloat)cornerRadius completed:(MGJAdvImgLoaderLoadImageCompletionBlock)completion {
    [self mgj_customize:^NSDictionary *{
        NSMutableDictionary *result = [NSMutableDictionary dictionary];
        [result setObject:@(newSize.width) forKey:key_MGJAdvImgLoader_UIImage_ResizeWidth];
        [result setObject:@(newSize.height) forKey:key_MGJAdvImgLoader_UIImage_ResizeHeight];
        [result setObject:@(scale) forKey:key_MGJAdvImgLoader_UIImage_ResizeScale];
        [result setObject:@(cornerRadius) forKey:key_MGJAdvImgLoader_UIImage_CornerRadius];
        return result;
    } contentMode:contentMode completed:completion];
}

- (void)mgj_resize:(CGSize)newSize scale:(CGFloat)scale contentMode:(UIViewContentMode)contentMode borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor completed:(MGJAdvImgLoaderLoadImageCompletionBlock)completion {
    [self mgj_customize:^NSDictionary *{
        NSMutableDictionary *result = [NSMutableDictionary dictionary];
        [result setObject:@(newSize.width) forKey:key_MGJAdvImgLoader_UIImage_ResizeWidth];
        [result setObject:@(newSize.height) forKey:key_MGJAdvImgLoader_UIImage_ResizeHeight];
        [result setObject:@(scale) forKey:key_MGJAdvImgLoader_UIImage_ResizeScale];
        [result setObject:@(borderWidth) forKey:key_MGJAdvImgLoader_UIImage_BorderWidth];
        [result setObject:borderColor forKey:key_MGJAdvImgLoader_UIImage_BorderColor];
        return result;
    } contentMode:contentMode completed:completion];
}

- (void)mgj_resize:(CGSize)newSize scale:(CGFloat)scale contentMode:(UIViewContentMode)contentMode cornerRadius:(CGFloat)cornerRadius borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor completed:(MGJAdvImgLoaderLoadImageCompletionBlock)completion {
    [self mgj_customize:^NSDictionary *{
        NSMutableDictionary *result = [NSMutableDictionary dictionary];
        [result setObject:@(newSize.width) forKey:key_MGJAdvImgLoader_UIImage_ResizeWidth];
        [result setObject:@(newSize.height) forKey:key_MGJAdvImgLoader_UIImage_ResizeHeight];
        [result setObject:@(scale) forKey:key_MGJAdvImgLoader_UIImage_ResizeScale];
        [result setObject:@(cornerRadius) forKey:key_MGJAdvImgLoader_UIImage_CornerRadius];
        [result setObject:@(borderWidth) forKey:key_MGJAdvImgLoader_UIImage_BorderWidth];
        [result setObject:borderColor forKey:key_MGJAdvImgLoader_UIImage_BorderColor];
        return result;
    } contentMode:contentMode completed:completion];
}

- (void)mgj_resize:(CGSize)newSize scale:(CGFloat)scale contentMode:(UIViewContentMode)contentMode applyBlurWithRadius:(CGFloat)radius tintColor:(UIColor *)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor maskImage:(UIImage *)maskImage completed:(MGJAdvImgLoaderLoadImageCompletionBlock)completion {
    [self mgj_customize:^NSDictionary *{
        NSMutableDictionary *result = [NSMutableDictionary dictionary];
        [result setObject:@(newSize.width) forKey:key_MGJAdvImgLoader_UIImage_ResizeWidth];
        [result setObject:@(newSize.height) forKey:key_MGJAdvImgLoader_UIImage_ResizeHeight];
        [result setObject:@(scale) forKey:key_MGJAdvImgLoader_UIImage_ResizeScale];
        [result setObject:@(radius) forKey:key_MGJAdvImgLoader_UIImage_BlurRadius];
        [result setObject:tintColor forKey:key_MGJAdvImgLoader_UIImage_BlurTintColor];
        [result setObject:@(saturationDeltaFactor) forKey:key_MGJAdvImgLoader_UIImage_BlurSaturationDeltaFactor];
        [result setObject:maskImage forKey:key_MGJAdvImgLoader_UIImage_BlurMaskImage];
        return result;
    } contentMode:contentMode completed:completion];
}

- (void)mgj_customize:(MGJAdvImgLoaderCustomizeBlock)customization contentMode:(UIViewContentMode)contentMode completed:(MGJAdvImgLoaderLoadImageCompletionBlock)completion {
    NSError *error = [NSError errorWithDomain:MGJAdvImgLoaderErrorDomain code:(-1003) userInfo:@{NSLocalizedDescriptionKey : @"Param error"}];
    if (!customization || !completion) {
        if (completion) {
            completion(nil, error, nil, nil, SDImageCacheTypeNone);
        }
        return ;
    } else {
        @weakify(self);
        [NSThread runInBackground:^{
            @strongify(self);
            if (customization) {
                NSDictionary *params = customization();
                UIImage *result = [UIImage mgj_customizeImage:self withParams:params contentMode:contentMode];
                if (completion) {
                    completion(result, nil, nil, nil, SDImageCacheTypeNone);
                }
            } else {
                if (completion) {
                    completion(nil, error, nil, nil, SDImageCacheTypeNone);
                }
            }
        }];
    }
}

@end
