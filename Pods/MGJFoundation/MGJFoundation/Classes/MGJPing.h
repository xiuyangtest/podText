#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    MGJPingStatusSuccess,
    MGJPingStatusFail,
    MGJPingStatusTimeout,
} MGJPingStatus;

@interface MGJPingResult: NSObject
@property (nonatomic) MGJPingStatus status;
@property (nonatomic) NSTimeInterval time;
@end

@interface MGJPing : NSObject

+ (void)pingAddress:(NSString *)address completion:(void (^)(MGJPingResult *result))completion;

+ (void)pingAddress:(NSString *)address timeout:(NSInteger)timeout completion:(void (^)(MGJPingResult *result))completion;

+ (void)pingRequest:(NSURLRequest *)request verifyString:(NSString *)verifyString completion:(void (^)(MGJPingResult *result))completion;

@end