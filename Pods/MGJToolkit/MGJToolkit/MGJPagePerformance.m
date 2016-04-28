//
//  MGJPagePerformance.m
//  MGJiPhoneSDKDemo
//
//  Created by limboy on 9/17/15.
//  Copyright (c) 2015 juangua. All rights reserved.
//

#import "MGJPagePerformance.h"
#import "MGJAnalytics.h"
#import <QuartzCore/QuartzCore.h>

static NSString *trackEventID;

@interface MGJPagePerformance ()
@property (nonatomic, assign) CFTimeInterval startTime;
@property (nonatomic, assign) CFTimeInterval stage1Time;
@property (nonatomic, assign) CFTimeInterval stage2Time;
@property (nonatomic, assign) BOOL hasRecordedPagePerformance;
@end

@implementation MGJPagePerformance

+ (void)setEventID:(NSString *)eventID
{
    trackEventID = eventID;
}

- (void)begin
{
    self.startTime = CACurrentMediaTime();
}

- (void)stage1
{
    self.stage1Time = CACurrentMediaTime();
}

- (void)stage2
{
    self.stage2Time = CACurrentMediaTime();
}

- (void)commit
{
    // 同时有 stage1 和 stage2，才进行打点
    if (self.delegate && trackEventID && !self.hasRecordedPagePerformance && self.stage1Time && self.stage2Time) {
        CFTimeInterval delta1 = self.stage1Time - self.startTime;
        CFTimeInterval delta2 = self.stage2Time - self.stage1Time;
        CFTimeInterval delta3 = CACurrentMediaTime() - self.stage2Time;
        [self.delegate didRecordedPagePerformanceWithEventID:trackEventID stage1:delta1 stage2:delta2 stage3:delta3];
        self.hasRecordedPagePerformance = YES;
    }
}

@end
