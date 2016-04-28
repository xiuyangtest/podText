//
//  MGJCommand.m
//  Demo
//
//  Created by limboy on 6/1/15.
//  Copyright (c) 2015 juangua. All rights reserved.
//

#import "MGJCommand.h"

@implementation MGJCommandResult
@end

@interface MGJCommand ()
@property (nonatomic, copy) MGJCommandConsumeBlock consumeHandler;
@property (nonatomic, copy) MGJCommandCancelBlock cancelHandler;

@property (nonatomic, readwrite) MGJCommandResult *result;
@property (nonatomic, readwrite) BOOL executing;
@end

@implementation MGJCommand

- (instancetype)initWithConsumeHandler:(MGJCommandConsumeBlock)consumeHandler
{
    return [self initWithConsumeHandler:consumeHandler cancelHandler:nil];
}

- (instancetype)initWithConsumeHandler:(MGJCommandConsumeBlock)consumeHandler cancelHandler:(MGJCommandCancelBlock)cancelHandler
{
    if (self = [super init]) {
        NSAssert(consumeHandler, @"consumeHandler can't be nil");
        self.consumeHandler = consumeHandler;
        self.cancelHandler = cancelHandler;
    }
    return self;
}

- (void)execute:(id)input
{
    if (!self.executing) {
        self.executing = YES;
        MGJCommandCompletionBlock completionHandler = ^(id error, id content) {
            MGJCommandResult *result = [[MGJCommandResult alloc] init];
            result.error = error;
            result.content = content;
            self.result = result;
            self.executing = NO;
        };
        self.consumeHandler(input, completionHandler);
    }
}

- (void)cancel
{
    self.cancelHandler ? self.cancelHandler() : nil;
    self.executing = NO;
}

@end
