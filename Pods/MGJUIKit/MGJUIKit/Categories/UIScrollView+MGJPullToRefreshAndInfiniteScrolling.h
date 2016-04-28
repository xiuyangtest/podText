//
//  UIScrollView+MGJDataState.h
//  Example
//
//  Created by limboy on 2/3/15.
//  Copyright (c) 2015 juangua. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIScrollView+SVPullToRefresh.h"
#import "UIScrollView+SVInfiniteScrolling.h"

typedef NS_ENUM(NSUInteger, MGJScrollViewDataState) {
    MGJScrollViewDataStateNormal,
    MGJScrollViewDataStateDisablePullToRefresh,
    MGJScrollViewDataStateDisableInfiniteScroll,
    
    MGJScrollViewDataStateNoData,
    MGJScrollViewDataStateNoMoreData,
    MGJScrollViewDataStateDataError,
};

@interface UIScrollView (MGJPullToRefreshAndInfiniteScrolling)

// 当没有数据时，呈现的 View，比如「没有更多了」
@property (nonatomic) UIView *noMoreDataView;

// 没有拿到数据时，呈现的 View
@property (nonatomic) UIView *noDataView;

// 由于网络等原因，获取数据失败时，显示的 View
@property (nonatomic) UIView *errorView;

// 处于不同的状态时，手动切换这个值
@property (nonatomic) MGJScrollViewDataState dataState;
@end
