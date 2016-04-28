//
//  MGJHTTPResponseSerializer.h
//  MGJiPhoneSDKDemo
//
//  Created by kunka on 14-9-5.
//  Copyright (c) 2014年 juangua. All rights reserved.
//

#import <AFNetworking/AFURLResponseSerialization.h>
#import "MPMessagePack.h"
#import <AFNetworking/AFNetworking.h>

@interface MGJHTTPResponseSerializer : AFHTTPResponseSerializer
@property (nonatomic, copy) NSString *classNameForResult;
@end
