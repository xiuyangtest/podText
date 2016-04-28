//
//  MGJPagePerformance.h
//  MGJiPhoneSDKDemo
//
//  Created by limboy on 9/17/15.
//  Copyright (c) 2015 juangua. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MGJPagePerformanceDelegate <NSObject>

- (void)didRecordedPagePerformanceWithEventID:(NSString *)eventID
                                       stage1:(CFTimeInterval)stage1
                                       stage2:(CFTimeInterval)stage2
                                       stage3:(CFTimeInterval)stage3;

@end

@class MGJAnalyticsViewController;

@interface MGJPagePerformance : NSObject

// 由外部来设置 eventID
+ (void)setEventID:(NSString *)eventID;

@property (nonatomic, weak) id<MGJPagePerformanceDelegate> delegate;

- (void)begin;
- (void)stage1;
- (void)stage2;
- (void)commit;

@end
