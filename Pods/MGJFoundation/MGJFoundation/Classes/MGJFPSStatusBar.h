//
//  MGJFPSStatusBar.h
//  Example
//
//  Created by Blank on 15/4/8.
//  Copyright (c) 2015年 juangua. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MGJFPSStatusBar :UIWindow
+ (instancetype)sharedInstance;
@property (nonatomic, assign) BOOL enabled;
@property(nonatomic, assign) NSInteger sampleCount;
@end
