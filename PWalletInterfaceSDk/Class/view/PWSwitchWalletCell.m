//
//  PWSwitchWalletCell.m
//  PWallet
//
//  Created by 郑晨 on 2019/11/7.
//  Copyright © 2019 陈健. All rights reserved.
//

#import "PWSwitchWalletCell.h"
#import "PWDataBaseManager.h"

@implementation PWSwitchWalletCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.backgroundColor = UIColor.clearColor;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self initView];
    }
    
    return self;
}

- (void)initView
{
    [self.contentView addSubview:self.backgroundImageView];
    [self.contentView addSubview:self.walletLogoImageView];
    [self.contentView addSubview:self.walletNameLab];
    [self.contentView addSubview:self.walletDesLab];
    [self.contentView addSubview:self.loginBtn];
    [self.contentView addSubview:self.assetLab];
    [self.contentView addSubview:self.currentWalletBtn];
    [self.contentView addSubview:self.addressLab];
    self.loginBtn.hidden = YES;
    self.currentWalletImageView.hidden = YES;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.backgroundImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(32);
        make.right.equalTo(self.contentView).offset(-19);
        make.top.equalTo(self.contentView);
        make.height.mas_equalTo(100);
    }];
    
    [self.walletLogoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(20);
        make.top.equalTo(self.contentView).offset(32);
        make.width.height.mas_equalTo(36);
    }];
    
    [self.walletNameLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(71);
        make.top.equalTo(self.contentView).offset(25);
        make.height.mas_equalTo(21);
    }];
    
    [self.loginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).offset(-39);
        make.top.equalTo(self.contentView).offset(24);
        make.height.mas_equalTo(24);
        make.width.mas_equalTo(80);
    }];
    
    [self.assetLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).offset(-36);
        make.top.equalTo(self.contentView).offset(22);
        make.height.mas_equalTo(25);
    }];
    
    [self.walletDesLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.walletNameLab);
        make.top.equalTo(self.walletNameLab.mas_bottom).offset(12);
        make.height.mas_equalTo(20);
        make.right.equalTo(self.contentView).offset(-90);
    }];
    
    [self.currentWalletBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView);
        make.right.equalTo(self.backgroundImageView);
        make.width.mas_equalTo(85);
        make.height.mas_equalTo(25);
    }];
    
    [self.addressLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.assetLab);
        make.centerY.equalTo(self.walletDesLab);
        make.height.mas_equalTo(self.walletDesLab);
    }];
}

- (void)clickBtn:(UIButton *)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(toLogin:)]) {
        [self.delegate toLogin:sender];
    }
}

