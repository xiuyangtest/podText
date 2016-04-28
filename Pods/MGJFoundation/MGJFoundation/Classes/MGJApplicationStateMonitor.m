//
//  MGJApplicationStateMonitor.m
//  Example
//
//  Created by limboy on 12/22/14.
//  Copyright (c) 2014 juangua. All rights reserved.
//

#import "MGJApplicationStateMonitor.h"

@implementation MGJApplicationStateMonitor

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidFinishLaunching:) name:UIApplicationDidFinishLaunchingNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidReceiveMemoryWarning:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillTerminate:) name:UIApplicationWillTerminateNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationSignificantTimeChange:) name:UIApplicationSignificantTimeChangeNotification object:nil];
    }
    return self;
}

- (void)applicationDidEnterBackground:(NSNotification *)notification
{
    if ([self.delegate respondsToSelector:@selector(applicationDidEnterBackground:)]) {
        [self.delegate applicationDidEnterBackground:[UIApplication sharedApplication]];
    }
}

- (void)applicationWillEnterForeground:(NSNotification *)notification
{
    if ([self.delegate respondsToSelector:@selector(applicationWillEnterForeground:)]) {
        [self.delegate applicationWillEnterForeground:[UIApplication sharedApplication]];
    }
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    if ([self.delegate respondsToSelector:@selector(applicationDidFinishLaunching:)]) {
        [self.delegate applicationDidFinishLaunching:[UIApplication sharedApplication]];
    }
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    if ([self.delegate respondsToSelector:@selector(applicationDidBecomeActive:)]) {
        [self.delegate applicationDidBecomeActive:[UIApplication sharedApplication]];
    }
}

- (void)applicationWillResignActive:(NSNotification *)notification
{
    if ([self.delegate respondsToSelector:@selector(applicationWillResignActive:)]) {
        [self.delegate applicationWillResignActive:[UIApplication sharedApplication]];
    }
}

- (void)applicationDidReceiveMemoryWarning:(NSNotification *)notification
{
    if ([self.delegate respondsToSelector:@selector(applicationDidReceiveMemoryWarning:)]) {
        [self.delegate applicationDidReceiveMemoryWarning:[UIApplication sharedApplication]];
    }
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
    if ([self.delegate respondsToSelector:@selector(applicationWillTerminate:)]) {
        [self.delegate applicationWillTerminate:[UIApplication sharedApplication]];
    }
}

- (void)applicationSignificantTimeChange:(NSNotification *)notification
{
    if ([self.delegate respondsToSelector:@selector(applicationSignificantTimeChange:)]) {
        [self.delegate applicationSignificantTimeChange:[UIApplication sharedApplication]];
    }
}

@end