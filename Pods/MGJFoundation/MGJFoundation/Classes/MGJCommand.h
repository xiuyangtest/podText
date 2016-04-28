//
//  MGJCommand.h
//  Demo
//
//  Created by limboy on 6/1/15.
//  Copyright (c) 2015 juangua. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^MGJCommandCompletionBlock)(id error, id content);

/**
 * input 是外部传过来的值，比如 user_id
 * 当拿到数据后，调用下 completionHandler，这样 `result` 属性就会变化
 */
typedef void(^MGJCommandConsumeBlock)(id input, MGJCommandCompletionBlock completionHandler);

/**
 *  有些操作，如 http 请求，需要手动取消
 */
typedef void(^MGJCommandCancelBlock)();

@interface MGJCommandResult : NSObject
@property (nonatomic) NSError *error;
@property (nonatomic) id content;
@end

@interface MGJCommand : NSObject

/**
 *  外部可以对这两个 property 进行 KVO
 */
@property (nonatomic, readonly) BOOL executing;
@property (nonatomic, readonly) MGJCommandResult *result;

- (instancetype)initWithConsumeHandler:(MGJCommandConsumeBlock )consumeHandler;
- (instancetype)initWithConsumeHandler:(MGJCommandConsumeBlock )consumeHandler cancelHandler:(MGJCommandCancelBlock )cancelHandler;

- (void)execute:(id)input;
- (void)cancel;
@end
