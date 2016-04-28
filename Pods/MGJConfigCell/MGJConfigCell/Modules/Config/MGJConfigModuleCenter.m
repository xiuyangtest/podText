//
//  MGJConfigModuleCenter.m
//  MGJConfigCell
//
//  Created by 鬼马 on 16/4/28.
//  Copyright © 2016年 鬼马. All rights reserved.
//

#import "MGJConfigModuleCenter.h"

#import "MGJConfigJsonEntity.h"
#import "NSMutableDictionary+MGJConfigSafe.h"
#import "NSMutableArray+MGJConfigSafe.h"
#import "NSObject+MGJConfigMapRule.h"
#import "MGJConfigBaseEntity.h"
#import "MGJConfigBaseViewModel.h"
#import "MGJConfigBaseCell.h"
#import "MGJConfigDataManager.h"

@interface MGJConfigModuleCenter ()

@end

@implementation MGJConfigModuleCenter

- (instancetype)initWithCellData:(NSDictionary *)data requestJson:(NSDictionary *)configData
{
    self = [super init];
    if (self) {
        [self initProperty];
        [self getConfigsCellWithData:data requestJson:configData];
    }
    return self;
}

- (void)initProperty
{
    self.configsCell     = [NSMutableArray array];
    self.configsPosition = [NSMutableArray array];
    self.dataSouce       = [NSMutableArray array];
    self.viewModelDatas  = [NSMutableArray array];
}

- (void)getConfigsCellWithData:(NSDictionary *)data requestJson:(NSDictionary *)configData
{
    MGJConfigDataManager *manager = [[MGJConfigDataManager alloc]init];
    MGJConfigJsonEntity *jsonEntity = [manager updateConfigFileWithJson:configData];
    int number = 0;
    NSArray *views = ((MGJConfigJsonPageEntity *)jsonEntity.configs.firstObject).views;
    for (MGJConfigJsonModuleEntity *moduleEntity in views) {
        NSString *key = moduleEntity.serverName;
        NSNumber *position = [NSNumber numberWithInteger:[moduleEntity.marginTop integerValue]];
        NSDictionary *moduleDic = [(NSMutableDictionary *)data mgj_safeDataForKey:key];
        
        if ([moduleDic isKindOfClass:[NSArray class]]) {
            moduleDic = [(NSMutableArray *)moduleDic mgj_objectOrNilAtIndex:number];
            number++;
        }
        
        Class cls     = [self getClassFromConfigsWithKey:key];
        Class dataCls = [self getDataClassFromConfigsWithKey:key];
        Class vmCls   = [self getViewModelClassFromConfigsWithKey:key];
        
        if (cls && moduleDic) {
            // cell
            [self.configsCell mgj_addObjectIfNotNil:cls];
            // 间距
            [self.configsPosition mgj_addObjectIfNotNil:position];
            // entity
            MGJConfigBaseEntity *baseEntity;
            if (dataCls) {
                baseEntity = [[dataCls alloc]initWithDictionary:moduleDic];
                //baseEntity.top = [moduleEntity.marginTop integerValue];
                [self.dataSouce mgj_addObjectIfNotNil:baseEntity];
            }
            // viewModel
            if (vmCls) {
                /**
                 要用init构造方法 initWithEntity
                 */
                MGJConfigBaseViewModel *viewModel = [[vmCls alloc]initWithEntity:baseEntity];
                viewModel.top = [moduleEntity.marginTop integerValue];
                [self.viewModelDatas mgj_addObjectIfNotNil:viewModel];
            }
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MGJConfigBaseCell *cell;
    
    Class cls = [self.configsCell objectAtIndex:indexPath.row];
    cell = [tableView dequeueReusableCellWithIdentifier:[cls cellForIdentifier] forIndexPath:indexPath];
    MGJConfigBaseViewModel *smallViewModel = [self.viewModelDatas mgj_objectOrNilAtIndex:indexPath.row];
    cell.baseViewModel = smallViewModel;
    
    if ([smallViewModel respondsToSelector:@selector(updateForViewModel)]) {
        [(id<MGJConfigViewModelMoudleProtocol>)smallViewModel updateForViewModel];
    }
    if ([cell respondsToSelector:@selector(updateCell)]) {
        [(id<MGJConfigCellModuleProtocol>)cell updateCell];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MGJConfigBaseViewModel *smallViewModel = [self.viewModelDatas mgj_objectOrNilAtIndex:indexPath.row];
    CGFloat height = 0;
    if ([smallViewModel respondsToSelector:@selector(cellForHeight)]) {
        height = [(id<MGJConfigViewModelMoudleProtocol>)smallViewModel cellForHeight];
    }
    NSInteger positon = [[self.configsPosition mgj_objectOrNilAtIndex:indexPath.row] integerValue];
    
    if (!height) {
        return 0;
    }
    return  height + positon;
}

- (void)registerClassForTableView:(UITableView *)tableView
{
    for (int i = 0; i < self.configsCell.count; i++) {
        Class cls = [self.configsCell mgj_objectOrNilAtIndex:i];
        [tableView registerClass:cls forCellReuseIdentifier:[cls cellForIdentifier]];
    }
}


@end
