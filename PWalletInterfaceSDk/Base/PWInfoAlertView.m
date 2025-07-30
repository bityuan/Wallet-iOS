//
//  PWInfoAlertView.m
//  PWallet
//
//  Created by 陈健 on 2018/9/7.
//  Copyright © 2018年 陈健. All rights reserved.
//

#import "PWInfoAlertView.h"

@interface PWInfoAlertView()
/**矩形alert view*/
@property (nonatomic,strong) UIView *rectView;
/**title*/
@property (nonatomic,strong) UILabel *titleLab;
/**message*/
@property (nonatomic,strong) UILabel *messageLab;
/**确定按钮*/
@property (nonatomic,strong) UIButton *okBtn;
@end

@implementation PWInfoAlertView
- (instancetype)initWithTitle:(NSString*)title message:(NSString*)message buttonName:(NSString*)buttonName {
    self = [super init];
    if (self) {
        [self createViewWithTitle:title message:message buttonName:buttonName];
    }
    return self;
}
- (void)createViewWithTitle:(NSString*)title message:(NSString*)message buttonName:(NSString*)buttonName {
    
    UIView *rectView = [[UIView alloc]init];
    [self addSubview:rectView];
    self.rectView = rectView;
    rectView.backgroundColor = SGColorRGBA(255, 255, 255, 1);
    
    UILabel *titleLab = [[UILabel alloc]init];
    [rectView addSubview:titleLab];
    self.titleLab = titleLab;
    titleLab.text = title;
    titleLab.font = [UIFont boldSystemFontOfSize:16];
    titleLab.textColor = TextColor51;
    
    UILabel *messageLab = [[UILabel alloc]init];
    [rectView addSubview:messageLab];
    self.messageLab = messageLab;
    messageLab.text = message;
    messageLab.font = [UIFont systemFontOfSize:14];
    messageLab.textColor = TextColor51;
    
    //确认 按钮
    UIButton *okBtn = [[UIButton alloc]init];
    [rectView addSubview:okBtn];
    self.okBtn = okBtn;
    [okBtn setTitle:buttonName forState:UIControlStateNormal];
    [okBtn setTitleColor:SGColorRGBA(47, 134, 242, 1) forState:UIControlStateNormal];
    okBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [okBtn addTarget:self action:@selector(okBtnPress:) forControlEvents:UIControlEventTouchUpInside];
    okBtn.backgroundColor = rectView.backgroundColor;
}

- (void)layoutSubviews {
    [self.rectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(40);
        make.right.equalTo(self).offset(-40);
        make.height.mas_equalTo(154);
        make.centerY.equalTo(self);
    }];
    self.rectView.layer.cornerRadius = 3;
    self.rectView.layer.masksToBounds = true;
    
    
    [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.rectView).offset(28);
        make.centerX.equalTo(self.rectView);
    }];
    
    [self.messageLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLab.mas_bottom).offset(15);
        make.centerX.equalTo(self.rectView);
    }];
    
    [self.okBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.rectView).offset(-1);
        make.right.equalTo(self.rectView).offset(1);
        make.bottom.equalTo(self.rectView).offset(1);
        make.height.mas_equalTo(44);
    }];
    self.okBtn.layer.borderWidth = 1;
    self.okBtn.layer.borderColor = SGColorRGBA(236, 236, 236, 1).CGColor;
   
}

// 确定按钮
- (void)okBtnPress:(UIButton*)sender {
    if (self.okBlock) {
        [self removeFromSuperview];
        self.okBlock(nil);
    }
}
@end
