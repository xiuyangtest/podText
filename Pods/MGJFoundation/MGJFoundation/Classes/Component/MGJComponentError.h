//
//  MGJComponentError.h
//  Example
//
//  Created by Blank on 15/7/29.
//  Copyright (c) 2015年 juangua. All rights reserved.
//

#ifndef Example_MGJComponentError_h
#define Example_MGJComponentError_h
NSString *const MGJComponentErrorDomain = @"MGJComponentErrorDomain";

enum {
    MGJComponentErrorValidateFailed = -1,
    MGJComponentErrorBundleNotExistInPath = -2,
    MGJComponentErrorBundleUnzipFailed = -3
};

#endif
