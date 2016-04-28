//
//  MGJImageMetaInfo.h
//  Example
//
//  Created by Blank on 15/12/7.
//  Copyright © 2015年 Juangua. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MGJImageMetaInfo : NSObject
@property (nonatomic, assign, readonly) CGSize originSize;
@property (nonatomic, assign, readonly) CGSize thumbnailSize;
@property (nonatomic, copy, readonly) NSString *imageCode;
@property (nonatomic, copy, readonly) NSString *originURL;

+ (instancetype)metaInfoWithURL:(NSString *)imageURL;
@end
