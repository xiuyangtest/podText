//
//  MGJConfigPurpleCell.m
//  MGJConfigCell
//
//  Created by 鬼马 on 16/4/27.
//  Copyright © 2016年 鬼马. All rights reserved.
//

#import "MGJConfigPurpleCell.h"
#import "MGJConfigPurpleViewModel.h"

@interface MGJConfigPurpleCell ()
@property (nonatomic , weak) UILabel *label;
@end

@implementation MGJConfigPurpleCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(20, 20, 100, 30)];
        label.backgroundColor = [UIColor yellowColor];
        [self.baseView addSubview:label];
        self.label = label;
        
        self.baseView.backgroundColor = [UIColor purpleColor];
    }
    return self;
}

- (void)updateCell
{
    [super updateCell];
    MGJConfigPurpleViewModel *viewModel = (MGJConfigPurpleViewModel *)self.baseViewModel;
    self.label.text = viewModel.title;
}

@end