- (void)setLocalWallet:(LocalWallet *)localWallet
{
    _localWallet = localWallet;
    if (_localWallet == nil) {
        return;
    }
    self.addressLab.hidden = YES;
    
    // 创建导入钱包
    self.walletLogoImageView.image = [UIImage imageNamed:@"wallet_normal_logo"];
    self.backgroundImageView.image = [UIImage imageNamed:@"wallet_normal_bg"];
    self.walletNameLab.text = _localWallet.wallet_name;
    self.walletDesLab.text = [NSString stringWithFormat:@"%@",@"助记词钱包".localized];
    self.walletNameLab.textColor = SGColorFromRGB(0xffffff);
    self.assetLab.textColor = SGColorFromRGB(0xffffff);
    self.walletDesLab.textColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:.5f];
    self.assetLab.hidden = NO;
    
    if (_localWallet.wallet_issmall == 2)
    {
        // 私钥钱包
//        self.addressLab.hidden = NO;
        NSArray *array = [[PWDataBaseManager shared] queryCoinArrayBasedOnWallet:_localWallet];
        NSString *mainStr = @"";
        LocalCoin *coin = array[0];
        mainStr = coin.coin_chain;
        self.walletLogoImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"wallet_%@_logo",coin.coin_type]];
        NSLog(@"___________%@",coin.coin_type);
        if(self.walletLogoImageView.image==nil){
            self.walletLogoImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"wallet_%@_logo",mainStr]];
        }
        self.backgroundImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"wallet_%@_bg",mainStr]];
        self.walletNameLab.text = _localWallet.wallet_name;
        self.walletNameLab.textColor = SGColorFromRGB(0xffffff);
        self.assetLab.textColor = SGColorFromRGB(0xffffff);
        self.walletDesLab.text = [NSString stringWithFormat:@"%@",@"私钥钱包".localized];
        NSString *address = [coin.coin_address stringByReplacingCharactersInRange:NSMakeRange(4, coin.coin_address.length - 8) withString:@"…"];
        self.addressLab.text = [NSString stringWithFormat:@"%@",address];
        
        self.walletDesLab.textColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:.5f];
        self.addressLab.textColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:.5f];
    }
    else if (_localWallet.wallet_issmall == 3){
        // 观察钱包
        // 观察钱包
        NSArray *infoArray = [_localWallet.wallet_password componentsSeparatedByString:@":"];
        self.walletLogoImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"wallet_%@_logo",infoArray[0]]];

        if([infoArray[0] isEqualToString:@"BTY"]){
            self.walletLogoImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"wallet_%@_logo",@"BTY"]];
        }
        if(self.walletLogoImageView.image == nil){
            self.walletLogoImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"wallet_%@_logo",infoArray[0]]];
        }

        self.backgroundImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"wallet_%@_bg",infoArray[0]]];
        if (self.backgroundImageView.image == nil) {
            self.backgroundImageView.image = [UIImage imageNamed:@"wallet_BTY_bg"];
        }
        self.walletNameLab.text = _localWallet.wallet_name;
        self.walletNameLab.textColor = SGColorFromRGB(0xffffff);
        self.assetLab.textColor = SGColorFromRGB(0xffffff);
        self.walletDesLab.text = [NSString stringWithFormat:@"%@",infoArray[1]];
        self.walletDesLab.textColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:.5f];
        
        if (_localWallet.wallet_totalassetsDollar == 1.) {
            self.walletLogoImageView.image = [UIImage imageNamed:@"wallet_leng_logo"];
            self.backgroundImageView.image = [UIImage imageNamed:@"wallet_normal_bg"];
            
        }
    }
    else if (_localWallet.wallet_issmall == 4)
    {
        // 找回钱包
        NSArray *array = [[PWDataBaseManager shared] queryCoinArrayBasedOnWallet:_localWallet];
        NSString *mainStr = @"";
        LocalCoin *coin = array[0];
        mainStr = coin.coin_chain;
        self.walletLogoImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"wallet_%@_logo",coin.coin_type]];
        NSLog(@"___________%@",coin.coin_type);
        if(self.walletLogoImageView.image==nil){
            self.walletLogoImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"wallet_%@_logo",mainStr]];
        }
        self.backgroundImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"wallet_%@_bg",mainStr]];
        self.walletNameLab.text = _localWallet.wallet_name;
        self.walletNameLab.textColor = SGColorFromRGB(0xffffff);
        self.assetLab.textColor = SGColorFromRGB(0xffffff);
        self.walletDesLab.text = [NSString stringWithFormat:@"%@",@"找回钱包".localized];
        NSString *address = [coin.coin_address stringByReplacingCharactersInRange:NSMakeRange(4, coin.coin_address.length - 8) withString:@"…"];
        self.addressLab.text = [NSString stringWithFormat:@"%@",address];
        
        self.walletDesLab.textColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:.5f];
        self.addressLab.textColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:.5f];
        
    }
    else
    {
        // 创建导入钱包
        self.walletLogoImageView.image = [UIImage imageNamed:@"wallet_normal_logo"];
        self.backgroundImageView.image = [UIImage imageNamed:@"wallet_normal_bg"];
        self.walletNameLab.text = _localWallet.wallet_name;
        self.walletDesLab.text = [NSString stringWithFormat:@"%@",@"助记词钱包".localized];
        self.walletNameLab.textColor = SGColorFromRGB(0xffffff);
        self.assetLab.textColor = SGColorFromRGB(0xffffff);
        self.walletDesLab.textColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:.5f];
        self.assetLab.hidden = NO;
        
    }
    if (_localWallet.wallet_isselected == 1)
    {
        self.currentWalletBtn.hidden = NO;
    }
    else
    {
        self.currentWalletBtn.hidden = YES;
    }
//    double totalAssets  = 0.00;
//    totalAssets = [[PWDataBaseManager shared] caculateTotalAssets:_localWallet];
//
//    self.assetLab.attributedText = [self amountAttributedString:totalAssets];

}


