//
//  MGJAnalytics.h
//  MGJAnalytics
//
//  Created by limboy on 12/1/14.
//  Copyright (c) 2014 mogujie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MGJSocketPerformanceParameters : NSObject
/**
 *  socket 接口的 sid
 */
@property (nonatomic, copy) NSString *sid;

/**
 *  socket 接口 的 cid
 */
@property (nonatomic, copy) NSString *cid;
/**
 *  socket 状态码
 */
@property (nonatomic, assign) NSInteger statusCode;
/**
 *  这次请求总共花费的时间
 */
@property (nonatomic, assign) NSInteger requestTime;
/**
 *  请求数据的大小 (byte)
 */
@property (nonatomic, assign) long long requestSize;
/**
 *  返回结果的大小 (byte)
 */
@property (nonatomic, assign) long long responseSize;
/**
 *  业务码，跟状态码不同，跟业务相关
 */
@property (nonatomic, assign) NSInteger resultCode;


/**
 *  api 版本
 */
@property (nonatomic, copy) NSString *apiver;

/**
 *  服务器 ip
 */
@property (nonatomic, copy) NSString *ip;

/**
 *  端口
 */
@property (nonatomic, assign) NSUInteger port;

@end

#pragma mark - MGJPerformanceParameters

@interface MGJPerformanceParameters : NSObject
/**
 *  请求路径，如 nmapi/system/v1/welcome/pop
 */
@property (nonatomic, strong) NSString *requestPath;
/**
 *  状态码，如 200
 */
@property (nonatomic, assign) NSInteger statusCode;
/**
 *  这次请求总共花费的时间
 */
@property (nonatomic, assign) NSInteger requestTime;
/**
 *  请求数据的大小 (byte)
 */
@property (nonatomic, assign) long long requestSize;
/**
 *  返回结果的大小 (byte)
 */
@property (nonatomic, assign) long long responsSize;
/**
 *  业务码，跟状态码不同，跟业务相关
 */
@property (nonatomic, assign) NSInteger resultCode;
/**
 *  错误信息
 */
@property (nonatomic, strong) NSString *errorMessage;

/**
 *  Host，如果 Host 有问题的话，可能会产生 404
 */
@property (nonatomic, copy) NSString *host;

/**
 *  请求发生时的 IP
 */
@property (nonatomic, copy) NSString *ip;


/**
 *  resonse header 里的 server
 */
@property (nonatomic, copy) NSString *server;

/**
 *  resonse header 里的 z-server
 */
@property (nonatomic, copy) NSString *zServer;

/**
 *  resonse header 里的 z-proxy
 */
@property (nonatomic, copy) NSString *zProxy;

/**
 *  跟 z-server 一样，作为备用
 */
@property (nonatomic, copy) NSString *backend;

@end

#pragma mark - MGJAnalyticsDataSource

@protocol MGJAnalyticsDataSource <NSObject>

@optional
- (NSString *)analyticsUserID;

/**
 *  本地时间与服务器传回来的时间的差值
 */
- (double)analyticsTimeOffsetBetweenServerAndLocal;

/**
 *  从服务端获取的最大文件尺寸
 */
- (NSInteger)analyticsFilesizeThreshold;

/**
 *  从服务端获取的发送时间间隔
 */
- (NSInteger) analyticsTimeIntervalThreshold;

@end


#pragma mark - MGJAnalytics

/**
 *  联网状态
 */
typedef NS_ENUM(NSInteger, MGJAnalyticsNetworkStatus){
    MGJAnalyticsNetworkStatusUnknown,
    MGJAnalyticsNetworkStatus2G,
    MGJAnalyticsNetworkStatus3G,
    MGJAnalyticsNetworkStatus4G,
    MGJAnalyticsNetworkStatusWiFi,
    MGJAnalyticsNetworkStatusWWAN,
};

extern NSInteger const MGJAnalyticsRefererCountToSend;

typedef void(^MGJPerformanceParametersHandler)(MGJPerformanceParameters *performanceParameters);

typedef BOOL (^MGJShouldProcessThisObject)(id obj);

/**
 *  设置要统计的App名称
 */
typedef NS_ENUM(NSInteger, MGJAnalyticsAppName){
    /**
     *  蘑菇街iPhone主应用
     */
    MGJAnalyticsAppNameMoGuJie = 0,
    /**
     *  蘑菇街iPad主应用
     */
    MGJAnalyticsAppNameMoGuJieHD = 2,
    /**
     *  Top iPhone
     */
    MGJAnalyticsAppNameTop = 3,
    
    /**
     *  小店
     */
    MGJAnalyticsAppNameXiaoDian = 5,
    
    /**
     *  uni
     */
    MGJAnalyticsAppNameUni = 7,
    
    /**
     *  uni
     */
    MGJAnalyticsAppNameKongKong = 13,
};

/**
 * 用于统计页面访问，事件，网络请求，设备启动
 */
@interface MGJAnalytics : NSObject

/**
 *  来源URL
 */
@property (nonatomic, copy) NSString *refererURL;

/**
 *  当前URL
 */
@property (nonatomic, copy) NSString *currentURL;

/**
 *  是否发送 referer URL 链路
 */
