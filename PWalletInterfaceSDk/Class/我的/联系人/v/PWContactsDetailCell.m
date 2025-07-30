//
//  PWContactsDetailCell.m
//  PWallet
//  联系人详情地址cell
//  Created by 陈健 on 2018/5/31.
//  Copyright © 2018年 陈健. All rights reserved.
//

#import "PWContactsDetailCell.h"
@interface PWContactsDetailCell()<UITextViewDelegate>
@property (nonatomic,weak) UILabel *addressLabel;
@property (nonatomic,weak) YYLabel *nameLabel;
@property (nonatomic,weak) UIButton *cAddressBtn;
@property (nonatomic,weak) UIImageView *bgImageView;
@end
@implementation PWContactsDetailCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = SGColorFromRGB(0xFCFCFF);
        [self initViews];
        return self;
    }
    return nil;
}

-(void)deselectCell {
//    self.bgImageView.layer.borderColor = [UIColor clearColor].CGColor;
    self.bgImageView.image = [UIImage imageNamed:@"Mask"];
}

- (void)setselectCell
{
//    self.bgImageView.layer.borderColor = SGColorFromRGB(0x7190FF).CGColor;
    self.bgImageView.image = [UIImage imageNamed:@"Group4"];
}

- (void)setAddressText:(NSString *)addressText {
    if (addressText) {
        _addressText = addressText;
        self.addressLabel.text = addressText;
    }
}

- (void)setCoinNameText:(NSString *)coinNameText {
    if (coinNameText) {
        _coinNameText = coinNameText;
        self.nameLabel.text = coinNameText;
    }
}

- (void)initViews {
    
    UIImageView *imageView = [[UIImageView alloc]init];
    imageView.image = [UIImage imageNamed:@"Mask"];
    imageView.userInteractionEnabled = true;
    imageView.layer.borderWidth = 1;
    imageView.layer.borderColor = [UIColor clearColor].CGColor;
    imageView.layer.cornerRadius = 6;
    [self.contentView addSubview:imageView];
    self.bgImageView = imageView;
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.contentView);
        make.centerX.equalTo(self.contentView);
        make.left.equalTo(self.contentView).with.offset(15);
        make.right.equalTo(self.contentView).with.offset(-15);
    }];
    
    //主链label
    YYLabel *nameLabel = [[YYLabel alloc]init];
    [imageView addSubview:nameLabel];
    nameLabel.font = [UIFont systemFontOfSize:16];
    nameLabel.textColor = [UIColor whiteColor];
    nameLabel.textContainerInset = UIEdgeInsetsMake(0, 14, 0, 14);
    nameLabel.backgroundColor = SGColorFromRGB(0x7190FF);
    self.nameLabel = nameLabel;
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(imageView).offset(25);
        make.left.equalTo(imageView).offset(20);
        make.height.mas_equalTo(26);
    }];
    nameLabel.layer.cornerRadius = 3;
    
    //复制按钮
    UIButton *copyAddressBtn = [[UIButton alloc]init];
    [imageView addSubview:copyAddressBtn];
    [copyAddressBtn setImage:[UIImage imageNamed:@"复制2"] forState:UIControlStateNormal];
    [copyAddressBtn setImage:[UIImage imageNamed:@"复制2"] forState:UIControlStateHighlighted];
    [copyAddressBtn addTarget:self action:@selector(copyAddressBtnPress:) forControlEvents:UIControlEventTouchUpInside];
    self.cAddressBtn = copyAddressBtn;
    [copyAddressBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(imageView).offset(-21);
        make.centerY.equalTo(nameLabel);
    }];
    
    //地址addressLabel
    UILabel *addressLabel = [[UILabel alloc]init];
    [imageView addSubview:addressLabel];
    addressLabel.font = [UIFont systemFontOfSize:14];
    addressLabel.textColor = SGColorRGBA(51, 54, 73, 1);
    addressLabel.numberOfLines = 0;
    self.addressLabel = addressLabel;
    [addressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(nameLabel);
        make.right.equalTo(copyAddressBtn);
        make.top.equalTo(nameLabel).offset(13);
        make.bottom.equalTo(imageView);
        
    }];
    
}

//button点击
- (void)copyAddressBtnPress:(UIButton*)sender {
    if (self.copyAddressBlock) {
        self.copyAddressBlock(self.addressText);
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
