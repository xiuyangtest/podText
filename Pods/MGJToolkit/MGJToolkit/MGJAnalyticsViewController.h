//
//  MGJAnalyticsViewController.h
//  MGJAnalytics
//
//  Created by limboy on 12/3/14.
//  Copyright (c) 2014 mogujie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGJPagePerformance.h"

/**
 *  如果需要用到统计，请继承此类
 */
@interface MGJAnalyticsViewController : UIViewController

/**
 *  是否记录当前页面的访问路径
 *  对于一些 ViewController Container 可以将该值设为 YES
 *  默认会在 `viewWillDisappear` 时将该值设为 YES，避免 pop 回来时又进行了一次 track
 */
@property (nonatomic) BOOL disableTrackPageAnalytics;

/**
 *  当 `viewWillDissAppear` 时，是否要继续 track page
 *  比如当在 Tabbar 的 VC 之间切换时，会需要统计各个 Tab 的点击情况，此时可以将该值设为 YES
 */

@property (nonatomic) BOOL enableTrackPageAnalyticsAfterViewWillDisappear;

/**
 *  用于统计的 requestURL
 */
@property (nonatomic) NSString *requestURLForAnalytics;

/**
 *  页面事件带的额外参数
 */
@property (nonatomic) NSMutableDictionary *requestParametersForAnalytics;

/**
 *  用来统计页面性能的一个东东
 */
@property (nonatomic, readonly) MGJPagePerformance *pagePerformance;


/**
 *  这个用来临时记一下 requestURL，在 viewDidAppear 时，看一下，如果自己没有 requestURLForAnalytics
 *  就使用这个值
 *
 *  @param requestURL
 */
+ (void)setRequestURLForAnalytics:(NSString *)requestURL;

/**
 * 这个用来临时记一下 requestParams，在 viewDidAppear 时，看一下，如果自己没有 requestParams
 *  就使用这个值
 *
 *  @param requestParams
 */
+ (void)setRequestURLParametersForAnalytics:(NSDictionary *)requestParams;

@end
