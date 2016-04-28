//
//  UIScrollView+SVDataState.m
//  Example
//
//  Created by limboy on 2/3/15.
//  Copyright (c) 2015 juangua. All rights reserved.
//

#import "UIScrollView+MGJPullToRefreshAndInfiniteScrolling.h"
#import <BlocksKit/UIView+BlocksKit.h>

#import <objc/runtime.h>

@implementation UIScrollView (MGJPullToRefreshAndInfiniteScrolling)

@dynamic dataState, noDataView, noMoreDataView, errorView;

- (void)showNoDataView
{
    if (self.noDataView) {
        self.noDataView.hidden = NO;
        CGRect frame = self.noDataView.frame;
        frame.origin.x = (self.frame.size.width - frame.size.width) / 2;
        self.noDataView.frame = frame;
        [self addSubview:self.noDataView];
    }
}

- (void)showNoMoreDataView
{
    if (self.noMoreDataView) {
        self.noMoreDataView.hidden = NO;
        CGRect frame = self.noMoreDataView.frame;
        frame.origin.x = (self.frame.size.width - frame.size.width) / 2;
        frame.origin.y = self.contentSize.height + (self.contentInset.bottom - frame.size.height) / 2;
        self.noMoreDataView.frame = frame;
        [self addSubview:self.noMoreDataView];
    }
}

- (void)showErrorView
{
    if (self.errorView) {
        self.errorView.hidden = NO;
        CGRect frame = self.errorView.frame;
        frame.origin.x = (self.frame.size.width - frame.size.width) / 2;
        self.errorView.frame = frame;
        [self addSubview:self.errorView];
    }
}

#pragma mark - Synthesizer

- (void)setDataState:(MGJScrollViewDataState)dataState
{
    objc_setAssociatedObject(self, @selector(dataState), @(dataState), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (dataState == MGJScrollViewDataStateNormal) {
        self.errorView.hidden = YES;
        self.noDataView.hidden = YES;
        self.noMoreDataView.hidden = YES;
        if (self.infiniteScrollingView) {
            self.showsInfiniteScrolling = YES;
            self.infiniteScrollingView.enabled = YES;
        }
    } else if (dataState == MGJScrollViewDataStateNoData) {
        self.errorView.hidden = YES;
        self.noMoreDataView.hidden = YES;
        [self showNoDataView];
        if (self.infiniteScrollingView) {
            self.showsInfiniteScrolling = NO;
        }
    } else if (dataState == MGJScrollViewDataStateDataError) {
        self.noMoreDataView.hidden = YES;
        self.noDataView.hidden = YES;
        [self showErrorView];
        if (self.infiniteScrollingView) {
            self.showsInfiniteScrolling = NO;
        }
    } else if (dataState == MGJScrollViewDataStateNoMoreData) {
        self.noDataView.hidden = YES;
        self.errorView.hidden = YES;
        [self showNoMoreDataView];
        if (self.infiniteScrollingView) {
            self.infiniteScrollingView.enabled = NO;
        }
    } else if (dataState == MGJScrollViewDataStateDisablePullToRefresh) {
        if (self.pullToRefreshView) {
            self.showsPullToRefresh = NO;
        }
    } else if (dataState == MGJScrollViewDataStateDisableInfiniteScroll) {
        if (self.infiniteScrollingView) {
            self.showsInfiniteScrolling = NO;
        }
    }
}

- (MGJScrollViewDataState)dataState
{
    NSNumber *state = objc_getAssociatedObject(self, @selector(dataState));
    return [state integerValue];
}

- (void)setNoMoreDataView:(UIView *)noMoreDataView
{
    objc_setAssociatedObject(self, @selector(noMoreDataView), noMoreDataView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView *)noMoreDataView
{
    return objc_getAssociatedObject(self, @selector(noMoreDataView));
}

- (UIView *)noDataView
{
    return objc_getAssociatedObject(self, @selector(noDataView));
}

- (void)setNoDataView:(UIView *)noDataView
{
    objc_setAssociatedObject(self, @selector(noDataView), noDataView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView *)errorView
{
    return objc_getAssociatedObject(self, @selector(errorView));
}

- (void)setErrorView:(UIView *)errorView
{
    if (errorView && self.errorView != errorView) {
        [errorView bk_whenTapped:^{
            [self triggerPullToRefresh];
        }];
    }
    objc_setAssociatedObject(self, @selector(errorView), errorView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


@end
