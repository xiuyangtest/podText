/**
 * @file:       UIImage+MGJUtils
 * @author:     kongkong
 * @date:       2015-12-10
 * @desc:       UIImage的扩展
 */
#if TARGET_OS_IOS
#import <UIKit/UIKit.h>

@interface UIImage (MGJUtils)

/**
 *
 */
- (UIImage *)mgj_scaleAndRotateImage:(float)maxResolution;

+ (id)mgj_createRoundedRectImage:(UIImage*)image size:(CGSize)size;

//等比例缩放
- (UIImage*)mgj_equalProportionScaleToSize:(CGSize)size;

//分割图片
- (NSDictionary *)mgj_cutImageByLines:(int)x andColumns:(int)y;

- (UIImage*)mgj_cutImageBySize:(CGFloat)y isDaren:(BOOL)isDaren;

+ (UIImage *)mgj_cutImageFromImage:(UIImage*)originImage byRect:(CGRect)rect;

+ (UIImage *)mgj_rotateImage:(UIImage *)aImage;

//简单缩放到指定大小
- (UIImage *)mgj_imageByScalingToSize:(CGSize)targetSize;

- (UIImage *)mgj_resizedImageWithContentMode:(UIViewContentMode)contentMode bounds:(CGSize)bounds;

//模糊图片
+ (UIImage *)mgj_blurryImage:(UIImage *)image withBlurLevel:(CGFloat)blur;

- (UIImage *)mgj_imageByApplyingAlpha:(CGFloat)alpha;


@end
#endif