@property (nonatomic, assign) BOOL sendRefererURLChain;


/**
 *  referURL 数组
 */
@property (nonatomic) NSMutableArray *refererArray;


/**
 *  一些额外信息的数据源
 */
@property (nonatomic) id <MGJAnalyticsDataSource> dataSource;

/**
 *  如果不提供的话，将使用默认值
 */
@property (nonatomic, copy) NSString *serverBaseURL;

/**
 *  是否开启调试模式，是的话，会输出一些可能有用的信息
 */
@property (nonatomic, assign) BOOL enableDebug;

/**
 *  通过设置这个属性，可以将某些类排除在统计外，如 Container VC，注意：是类名称
 */
@property (nonatomic) NSMutableArray *excludedClassNames;

/**
 * 如果不想处理这个 object 的话，返回 NO 即可
 */
@property (nonatomic, copy) MGJShouldProcessThisObject shouldProcessThisObject;

/**
 *  点击 button 时或页面将要跳转时，设置该值，方便下一个页面获取
 */
@property (nonatomic, copy) NSString *ptpURL;

/**
 * 上一个页面的 ptpURL
 */
@property (nonatomic, copy) NSString *ptpRef;

/**
 *  当前页面的 cnt，比如 a.b.0.0.e
 */
@property (nonatomic, copy, readwrite) NSString *ptpCnt;

/**
 *  可以让外部设置的一个属性，主要用在 SKU 上
 */
@property (nonatomic, copy) NSString *ptpFrom;

/**
 *  根据 pageRequestURL 生成 ptpCnt
 *
 *  @param pageRequestURL 就是 MGJAnalyticsVC 里的 requestURLForAnalytics 属性
 *
 *  @return a.b.0.0.e
 */
- (NSString *)ptpCntWithPageRequestURL:(NSString *)pageRequestURL;

/**
 *  先调用此方法来进行初始化设置
 *
 *  @param appName 当前App名字
 *  @param channel 来源渠道
 *  @param version 版本号，如 702，不是系统版本号
 *
 *  @return self
 */
+ (void)startWithAppName:(MGJAnalyticsAppName)appName channel:(NSString *)channel version:(NSInteger)version DEPRECATED_MSG_ATTRIBUTE("已改为读取 Bundle 中的版本号，请使用 startWithAppName:channel:");

/**
 *  先调用此方法来进行初始化设置
 *
 *  @param appName 当前App名字
 *  @param channel 来源渠道
 */
+ (void)startWithAppName:(MGJAnalyticsAppName)appName channel:(NSString *)channel;

/**
 *  获取单例的方法
 *
 *  @return self
 */
+ (instancetype)sharedInstance;

/**
 * 调用这个方法可以直接写入 ptp_url 和 ptp_cnt
 */
+ (void)trackPTPURL:(NSString *)ptpURL andPTPCnt:(NSString *)ptpCnt;

/**
 *  记录页面的访问路径
 *
 *  @param requestURL 页面的请求URL
 *  @param parameters 如果有多余的参数可以在这里提供
 */
+ (void)trackPageWithRequestURL:(NSString *)requestURL parameters:(NSDictionary *)parameters;

/**
 *  记录事件
 *
 *  @param event      事件名称
 *  @param parameters 如果该事件有相关参数，可以在这里提供
 */
+ (void)trackEvent:(NSString *)event parameters:(NSDictionary *)parameters;

/**
 *  统计某断代码执行时间，默认的时间参数 key 为 time，单位毫秒
 *
 *  @param block      要统计的代码
 *  @param event      时间名称
 *  @param key        时间参数的 key
 *  @param parameters 其他额外参数
 */
+ (void)trackTimeExpend:(void(^)())block event:(NSString *)event timeKey:(NSString *)key parameters:(NSDictionary *)parameters;

/**
 *  记录网络请求状况
 *
 *  @param handler 会传入一个 `MGJPerformanceParameters` instance，设置它的一些属性即可
 */
+ (void)trackNetworkPerformanceWithHandler:(MGJPerformanceParametersHandler)handler;

/**
 *  记录 socket 连接情况
 *
 *  @param parameters 统计参数
 */
+ (void)trackSocketPerformanceWithParameters:(MGJSocketPerformanceParameters *)parameters;


/**
 *  开始记录消耗时间，如果多次使用相同event调用该方法，则以最新一次调用为起始时间
 *
 *  @param event 事件名称
 */
+ (void)startTrackTimeConsumptionWithEvent:(NSString*)event;

/**
 *  结束记录消耗时间（以毫秒为单位整数），如果多次使用相同event调用改方法，则以第一次有效，后面的调用无效
 *
 *  @param event 事件名称
 *  @param parameters 如果该事件有相关参数，可以在这里提供
 *
 */
+ (void)stopTrackTimeConsumptionWithEvent:(NSString*)event parameters:(NSDictionary *)parameters;

/**
 *  当前联网方式
 *
 *  @return 
 */
+ (MGJAnalyticsNetworkStatus)networkStatus;

/**
 *  是否开启 socket 统计
 *
 *  @param enabled
 */
+ (void)enableTrackingSocketPerformance:(BOOL)enabled;
@end
