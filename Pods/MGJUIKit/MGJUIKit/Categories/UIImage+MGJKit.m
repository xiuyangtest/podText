//
//  UIImage+MGJKit.m
//  MGJFoundation
//
//  Created by limboy on 12/3/14.
//  Copyright (c) 2014 juangua. All rights reserved.
//

#import "UIImage+MGJKit.h"
#import <objc/runtime.h>
#import <MGJMacros.h>
#import "NSString+MGJKit.h"
#import <Accelerate/Accelerate.h>

static BOOL hasSwizzled = NO;

@implementation UIImage (MGJKit)

+ (instancetype)mgj_imageWithSolidColor:(UIColor *)color size:(CGSize)size
{
    NSParameterAssert(color);
    NSAssert(!CGSizeEqualToSize(size, CGSizeZero), @"Size cannot be CGSizeZero");
    
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    
    // Create a context depending on given size
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    
    // Fill it with your color
    [color setFill];
    UIRectFill(rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (void)mgj_swizzleUIImageWithImageNamed {
    if(SYSTEM_VERSION_LESS_THAN(@"9")){
        return;
    }
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method originMethod = class_getClassMethod(self, @selector(imageNamed:));
        Method newMethod = class_getClassMethod(self, @selector(mgj_imageNamed:));
        method_exchangeImplementations(originMethod, newMethod);
    });
}

+(instancetype) mgj_imageNamed:(NSString *)imageName{
    return [self mgj_imageNamed:imageName inLibrary:nil];
}

+ (instancetype)mgj_imageNamed:(NSString *)imageName inLibrary:(NSString *)libraryName {
    id result = nil;
    
    if([UIImage respondsToSelector:@selector(imageNamed:inBundle:compatibleWithTraitCollection:)]){
        if(!MGJ_IS_EMPTY(libraryName)){
            imageName = [NSString stringWithFormat:@"%@.bundle/%@", libraryName, imageName];
        }
        result = [UIImage imageNamed:imageName inBundle:nil compatibleWithTraitCollection:nil];
    }
    else{
        if (!MGJ_IS_EMPTY(imageName)) {
            if (MGJ_IS_EMPTY(libraryName)) {
                result = [self imageNamed:imageName];
            } else {
#ifdef MGJBOUNDLESUPPORT_DISABLE
                result = [self imageNamed:imageName];
#else
                result = [self imageNamed:[NSString stringWithFormat:@"%@.bundle/%@", libraryName, imageName]];
#endif
            }
        }
    }
    return result;
}

