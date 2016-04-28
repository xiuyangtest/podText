//
//  MGJSliderView.h
//  MogujieHD
//
//  Created by xinba on 9/11/14.
//  Copyright (c) 2014年 juangua. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SwipeView/SwipeView.h>

/**
 *  MGJSliderView 的 PageControl 样式
 */
typedef NS_ENUM(NSInteger, MGJSliderViewPageControlStyle){
    /**
     *  点
     */
    MGJSliderViewPageControlStyleDot,
    /**
     *  数字
     */
    MGJSliderViewPageControlStyleNumber,
};

/**
 *  MGJSliderView 的 PageControl 对齐方式
 */
typedef NS_ENUM(NSInteger, MGJSliderViewPageControlAlignment){
    /**
     *  左对齐
     */
    MGJSliderViewPageControlAlignmentLeft      = 0,
    /**
     *  居中对齐
     */
    MGJSliderViewPageControlAlignmentCenter    = 1,
    /**
     *  右对齐
     */
    MGJSliderViewPageControlAlignmentRight     = 2,
};

@interface MGJPageView : UIView
- (instancetype)initWithPageNumber:(NSInteger)number;
@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, assign) NSInteger numberOfPages;
@end

@protocol MGJSliderViewDelegate;
@protocol MGJSliderViewDataSource;


@interface MGJSliderView : UIView <SwipeViewDelegate, SwipeViewDataSource>
@property(nonatomic, readonly) UIPageControl *pageControl;
@property(nonatomic, readonly) MGJPageView *pageView;
@property(nonatomic, readonly) SwipeView *swipeView;
@property(nonatomic) float sliderBannerChangeInterval;

@property(nonatomic, weak) id <MGJSliderViewDelegate> delegate;
@property(nonatomic, weak) id <MGJSliderViewDataSource> dataSource;

/**
 *  创建 sliderview
 *
 *  @param frame frame
 *  @param style pagecontrol 样式
 *  @param alignment pagecontrol 对齐方式
 *
 *  @return
 */
- (instancetype)initWithFrame:(CGRect)frame style:(MGJSliderViewPageControlStyle)style alignment:(MGJSliderViewPageControlAlignment)alignment;

/**
* 所有页面的数量
*/
@property(nonatomic, readonly) NSInteger totalItemCount;

/**
* 现在页面的索引
*/
@property(nonatomic, assign) NSInteger currentIndex;

/**
* 是否启用循环滚动
*/
@property(nonatomic, assign) BOOL wrapEnabled;

/**
* 是否启用自动滚动
*/
@property(nonatomic, assign) BOOL autoScroll;


/**
* 当只有一张图片的时候禁用滚动
*/
@property(nonatomic) BOOL disableScrollOnlyOneImage;

/**
 * 使用自定义的pageControl选中的颜色
 */
@property(nonatomic, strong) UIColor *currentPageIndicatorTintColor;

/**
 * 使用自定义的pageControl未选中的颜色
 */
@property(nonatomic, strong) UIColor *pageIndicatorTintColor;

/**
* 重载数据
*/
- (void)reloadData;

/**
* 滚动到指定的项
*/
- (void)scrollToItemAtIndex:(NSInteger)index;

@end


/**
*  SliderViewDelegate
*/
@protocol MGJSliderViewDelegate <NSObject>
@optional
/**
*  选中了 SliderView 中某个 cell
*
*  @param swipeView swipeView
*  @param index      cell 的索引
*/
- (void)sliderView:(MGJSliderView *)sliderView didSelectViewAtIndex:(NSInteger)index;

/**
*  SliderView 滚动到某个 cell
*
*  @param swipeView swipeView
*  @param index      cell 的索引
*/
- (void)sliderView:(MGJSliderView *)sliderView didSliderToIndex:(NSInteger)index;

- (void)sliderViewDidScroll:(MGJSliderView *)sliderView;

- (void)sliderViewWillBeginDragging:(MGJSliderView *)sliderView;

- (void)sliderViewDidEndDragging:(MGJSliderView *)sliderView willDecelerate:(BOOL)decelerate;

- (void)sliderViewWillBeginDecelerating:(MGJSliderView *)sliderView;

- (void)sliderViewDidEndDecelerating:(MGJSliderView *)sliderView;

- (void)sliderViewDidEndScrollingAnimation:(MGJSliderView *)sliderView;

@end



/**
*  SliderViewDataSource
*/
@protocol MGJSliderViewDataSource <NSObject>

@required
/**
*  swipeView 中的 cell 数量
*
*  @param swipeView swipeView
*
*  @return cell 数量
*/
- (NSInteger)numberOfItemsInSliderView:(MGJSliderView *)sliderView;

/**
*  某个索引的 view
*
*  @param swipeView swipeView
*  @param index      index
*
*  @return 这个Slider要显示的view
*/
- (UIView *)sliderView:(MGJSliderView *)sliderView viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view;

@optional
/**
 *  设置Item Size
 *
 *  @param sliderView MGJSliderView
 *
 *  @return Item的大小
 */
- (CGSize)sliderViewItemSize:(MGJSliderView *)sliderView;


@end
