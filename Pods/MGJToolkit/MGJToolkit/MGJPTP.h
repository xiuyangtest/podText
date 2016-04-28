//
//  MGJPTP.h
//  Example
//
//  Created by limboy on 12/30/14.
//  Copyright (c) 2014 juangua. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSObject (PTP)
@property (nonatomic, copy) NSString *ptpModuleName;
@end

@interface UIControl (PTP)
+ (void)mgj_swizzleAddTargetAction;
@property (nonatomic, assign) BOOL ignorePTP;
@end

@interface UIGestureRecognizer (PTP)
@property (nonatomic, assign) BOOL ignorePTP;
@end

#pragma mark - MGJPTPDelegate

@protocol MGJPTPDelegate <NSObject>

- (void)didGeneratedPTP:(NSString *)ptp;

@end



@interface MGJPTP : NSObject

/**
 *  需要先调用这个方法来注册 appName
 *
 *  @param appName
 */
+ (void)startWithAppName:(NSString *)appName;

/**
 *  开启调试模式，可以对模块描边，输出更多有用的信息
 */
+ (void)enableDebug;

/**
 *  点击 button 自动添加 PTP 信息
 */
+ (void)enableButtonSwizzle;

/**
 *  设置 Delegate，当 PTP 生成时会通知它
 */
+ (void)setDelegate:(id <MGJPTPDelegate>)delegate;

/**
 *  设置哪些 button Class 要被忽略
 *
 *  @param buttonClasses
 */
+ (void)setExcludedButtonClasses:(NSArray *)buttonClasses;

/**
 * 生成验证码，也就是 e 字段
 */
+ (NSString *)verifyCode;

/**
 *  根据 requestURL 来生成 page 模板，比如 amj0.a0b1.0.0.2c7
 *
 *  @param requestURL 用于统计的 URL
 *
 *  @return 类似 amj0.a0b1.0.0.2c7
 */
+ (NSString *)generatePageTemplateWithRequestURL:(NSString *)requestURL;

/**
 *  根据触发事件的 view 生成 PTP ，其他的信息会自动通过 responderChain 结合 Protocol 来获取
 */
+ (NSString *)generatePTPWithTriggerView:(UIView *)view;

/**
 *  根据触发事件的 view 和 position 生成 PTP，常用于被复用的 Cell
 *
 *  @param view
 *  @param position 该 view 所在的位置信息
 *
 *  @return
 */
+ (NSString *)generatePTPWithTriggerView:(UIView *)view position:(NSInteger)position;

/**
 *  根据触发事件的 view, position 和 模块名称 来生成 PTP，用于处理一些特殊情况
 */
+ (NSString *)generatePTPWithTriggerView:(UIView *)view position:(NSInteger)position moduleName:(NSString *)moduleName;

/**
 *  根据 postion / module / page 生成 PTP
 */
+ (NSString *)generatePTPWithPosition:(NSInteger)position module:(id)module page:(id)page;
@end