- (UIImage *)resizeToSize:(CGSize)newSize contentMode:(UIViewContentMode)contentMode
{
    if (CGSizeEqualToSize(newSize, CGSizeZero)) {
        return nil;
    }
    
    CGFloat x = 0;
    CGFloat y = 0;
    CGFloat width = self.size.width;
    CGFloat height = self.size.height;
    CGFloat screenScale = [UIScreen mainScreen].scale;
    CGFloat contextWidth = newSize.width * screenScale;
    CGFloat contextHeight = newSize.height * screenScale;
    
    switch (contentMode) {
        case UIViewContentModeCenter:
        {
            x = (newSize.width - width) / 2;
            y = (newSize.height - height) / 2;
        }
            break;
        case UIViewContentModeTop:
        {
            x = (newSize.width - width) / 2;
            y = (newSize.height - height);
        }
            break;
        case UIViewContentModeBottom:
        {
            x = (newSize.width - width) / 2;
        }
            break;
        case UIViewContentModeLeft:
        {
            y = (newSize.height - height) / 2;
        }
            break;
        case UIViewContentModeRight:
        {
            x = (newSize.width - width);
            y = (newSize.height - height) / 2;;
        }
            break;
        case UIViewContentModeTopLeft:
        {
            y = (newSize.height - height);
        }
            break;
        case UIViewContentModeTopRight:
        {
            x = (newSize.width - width);
            y = (newSize.height - height);
        }
            break;
        case UIViewContentModeBottomLeft:
            break;
        case UIViewContentModeBottomRight:
        {
            x = (newSize.width - width);
        }
            break;
        case UIViewContentModeScaleAspectFit:
        {
            CGFloat widthRatio = newSize.width / width;
            CGFloat heightRatio = newSize.height / height;
            CGFloat ratio = MIN(widthRatio, heightRatio);
            
            width = width * ratio;
            height = height * ratio;
            x = (newSize.width - width) / 2;
            y = (newSize.height - height) / 2;
        }
            break;
        case UIViewContentModeScaleAspectFill:
        {
            CGFloat widthRatio = newSize.width / width;
            CGFloat heightRatio = newSize.height / height;
            CGFloat ratio = MAX(widthRatio, heightRatio);
            
            width = width * ratio;
            height = height * ratio;
            x = (newSize.width - width) / 2;
            y = (newSize.height - height) / 2;
        }
            break;
        case UIViewContentModeScaleToFill:
        default:
        {
            width = newSize.width;
            height = newSize.height;
        }
            break;
    }
    
    
    CGColorSpaceRef colourSpace = CGColorSpaceCreateDeviceRGB();
    
    //这里 context 大小为像素大小
    CGContextRef bitmapContext = CGBitmapContextCreate(NULL, contextWidth, contextHeight, 8, 0, colourSpace, kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrderDefault);
    CGColorSpaceRelease(colourSpace);
    
    CGContextSetShouldAntialias(bitmapContext, true);
    CGContextSetAllowsAntialiasing(bitmapContext, true);
    CGContextSetInterpolationQuality(bitmapContext, kCGInterpolationHigh);
    
    //之前计算都是用 pt，绘制时要转成 px
    CGContextDrawImage(bitmapContext, CGRectMake(x * screenScale, y * screenScale, width * screenScale, height * screenScale), self.CGImage);
    
    CGImageRef scaledImageRef = CGBitmapContextCreateImage(bitmapContext);
    UIImage *resizedImage = [UIImage imageWithCGImage:scaledImageRef scale:screenScale orientation:self.imageOrientation];
    
    CGImageRelease(scaledImageRef);
    CGContextRelease(bitmapContext);
    
    return resizedImage;
}

- (instancetype)mgj_decodedImage {
    UIImage *result = nil;
    CGColorSpaceRef colorSpace = NULL;
    CGContextRef context = NULL;
    CGImageRef decompressedImageRef = NULL;
    
    if (self.images) {
        // Do not decode animated images
        result = self;
        return result;
    }
    
    CGImageRef imageRef = self.CGImage;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imageRef), CGImageGetHeight(imageRef));
    CGRect imageRect = (CGRect){.origin = CGPointZero, .size = imageSize};
    
    colorSpace = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
    
    int infoMask = (bitmapInfo & kCGBitmapAlphaInfoMask);
    BOOL anyNonAlpha = (infoMask == kCGImageAlphaNone || infoMask == kCGImageAlphaNoneSkipFirst || infoMask == kCGImageAlphaNoneSkipLast);
    
    // CGBitmapContextCreate doesn't support kCGImageAlphaNone with RGB.
    // https://developer.apple.com/library/mac/#qa/qa1037/_index.html
    if (infoMask == kCGImageAlphaNone && CGColorSpaceGetNumberOfComponents(colorSpace) > 1) {
        // Unset the old alpha info.
        bitmapInfo &= ~kCGBitmapAlphaInfoMask;
        
        // Set noneSkipFirst.
        bitmapInfo |= kCGImageAlphaNoneSkipFirst;
    }
    // Some PNGs tell us they have alpha but only 3 components. Odd.
    else if (!anyNonAlpha && CGColorSpaceGetNumberOfComponents(colorSpace) == 3) {
        // Unset the old alpha info.
        bitmapInfo &= ~kCGBitmapAlphaInfoMask;
        bitmapInfo |= kCGImageAlphaPremultipliedFirst;
    }
    
    context = CGBitmapContextCreate(NULL, imageSize.width, imageSize.height, CGImageGetBitsPerComponent(imageRef), 0, colorSpace, bitmapInfo);
    
    if (!context) {
        result = self;
        
        if (colorSpace) {
            CGColorSpaceRelease(colorSpace);
            colorSpace = NULL;
        }
        
        return result;
    }
    
    CGContextDrawImage(context, imageRect, imageRef);
    decompressedImageRef = CGBitmapContextCreateImage(context);
    
    result = [UIImage imageWithCGImage:decompressedImageRef scale:self.scale orientation:self.imageOrientation];
    
    if (colorSpace) {
        CGColorSpaceRelease(colorSpace);
        colorSpace = NULL;
    }
    if (context) {
        CGContextRelease(context);
        context = NULL;
    }
    if (decompressedImageRef) {
        CGImageRelease(decompressedImageRef);
        decompressedImageRef = NULL;
    }
    
    return result;
}