- (NSMutableAttributedString *)amountAttributedString:(double)totalAssets {
    NSString *text;
    text = [NSString stringWithFormat:@"￥%.2f",totalAssets];
    
    NSMutableAttributedString *fontAttributeNameStr = [[NSMutableAttributedString alloc]initWithString:text];
    
    [fontAttributeNameStr addAttribute:NSFontAttributeName value:kPUBLICNUMBERFONT_SIZE(18) range:NSMakeRange(0, 1)];
    [fontAttributeNameStr addAttribute:NSFontAttributeName value:kPUBLICNUMBERFONT_SIZE(18) range:NSMakeRange(1, text.length - 1)];
    return fontAttributeNameStr;
}

- (CGFloat)stringWidthWithText:(NSString *)text font:(UIFont *)font {
    
    CGFloat margin = 2;

    return [text boundingRectWithSize:CGSizeMake(MAXFLOAT, font.lineHeight) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil].size.width + margin;
}

#pragma mark - getter and setter
- (UIImageView *)backgroundImageView
{
    if (!_backgroundImageView) {
        _backgroundImageView = [[UIImageView alloc] init];
    }
    return _backgroundImageView;
}

- (UIImageView *)walletLogoImageView
{
    if (!_walletLogoImageView) {
        _walletLogoImageView = [[UIImageView alloc] init];
        _walletLogoImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _walletLogoImageView;
}

- (UILabel *)walletNameLab
{
    if (!_walletNameLab) {
        _walletNameLab = [[UILabel alloc] init];
        _walletNameLab.font = [UIFont boldSystemFontOfSize:15.f];
        _walletNameLab.textColor = SGColorFromRGB(0x103ed6);
        _walletNameLab.textAlignment = NSTextAlignmentLeft;
    }
    return _walletNameLab;
}

- (UILabel *)walletDesLab
{
    if (!_walletDesLab) {
        _walletDesLab = [[UILabel alloc] init];
        _walletDesLab.font = [UIFont systemFontOfSize:14.f];
        _walletDesLab.textAlignment = NSTextAlignmentLeft;
        _walletDesLab.textColor = SGColorFromRGB(0x7a96f8);
        _walletDesLab.lineBreakMode = NSLineBreakByTruncatingMiddle;
    }
    return _walletDesLab;
}

- (UILabel *)assetLab
{
    if (!_assetLab) {
        _assetLab = [[UILabel alloc] init];
        _assetLab.textAlignment = NSTextAlignmentRight;
        _assetLab.font = kPUBLICNUMBERFONT_SIZE(18.f);
        _assetLab.textColor = SGColorFromRGB(0x103ed6);
        
    }
    return _assetLab;
}

- (UIImageView *)currentWalletImageView
{
    if (!_currentWalletImageView) {
        _currentWalletImageView = [[UIImageView alloc] init];
        _currentWalletImageView.image = [UIImage imageNamed:@"current_wallet"];
        _currentWalletImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _currentWalletImageView;
}

- (UIButton *)currentWalletBtn
{
    if (!_currentWalletBtn) {
        _currentWalletBtn = [[UIButton alloc] init];
        [_currentWalletBtn setTitle:@"当前钱包".localized forState:UIControlStateNormal];
        [_currentWalletBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        [_currentWalletBtn.titleLabel setFont:[UIFont systemFontOfSize:12.f]];
        [_currentWalletBtn setBackgroundImage:[UIImage imageNamed:@"current_wallet"] forState:UIControlStateHighlighted];
        [_currentWalletBtn setBackgroundImage:[UIImage imageNamed:@"current_wallet"] forState:UIControlStateNormal];
        _currentWalletBtn.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _currentWalletBtn;
}

- (UIButton *)loginBtn
{
    if (!_loginBtn) {
        _loginBtn = [[UIButton alloc] init];
        [_loginBtn setTitle:@"注册/登录".localized forState:UIControlStateNormal];
        [_loginBtn setTitleColor:SGColorFromRGB(0x103ed6) forState:UIControlStateNormal];
        [_loginBtn.titleLabel setFont:[UIFont systemFontOfSize:12.f]];
        [_loginBtn.layer setCornerRadius:12.f];
        [_loginBtn setBackgroundColor:UIColor.whiteColor];
        
        [_loginBtn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _loginBtn;
}

- (UILabel *)addressLab
{
    if (!_addressLab) {
        _addressLab = [UILabel getLabWithFont:[UIFont systemFontOfSize:14.f]
                                    textColor:SGColorFromRGB(0x7a96f8)
                                textAlignment:NSTextAlignmentRight
                                         text:@""];
        
    }
    return _addressLab;
}

@end
