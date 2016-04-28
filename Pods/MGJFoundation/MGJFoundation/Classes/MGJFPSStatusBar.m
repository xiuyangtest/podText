//
//  MGJFPSStatusBar.m
//  Example
//
//  Created by Blank on 15/4/8.
//  Copyright (c) 2015年 juangua. All rights reserved.
//

#import "MGJFPSStatusBar.h"

static const NSInteger MAXFPS = 75;
static const NSInteger DEFAULT_SAMPLECOUNT = 300;
static const CGFloat TEXT_WIDTH = 40.f;

@interface MGJFPSStatusBar ()
@property(nonatomic, strong) CADisplayLink *displayLink;
@property(nonatomic, strong) CAShapeLayer *chartLayer;
@property(nonatomic, strong) CATextLayer *textLayer;
@property(nonatomic, assign) CFTimeInterval lastTimeStamp;
@property(nonatomic, strong) NSMutableArray *fpsSamples;
@end

@implementation MGJFPSStatusBar

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static MGJFPSStatusBar *instance;
    dispatch_once(&onceToken, ^{
        instance = [[MGJFPSStatusBar alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super initWithFrame:[UIApplication sharedApplication].statusBarFrame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        self.windowLevel = UIWindowLevelStatusBar + 1;
        self.hidden = YES;
        self.lastTimeStamp = 0;
        self.fpsSamples = [NSMutableArray array];
        
        self.sampleCount = DEFAULT_SAMPLECOUNT;
        
        self.chartLayer = [CAShapeLayer layer];
        self.chartLayer.frame = CGRectMake(0, 0, self.frame.size.width - TEXT_WIDTH, self.frame.size.height);
        self.chartLayer.lineWidth = 1;
        self.chartLayer.strokeColor = [UIColor greenColor].CGColor;
        [self.layer addSublayer:self.chartLayer];
        
        self.textLayer = [CATextLayer layer];
        self.textLayer.frame = CGRectMake(self.frame.size.width - TEXT_WIDTH, 0, TEXT_WIDTH, self.frame.size.height);
        self.textLayer.fontSize = 12.f;
        self.textLayer.alignmentMode = kCAAlignmentRight;
        self.textLayer.foregroundColor = [UIColor greenColor].CGColor;
        [self.layer addSublayer:self.textLayer];
        
        self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(handleDisplayLink)];
        self.displayLink.paused = YES;
        [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    return self;
}

- (void)setSampleCount:(NSInteger)sampleCount
{
    _sampleCount = sampleCount;
    [self.fpsSamples removeAllObjects];
    for (int i = 0; i < _sampleCount; i++) {
        [self.fpsSamples addObject:@(0)];
    }
}

- (void)setEnabled:(BOOL)enabled
{
    if (_enabled != enabled){
        _enabled = enabled;
        if (enabled) {
            [self show];
        }
        else
        {
            [self hide];
        }
    }
    
}

- (void)show
{
    self.hidden = NO;
    [self start];
}

- (void)hide
{
    self.hidden = YES;
    [self pause];
}

- (void)pause
{
    self.displayLink.paused = YES;
}

- (void)start
{
    self.displayLink.paused = NO;
}

- (void)handleDisplayLink
{
    if (self.lastTimeStamp > 0) {
        [self.fpsSamples addObject:@((int)(1 / (self.displayLink.timestamp - self.lastTimeStamp)))];
        if (self.fpsSamples.count > self.sampleCount) {
            self.fpsSamples = [[self.fpsSamples subarrayWithRange:NSMakeRange(self.fpsSamples.count - self.sampleCount, self.sampleCount)] mutableCopy];
        }
        [self drawChart];
    }
    self.lastTimeStamp = self.displayLink.timestamp;
}

- (void)drawChart
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    [path moveToPoint:[self getPointForFPS:[self.fpsSamples[0] integerValue] atIndex:0]];
    [self.fpsSamples enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [path addLineToPoint:[self getPointForFPS:[obj integerValue] atIndex:idx]];
    }];
    
    self.chartLayer.path = path.CGPath;
    self.textLayer.string = [NSString stringWithFormat:@"FPS:%@", [self.fpsSamples.lastObject stringValue]];
}

- (CGPoint)getPointForFPS:(NSInteger)fps atIndex:(NSInteger)index
{
    return CGPointMake(1.f * index / self.sampleCount * self.chartLayer.frame.size.width, 1.f * fps / MAXFPS * self.chartLayer.frame.size.height);
}

#pragma mark - notifications
- (void)didEnterBackground
{
    [self pause];
}

- (void)didBecomeActive
{
    [self start];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_displayLink invalidate];
    _displayLink = nil;
}
@end
