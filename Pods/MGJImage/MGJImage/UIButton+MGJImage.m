//
//  UIButton+MGJImage.m
//  Example
//
//  Created by 昆卡 on 16/1/4.
//  Copyright © 2016年 Juangua. All rights reserved.
//

#import "UIButton+MGJImage.h"
#import "MGJImageConfigManager.h"
#import "MGJImageAdapter.h"

@implementation UIButton (MGJImage)

- (void)mgj_setBackgroundImageWithURL:(NSURL *)url forState:(UIControlState)state placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options completed:(SDWebImageCompletionBlock)completedBlock
{
    [self mgj_setBackgroundImageWithURL:url expectSize:0 forState:state placeholderImage:placeholder options:options completed:completedBlock];
}

- (void)mgj_setBackgroundImageWithURL:(NSURL *)url expectSize:(NSInteger)expectSize forState:(UIControlState)state placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options completed:(SDWebImageCompletionBlock)completedBlock
{
    [self mgj_setBackgroundImageWithURL:url expectSize:expectSize needCrop:NO forState:state placeholderImage:placeholder options:options completed:completedBlock];
}


- (void)mgj_setBackgroundImageWithURL:(NSURL *)url expectSize:(NSInteger)expectSize needCrop:(BOOL)needCrop forState:(UIControlState)state placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options completed:(SDWebImageCompletionBlock)completedBlock {
    
    
    NSString *downloadURLString = [url absoluteString];
    
    //匹配图片规则，替换 URL
    if (expectSize > 0) {
        downloadURLString = [[MGJImageAdapter sharedInstance] adaptImageURL:downloadURLString toSize:expectSize needCrop:needCrop];
    }
    
    NSURL *downloadURL = [NSURL URLWithString:downloadURLString];
    
    NSTimeInterval beginTime = [[NSDate date] timeIntervalSince1970];
    
    [self sd_setBackgroundImageWithURL:downloadURL forState:state placeholderImage:placeholder options:options completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
        if (!image || error) {
            if ([MGJImageConfigManager downloadImageFailureBlock]) {
                [MGJImageConfigManager downloadImageFailureBlock](error,imageURL.absoluteString);
            }
        }
        else
        {
            if ([MGJImageConfigManager downloadImageSuccessBlock]) {
                NSTimeInterval finishTime = [[NSDate date] timeIntervalSince1970];
                NSTimeInterval duration = finishTime - beginTime;
                [MGJImageConfigManager downloadImageSuccessBlock](cacheType,duration,imageURL.absoluteString);
            }
        }
        
        if (completedBlock) {
            completedBlock(image, error, cacheType, imageURL);
        }
        
    }];
    
}


- (void)mgj_setImageWithURL:(NSURL *)url forState:(UIControlState)state placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options completed:(SDWebImageCompletionBlock)completedBlock
{
    [self mgj_setImageWithURL:url expectSize:0 forState:state placeholderImage:placeholder options:options completed:completedBlock];
}

- (void)mgj_setImageWithURL:(NSURL *)url expectSize:(NSInteger)expectSize forState:(UIControlState)state placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options completed:(SDWebImageCompletionBlock)completedBlock
{
    [self mgj_setImageWithURL:url expectSize:expectSize needCrop:NO forState:state placeholderImage:placeholder options:options completed:completedBlock];
}


- (void)mgj_setImageWithURL:(NSURL *)url expectSize:(NSInteger)expectSize needCrop:(BOOL)needCrop forState:(UIControlState)state placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options completed:(SDWebImageCompletionBlock)completedBlock {
    
    
    NSString *downloadURLString = [url absoluteString];
    
    //匹配图片规则，替换 URL
    if (expectSize > 0) {
        downloadURLString = [[MGJImageAdapter sharedInstance] adaptImageURL:downloadURLString toSize:expectSize needCrop:needCrop];
    }
    
    NSURL *downloadURL = [NSURL URLWithString:downloadURLString];
    
    NSTimeInterval beginTime = [[NSDate date] timeIntervalSince1970];
    
    [self sd_setImageWithURL:downloadURL forState:state placeholderImage:placeholder options:options completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
        if (!image || error) {
            if ([MGJImageConfigManager downloadImageFailureBlock]) {
                [MGJImageConfigManager downloadImageFailureBlock](error,imageURL.absoluteString);
            }
        }
        else
        {
            if ([MGJImageConfigManager downloadImageSuccessBlock]) {
                NSTimeInterval finishTime = [[NSDate date] timeIntervalSince1970];
                NSTimeInterval duration = finishTime - beginTime;
                [MGJImageConfigManager downloadImageSuccessBlock](cacheType,duration,imageURL.absoluteString);
            }
        }
        
        if (completedBlock) {
            completedBlock(image, error, cacheType, imageURL);
        }
        
    }];
    
}
@end
