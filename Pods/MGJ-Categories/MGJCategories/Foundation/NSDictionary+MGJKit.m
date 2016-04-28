//
//  NSDictionary+MGJKit.m
//  Pods
//
//  Created by limboy on 12/19/14.
//
//

#import "NSDictionary+MGJKit.h"

@implementation NSDictionary (MGJKit)

- (CGPoint)mgj_pointForKey:(NSString *)key
{
    CGPoint point = CGPointZero;
    NSDictionary *dictionary = [self valueForKey:key];
    BOOL success = CGPointMakeWithDictionaryRepresentation((CFDictionaryRef)dictionary, &point);
    if (success) return point;
    else return CGPointZero;
}

- (CGSize)mgj_sizeForKey:(NSString *)key
{
    CGSize size = CGSizeZero;
    NSDictionary *dictionary = [self valueForKey:key];
    BOOL success = CGSizeMakeWithDictionaryRepresentation((CFDictionaryRef)dictionary, &size);
    if (success) return size;
    else return CGSizeZero;
}

- (CGRect)mgj_rectForKey:(NSString *)key
{
    CGRect rect = CGRectZero;
    NSDictionary *dictionary = [self valueForKey:key];
    BOOL success = CGRectMakeWithDictionaryRepresentation((CFDictionaryRef)dictionary, &rect);
    if (success) return rect;
    else return CGRectZero;
}

- (NSString*)mgj_ConvertJSONString{
    
    NSError* error = nil;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:self
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    
    if (error != nil) {
        NSLog(@"NSDictionary JSONString error: %@", [error localizedDescription]);
        return nil;
    } else {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    return nil;
}
@end
