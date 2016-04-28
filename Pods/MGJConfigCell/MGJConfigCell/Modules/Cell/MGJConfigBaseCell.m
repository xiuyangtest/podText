//
//  MGJConfigBaseCell.m
//  MGJConfigCell
//
//  Created by 鬼马 on 16/4/27.
//  Copyright © 2016年 鬼马. All rights reserved.
//

#import "MGJConfigBaseCell.h"

@implementation MGJConfigBaseCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        if (!self.baseView.superview) {
            [self.contentView addSubview:self.baseView];
        }
    }
    return self;
}

+ (NSString *)cellForIdentifier
{
    return NSStringFromClass([self class]);
}

- (void)updateCell
{
    self.baseView.frame = CGRectMake(0, self.baseViewModel.top, [UIScreen mainScreen].bounds.size.width, [self.baseViewModel cellForHeight]);
}
- (UIView *)baseView
{
    if (!_baseView) {
        _baseView = [[UIView alloc]init];
        _baseView.backgroundColor = [UIColor clearColor];
        _baseView.layer.masksToBounds = YES;
    }
    return _baseView;
}

@end
