//
//  UIImage+UIImageUtils.m
//  Mogujie4iPhone
//
//  Created by qimi on 12-8-9.
//
//
#if TARGET_OS_IOS
#import "UIImage+MGJUtils.h"

@implementation UIImage (MGJUtils)

- (UIImage *)mgj_scaleAndRotateImage:(float)maxRelosution
{
	CGImageRef imgRef = self.CGImage;
    
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    if (width > maxRelosution || height > maxRelosution) {
        CGFloat ratio = width/height;
        if (ratio > 1) {
            bounds.size.width = maxRelosution;
            bounds.size.height = bounds.size.width / ratio;
        }
        else {
            bounds.size.height = maxRelosution;
            bounds.size.width = bounds.size.height * ratio;
        }
    }
    
    CGFloat scaleRatio = bounds.size.width / width;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    CGFloat boundHeight;
    UIImageOrientation orient = self.imageOrientation;
    switch(orient) {
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
            
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
            
        case UIImageOrientationLeftMirrored: //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
            
    }
    
    UIGraphicsBeginImageContext(bounds.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    }
    else {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
    
    CGContextConcatCTM(context, transform);
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageCopy;
}

static void addRoundedRectToPath(CGContextRef context, CGRect rect, float ovalWidth,
	float ovalHeight)
{
	float fw, fh;

	if ((ovalWidth == 0) || (ovalHeight == 0)) {
		CGContextAddRect(context, rect);
		return;
	}

	CGContextSaveGState(context);
	CGContextTranslateCTM(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
	CGContextScaleCTM(context, ovalWidth, ovalHeight);
	fw	= CGRectGetWidth(rect) / ovalWidth;
	fh	= CGRectGetHeight(rect) / ovalHeight;

	CGContextMoveToPoint(context, fw, fh / 2);				// Start at lower right corner
	CGContextAddArcToPoint(context, fw, fh, fw / 2, fh, 1);	// Top right corner
	CGContextAddArcToPoint(context, 0, fh, 0, fh / 2, 1);	// Top left corner
	CGContextAddArcToPoint(context, 0, 0, fw / 2, 0, 1);	// Lower left corner
	CGContextAddArcToPoint(context, fw, 0, fw, fh / 2, 1);	// Back to lower right

	CGContextClosePath(context);
	CGContextRestoreGState(context);
}

+ (id)mgj_createRoundedRectImage:(UIImage *)image size:(CGSize)size
{
	// the size of CGContextRef
	int				w			= size.width;
	int				h			= size.height;
	UIImage			*img		= image;
	CGColorSpaceRef colorSpace	= CGColorSpaceCreateDeviceRGB();
	CGContextRef	context		= CGBitmapContextCreate(NULL, w, h, 8, 4 * w, colorSpace, kCGBitmapAlphaInfoMask);
	CGRect			rect		= CGRectMake(0, 0, w, h);

	CGContextBeginPath(context);
	addRoundedRectToPath(context, rect, 5, 5);
	CGContextClosePath(context);
	CGContextClip(context);
	CGContextDrawImage(context, CGRectMake(0, 0, w, h), img.CGImage);
	CGContextDrawPath(context, kCGPathFillStroke);
	CGContextSetShadowWithColor(context, CGSizeMake(200, 200), 100, [UIColor blackColor].CGColor);
	CGImageRef imageMasked = CGBitmapContextCreateImage(context);
	CGContextRelease(context);
	CGColorSpaceRelease(colorSpace);
	img = [UIImage imageWithCGImage:imageMasked];
	CGImageRelease(imageMasked);
	return img;
}

// 等比例缩放
- (UIImage *)mgj_equalProportionScaleToSize:(CGSize)size
{
	CGFloat width	= CGImageGetWidth(self.CGImage);
	CGFloat height	= CGImageGetHeight(self.CGImage);

	float	verticalRadio	= size.height * 1.0 / height;
	float	horizontalRadio = size.width * 1.0 / width;

	float radio = 1;

	if ((verticalRadio > 1) && (horizontalRadio > 1)) {
		radio = verticalRadio > horizontalRadio ? horizontalRadio : verticalRadio;
	} else {
		radio = verticalRadio < horizontalRadio ? verticalRadio : horizontalRadio;
	}

	width	= width * radio;
	height	= height * radio;

	int xPos	= (size.width - width) / 2;
	int yPos	= (size.height - height) / 2;

	// 创建一个bitmap的context
	// 并把它设置成为当前正在使用的context
	UIGraphicsBeginImageContext(size);

	// 绘制改变大小的图片
	[self drawInRect:CGRectMake(xPos, yPos, width, height)];

	// 从当前context中创建一个改变大小后的图片
	UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();

	// 使当前的context出堆栈
	UIGraphicsEndImageContext();

	// 返回新的改变大小后的图片
	return scaledImage;
}

// 切割图片
// 返回一个UIImage 的字典，参数：image    分割的行数x    分割的列数y
- (NSDictionary *)mgj_cutImageByLines:(int)x andColumns:(int)y
{
	float	x_NewImg	= self.size.width * 1.0 / y;
	float	y_NewImg	= self.size.height * 1.0 / x;

	// 保存分割后的图片
	NSMutableDictionary *_multableImgDic = [[NSMutableDictionary alloc] initWithCapacity:1];

	for (int i = 0; i < x; i++) {
		for (int j = 0; j < y; j++) {
			CGImageRef	imageRef	= CGImageCreateWithImageInRect([self CGImage], CGRectMake(x_NewImg * j, y_NewImg * i, x_NewImg, y_NewImg));
			UIImage		*eleImg		= [UIImage imageWithCGImage:imageRef];
			// 分割后Image的名字
			NSString *_imgNameStr = [NSString stringWithFormat:@"%d%d.png", i, j];

			[_multableImgDic setObject:eleImg forKey:_imgNameStr];
            CGImageRelease(imageRef);
		}
	}

	NSDictionary *dic = _multableImgDic;
	return dic;
}

-(UIImage*)mgj_cutImageBySize:(CGFloat)y isDaren:(BOOL)isDaren{
  
	float	y_NewImg	= y;
    CGFloat height = isDaren ? (self.size.height/2-y_NewImg/2)*0.4 : (self.size.height/2-y_NewImg/2)*0.8;
    CGFloat startY = self.size.height > y_NewImg ? height : 0;
    CGImageRef	imageRef	= CGImageCreateWithImageInRect([self CGImage], CGRectMake(0, startY, self.size.width, y_NewImg));
    UIImage		*eleImg		= [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return eleImg;
}

+ (UIImage *)mgj_cutImageFromImage:(UIImage*)originImage byRect:(CGRect)rect
{
    CGImageRef imageRef = originImage.CGImage;
    CGImageRef subImageRef = CGImageCreateWithImageInRect(imageRef, rect);
    UIImage* subImage = [UIImage imageWithCGImage:subImageRef];
    CGImageRelease(subImageRef);
    return subImage;
    
}

+(UIImage *)mgj_rotateImage:(UIImage *)aImage
{
    CGImageRef imgRef = aImage.CGImage;
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    CGFloat scaleRatio = 1;
    CGFloat boundHeight;
    UIImageOrientation orient = aImage.imageOrientation;
    switch(orient)
    {
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(width, height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
        case UIImageOrientationLeftMirrored: //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(height, width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
        case UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
        default:
            break;
            //            [NSException raise:NSInternalIncistencyException format:@"Invalid image orientation"];
    }
    UIGraphicsBeginImageContext(bounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    }
    else {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
    CGContextConcatCTM(context, transform);
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return imageCopy;
}

- (UIImage *)mgj_imageByScalingToSize:(CGSize)targetSize
{
    UIGraphicsBeginImageContext(targetSize);
	[self drawInRect:CGRectMake(0.0f, 0.0f, targetSize.width, targetSize.height)];
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
//	if(newImage == nil)
//        DBG(@"could not scale image");
	return newImage ;
}

- (UIImage *)resizedImage:(CGSize)newSize
{
    CGRect newRect = CGRectIntegral(CGRectMake(0, 0, newSize.width, newSize.height));
//    CGRect transposedRect = CGRectMake(0, 0, newRect.size.height, newRect.size.width);
    CGImageRef imageRef = self.CGImage;
    
    // Build a context that's the same dimensions as the new size
    CGContextRef bitmap = CGBitmapContextCreate(NULL,
                                                newRect.size.width,
                                                newRect.size.height,
                                                CGImageGetBitsPerComponent(imageRef),
                                                0,
                                                CGImageGetColorSpace(imageRef),
                                                CGImageGetBitmapInfo(imageRef));

    // Rotate and/or flip the image if required by its orientation
//    CGContextConcatCTM(bitmap, transform);
    
    // Set the quality level to use when rescaling
//    CGContextSetInterpolationQuality(bitmap, quality);
    
    // Draw into the context; this scales the image
    CGContextDrawImage(bitmap, newRect, imageRef);
    
    // Get the resized image from the context and a UIImage
    CGImageRef newImageRef = CGBitmapContextCreateImage(bitmap);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    
    // Clean up
    CGContextRelease(bitmap);
    CGImageRelease(newImageRef);
    
    return newImage;
}

- (UIImage *)mgj_resizedImageWithContentMode:(UIViewContentMode)contentMode bounds:(CGSize)bounds
{
    CGFloat horizontalRatio = bounds.width / self.size.width;
    CGFloat verticalRatio = bounds.height / self.size.height;
    CGFloat ratio;
    
    switch (contentMode) {
        case UIViewContentModeScaleAspectFill:
            ratio = MAX(horizontalRatio, verticalRatio);
            break;
            
        case UIViewContentModeScaleAspectFit:
            ratio = MIN(horizontalRatio, verticalRatio);
            break;
            
        default:
            [NSException raise:NSInvalidArgumentException format:@"Unsupported content mode: %ld", (long)contentMode];
    }

    CGSize newSize = CGSizeMake(self.size.width * ratio, self.size.height * ratio);
    return [self resizedImage:newSize];
}

+ (UIImage *)mgj_blurryImage:(UIImage *)image withBlurLevel:(CGFloat)blur
{
    CIContext *ciContext = [CIContext contextWithOptions:nil];
    CIImage *inputImage = [CIImage imageWithCGImage:image.CGImage];
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"
                                  keysAndValues:kCIInputImageKey, inputImage,
                        @"inputRadius", @(blur),
                        nil];
    CIImage *outputImage = filter.outputImage;
    CGImageRef outImage = [ciContext createCGImage:outputImage fromRect:[inputImage extent]];
    
    UIImage *endImage = [UIImage imageWithCGImage:outImage];
    CGImageRelease(outImage);
    return endImage;
    //    return [[UIImage alloc] initWithCIImage:outputImage];
}

- (UIImage *)mgj_imageByApplyingAlpha:(CGFloat) alpha {
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0f);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGRect area = CGRectMake(0, 0, self.size.width, self.size.height);
    
    CGContextScaleCTM(ctx, 1, -1);
    CGContextTranslateCTM(ctx, 0, -area.size.height);
    
    CGContextSetBlendMode(ctx, kCGBlendModeMultiply);
    
    CGContextSetAlpha(ctx, alpha);
    
    CGContextDrawImage(ctx, area, self.CGImage);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}


@end
#endif