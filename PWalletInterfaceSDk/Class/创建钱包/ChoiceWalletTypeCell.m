//
//  ChoiceWalletTypeCell.m
//  PWalletInterfaceSDk
//
//  Created by 郑晨 on 2022/9/5.
//  Copyright © 2022 fzm. All rights reserved.
//

#import "ChoiceWalletTypeCell.h"

@implementation ChoiceWalletTypeCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self createView];
    }
    
    return self;
}

- (void)createView
{
    [self.contentView addSubview:self.contentsView];
    [self.contentsView addSubview:self.bgImgView];
    [self.contentsView addSubview:self.walletTypeImgView];
    [self.contentsView addSubview:self.confirBtn];
    
    [self.contentsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(16);
        make.right.equalTo(self.contentView).offset(-16);
        make.top.equalTo(self.contentView).offset(10);
        make.height.mas_equalTo(116);
    }];
    [self.bgImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentsView);
        make.right.equalTo(self.contentsView);
        make.top.equalTo(self.contentsView);
        make.height.mas_equalTo(116);
    }];
    
    [self.walletTypeImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentsView).offset(19);
        make.centerY.equalTo(self.contentsView);
        make.height.mas_equalTo(25);
    }];
    
    [self.confirBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentsView).offset(-25);
        make.centerY.equalTo(self.contentsView);
        make.height.mas_equalTo(32);
        make.width.mas_equalTo(70);
    }];
    
}

#pragma mark - getter setter
- (UIView *)contentsView
{
    if (!_contentsView) {
        _contentsView = [[UIView alloc] init];
        _contentsView.backgroundColor = UIColor.whiteColor;
    }
    
    return _contentsView;
}

- (UIImageView *)bgImgView
{
    if (!_bgImgView) {
        _bgImgView = [[UIImageView alloc] init];
        _bgImgView.contentMode = UIViewContentModeScaleAspectFill;
        
    }
    return _bgImgView;
}

- (UIImageView *)walletTypeImgView
{
    if (!_walletTypeImgView) {
        _walletTypeImgView = [[UIImageView alloc] init];
        _walletTypeImgView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _walletTypeImgView;
}

- (UIButton *)confirBtn
{
    if (!_confirBtn) {
        _confirBtn = [[UIButton alloc] init];
        [_confirBtn setTitle:@"确定 ＞".localized forState:UIControlStateNormal];
        [_confirBtn.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Semibold" size:14]];
        [_confirBtn setImage:[UIImage imageNamed:@"type_to"] forState:UIControlStateNormal];
        _confirBtn.layer.cornerRadius = 5;
        
    }
    
    return _confirBtn;
}

@end
