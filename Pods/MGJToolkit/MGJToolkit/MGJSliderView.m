//
//  MGJSliderView.m
//  MogujieHD
//
//  Created by xinba on 9/11/14.
//  Copyright (c) 2014年 juangua. All rights reserved.
//

#import "MGJSliderView.h"
#import "NSString+MGJKit.h"
#import <MGJUIKit/UIView+MGJKit.h>

#define SlideView_Font12 [UIFont systemFontOfSize:12.0f]


@implementation MGJPageView
- (instancetype)initWithPageNumber:(NSInteger)number {
    CGSize textSize = [[NSString stringWithFormat:@"%zd/%zd", number, number] mgj_sizeWithFont:SlideView_Font12];
    self = [super initWithFrame:CGRectMake(0, 0, textSize.width + 20.f, 20.f)];
    if (self) {
        self.layer.cornerRadius = self.height / 2;
        self.clipsToBounds = YES;
        self.backgroundColor = [[UIColor alloc] initWithRed:0 green:0 blue:0 alpha:0.3];
        self.numberOfPages = number;
        
        [self addSubview:self.textLabel];
        
        self.currentPage = 0;
    }
    return self;
}

- (void)setCurrentPage:(NSInteger)currentPage
{
    if (currentPage < 0)
    {
        _currentPage = 0;
    }
    else if (currentPage > self.numberOfPages)
    {
        _currentPage = self.numberOfPages;
    }
    else
    {
        _currentPage = currentPage;
    }
    self.textLabel.text = [NSString stringWithFormat:@"%ld/%ld", _currentPage + 1, (long)self.numberOfPages];
}

- (void)setNumberOfPages:(NSInteger)numberOfPages
{
    if (numberOfPages < 0) {
        _numberOfPages = 0;
    }
    else
    {
        _numberOfPages = numberOfPages;
    }
    if (_numberOfPages <= 1) {
        self.hidden = YES;
    }
    else
    {
        self.hidden = NO;
    }
    CGSize textSize = [[NSString stringWithFormat:@"%ld/%ld", (long)numberOfPages, (long)numberOfPages] mgj_sizeWithFont:SlideView_Font12];
    
    self.width = textSize.width + 20.f;
    self.textLabel.width = self.width;
    self.currentPage = 0;
}

-(UILabel *)textLabel{
    if (!_textLabel) {
        _textLabel = [[UILabel alloc] initWithFrame:self.bounds];
        _textLabel.backgroundColor = [UIColor clearColor] ;
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.textColor = [UIColor whiteColor];
        _textLabel.font = SlideView_Font12;
    }
    return _textLabel;
}
@end


static const float SliderBannerChangeInterval = 4.0f;

static const double SliderAutoScrollDuration = 0.4;

@interface MGJSliderView ()
@property(nonatomic, strong) NSTimer *timer;
@property(nonatomic, assign) MGJSliderViewPageControlStyle style;
@property(nonatomic, assign) MGJSliderViewPageControlAlignment alignment;
@property(nonatomic, strong) MGJPageView *pageView;
@end

@implementation MGJSliderView {

}

@synthesize pageControl = pageControl;


- (instancetype)initWithFrame:(CGRect)frame style:(MGJSliderViewPageControlStyle)style alignment:(MGJSliderViewPageControlAlignment)alignment
{
    self = [super initWithFrame:frame];
    if (self) {
        self.style = style;
        self.alignment = alignment;
        [self setupViews];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame style:MGJSliderViewPageControlStyleDot alignment:MGJSliderViewPageControlAlignmentCenter];
}

#pragma mark View Life

