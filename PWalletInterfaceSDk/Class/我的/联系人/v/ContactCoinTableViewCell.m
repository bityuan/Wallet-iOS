//
//  ContactCoinTableViewCell.m
//  PWallet
//
//  Created by 宋刚 on 2018/6/15.
//  Copyright © 2018年 陈健. All rights reserved.
//

#import "ContactCoinTableViewCell.h"
@interface ContactCoinTableViewCell()
@property (nonatomic,strong) UIImageView *bgIcon;
@property (nonatomic,strong) UIImageView *coinIcon;
@property (nonatomic,strong) UILabel *coinNameLab;
@property (nonatomic,strong) UILabel *chineseLab;
@end

@implementation ContactCoinTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = UIColor.clearColor;
        [self createView];
    }
    return self;
}

- (void)createView
{
    UIImageView *bgIcon = [[UIImageView alloc] init];
    bgIcon.layer.cornerRadius = 18;
    bgIcon.layer.masksToBounds = YES;
    bgIcon.backgroundColor = [UIColor whiteColor];
    bgIcon.layer.borderWidth = 0.5;
    bgIcon.layer.borderColor = LineColor.CGColor;
    [self.contentView addSubview:bgIcon];
    self.bgIcon = bgIcon;
    
    UIImageView *coinIcon = [[UIImageView alloc] init];
    coinIcon.layer.cornerRadius = 12;
    coinIcon.layer.masksToBounds = YES;
    [self.contentView addSubview:coinIcon];
    self.coinIcon = coinIcon;
    
    UILabel *coinNameLab = [[UILabel alloc] init];
    coinNameLab.textColor = CMColor(51, 51, 51);
    coinNameLab.font = [UIFont systemFontOfSize:16];
    coinNameLab.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:coinNameLab];
    self.coinNameLab = coinNameLab;
    
    UILabel *chineseLab = [[UILabel alloc] init];
    chineseLab.textColor = PlaceHolderColor;
    chineseLab.font = [UIFont boldSystemFontOfSize:13];
    chineseLab.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:chineseLab];
    self.chineseLab = chineseLab;
    
    chineseLab.alpha = 0;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self.bgIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(36);
        make.left.equalTo(self.contentView).with.offset(30);
        make.centerY.equalTo(self.contentView);
    }];
    
    [self.coinIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(24);
        make.centerX.equalTo(self.bgIcon.mas_centerX);
        make.centerY.equalTo(self.bgIcon.mas_centerY);
    }];
    
    [self.coinNameLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bgIcon.mas_right).with.offset(20);
        make.top.bottom.equalTo(self.contentView);
    }];
    
    [self.chineseLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self.contentView);
        make.left.equalTo(self.coinNameLab.mas_right).with.offset(0);
        make.width.mas_equalTo(120);
    }];
}

- (void)setCoinPrice:(CoinPrice *)coinPrice
{
    _coinPrice = coinPrice;
    self.coinNameLab.text = IS_BLANK(coinPrice.coinprice_optional_name) ? coinPrice.coinprice_name : coinPrice.coinprice_optional_name;
    if (coinPrice.coinprice_icon != nil) {
        [self.coinIcon sd_setImageWithURL:[NSURL URLWithString:coinPrice.coinprice_icon]];
    }
    if (![coinPrice.coinprice_nickname isEqualToString:@""]) {
        self.chineseLab.text = [NSString stringWithFormat:@"(%@)",coinPrice.coinprice_nickname];
    }
}

- (void)setSearchDic:(NSDictionary *)searchDic
{
    _searchDic = searchDic;
    self.coinNameLab.text = IS_BLANK(searchDic[@"optional_name"]) ? searchDic[@"name"] : searchDic[@"optional_name"];
    if (searchDic[@"icon"] != nil && ![searchDic[@"icon"] isEqual:[NSNull null]]) {
         [self.coinIcon sd_setImageWithURL:[NSURL URLWithString:searchDic[@"icon"]]];
    }
    
    if (![searchDic[@"nickname"] isEqualToString:@""]) {
        self.chineseLab.text = [NSString stringWithFormat:@"(%@)",searchDic[@"nickname"]];
    }
}
@end
