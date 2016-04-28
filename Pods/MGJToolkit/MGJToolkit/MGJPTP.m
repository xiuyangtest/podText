//
//  MGJPTP.m
//  Example
//
//  Created by limboy on 12/30/14.
//  Copyright (c) 2014 juangua. All rights reserved.
//

#import "MGJPTP.h"
#import <MGJFoundation.h>
#import <objc/runtime.h>
#import <objc/message.h>
#import <MGJUIKit.h>
#import "MGJAnalyticsViewController.h"
#import "MGJPTPHash.h"
#import <NSString+MGJKit.h>
#import <URLEntity.h>
#import "MGJAnalytics.h"

static NSString *MGJ_PTP_APP_NAME;
static BOOL MGJ_PTP_ENABLE_DEBUG;
static id <MGJPTPDelegate> MGJ_PTP_DELEGATE;
static NSArray *MGJ_PTP_EXCLUDED_BUTTON_CLASSES;

@implementation NSObject (PTP)

- (NSString *)ptpModuleName
{
    return objc_getAssociatedObject(self, @selector(ptpModuleName));
}

- (void)setPtpModuleName:(NSString *)ptpModuleName
{
    objc_setAssociatedObject(self, @selector(ptpModuleName), ptpModuleName, OBJC_ASSOCIATION_COPY_NONATOMIC);
    if ([self isKindOfClass:[UIView class]] && MGJ_PTP_ENABLE_DEBUG) {
        UIView *view = (UIView *)self;
        view.layer.borderColor = [UIColor redColor].CGColor;
        view.layer.borderWidth = 3;
        if (![view mgj_associatedValueForKey:@"ptp"]) {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 20)];
            label.backgroundColor = [UIColor redColor];
            label.text = [NSString stringWithFormat:@" %@ ", view.ptpModuleName];
            label.textColor = [UIColor whiteColor];
            [label sizeToFit];
            [view addSubview:label];
            [view mgj_associateValue:label withKey:@"ptp"];
        } else {
            UILabel *label = [view mgj_associatedValueForKey:@"ptp"];
            label.text = [NSString stringWithFormat:@" %@ ", view.ptpModuleName];
        }
    }
}

@end


@implementation UIControl (PTP)

