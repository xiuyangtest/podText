//
//  MGJBadgeView.h
//  MGJiPhoneSDK
//
//  Created by kunka on 14-6-11.
//  Copyright (c) 2014年 juangua. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  badgeview 的基类
 */
@interface MGJBadgeView : UIView
{
    NSInteger _badgeNum;
}

/**
 *  badge 数字
 */
@property (nonatomic, assign) NSInteger badgeNum;
@end
