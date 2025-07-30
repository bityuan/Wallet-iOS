//
//  PWMyWalletSetCell.m
//  PWallet
//
//  Created by 于优 on 2018/11/12.
//  Copyright © 2018 陈健. All rights reserved.
//

#import "PWMyWalletSetCell.h"

@interface PWMyWalletSetCell ()

/** title */
@property (nonatomic, strong) UILabel *titleLab;

@end

@implementation PWMyWalletSetCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self createView];
    }
    return self;
}

- (void)createView {
    self.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:self.titleLab];
    
    _nextImg = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"accessory"]];
    _nextImg.contentMode = UIViewContentModeCenter;
    [self.contentView addSubview:_nextImg];
    
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = SGColorFromRGB(0xD9DCE9);
    [self.contentView addSubview:lineView];
    [self.contentView addSubview:self.blueToothLabel];
    [self.contentView addSubview:self.switchBtn];
    
    
    [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView);
        make.left.mas_offset(16);
        make.height.mas_offset(22);
        make.width.mas_offset(kScreenWidth * 0.6);
    }];
    
    [_nextImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView);
        make.right.mas_offset(-19);
        make.height.mas_offset(14);
        make.width.mas_offset(14);
    }];
    
    [self.switchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).offset(-17);
        make.centerY.equalTo(self.contentView);
        make.width.mas_equalTo(38);
        make.height.mas_equalTo(23);
    }];
    
    [self.blueToothLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).offset(-35);
        make.centerY.equalTo(self.contentView);
    }];
    
    
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_offset(0);
        make.right.mas_offset(0);
        make.left.mas_offset(16);
        make.height.mas_offset(0.5);
    }];
}

#pragma mark - setter & getter

- (void)setTitleName:(NSString *)titleName {
    _titleName = titleName;
    
    if (titleName.length > 0) {
        self.titleLab.text = titleName;
    }
    else {
        for (UIView *view in [self.contentView subviews]) {
            view.hidden = YES;
        }
    }
}

- (UILabel *)titleLab {
    if (!_titleLab) {
        _titleLab = [UILabel new];
        _titleLab.text = @"";
        _titleLab.font = [UIFont systemFontOfSize:16];
        _titleLab.textColor = CMColorFromRGB(0x333649);
        _titleLab.textAlignment = NSTextAlignmentLeft;
    }
    return _titleLab;
}

- (UIButton *)switchBtn
{
    if (!_switchBtn) {
        _switchBtn = [[UIButton alloc] init];
        [_switchBtn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _switchBtn;
}

- (UILabel *)blueToothLabel {
    if (!_blueToothLabel) {
        _blueToothLabel = [UILabel new];
        _blueToothLabel.text = @"--未连接".localized;
        _blueToothLabel.font = [UIFont systemFontOfSize:14];
        _blueToothLabel.textColor = SGColorRGBA(240, 100, 43, 1);
        _blueToothLabel.textAlignment = NSTextAlignmentRight;
        _blueToothLabel.userInteractionEnabled = YES;
    }
    return _blueToothLabel;
}



- (void)clickBtn:(UIButton *)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(switchPay:)]) {
        [self.delegate switchPay:sender];
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
