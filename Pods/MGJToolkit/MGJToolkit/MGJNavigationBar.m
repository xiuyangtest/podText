//
//  MGJNavigationBar.m
//  Mogujie4iPhone
//
//  Created by dong wu on 12-7-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MGJNavigationBar.h"
#import "UIView+MGJKit.h"
#import "MGJMacros.h"
#import "MGJPTP.h"

#define TAG_TITLELABEL_NAVIGATIONBAR   50000

@interface MGJNavigationBar()
@property(nonatomic, strong) UIView *backgroundView;
@property(nonatomic, strong) UIView *containerView;
@property(nonatomic, strong) UIView *bottomBorder;

@end

@implementation MGJNavigationBar

- (instancetype)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame needBlurEffect:YES];
}

- (id)initWithFrame:(CGRect)frame needBlurEffect:(BOOL)needBlurEffect
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.clipsToBounds = NO;
        
        self.backgroundView = [[UIView alloc] initWithFrame:self.bounds];
        
        self.containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height - [[UIApplication sharedApplication] statusBarFrame].size.height )];
        self.containerView.bottom = self.height;
        
        if (SYSTEM_VERSION_GREATER_THAN(@"8.0") && needBlurEffect) {
            UIVisualEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
            UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
            effectView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
            [self addSubview:effectView];
            [effectView.contentView addSubview:self.backgroundView];
            [effectView.contentView addSubview:self.containerView];
        }
        else
        {
            [self addSubview:self.backgroundView];
            [self addSubview:self.containerView];
        }
        
        //描边
        self.bottomBorder = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.containerView.width, 1 / [UIScreen mainScreen].scale)];
        self.bottomBorder.bottom = self.containerView.height;
        self.bottomBorder.backgroundColor = [UIColor grayColor];
        [self.containerView addSubview:self.bottomBorder];
        
        self.ptpModuleName = @"_head";
    }
    return self;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    self.backgroundView.backgroundColor = backgroundColor;
}

- (void)setTitle:(NSString *)title
{
    _title = title;
    if (nil == _titleView) {
        _titleView = [[UIView alloc] initWithFrame:CGRectMake((self.containerView.width - 200)/2, 0, 200, self.containerView.height)];
    }else {
        [_titleView removeAllSubviews];
    }
    _titleView.frame = CGRectMake((self.containerView.width - 200)/2, 0, 200, self.containerView.height);
    _titleView.backgroundColor = [UIColor clearColor];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 200, _titleView.height - 10)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = self.titleColor ? : [UIColor blackColor];
    titleLabel.text = _title;
    titleLabel.font = [UIFont boldSystemFontOfSize:18];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.adjustsFontSizeToFitWidth = YES;
    titleLabel.minimumScaleFactor = 14 / 18.f;
    titleLabel.tag = TAG_TITLELABEL_NAVIGATIONBAR;
    [_titleView addSubview:titleLabel];
    
    [_titleView removeFromSuperview];
    [self.containerView addSubview:_titleView];
}

- (void)setTitleColor:(UIColor*)color
{
    _titleColor = color;
    UILabel *titleLabel = (UILabel*)[_titleView viewWithTag:TAG_TITLELABEL_NAVIGATIONBAR];
    titleLabel.textColor = color;
}

- (void)setTitleView:(UIView *)titleView
{
    [_titleView removeFromSuperview];
    _titleView = nil;
    if (titleView) {
        _titleView = titleView;
        _titleView.center = CGPointMake(self.containerView.width / 2, self.containerView.height / 2) ;
        [self.containerView addSubview:_titleView];
    }
}

- (UILabel *)titleLabel
{
    UILabel *titleLabel = (UILabel*)[_titleView viewWithTag:TAG_TITLELABEL_NAVIGATIONBAR];
    return titleLabel;
}

- (void)setLeftBarButton:(UIView *)leftBarButton
{
    [_leftBarButton removeFromSuperview];
    _leftBarButton = nil;
    if (leftBarButton) {
        _leftBarButton = leftBarButton;
        _leftBarButton.center = CGPointMake(_leftBarButton.width/2, self.containerView.height/2);
        
        // 对于左上角的按钮不记录 PTP
        if ([leftBarButton isKindOfClass:[UIButton class]]) {
            ((UIButton *)leftBarButton).ignorePTP = YES;
        }
        
        [self.containerView addSubview:_leftBarButton];
    }
}

- (void)setRightBarButton:(UIView *)rightBarButton
{
    [_rightBarButton removeFromSuperview];
    _rightBarButton = nil;
    if (rightBarButton) {
        _rightBarButton = rightBarButton;
        _rightBarButton.center = CGPointMake(self.containerView.width - (_rightBarButton.width/2), self.containerView.height/2);
        [self.containerView addSubview:_rightBarButton];
        [self.containerView bringSubviewToFront:_rightBarButton];
    }
}

- (void)setBottomBorderColor:(UIColor*)color
{
    self.bottomBorder.backgroundColor = color;
}

- (UIColor *)backgroundColor
{
    return self.backgroundView.backgroundColor;
}


@end
