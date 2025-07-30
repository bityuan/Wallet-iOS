//
//  PWRememberCodeAlertView.m
//  PWallet
//
//  Created by 陈健 on 2018/11/15.
//  Copyright © 2018 陈健. All rights reserved.
//

#import "PWRememberCodeAlertView.h"
#import "NSString+CommonUseTool.h"

@interface PWRememberCodeAlertView()

@end

@implementation PWRememberCodeAlertView

- (instancetype)initWithTitle:(NSString*)title rememberCode:(NSString*)rememberCode buttonName:(NSString*)buttonName {
    self = [super init];
    if (self) {
        [self createViewWithTitle:title rememberCode:rememberCode buttonName:buttonName];
        self.rememberCode = rememberCode;
    }
    return self;
}
- (void)createViewWithTitle:(NSString*)title rememberCode:(NSString*)rememberCode buttonName:(NSString*)buttonName {
    
    //白色Cover view
    UIView *whiteView = [[UIView alloc]init];
    [self addSubview:whiteView];
    whiteView.backgroundColor = [UIColor whiteColor];
    whiteView.layer.cornerRadius = 6;
    whiteView.layer.masksToBounds = true;
    CGFloat whiteViewHeight = 600;
    [whiteView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(whiteViewHeight * kScreenRatio);
        make.left.equalTo(self).offset(25);
        make.right.equalTo(self).offset(-25);
        make.centerY.equalTo(self);
    }];
    
    //title label
    UILabel *titleLab = [[UILabel alloc]init];
    [whiteView addSubview:titleLab];
    titleLab.text = title;
    titleLab.font = [UIFont boldSystemFontOfSize:17];
    titleLab.textColor = SGColorRGBA(51, 54, 73, 1);
    [titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(whiteView).offset(15);
        make.left.equalTo(whiteView).offset(25);
    }];
    
    //叉叉(取消)按钮
    UIButton *cancelBtn = [[UIButton alloc]init];
    [whiteView addSubview:cancelBtn];
    [cancelBtn setImage:[UIImage imageNamed:@"叉叉"] forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
    [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(44);
        make.height.mas_equalTo(44);
        make.right.equalTo(whiteView).offset(-10);
        make.centerY.equalTo(titleLab);
    }];
    
    UIView *line = [[UIView alloc]init];
    line.backgroundColor = SGColorRGBA(113, 144, 255, 1);
    [whiteView addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(titleLab);
        make.top.equalTo(titleLab.mas_bottom).offset(12);
        make.height.mas_equalTo(4);
        make.width.mas_equalTo(45);
    }];
    
    UIView *messageBgView = [[UIView alloc]init];
    [whiteView addSubview:messageBgView];
    messageBgView.backgroundColor = SGColorRGBA(248, 248, 250, 1);
    [messageBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(line.mas_bottom).offset(25);
        make.left.equalTo(whiteView).offset(25);
        make.right.equalTo(whiteView).offset(-25);
        make.height.mas_equalTo(200);
    }];
    
    YYLabel *messageLab = [[YYLabel alloc]init];
    [messageBgView addSubview:messageLab];
    messageLab.text = rememberCode;
    if ((rememberCode.length > 1) && ([[rememberCode substringToIndex:1] isLatter])) {
        messageLab.font = [UIFont boldSystemFontOfSize:24];
    }else{
        messageLab.font = [UIFont boldSystemFontOfSize:36];
    }
   
    messageLab.textColor = SGColorRGBA(51, 54, 73, 1);
    messageLab.numberOfLines = 0;
    [messageLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(messageBgView);
        make.height.equalTo(messageBgView);
        //英文助记词
        make.left.equalTo(messageBgView).offset(15);
        make.right.equalTo(messageBgView).offset(-15);
        
    }];
    
    messageBgView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
    tap.numberOfTapsRequired = 1;
    [messageBgView addGestureRecognizer:tap];
    
    //请妥善保管您的助记词，以便丢失后找回
    UIButton *infoLabel = [[UIButton alloc]init];
    [whiteView addSubview:infoLabel];
    [infoLabel setTitle:@" 请将助记词安全保管，离线保存，建议手工抄写".localized forState:UIControlStateNormal];
    infoLabel.titleLabel.font = [UIFont systemFontOfSize:12];
    infoLabel.titleLabel.numberOfLines = 0;
    [infoLabel setTitleColor:SGColorRGBA(221, 46, 65, 1) forState:UIControlStateNormal];
    [infoLabel setImage:[UIImage imageNamed:@"红叹号"] forState:UIControlStateNormal];
    [infoLabel setImage:[UIImage imageNamed:@"红叹号"] forState:UIControlStateHighlighted];
    [infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(messageBgView);
        make.right.equalTo(messageBgView);
        make.top.equalTo(messageBgView.mas_bottom).offset(17);
    }];
    
    UIImageView *qrcodeImg = [[UIImageView alloc]init];
    qrcodeImg.image = [CommonFunction createImgQRCodeWithString:rememberCode centerImage:nil];
    [whiteView addSubview:qrcodeImg];
    [qrcodeImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(infoLabel.mas_bottom).offset(21);
        make.centerX.equalTo(self);
        make.left.mas_offset(88);
        make.width.height.mas_offset(150);
    }];
    
    UILabel *noticeLabel = [[UILabel alloc]init];
    [whiteView addSubview:noticeLabel];
    noticeLabel.text = @"助记词二维码".localized;
    noticeLabel.font = [UIFont boldSystemFontOfSize:14];
    noticeLabel.textColor = SGColorRGBA(51, 54, 73, 1);
    [noticeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(qrcodeImg.mas_bottom).offset(9);
    }];
    
    //okBtn
    UIButton *okBtn = [[UIButton alloc]init];
    [whiteView addSubview:okBtn];
    [okBtn setTitle:buttonName forState:UIControlStateNormal];
    okBtn.titleLabel.font = [UIFont systemFontOfSize:17];
    [okBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [okBtn setBackgroundColor:SGColorRGBA(113, 144, 255, 1)];
    okBtn.layer.cornerRadius = 6;
    okBtn.layer.masksToBounds = true;
    okBtn.layer.borderColor = SGColorRGBA(113, 144, 255, 1).CGColor;
    okBtn.layer.borderWidth = 0.5;
    [okBtn addTarget:self action:@selector(okBtnPress:) forControlEvents:UIControlEventTouchUpInside];
    [okBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(120);
        make.height.mas_equalTo(40);
        make.bottom.equalTo(whiteView).offset(-20);
        make.centerX.equalTo(whiteView);
    }];
    
}

// 确定按钮
- (void)okBtnPress:(UIButton*)sender {
    if (self.okBlock) {
        [self removeFromSuperview];
        self.okBlock(nil);
    }
}

- (void)tapAction:(UITapGestureRecognizer *)sender{
    if (self.ClickPastAction) {
        self.ClickPastAction(self.rememberCode);
    }
}
@end
