//
//  MGJConfigModuleCenter.h
//  MGJConfigCell
//
//  Created by 鬼马 on 16/4/28.
//  Copyright © 2016年 鬼马. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol MGJConfigCellDataSouceProtocol <NSObject>

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)registerClassForTableView:(UITableView *)tableView;

@end
@interface MGJConfigModuleCenter : NSObject<MGJConfigCellDataSouceProtocol>

@property (nonatomic , strong) NSMutableArray *configsCell;
@property (nonatomic , strong) NSMutableArray *configsPosition;
@property (nonatomic , strong) NSMutableArray *dataSouce;
@property (nonatomic , strong) NSMutableArray *viewModelDatas;

- (instancetype)initWithCellData:(NSDictionary *)data requestJson:(NSDictionary *)configData;

@end
