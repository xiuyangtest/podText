//
//  MGJImageMetaInfo.m
//  Example
//
//  Created by Blank on 15/12/7.
//  Copyright © 2015年 Juangua. All rights reserved.
//

#import "MGJImageMetaInfo.h"
#import <MGJ-Categories/UIDevice+MGJKit.h>

@interface MGJImageMetaInfo ()
@property (nonatomic, assign) CGSize originSize;
@property (nonatomic, assign) CGSize thumbnailSize;
@property (nonatomic, copy) NSString *imageCode;
@property (nonatomic, copy) NSString *originURL;
@end


@implementation MGJImageMetaInfo
+ (instancetype)metaInfoWithURL:(NSString *)imageURL
{
    if (!imageURL) {
        return nil;
    }

    static NSRegularExpression *regularExpression = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
       regularExpression = [[NSRegularExpression alloc] initWithPattern:@"_[a-zA-Z0-9]{18,37}_\\d+x\\d+\\.[a-zA-Z]+(_\\d+x\\d+(\\.\\S+){0,1}\\.[a-zA-Z]+){0,1}" options:NSRegularExpressionCaseInsensitive error:nil];
    });
    
    NSTextCheckingResult *match = [regularExpression firstMatchInString:imageURL options:0 range:NSMakeRange(0, imageURL.length)];
    if (!match) {
        return nil;
    }
    
    //如果正则匹配成功，那么一定有原图尺寸
    
    MGJImageMetaInfo *metaInfo = [[MGJImageMetaInfo alloc] init];
    
    //去掉开头的_
    NSString *resultString = [imageURL substringWithRange:NSMakeRange(match.range.location + 1, match.range.length - 1)];
    
    //根据 _ 区分原图尺寸与缩略图参数
    NSArray *separatedByUnderline = [resultString componentsSeparatedByString:@"_"];
   
    //取原图尺寸
    NSArray *sizeComponent = [[[separatedByUnderline[1] componentsSeparatedByString:@"."] objectAtIndex:0] componentsSeparatedByString:@"x"];
    metaInfo.originSize = CGSizeMake([sizeComponent[0] integerValue], [sizeComponent[1] integerValue]);
    
    //存在缩略图参数的情况
    if (separatedByUnderline.count == 3) {
        //区分尺寸和格式
        NSArray *separatedByDot = [separatedByUnderline[2] componentsSeparatedByString:@"."];
        //取缩略图宽高
        NSArray *expectSizeComponent = [separatedByDot[0] componentsSeparatedByString:@"x"];

        //缩略图尺寸按照 750 为参照，根据屏幕尺寸换算，得到所需的大小。
        NSInteger widthFromURL = [expectSizeComponent[0] integerValue];
        NSInteger heightFromURL = [expectSizeComponent[1] integerValue];
        
        
        //高度为 999 时需要换算高度
        if (heightFromURL == 999) {
            heightFromURL = metaInfo.originSize.height / metaInfo.originSize.width * widthFromURL;
        }
        
        metaInfo.thumbnailSize = CGSizeMake(widthFromURL, heightFromURL);
        
        //质量参数不能单独存在，因此如果参数分为 3 或 4 段时，第二段一定为切图参数
        if (separatedByDot.count >= 3)
        {
            metaInfo.imageCode = separatedByDot[1];
        }
        metaInfo.originURL = [imageURL substringToIndex:imageURL.length - [separatedByUnderline[2] length] - 1];
    }
    else
    {
        metaInfo.originURL = imageURL;
    }
    
    
    return metaInfo;
}
@end
