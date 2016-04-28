//
//  MGJHangDetector.m
//  MGJFoundation
//
//  Created by limboy on 12/12/14.
//  Copyright (c) 2014 juangua. All rights reserved.
//

#import "MGJHangDetector.h"
#import "UIDevice+MGJKit.h"
#import "UIApplication+MGJKit.h"

static CGFloat pingTimeInterval = 1.5;

NSString * const MGJHangDetectorNotification = @"MGJHangDetectorNotification";

@implementation MGJHangDetector

+ (void)startHangDetector {
    NSThread *hangDetectionThread = [[NSThread alloc] initWithTarget:self selector:@selector(deadThreadMain) object:nil];
    [hangDetectionThread start];
}

+ (void)startHangDetectorWithTimeInterval:(CGFloat)timeInterval
{
    pingTimeInterval = timeInterval;
    [self startHangDetector];
}

static volatile NSInteger DEAD_SIGNAL = 0;
+ (void)deadThreadTick {
    if (DEAD_SIGNAL == 1) {
        [[NSNotificationCenter defaultCenter] postNotificationName:MGJHangDetectorNotification object:nil];
    }
    DEAD_SIGNAL = 1;
    dispatch_async(dispatch_get_main_queue(), ^{DEAD_SIGNAL = 0;});
}

+ (void)deadThreadMain {
    [NSThread currentThread].name = @"HangDetector";
    @autoreleasepool {
        [NSTimer scheduledTimerWithTimeInterval:pingTimeInterval target:self selector:@selector(deadThreadTick) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate distantFuture]];
    }
}

@end
