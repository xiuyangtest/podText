//
//  MGJNativeComponentMetaInfo.h
//  Example
//
//  Created by limboy on 7/21/15.
//  Copyright (c) 2015 juangua. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MGJEntity.h"

@interface MGJNativeComponentMetaInfo : MGJEntity

@property (nonatomic, copy) NSString *id;
@property (nonatomic, copy) NSString *version;
@property (nonatomic, copy) NSString *category;
@property (nonatomic, copy) NSString *type;

@end