- (void)setupViews {
    if (nil == _swipeView) {
        _swipeView = [[SwipeView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
        _swipeView.backgroundColor = [UIColor clearColor];
        _swipeView.delegate = self;
        _swipeView.dataSource = self;
        _swipeView.pagingEnabled = YES;
        [self addSubview:_swipeView];
    }

    if (nil == pageControl && self.style == MGJSliderViewPageControlStyleDot) {
        pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 0, self.width, 10)];
        pageControl.bottom = self.height - 3;
        pageControl.hidesForSinglePage = YES;
        pageControl.userInteractionEnabled = NO;
        pageControl.currentPageIndicatorTintColor = [UIColor colorWithRed:255 / 255.0f green:87 / 255.0f blue:119 / 255.0f alpha:1.0f];
        pageControl.pageIndicatorTintColor = [UIColor whiteColor];
        [self addSubview:pageControl];
    }
    
    if (nil == self.pageView && self.style == MGJSliderViewPageControlStyleNumber) {
        self.pageView = [[MGJPageView alloc] initWithPageNumber:0];
        self.pageView.bottom = self.height - 10.f;
        [self addSubview:self.pageView];
    }
}

#pragma mark Properties

- (NSInteger)totalItemCount {
    return _swipeView.numberOfItems;
}

- (NSInteger)currentIndex {
    return _swipeView.currentItemIndex;
}

- (void)setCurrentIndex:(NSInteger)currentIndex {
    _swipeView.currentItemIndex = currentIndex;
}


- (BOOL)wrapEnabled {
    return _swipeView.wrapEnabled;
}

- (void)setWrapEnabled:(BOOL)wrapEnabled {
    _swipeView.wrapEnabled = wrapEnabled;
}


- (void)setAutoScroll:(BOOL)autoScroll {
    _autoScroll = autoScroll;
    if (_autoScroll) {
        [self startAnimation];
    }
    else {
        [self stopAnimation];
    }
}


#pragma mark Animation

