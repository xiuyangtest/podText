//
//  MGJConfigYellowCell.m
//  MGJConfigCell
//
//  Created by 鬼马 on 16/4/27.
//  Copyright © 2016年 鬼马. All rights reserved.
//

#import "MGJConfigYellowCell.h"

@interface MGJConfigYellowCell ()
@property (nonatomic , weak) UILabel *label;
@end

@implementation MGJConfigYellowCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(20, 20, 100, 30)];
        label.backgroundColor = [UIColor purpleColor];
        [self.baseView addSubview:label];
        self.label = label;
        self.baseView.backgroundColor = [UIColor yellowColor];
    }
    return self;
}

- (void)updateCell
{
    [super updateCell];
}

@end