- (UIImage *)mgj_imageWithCornerRadius:(CGSize)fitSize radius:(CGFloat)radius contentMode:(UIViewContentMode)contentMode {

    CGRect scaledImageRect = CGRectZero;

    //Keep fucking aspect fill
    CGFloat aspectWidth = fitSize.width / self.size.width;
    CGFloat aspectHeight = fitSize.height / self.size.height;
    CGFloat aspectRatio = (contentMode == UIViewContentModeScaleAspectFill) ?
            MAX (aspectWidth, aspectHeight) :
            MIN(aspectWidth, aspectHeight);

    scaledImageRect.size.width = self.size.width * aspectRatio;
    scaledImageRect.size.height = self.size.height * aspectRatio;
    scaledImageRect.origin.x = (fitSize.width - scaledImageRect.size.width) / 2.0f;
    scaledImageRect.origin.y = (fitSize.height - scaledImageRect.size.height) / 2.0f;

    UIGraphicsBeginImageContextWithOptions(fitSize, NO, 0);

    CGContextAddPath(UIGraphicsGetCurrentContext(),
            [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, fitSize.width, fitSize.height) cornerRadius:radius].CGPath);
    CGContextClip(UIGraphicsGetCurrentContext());
    [self drawInRect:scaledImageRect];
    UIImage *output = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return output;
}