- (void)stopAnimation {
    if ([_timer isValid]) {
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)startAnimation {
    if (!_timer) {
        float timerInterval = self.sliderBannerChangeInterval > 0 ? self.sliderBannerChangeInterval : SliderBannerChangeInterval;
        self.timer = [NSTimer scheduledTimerWithTimeInterval:timerInterval
                                                      target:self
                                                    selector:@selector(step)
                                                    userInfo:nil
                                                     repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSDefaultRunLoopMode];
        [[NSRunLoop mainRunLoop] addTimer:_timer forMode:UITrackingRunLoopMode];
    }
}

- (void)step {
    if (!_swipeView.isScrolling) {
        [_swipeView scrollToItemAtIndex:_swipeView.currentItemIndex + 1 duration:SliderAutoScrollDuration];
    }
}

- (void)didMoveToWindow {
    [super didMoveToWindow];
    if (self.window && self.autoScroll) {
        [self startAnimation];
    }
    else{
        [self stopAnimation];
    }
}


#pragma mark SliderView DataSource

- (NSInteger)numberOfItemsInSwipeView:(SwipeView *)swipeView {
    if ([self.dataSource respondsToSelector:@selector(numberOfItemsInSliderView:)]) {
        return [self.dataSource numberOfItemsInSliderView:self];
    }
    return 0;
}

- (UIView *)swipeView:(SwipeView *)swipeView viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view {
    if ([self.dataSource respondsToSelector:@selector(sliderView:viewForItemAtIndex:reusingView:)]) {
        return [self.dataSource sliderView:self viewForItemAtIndex:index reusingView:view];
    }
    return nil;
}

- (CGSize)swipeViewItemSize:(SwipeView *)swipeView {
    if ([self.dataSource respondsToSelector:@selector(sliderViewItemSize:)]) {
        return [self.dataSource sliderViewItemSize:self];
    }
    return swipeView.bounds.size;
}

- (void)reloadData {
    [_swipeView reloadData];
    _swipeView.currentPage = 0;
    [self reloadPageControl];
}

- (void)reloadPageControl {
    if (self.pageControl){
        pageControl.width = self.width;
        pageControl.centerX = self.width / 2;
        pageControl.numberOfPages = _swipeView.numberOfPages;
        
        CGSize size = [pageControl sizeForNumberOfPages:_swipeView.numberOfPages];
        pageControl.width = size.width;
        pageControl.currentPage = 0;
        
        if (self.alignment == MGJSliderViewPageControlAlignmentLeft) {
            pageControl.left = 10.f;
        }
        else if (self.alignment == MGJSliderViewPageControlAlignmentRight)
        {
            pageControl.right = self.width - 10.f;
        }
        else
        {
            pageControl.centerX = self.width / 2;
        }
        
        if (_swipeView.numberOfPages <= 1 && self.disableScrollOnlyOneImage) {
            _swipeView.scrollEnabled = NO;
        }
        
        //pageControl 未选中颜色自定义
        if (_pageIndicatorTintColor) {
            pageControl.pageIndicatorTintColor = _pageIndicatorTintColor;
        }
        //pageControl 选中颜色自定义
        if (_currentPageIndicatorTintColor) {
            pageControl.currentPageIndicatorTintColor = _currentPageIndicatorTintColor;
        }
    }
    
    if (self.pageView) {
        self.pageView.numberOfPages = _swipeView.numberOfPages;
        self.pageView.currentPage = 0;
        if (self.alignment == MGJSliderViewPageControlAlignmentLeft)
        {
            self.pageView.left = 10.f;
        }
        else if (self.alignment == MGJSliderViewPageControlAlignmentCenter)
        {
            self.pageView.centerX = self.width / 2;
        }
        else
        {
            self.pageView.right = self.width - 10.f;
        }
    }
}


#pragma mark SwipeView Delegate

- (void)scrollToItemAtIndex:(NSInteger)index {
    [_swipeView scrollToItemAtIndex:index duration:SliderAutoScrollDuration];
}

- (void)swipeViewCurrentItemIndexDidChange:(SwipeView *)swipeView {
    pageControl.currentPage = swipeView.currentItemIndex;
    self.pageView.currentPage = swipeView.currentItemIndex;
    if ([self.delegate respondsToSelector:@selector(sliderView:didSliderToIndex:)]) {
        [self.delegate sliderView:self didSliderToIndex:swipeView.currentItemIndex];
    }

}

- (void)swipeView:(SwipeView *)swipeView didSelectItemAtIndex:(NSInteger)index {
    if ([self.delegate respondsToSelector:@selector(sliderView:didSelectViewAtIndex:)]) {
        [self.delegate sliderView:self didSelectViewAtIndex:index];
    }

}

- (void)swipeViewDidScroll:(SwipeView *)swipeView {
    if ([self.delegate respondsToSelector:@selector(sliderViewDidScroll:)]) {
        [self.delegate sliderViewDidScroll:self];
    }
}

- (void)swipeViewWillBeginDragging:(SwipeView *)swipeView {
    if (self.autoScroll) {
        [self stopAnimation];
    }

    if ([self.delegate respondsToSelector:@selector(sliderViewWillBeginDragging:)]) {
        [self.delegate sliderViewWillBeginDragging:self];
    }
}

- (void)swipeViewDidEndDragging:(SwipeView *)swipeView willDecelerate:(BOOL)decelerate {
    if (self.autoScroll) {
        [self startAnimation];
    }
    if ([self.delegate respondsToSelector:@selector(sliderViewDidEndDragging:willDecelerate:)]) {
        [self.delegate sliderViewDidEndDragging:self willDecelerate:decelerate];
    }
}

- (void)swipeViewWillBeginDecelerating:(SwipeView *)swipeView {
    if ([self.delegate respondsToSelector:@selector(sliderViewWillBeginDecelerating:)]) {
        [self.delegate sliderViewWillBeginDecelerating:self];
    }
}

- (void)swipeViewDidEndDecelerating:(SwipeView *)swipeView {
    if ([self.delegate respondsToSelector:@selector(sliderViewDidEndDecelerating:)]) {
        [self.delegate sliderViewDidEndDecelerating:self];
    }
}

- (void)swipeViewDidEndScrollingAnimation:(SwipeView *)swipeView {
    if ([self.delegate respondsToSelector:@selector(sliderViewDidEndScrollingAnimation:)]) {
        [self.delegate sliderViewDidEndScrollingAnimation:self];
    }
}

@end

