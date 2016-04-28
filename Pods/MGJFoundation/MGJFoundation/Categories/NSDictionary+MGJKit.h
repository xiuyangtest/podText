//
//  NSDictionary+MGJKit.h
//  Pods
//
//  Created by limboy on 12/19/14.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSDictionary (MGJKit)

- (CGPoint)mgj_pointForKey:(NSString *)key;
- (CGSize)mgj_sizeForKey:(NSString *)key;
- (CGRect)mgj_rectForKey:(NSString *)key;

@end
