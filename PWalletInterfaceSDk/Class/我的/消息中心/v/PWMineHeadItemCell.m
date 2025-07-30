//
//  PWMineHeadItemCell.m
//  PWallet
//
//  Created by 郑晨 on 2019/12/16.
//  Copyright © 2019 陈健. All rights reserved.
//

#import "PWMineHeadItemCell.h"

@implementation PWMineHeadItemCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self initView];
    }
    
    return self;
}

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        [self initView];
    }
    
    return self;
}

- (void)initView
{
    [self.contentView addSubview:self.itemImageView];
    [self.contentView addSubview:self.titleLab];
    [self.contentView addSubview:self.hotImageView];
    
    [self.itemImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentView);
        make.top.equalTo(self.contentView).offset(25);
        make.width.height.mas_equalTo(28 * kScreenRatio);
    }];
    
    [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentView);
        make.top.equalTo(self.itemImageView.mas_bottom);
        make.height.mas_equalTo(40);
        if ([LocalizableService getAPPLanguage] == LanguageJapanese)
        {
            make.width.mas_equalTo(80);
        }
        else
        {
            make.width.mas_equalTo(60);
        }
        
    }];
    
    [self.hotImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.itemImageView.mas_right);
        make.top.equalTo(self.itemImageView).offset(2);
        make.width.mas_equalTo(11);
        make.height.mas_equalTo(12);
    }];
    
}

#pragma mark - getter and setter
- (UIImageView *)itemImageView
{
    if (!_itemImageView) {
        _itemImageView = [[UIImageView alloc] init];
        _itemImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _itemImageView;
}

- (UILabel *)titleLab
{
    if (!_titleLab) {
        _titleLab = [UILabel getLabWithFont:[UIFont systemFontOfSize:14.f]
                                  textColor:SGColorFromRGB(0x333649)
                              textAlignment:NSTextAlignmentCenter
                                       text:@""];
        _titleLab.numberOfLines = 0;
    }
    return _titleLab;
}

- (UIImageView *)hotImageView
{
    if (!_hotImageView) {
        _hotImageView = [[UIImageView alloc] init];
        _hotImageView.image = [UIImage imageNamed:@"mine_huo"];
        
    }
    return _hotImageView;
}

@end
