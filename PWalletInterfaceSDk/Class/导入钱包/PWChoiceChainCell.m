//
//  PWChoiceChainCell.m
//  PWallet
//
//  Created by 郑晨 on 2019/10/24.
//  Copyright © 2019 陈健. All rights reserved.
//

#import "PWChoiceChainCell.h"

@implementation PWChoiceChainCell

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
    
    if (self)
    {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = UIColor.clearColor;
        
        [self initView];
    }
    return self;
}

- (void)initView
{
    [self.contentView addSubview:self.contentsView];
    [self.contentsView addSubview:self.logoImageView];
    [self.contentsView addSubview:self.coinLab];
    [self.contentsView addSubview:self.choiceBtn];
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.contentsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(16);
        make.right.equalTo(self).offset(-16);
        make.top.bottom.equalTo(self);
    }];
    
    [self.logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentsView).offset(10);
        make.top.equalTo(self.contentsView).offset(18);
        make.width.height.mas_equalTo(24);
    }];
    
    [self.coinLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.logoImageView.mas_right).offset(10);
        make.top.equalTo(self.contentsView).offset(19);
        make.height.mas_equalTo(22);
    }];
    
    [self.choiceBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentsView);
        make.top.equalTo(self.contentsView);
        make.width.height.mas_equalTo(60);
    }];
}

#pragma mark - 选择主链
- (void)choiceChain:(UIButton *)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(choiceChain:cell:)]) {
        [self.delegate choiceChain:sender cell:self];
    }
}

#pragma mark - getter setter

- (UIView *)contentsView
{
    if (!_contentsView) {
        _contentsView = [[UIView alloc] init];
        _contentsView.layer.cornerRadius = 5.f;
        _contentsView.backgroundColor = UIColor.whiteColor;
        
    }
    return _contentsView;
}

- (UIImageView *)logoImageView
{
    if (!_logoImageView) {
        _logoImageView = [[UIImageView alloc] init];
    }
    return _logoImageView;
}

- (UILabel *)coinLab
{
    if (!_coinLab) {
        _coinLab = [[UILabel alloc] init];
        _coinLab.textColor = SGColorFromRGB(0x333649);
        _coinLab.font = [UIFont boldSystemFontOfSize:16.f];
        _coinLab.textAlignment = NSTextAlignmentLeft;
        
    }
    return _coinLab;
}

- (UIButton *)choiceBtn
{
    if (!_choiceBtn) {
        _choiceBtn = [[UIButton alloc] init];
        [_choiceBtn setImage:[UIImage imageNamed:@"chain_unselected"] forState:UIControlStateNormal];
        [_choiceBtn setContentMode:UIViewContentModeScaleAspectFit];
        [_choiceBtn addTarget:self action:@selector(choiceChain:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _choiceBtn;
}

@end
