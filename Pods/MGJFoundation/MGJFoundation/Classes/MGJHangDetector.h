//
//  MGJHangDetector.h
//  MGJFoundation
//
//  Created by limboy on 12/12/14.
//  Copyright (c) 2014 juangua. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 *  当主线程阻塞时会发出该通知
 */
extern NSString * const MGJHangDetectorNotification;

/**
 *  可以使用该类来检测主线程是否被阻塞
 *  实现原理是每隔 N 秒去 ping 一下主线程，如果没有响应说明被阻塞，此时会发送 Notification
 *  该 Notificaiton 里包含了必要的信息，如调用堆栈，View树，Controllers等
 */
@interface MGJHangDetector : NSObject

+ (void)startHangDetector;

// 每隔多长时间 ping 一下主线程
+ (void)startHangDetectorWithTimeInterval:(CGFloat)timeInterval;

@end
