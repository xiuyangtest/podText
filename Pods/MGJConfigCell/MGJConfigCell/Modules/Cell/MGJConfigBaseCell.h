//
//  MGJConfigBaseCell.h
//  MGJConfigCell
//
//  Created by 鬼马 on 16/4/27.
//  Copyright © 2016年 鬼马. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "MGJConfigCellModuleProtocol.h"
#import "MGJConfigBaseViewModel.h"

@protocol MGJConfigCellModuleProtocol <NSObject>

- (void)updateCell;
+ (NSString *)cellForIdentifier;

@end

@interface MGJConfigBaseCell : UITableViewCell<MGJConfigCellModuleProtocol>

@property (nonatomic , strong) UIView *baseView;
@property (nonatomic , strong) MGJConfigBaseViewModel *baseViewModel;

@end