- (instancetype)mgj_applyResizeToSize:(CGSize)newSize withContentMode:(UIViewContentMode)contentMode {
    UIImage *result = nil;
    CGContextRef bitmapContext = nil;
    CGImageRef scaledImageRef = nil;
    CGColorSpaceRef colourSpace = nil;
    
    result = self;
    if (CGSizeEqualToSize(newSize, CGSizeZero)) {
        return result;
    }
    
    CGFloat pxLocX = 0;
    CGFloat pxLocY = 0;
    CGFloat pxOldWidth = self.size.width * self.scale;
    CGFloat pxOldHeight = self.size.height * self.scale;
    CGFloat screenScale = [UIScreen mainScreen].scale;
    CGFloat pxNewWidth = newSize.width * screenScale;
    CGFloat pxNewHeight = newSize.height * screenScale;
    
    if (pxNewWidth > pxOldWidth && pxNewHeight > pxOldHeight) {
        return result;
    }
    
    switch (contentMode) {
        case UIViewContentModeCenter: {
            pxLocX = (pxNewWidth - pxOldWidth) / 2;
            pxLocY = (pxNewHeight - pxOldHeight) / 2;
        }
            break;
        case UIViewContentModeTop: {
            pxLocX = (pxNewWidth - pxOldWidth) / 2;
            pxLocY = (pxNewHeight - pxOldHeight);
        }
            break;
        case UIViewContentModeBottom: {
            pxLocX = (pxNewWidth - pxOldWidth) / 2;
        }
            break;
        case UIViewContentModeLeft: {
            pxLocY = (pxNewHeight - pxOldHeight) / 2;
        }
            break;
        case UIViewContentModeRight: {
            pxLocX = (pxNewWidth - pxOldWidth);
            pxLocY = (pxNewHeight - pxOldHeight) / 2;
        }
            break;
        case UIViewContentModeTopLeft: {
            pxLocY = (pxNewHeight - pxOldHeight);
        }
            break;
        case UIViewContentModeTopRight: {
            pxLocX = (pxNewWidth - pxOldWidth);
            pxLocY = (pxNewHeight - pxOldHeight);
        }
            break;
        case UIViewContentModeBottomLeft:
            break;
        case UIViewContentModeBottomRight: {
            pxLocX = (pxNewWidth - pxOldWidth);
        }
            break;
        case UIViewContentModeScaleAspectFit: {
            CGFloat ratio = MIN((pxNewWidth / pxOldWidth), (pxNewHeight / pxOldHeight));
            pxOldWidth *= ratio;
            pxOldHeight *= ratio;
            pxLocX = (pxNewWidth - pxOldWidth) / 2;
            pxLocY = (pxNewHeight - pxOldHeight) / 2;
        }
            break;
        case UIViewContentModeScaleAspectFill: {
            CGFloat ratio = MAX((pxNewWidth / pxOldWidth), (pxNewHeight / pxOldHeight));
            pxOldWidth *= ratio;
            pxOldHeight *= ratio;
            pxLocX = (pxNewWidth - pxOldWidth) / 2;
            pxLocY = (pxNewHeight - pxOldHeight) / 2;
        }
            break;
        case UIViewContentModeScaleToFill:
        default: {
            pxOldWidth = pxNewWidth;
            pxOldHeight = pxNewHeight;
        }
            break;
    }
    
    colourSpace = CGColorSpaceCreateDeviceRGB();
    
    const CGBitmapInfo originalBitmapInfo = CGImageGetBitmapInfo(self.CGImage);
    
    // See: http://stackoverflow.com/questions/23723564/which-cgimagealphainfo-should-we-use
    const uint32_t alphaInfo = (originalBitmapInfo & kCGBitmapAlphaInfoMask);
    CGBitmapInfo bitmapInfo = originalBitmapInfo;
    BOOL unsupported = NO;
    switch (alphaInfo) {
        case kCGImageAlphaNone: {
            bitmapInfo &= ~kCGBitmapAlphaInfoMask;
            bitmapInfo |= kCGImageAlphaNoneSkipFirst;
        }
            break;
        case kCGImageAlphaPremultipliedFirst:
        case kCGImageAlphaPremultipliedLast:
        case kCGImageAlphaNoneSkipFirst:
        case kCGImageAlphaNoneSkipLast:
            break;
        case kCGImageAlphaOnly:
        case kCGImageAlphaLast:
        case kCGImageAlphaFirst: { // Unsupported
            unsupported = YES;
        }
            break;
    }
    
    if (unsupported) {
        if (colourSpace) {
            CGColorSpaceRelease(colourSpace);
            colourSpace = nil;
        }
        return result;
    }
    
    bitmapContext = CGBitmapContextCreate(NULL, pxNewWidth, pxNewHeight, CGImageGetBitsPerComponent(self.CGImage), 0, colourSpace, bitmapInfo);
    
    CGContextSetShouldAntialias(bitmapContext, true);
    CGContextSetAllowsAntialiasing(bitmapContext, true);
    CGContextSetInterpolationQuality(bitmapContext, kCGInterpolationHigh);
    
    CGContextDrawImage(bitmapContext, CGRectMake(pxLocX, pxLocY, pxOldWidth, pxOldHeight), self.CGImage);
    
    scaledImageRef = CGBitmapContextCreateImage(bitmapContext);
    result = [UIImage imageWithCGImage:scaledImageRef scale:screenScale orientation:self.imageOrientation];
    
    if (colourSpace) {
        CGColorSpaceRelease(colourSpace);
        colourSpace = nil;
    }
    if (scaledImageRef) {
        CGImageRelease(scaledImageRef);
        scaledImageRef = nil;
    }
    if (bitmapContext) {
        CGContextRelease(bitmapContext);
        bitmapContext = nil;
    }
    
    return result;
}

- (instancetype)mgj_applyBlurWithRadius:(CGFloat)blurRadius tintColor:(UIColor *)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor maskImage:(UIImage *)maskImage {
    return [self mgj_applyBlurWithRadius:blurRadius tintColor:tintColor saturationDeltaFactor:saturationDeltaFactor maskImage:maskImage didCancel:^BOOL{ return NO; }];
}

