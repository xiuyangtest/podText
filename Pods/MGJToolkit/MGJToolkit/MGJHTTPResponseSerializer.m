//
//  MGJHTTPResponseSerializer.m
//  MGJiPhoneSDKDemo
//
//  Created by kunka on 14-9-5.
//  Copyright (c) 2014年 juangua. All rights reserved.
//

#import "MGJHTTPResponseSerializer.h"
#import <MGJFoundation/MGJEntity.h>

#define ContentType_MessagePack @"application/x-msgpack"

static NSError * MGJErrorWithUnderlyingError(NSError *error, NSError *underlyingError) {
    if (!error) {
        return underlyingError;
    }
    
    if (!underlyingError || error.userInfo[NSUnderlyingErrorKey]) {
        return error;
    }
    
    NSMutableDictionary *mutableUserInfo = [error.userInfo mutableCopy];
    mutableUserInfo[NSUnderlyingErrorKey] = underlyingError;
    
    return [[NSError alloc] initWithDomain:error.domain code:error.code userInfo:mutableUserInfo];
}

static BOOL MGJErrorOrUnderlyingErrorHasCodeInDomain(NSError *error, NSInteger code, NSString *domain) {
    if ([error.domain isEqualToString:domain] && error.code == code) {
        return YES;
    } else if (error.userInfo[NSUnderlyingErrorKey]) {
        return MGJErrorOrUnderlyingErrorHasCodeInDomain(error.userInfo[NSUnderlyingErrorKey], code, domain);
    }
    
    return NO;
}


@implementation MGJHTTPResponseSerializer

+ (instancetype)serializer {
    MGJHTTPResponseSerializer *serializer = [[self alloc] init];
    return serializer;
}

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/html",ContentType_MessagePack, nil];
    
    return self;
}

- (id)responseObjectForResponse:(NSURLResponse *)response data:(NSData *)data error:(NSError *__autoreleasing *)error
{
    if (![self validateResponse:(NSHTTPURLResponse *)response data:data error:error]) {
        if (!error || MGJErrorOrUnderlyingErrorHasCodeInDomain(*error, NSURLErrorCannotDecodeContentData, AFURLResponseSerializationErrorDomain)) {
            return nil;
        }
    }
    
    if (!data) {
        return nil;
    }
    
    id responseObject = nil;
    NSError *serializationError = nil;
    
    //messagepack
    if ([response.MIMEType isEqualToString:ContentType_MessagePack]) {
        responseObject = [MPMessagePackReader readData:data error:&serializationError];
    }
    //json
    else
    {
        responseObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&serializationError];
    }
   
    //如果设置了类名，那么只能返回对应类的实例，或者 nil
    if (self.classNameForResult) {
        
        if (responseObject && [responseObject isKindOfClass:[NSDictionary class]]) {
            
            id resultObject = responseObject[@"result"];
            
            if (resultObject) {
                
                //先移除原有的 result
                responseObject = [responseObject mutableCopy];
                [responseObject removeObjectForKey:@"result"];
                
                Class class = NSClassFromString(self.classNameForResult);
                
                if (class && [class isSubclassOfClass:[MGJEntity class]]) {
                    //如果是字典，直接转成 entity
                    if ([resultObject isKindOfClass:[NSDictionary class]]) {
                        id resultEntity = nil;
                        resultEntity = [((MGJEntity *)[class alloc]) initWithDictionary:resultObject];
                        
                        if (resultEntity) {
                            responseObject[@"result"] = resultEntity;
                        }
                    }
                    //如果是数组，对数组里面每一个对象处理，转成entity
                    else if ([resultObject isKindOfClass:[NSArray class]]) {
                        id resultArray = [MGJEntity parseToEntityArray:resultObject withType:class];
                        if (resultArray) {
                            responseObject[@"result"] = resultArray;
                        }
                    }
                }
                
            }
            
        }
    }
    
    if (error) {
        *error = MGJErrorWithUnderlyingError(serializationError, *error);;
    }
    

    
    return responseObject;
}


@end