- (void)setIgnorePTP:(BOOL)ignorePTP
{
    objc_setAssociatedObject(self, @selector(ignorePTP), @(ignorePTP), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)ignorePTP
{
    NSNumber *result = objc_getAssociatedObject(self, @selector(ignorePTP));
    return result ? [result boolValue] : NO;
}

+ (void)mgj_swizzleAddTargetAction
{
    Method originMethod = class_getInstanceMethod([UIControl class], @selector(addTarget:action:forControlEvents:));
    Method newMethod = class_getInstanceMethod(self, @selector(mgj_addTarget:action:forControlEvents:));
    method_exchangeImplementations(originMethod, newMethod);
    
    originMethod = class_getClassMethod([UIControl class], @selector(removeTarget:action:forControlEvents:));
    newMethod = class_getClassMethod(self, @selector(mgj_removeTarget:action:forControlEvents:));
    method_exchangeImplementations(originMethod, newMethod);
}

- (void)mgj_removeTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents
{
    [self mgj_removeTarget:target action:action forControlEvents:controlEvents];
    if (controlEvents == UIControlEventTouchUpInside && ![MGJ_PTP_EXCLUDED_BUTTON_CLASSES containsObject:NSStringFromClass(self.class)]) {
        [self mgj_removeTarget:self action:@selector(mgj_buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)mgj_addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents
{
    if (controlEvents == UIControlEventTouchUpInside && ![MGJ_PTP_EXCLUDED_BUTTON_CLASSES containsObject:NSStringFromClass(self.class)]) {
        [self mgj_addTarget:self action:@selector(mgj_buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
    [self mgj_addTarget:target action:action forControlEvents:controlEvents];
}

- (void)mgj_buttonTapped:(UIControl *)button
{
    if (!self.ignorePTP) {
        [MGJPTP generatePTPWithTriggerView:button];
    }
}
@end



@implementation UIGestureRecognizer (PTP)

- (void)setIgnorePTP:(BOOL)ignorePTP
{
    objc_setAssociatedObject(self, @selector(ignorePTP), @(ignorePTP), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)ignorePTP
{
    NSNumber *result = objc_getAssociatedObject(self, @selector(ignorePTP));
    return result ? [result boolValue] : NO;
}

+ (void)mgj_swizzleAddTargetAction
{
    Method originMethod = class_getInstanceMethod([UIGestureRecognizer class], @selector(addTarget:action:));
    Method newMethod = class_getInstanceMethod(self, @selector(mgj_addTarget:action:));
    method_exchangeImplementations(originMethod, newMethod);
    
    originMethod = class_getClassMethod([UIGestureRecognizer class], @selector(removeTarget:action:));
    newMethod = class_getClassMethod(self, @selector(mgj_removeTarget:action:));
    method_exchangeImplementations(originMethod, newMethod);
    
    originMethod = class_getInstanceMethod([UIGestureRecognizer class], @selector(initWithTarget:action:));
    newMethod = class_getInstanceMethod(self, @selector(mgj_initWithTarget:action:));
    method_exchangeImplementations(originMethod, newMethod);
}

- (instancetype)mgj_initWithTarget:(id)target action:(SEL)action
{
    [self mgj_initWithTarget:target action:action];
    if ([self isMemberOfClass:[UITapGestureRecognizer class]]) {
        [self mgj_addTarget:self action:@selector(mgj_tapped:)];
    }
    return self;
}

- (void)mgj_removeTarget:(id)target action:(SEL)action
{
    [self mgj_removeTarget:target action:action];
    if ([self isMemberOfClass:[UITapGestureRecognizer class]]) {
        [self mgj_removeTarget:self action:@selector(mgj_tapped:)];
    }
}

- (void)mgj_addTarget:(id)target action:(SEL)action
{
    [self mgj_addTarget:target action:action];
    // 如果目标 view 是 scrollView 则不处理
    if ([self isMemberOfClass:[UITapGestureRecognizer class]]) {
        [self mgj_addTarget:self action:@selector(mgj_tapped:)];
    }
}

- (void)mgj_tapped:(UITapGestureRecognizer *)gesture
{
    if (![self.view isKindOfClass:[UIScrollView class]] && !self.ignorePTP) {
        [MGJPTP generatePTPWithTriggerView:gesture.view];
    }
}

@end


@implementation MGJPTP

#pragma mark - Public

+ (void)startWithAppName:(NSString *)appName
{
    MGJ_PTP_APP_NAME = appName;
}

+ (void)enableDebug
{
    MGJ_PTP_ENABLE_DEBUG = YES;
}

+ (void)enableButtonSwizzle
{
    [UIControl mgj_swizzleAddTargetAction];
    [UITapGestureRecognizer mgj_swizzleAddTargetAction];
}

+ (void)setDelegate:(id<MGJPTPDelegate>)delegate
{
    MGJ_PTP_DELEGATE = delegate;
}

+ (void)setExcludedButtonClasses:(NSArray *)buttonClasses
{
    MGJ_PTP_EXCLUDED_BUTTON_CLASSES = buttonClasses;
}

+ (NSString *)generatePageTemplateWithRequestURL:(NSString *)requestURL
{
    return [NSString stringWithFormat:@"%@.%@.0.0.%@", MGJ_PTP_APP_NAME, [self encodePage:requestURL], [self verifyCode]];
}

+ (NSString *)generatePTPWithTriggerView:(UIView *)view
{
    UIResponder *page = [self findPageWithTriggerView:view];
    id module = [self findModuleWithTriggerView:view];
    
    // 再根据模块找到 subView
    UIResponder *subViewOfModule;
    __block NSInteger positionOfParentView = 0;
    
    if (module) {
        // 特殊情况，特殊处理
        if (view == module) {
            subViewOfModule = module;
        } else {
            subViewOfModule = [self responderOfView:view passingTest:^BOOL(UIResponder *responder) {
                return responder.nextResponder == module ? YES : NO;
            }];
        }
    } else {
        // 设置默认的 moduleName
        // 先找到它在父类的位置
        NSString *viewClass = NSStringFromClass(view.class);
        if (view.superview) {
            viewClass = [viewClass stringByAppendingString:NSStringFromClass(view.superview.class)];
            [view.superview.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                if (obj == view) {
                    positionOfParentView = idx;
                }
            }];
        }
        
        module = [MGJPTPHash hashWithInputString:[NSString stringWithFormat:@"%@", viewClass] length:5];
    }
    
    // 根据 subView 找到 position
    NSUInteger position = positionOfParentView;
    __block BOOL shouldUsePostionOfParent = YES;
    if (subViewOfModule) {
        // 特殊情况，特殊处理
        if (module == subViewOfModule) {
            position = 0;
        } else {
            // 对于没找到的情况，统一处理
            __block NSInteger ignoredItemsCount = 0;
            position = [((UIView *)module).subviews indexOfObjectPassingTest:^BOOL(UIView *view, NSUInteger idx, BOOL *stop) {
                // 有可能里面的 Item 并不都是目标 Item，把不是的排除
                if (![view isKindOfClass:[UIControl class]]) {
                    BOOL shouldIgnore = YES;
                    for (UIGestureRecognizer *gesture in view.gestureRecognizers) {
                        if ([gesture isKindOfClass:[UITapGestureRecognizer class]]) {
                            shouldIgnore = NO;
                        }
                    }
                    if (shouldIgnore) {
                        ignoredItemsCount++;
                    }
                }
                if (view == subViewOfModule) {
                    shouldUsePostionOfParent = NO;
                    *stop = YES;
                    return YES;
                }
                return NO;
            }];
            if (shouldUsePostionOfParent) {
                position = positionOfParentView;
            } else {
                position -= ignoredItemsCount;
                position = MAX(position, 0);
            }
        }
    }
    
    return [self generatePTPWithPosition:position module:module page:page];
}

+ (NSString *)generatePTPWithTriggerView:(UIView *)view position:(NSInteger)position
{
    UIResponder *page = [self findPageWithTriggerView:view];
    UIView *module = [self findModuleWithTriggerView:view];
    return [self generatePTPWithPosition:position module:module page:page];
}

+ (NSString *)generatePTPWithTriggerView:(UIView *)view position:(NSInteger)position moduleName:(NSString *)moduleName
{
    if ((MGJ_IS_EMPTY(moduleName) || [moduleName isEqualToString:@"null"])) {
        moduleName = [MGJAnalytics sharedInstance].currentURL;
    }
    UIResponder *page = [self findPageWithTriggerView:view];
    return [self generatePTPWithPosition:position module:moduleName page:page];
}

+ (NSString *)generatePTPWithPosition:(NSInteger)position module:(id)module page:(id)page
{
    if ((MGJ_IS_EMPTY(page) || ([page isKindOfClass:[NSString class]] && [page isEqualToString:@"null"]))) {
        page = [MGJAnalytics sharedInstance].currentURL;
    }
    
    NSString *pageName = [self encodePage:page];
    NSString *moduleName = [self encodeModule:module];
    
    // 如果没找到位置，默认为 0
    if (position == NSNotFound) {
        position = 0;
    } else {
        // 后端需要从1开始
        position += 1;
    }
    // 如果没找到模块，设为0
    if (!moduleName.length) {
        moduleName = @"0";
    }
    
    if (MGJ_PTP_ENABLE_DEBUG) {
        //        NSString *originPageName = [page isKindOfClass:[MGJAnalyticsViewController class]] ?
        //                               ((MGJAnalyticsViewController *)page).requestURLForAnalytics :
        //                                                                                      page ;
        //        pageName = [pageName stringByAppendingString:[NSString stringWithFormat:@"-%@", originPageName]];
        //        moduleName = [moduleName stringByAppendingString:[NSString stringWithFormat:@"-%@", module]];
    }
    NSString *ptp = [NSString stringWithFormat:@"%@.%@.%@.%ld.%@", MGJ_PTP_APP_NAME, pageName, moduleName, (long)position, [self verifyCode]];
    if (MGJ_PTP_DELEGATE) {
        [MGJ_PTP_DELEGATE didGeneratedPTP:ptp];
    }
    return ptp;
}

#pragma mark - Utils

+ (UIView *)findModuleWithTriggerView:(UIView *)view
{
    return (UIView *)[self responderOfView:view passingTest:^BOOL(UIResponder *responder) {
        return responder.ptpModuleName ? YES : NO;
    }];
}

+ (UIResponder *)findPageWithTriggerView:(UIView *)view
{
    return [self responderOfView:view passingTest:^BOOL(UIResponder *responder) {
        MGJAnalyticsViewController *viewController = (MGJAnalyticsViewController *)responder;
        // 实现了 MGJPTPPage 或 requestURLForAnalytics 不为空
        if ([viewController respondsToSelector:@selector(requestURLForAnalytics)] &&
            viewController.requestURLForAnalytics
            && !viewController.disableTrackPageAnalytics
            ) {
            return YES;
        }
        return NO;
    }];
}

+ (UIResponder *)responderOfView:(UIView *)view passingTest:(BOOL (^)(UIResponder *responder))test
{
    UIResponder *responder = view;
    
    while (responder) {
        BOOL shouldStop = test(responder);
        if (shouldStop) {
            return responder;
        }
        responder = responder.nextResponder;
    }
    return nil;
}

+ (NSString *)verifyCode
{
    NSString *randomString = [MGJPTPHash randomStringWithLength:5];
    return [MGJPTPHash attachVerifyToString:randomString];
}

+ (NSString *)encodeModule:(id)module
{
    if (!module) {
        return @"";
    }
    
    NSString *moduleName;
    if ([module isKindOfClass:[NSString class]]) {
        moduleName = module;
    } else {
        moduleName = [module performSelector:@selector(ptpModuleName)];
    }
    
    // 以 _ 开头的为预定义的模块，不做修改
    if (moduleName.length && [[moduleName substringToIndex:1] isEqualToString:@"_"]) {
        return moduleName;
    }
    
    return [MGJPTPHash hashWithInputString:moduleName length:5];
}

+ (NSString *)encodePage:(id)page
{
    if (!page) {
        return @"0";
    }
    NSString *pageName;
    if ([page isKindOfClass:[NSString class]]) {
        pageName = [page componentsSeparatedByString:@"?"][0];
        UrlEntity *pageEntity = [UrlEntity URLWithString:page];
        if (pageEntity.params[@"fcid"]) {
            pageName = [pageName stringByAppendingString:pageEntity.params[@"fcid"]];
        } else if (pageEntity.params[@"mt"]) {
            pageName = [pageName stringByAppendingString:pageEntity.params[@"mt"]];
        }
    } else {
        if ([page isKindOfClass:[MGJAnalyticsViewController class]]) {
            MGJAnalyticsViewController *thePage = (MGJAnalyticsViewController *)page;
            if (thePage.requestURLForAnalytics) {
                // 取出前面一段
                pageName = [thePage.requestURLForAnalytics componentsSeparatedByString:@"?"][0];
                UrlEntity *pageEntity = [UrlEntity URLWithString:thePage.requestURLForAnalytics];
                if (pageEntity.params[@"fcid"]) {
                    pageName = [pageName stringByAppendingString:pageEntity.params[@"fcid"]];
                } else if (pageEntity.params[@"mt"]) {
                    pageName = [pageName stringByAppendingString:pageEntity.params[@"mt"]];
                }
            }
        } else {
            pageName = NSStringFromClass([page class]);
        }
    }
    
    return [MGJPTPHash pageHashWithURL:pageName];
}

@end