- (instancetype)mgj_applyBlurWithRadius:(CGFloat)blurRadius tintColor:(UIColor *)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor maskImage:(UIImage *)maskImage didCancel:(BOOL (^)())didCancel {
    UIEdgeInsets edgeInsets = UIEdgeInsetsMake(0, 0, 1, 1);
    return [self mgj_applyBlurForEdgeInsets:edgeInsets withRadius:blurRadius tintColor:tintColor saturationDeltaFactor:saturationDeltaFactor maskImage:maskImage didCancel:didCancel];
}

- (instancetype)mgj_applyBlurForEdgeInsets:(UIEdgeInsets)edgeInsets withRadius:(CGFloat)blurRadius tintColor:(UIColor *)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor maskImage:(UIImage *)maskImage didCancel:(BOOL (^)())didCancel {
    UIImage *result = nil;
    if (!self.CGImage || self.size.width < 1 || self.size.height < 1) {
        return result;
    }
    
    @autoreleasepool {
        CGRect imageRect = {CGPointZero, self.size};
        CGPoint imageBlurOrigin = CGPointMake(edgeInsets.left, edgeInsets.bottom);
        imageBlurOrigin.x = MAX(imageBlurOrigin.x, 0);
        imageBlurOrigin.y = MAX(imageBlurOrigin.y, 0);
        imageBlurOrigin.x = MIN(imageBlurOrigin.x, imageRect.size.width);
        imageBlurOrigin.y = MIN(imageBlurOrigin.y, imageRect.size.height);
        
        CGSize imageBlurSize = CGSizeMake(self.size.width - edgeInsets.right - imageBlurOrigin.x, self.size.height - edgeInsets.top - imageBlurOrigin.y);
        imageBlurSize.width = MAX(imageBlurSize.width, 0);
        imageBlurSize.height = MAX(imageBlurSize.height, 0);;
        
        CGRect imageBlurRect = {imageBlurOrigin, imageBlurSize};
        
        UIImage *effectImage = self;
        
        BOOL hasBlur = blurRadius > __FLT_EPSILON__;
        BOOL hasSaturationChange = fabs(saturationDeltaFactor - 1.) > __FLT_EPSILON__;
        
        if (hasBlur || hasSaturationChange) {
            UIGraphicsBeginImageContextWithOptions(imageBlurRect.size, NO, [[UIScreen mainScreen] scale]);
            CGContextRef effectInContext = UIGraphicsGetCurrentContext();
            CGContextScaleCTM(effectInContext, 1.0, -1.0);
            CGContextTranslateCTM(effectInContext, 0, -imageBlurRect.size.height);
            CGContextDrawImage(effectInContext, imageRect, self.CGImage);
            vImage_Buffer effectInBuffer;
            effectInBuffer.data     = CGBitmapContextGetData(effectInContext);
            effectInBuffer.width    = CGBitmapContextGetWidth(effectInContext);
            effectInBuffer.height   = CGBitmapContextGetHeight(effectInContext);
            effectInBuffer.rowBytes = CGBitmapContextGetBytesPerRow(effectInContext);
            
            UIGraphicsBeginImageContextWithOptions(imageBlurRect.size, NO, [[UIScreen mainScreen] scale]);
            CGContextRef effectOutContext = UIGraphicsGetCurrentContext();
            vImage_Buffer effectOutBuffer;
            effectOutBuffer.data     = CGBitmapContextGetData(effectOutContext);
            effectOutBuffer.width    = CGBitmapContextGetWidth(effectOutContext);
            effectOutBuffer.height   = CGBitmapContextGetHeight(effectOutContext);
            effectOutBuffer.rowBytes = CGBitmapContextGetBytesPerRow(effectOutContext);
            
            
            if (hasBlur) {
                // A description of how to compute the box kernel width from the Gaussian
                // radius (aka standard deviation) appears in the SVG spec:
                // http://www.w3.org/TR/SVG/filters.html#feGaussianBlurElement
                //
                // For larger values of 's' (s >= 2.0), an approximation can be used: Three
                // successive box-blurs build a piece-wise quadratic convolution kernel, which
                // approximates the Gaussian kernel to within roughly 3%.
                //
                // let d = floor(s * 3*sqrt(2*pi)/4 + 0.5)
                //
                // ... if d is odd, use three box-blurs of size 'd', centered on the output pixel.
                //
                CGFloat inputRadius = blurRadius * [[UIScreen mainScreen] scale];
                uint32_t radius = floor(inputRadius * 3. * sqrt(2 * M_PI) / 4 + 0.5);
                if (radius % 2 != 1) {
                    radius += 1; // force radius to be odd so that the three box-blur methodology works.
                }
                
                if (!MGJ_IS_EMPTY(didCancel) && didCancel()) {
                    UIGraphicsEndImageContext();
                    return result;
                }
                
                vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, NULL, 0, 0, radius, radius, 0, kvImageEdgeExtend);
                
                if (!MGJ_IS_EMPTY(didCancel) && didCancel()) {
                    UIGraphicsEndImageContext();
                    return result;
                }
                
                vImageBoxConvolve_ARGB8888(&effectOutBuffer, &effectInBuffer, NULL, 0, 0, radius, radius, 0, kvImageEdgeExtend);
                
                if (!MGJ_IS_EMPTY(didCancel) && didCancel()) {
                    UIGraphicsEndImageContext();
                    return result;
                }
                
                vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, NULL, 0, 0, radius, radius, 0, kvImageEdgeExtend);
            }
            
            if (!MGJ_IS_EMPTY(didCancel) && didCancel()) {
                UIGraphicsEndImageContext();
                return result;
            }
            
            
            BOOL effectImageBuffersAreSwapped = NO;
            if (hasSaturationChange) {
                CGFloat s = saturationDeltaFactor;
                CGFloat floatingPointSaturationMatrix[] = {
                    0.0722 + 0.9278 * s,  0.0722 - 0.0722 * s,  0.0722 - 0.0722 * s,  0,
                    0.7152 - 0.7152 * s,  0.7152 + 0.2848 * s,  0.7152 - 0.7152 * s,  0,
                    0.2126 - 0.2126 * s,  0.2126 - 0.2126 * s,  0.2126 + 0.7873 * s,  0,
                    0,                    0,                    0,  1,
                };
                const int32_t divisor = 256;
                NSUInteger matrixSize = sizeof(floatingPointSaturationMatrix)/sizeof(floatingPointSaturationMatrix[0]);
                int16_t saturationMatrix[matrixSize];
                for (NSUInteger i = 0; i < matrixSize; ++i) {
                    saturationMatrix[i] = (int16_t)roundf(floatingPointSaturationMatrix[i] * divisor);
                }
                if (hasBlur) {
                    vImageMatrixMultiply_ARGB8888(&effectOutBuffer, &effectInBuffer, saturationMatrix, divisor, NULL, NULL, kvImageNoFlags);
                    effectImageBuffersAreSwapped = YES;
                } else {
                    vImageMatrixMultiply_ARGB8888(&effectInBuffer, &effectOutBuffer, saturationMatrix, divisor, NULL, NULL, kvImageNoFlags);
                }
            }
            if (!effectImageBuffersAreSwapped) {
                effectImage = UIGraphicsGetImageFromCurrentImageContext();
            }
            UIGraphicsEndImageContext();
        }
        
        // Set up output context.
        UIGraphicsBeginImageContextWithOptions(self.size, NO, [[UIScreen mainScreen] scale]);
        CGContextRef outputContext = UIGraphicsGetCurrentContext();
        CGContextScaleCTM(outputContext, 1.0, -1.0);
        CGContextTranslateCTM(outputContext, 0, -self.size.height);
        
        // Draw base image.
        CGContextDrawImage(outputContext, imageRect, self.CGImage);
        
        // Draw effect image.
        if (hasBlur) {
            CGContextSaveGState(outputContext);
            if (maskImage) {
                CGContextClipToMask(outputContext, imageRect, maskImage.CGImage);
            }
            CGContextDrawImage(outputContext, imageBlurRect, effectImage.CGImage);
            CGContextRestoreGState(outputContext);
        }
        
        // Add in color tint.
        if (tintColor) {
            CGContextSaveGState(outputContext);
            CGContextSetFillColorWithColor(outputContext, tintColor.CGColor);
            CGContextFillRect(outputContext, imageBlurRect);
            CGContextRestoreGState(outputContext);
        }
        
        // Output image is ready.
        result = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return result;
}

