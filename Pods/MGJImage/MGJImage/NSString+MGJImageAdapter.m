//
//  NSString+MGJImageAdapter.m
//  Example
//
//  Created by Blank on 15/12/25.
//  Copyright © 2015年 Juangua. All rights reserved.
//

#import "NSString+MGJImageAdapter.h"
#import "MGJImageAdapter.h"

@implementation NSString (MGJImageAdapter)
- (NSString *)mgj_adaptedImageURL
{
    return [[MGJImageAdapter sharedInstance] adaptImageURL:self];
}
@end
