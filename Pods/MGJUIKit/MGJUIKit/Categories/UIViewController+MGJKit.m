//
//  UIViewController+MGJKit.m
//  Example
//
//  Created by limboy on 3/3/15.
//  Copyright (c) 2015 juangua. All rights reserved.
//

#import "UIViewController+MGJKit.h"
#import <NSBundle+MGJKit.h>
#import <MGJMacros.h>

@implementation UIViewController (MGJKit)

- (instancetype)initWithLibraryBundle:(NSString *)libraryName {
    id result = nil;
    if (!MGJ_IS_EMPTY(libraryName)) {
#ifdef MGJBOUNDLESUPPORT_DISABLE
        NSString *nibPath = [[NSBundle mainBundle] pathForResource:[[self class] description] ofType:@"nib"];
        if (!MGJ_IS_EMPTY(nibPath)) {
            result = [self initWithNibName:nil bundle:nil];
        }
#else
        NSBundle *bundle = [NSBundle mgj_libraryResourcesBundle:libraryName];
        if (!MGJ_IS_EMPTY(bundle)) {
            result = [self initWithNibName:nil bundle:bundle];
        }
#endif
    }
    return result;
}

@end