- (instancetype)mgj_applyGaussianBlurWithRadius:(CGFloat)blurRadius {
    CIContext *ciContent = [CIContext contextWithOptions:nil];
    CIImage *ciImage = [CIImage imageWithCGImage:self.CGImage];
    CIFilter *ciGaussianBlurFilter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [ciGaussianBlurFilter setValue:ciImage forKey:kCIInputImageKey];
    [ciGaussianBlurFilter setValue:@(blurRadius) forKey:kCIInputRadiusKey];
    CGImageRef cgImage = [ciContent createCGImage:ciGaussianBlurFilter.outputImage fromRect:ciImage.extent];
    return [UIImage imageWithCGImage:cgImage];
}

- (UIImage *)mgj_blurredImageWithRadius:(CGFloat)radius iterations:(NSUInteger)iterations tintColor:(UIColor *)tintColor
{
    //image must be nonzero size
    if (floorf(self.size.width) * floorf(self.size.height) <= 0.0f) return self;

    //boxsize must be an odd integer
    uint32_t boxSize = (uint32_t)(radius * self.scale);
    if (boxSize % 2 == 0) boxSize ++;

    //create image buffers
    CGImageRef imageRef = self.CGImage;

    //convert to ARGB if it isn't
    if (CGImageGetBitsPerPixel(imageRef) != 32 ||
            CGImageGetBitsPerComponent(imageRef) != 8 ||
            !((CGImageGetBitmapInfo(imageRef) & kCGBitmapAlphaInfoMask)))
    {
        UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
        [self drawAtPoint:CGPointZero];
        imageRef = UIGraphicsGetImageFromCurrentImageContext().CGImage;
        UIGraphicsEndImageContext();
    }

    vImage_Buffer buffer1, buffer2;
    buffer1.width = buffer2.width = CGImageGetWidth(imageRef);
    buffer1.height = buffer2.height = CGImageGetHeight(imageRef);
    buffer1.rowBytes = buffer2.rowBytes = CGImageGetBytesPerRow(imageRef);
    size_t bytes = buffer1.rowBytes * buffer1.height;
    buffer1.data = malloc(bytes);
    buffer2.data = malloc(bytes);

    //create temp buffer
    void *tempBuffer = malloc((size_t)vImageBoxConvolve_ARGB8888(&buffer1, &buffer2, NULL, 0, 0, boxSize, boxSize,
            NULL, kvImageEdgeExtend + kvImageGetTempBufferSize));

    //copy image data
    CFDataRef dataSource = CGDataProviderCopyData(CGImageGetDataProvider(imageRef));
    memcpy(buffer1.data, CFDataGetBytePtr(dataSource), bytes);
    CFRelease(dataSource);

    for (NSUInteger i = 0; i < iterations; i++)
    {
        //perform blur
        vImageBoxConvolve_ARGB8888(&buffer1, &buffer2, tempBuffer, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);

        //swap buffers
        void *temp = buffer1.data;
        buffer1.data = buffer2.data;
        buffer2.data = temp;
    }

    //free buffers
    free(buffer2.data);
    free(tempBuffer);

    //create image context from buffer
    CGContextRef ctx = CGBitmapContextCreate(buffer1.data, buffer1.width, buffer1.height,
            8, buffer1.rowBytes, CGImageGetColorSpace(imageRef),
            CGImageGetBitmapInfo(imageRef));

    //apply tint
    if (tintColor && CGColorGetAlpha(tintColor.CGColor) > 0.0f)
    {
        CGContextSetFillColorWithColor(ctx, [tintColor colorWithAlphaComponent:0.25].CGColor);
        CGContextSetBlendMode(ctx, kCGBlendModePlusLighter);
        CGContextFillRect(ctx, CGRectMake(0, 0, buffer1.width, buffer1.height));
    }

    //create image from context
    imageRef = CGBitmapContextCreateImage(ctx);
    UIImage *image = [UIImage imageWithCGImage:imageRef scale:self.scale orientation:self.imageOrientation];
    CGImageRelease(imageRef);
    CGContextRelease(ctx);
    free(buffer1.data);
    return image;
}

/**
 * 添加水印图片
 */
- (UIImage *) mgj_applyWaterMarkWithImage:(UIImage*)watermark {
    /**
     *  水印图片和文字的比例系数
     */
    CGFloat waterMarkImageRadio = 83.f / 750;
    CGFloat leftPaddingRadio = 12.f / 750;

    /**
     *  计算水印图片的大小
     */
    CGFloat waterMarkImageWidth = waterMarkImageRadio * CGImageGetWidth(self.CGImage);
    CGFloat waterMarkImageHeight = waterMarkImageWidth / watermark.size.width * watermark.size.height;
    
    /**
     *  计算padding
     */
    CGFloat leftPadding = leftPaddingRadio * CGImageGetWidth(self.CGImage);

    CGFloat imageScale = self.scale;
    CGSize size = CGSizeMake(floor(self.size.width * imageScale), floor(self.size.height * imageScale));
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.f);
    
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    [watermark drawInRect:CGRectMake(leftPadding,
                                     size.height - leftPadding - waterMarkImageHeight,
                                     waterMarkImageWidth,
                                     waterMarkImageHeight)];
    UIImage *retImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return retImage;

}

- (UIImage *)mgj_applyWaterMarkWithText:(NSString *)text {
    /**
     *  水印图片和文字的比例系数
     */
    CGFloat waterMarkImageRadio = 83.f / 750;
    CGFloat textRadio = 17.f / 750;
    CGFloat leftPaddingRadio = 12.f / 750;
    CGFloat textAndWaterMarkPaddingRadio = 4.f / 750;
    
    /**
     *  计算得到的文本大小
     */
    UIFont *textFont = [UIFont systemFontOfSize:textRadio * CGImageGetWidth(self.CGImage)];
    
    /**
     *  计算水印图片的大小
     */
    UIImage *watermark = [UIImage imageNamed:@"MGJControls.bundle/watermark"];
    CGFloat waterMarkImageWidth = waterMarkImageRadio * CGImageGetWidth(self.CGImage);
    CGFloat waterMarkImageHeight = waterMarkImageWidth / watermark.size.width * watermark.size.height;
    
    /**
     *  计算padding
     */
    CGFloat leftPadding = leftPaddingRadio * CGImageGetWidth(self.CGImage);
    CGFloat textAndWaterMarkPadding = textAndWaterMarkPaddingRadio * CGImageGetWidth(self.CGImage);
    
    CGFloat imageScale = self.scale;
    CGSize size = CGSizeMake(floor(self.size.width * imageScale), floor(self.size.height * imageScale));
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.f);
    
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    if(MGJ_IS_EMPTY(text)){
        [watermark drawInRect:CGRectMake(leftPadding,
                                         size.height - leftPadding - waterMarkImageHeight,
                                         waterMarkImageWidth,
                                         waterMarkImageHeight)];
    }
    else{
        CGSize textSize = [text mgj_sizeWithFont:textFont];
        NSAttributedString *coloredString = [[NSAttributedString alloc]
                                             initWithString:text
                                             attributes:@{
                                                          NSForegroundColorAttributeName:[UIColor whiteColor],
                                                          NSFontAttributeName:textFont
                                                          }];
        [coloredString drawAtPoint:CGPointMake(leftPadding, size.height - leftPadding - textSize.height)];
        [watermark drawInRect:CGRectMake(leftPadding,
                                         size.height - leftPadding - textSize.height - textAndWaterMarkPadding - waterMarkImageHeight,
                                         waterMarkImageWidth,
                                         waterMarkImageHeight)];
    }
    UIImage *retImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return retImage;
}

@end
