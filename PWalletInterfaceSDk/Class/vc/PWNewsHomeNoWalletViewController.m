//
//  PWNewsHomeNoWalletViewController.m
//  PWallet
//
//  Created by 郑晨 on 2019/11/26.
//  Copyright © 2019 陈健. All rights reserved.
//

#import "PWNewsHomeNoWalletViewController.h"
#import <YYLabel.h>
#import "CreateWalletViewController.h"
#import "PWImportWalletViewController.h"
#import "ImportWalletHomeViewController.h"

@interface PWNewsHomeNoWalletViewController ()

@property (nonatomic, strong) UIImageView *happyImageView;// ”好看“的图片
@property (nonatomic, strong) UIImageView *normalWalletBgIamgeView; // 区块链钱包背景
@property (nonatomic, strong) UILabel *normalWalletTitleLab; // 标题
@property (nonatomic, strong) UIButton *createBtn;// 创建钱包
@property (nonatomic, strong) UIButton *importBtn;// 导入钱包

@end

@implementation PWNewsHomeNoWalletViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = SGColorFromRGB(0xf0f3ff);
    [self createView];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changeLanguage)
                                                 name:kChangeLanguageNotification
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
     [self.navigationController setNavigationBarHidden:true animated:animated];
    if (@available(iOS 13.0, *)) {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDarkContent;
    } else {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:false animated:animated];
}

- (void)createView
{
    [self.view addSubview:self.happyImageView];
    [self.happyImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view);
        make.width.mas_equalTo(375 * kScreenRatio);
        make.height.mas_equalTo(330 * kScreenRatio);
    }];
    [self.view addSubview:self.normalWalletBgIamgeView];
    [self.normalWalletBgIamgeView addSubview:self.normalWalletTitleLab];
    [self.normalWalletBgIamgeView addSubview:self.createBtn];
    [self.normalWalletBgIamgeView addSubview:self.importBtn];
    self.normalWalletBgIamgeView.hidden = NO;
    [self.normalWalletBgIamgeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        if (!isIPhoneXSeries) {
            make.top.equalTo(self.happyImageView.mas_bottom).offset(20 * kScreenRatio);
        }
        else
        {
            make.top.equalTo(self.happyImageView.mas_bottom).offset(72 * kScreenRatio);
        }
        
        make.height.mas_equalTo(170 * kScreenRatio);
        make.width.mas_equalTo(330 * kScreenRatio);
    }];
    
    [self.normalWalletTitleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.normalWalletBgIamgeView).offset(20);
        make.top.equalTo(self.normalWalletBgIamgeView).offset(20);
        make.right.equalTo(self.normalWalletBgIamgeView).offset(-20);
        make.height.mas_equalTo(33);
    }];
    
    
    [self.createBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.normalWalletBgIamgeView).offset(16);
        make.width.mas_equalTo(90);
        make.height.mas_equalTo(36);
        make.bottom.equalTo(self.normalWalletBgIamgeView).offset(-20);
    }];
    [self.importBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.createBtn.mas_right).offset(29);
        make.width.height.bottom.equalTo(self.createBtn);
    }];
}

#pragma mark - label加图片
- (NSMutableAttributedString *)labelAddImageWithImage:(UIImage *)image andLabelStr:(NSString *)labelStr
{
    NSMutableAttributedString *abs = [[NSMutableAttributedString alloc] initWithString:labelStr == nil ? @"" : labelStr];
    NSTextAttachment *attach = [[NSTextAttachment alloc] init];
    attach.image = image;
    attach.bounds = CGRectMake(3, 0, 16, 16);
    NSAttributedString *imageStr = [NSAttributedString attributedStringWithAttachment:attach];
    [abs appendAttributedString:imageStr];

    return abs;
}

#pragma mark - 切换语言通知
- (void)changeLanguage
{
   
    [self.normalWalletTitleLab setText:@"区块链钱包".localized];
    self.normalWalletTitleLab.attributedText = [self labelAddImageWithImage:[UIImage imageNamed:@"tip"]
    andLabelStr:self.normalWalletTitleLab.text];
    [self.createBtn setTitle:@"创建钱包".localized forState:UIControlStateNormal];
    [self.importBtn setTitle:@"导入钱包".localized forState:UIControlStateNormal];
   
   
    
    [self.createBtn.titleLabel setFont:[UIFont systemFontOfSize:15.f]];
    [self.importBtn.titleLabel setFont:[UIFont systemFontOfSize:15.f]];
    
    if ([LocalizableService getAPPLanguage] == LanguageEnglish) {
        [self.normalWalletTitleLab mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(33);
        }];
        [self.createBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(110);
        }];
        [self.importBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(110);
        }];
    }
    else
    {
        [self.normalWalletTitleLab mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(33);
        }];
       [self.createBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(90);
        }];
        [self.importBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(90);
        }];
       
    }
    
}

#pragma mark - 按钮点击事

#pragma mark - 按钮点击事件
- (void)btnAction:(UIButton *)sender
{
    switch (sender.tag) {
        case 1:
        {
            // 创建钱包
            CreateWalletViewController *vc = [[CreateWalletViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 2:
        {
            // 导入钱包
            ImportWalletHomeViewController *homeVC = [[ImportWalletHomeViewController alloc] init];
            [self.navigationController pushViewController:homeVC animated:YES];

        }
            break;
        default:
            break;
    }
}


- (UIImageView *)happyImageView
{
    if (!_happyImageView) {
        _happyImageView = [[UIImageView alloc] init];
        _happyImageView.image = [UIImage imageNamed:@"happyimage_other"];
        _happyImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _happyImageView;
}

- (UIImageView *)normalWalletBgIamgeView
{
    if (!_normalWalletBgIamgeView) {
        _normalWalletBgIamgeView = [[UIImageView alloc] init];
        _normalWalletBgIamgeView.image = [UIImage imageNamed:@"nowallet_nromal_bg"];
        _normalWalletBgIamgeView.contentMode = UIViewContentModeScaleAspectFit;
        _normalWalletBgIamgeView.tag = 100;
        [_normalWalletBgIamgeView setUserInteractionEnabled:YES];
    }
    return _normalWalletBgIamgeView;
}

- (UILabel *)normalWalletTitleLab
{
    if (!_normalWalletTitleLab) {
        _normalWalletTitleLab = [[UILabel alloc]init];
        _normalWalletTitleLab.text = @"区块链钱包".localized;
        _normalWalletTitleLab.font = [UIFont systemFontOfSize:24];
        _normalWalletTitleLab.textColor = SGColorFromRGB(0xffffff);
        _normalWalletTitleLab.textAlignment = NSTextAlignmentLeft;
        _normalWalletTitleLab.attributedText = [self labelAddImageWithImage:[UIImage imageNamed:@"tip"]
                                                                andLabelStr:_normalWalletTitleLab.text];
        _normalWalletTitleLab.numberOfLines = 0;
        

    }
    return _normalWalletTitleLab;
}

- (UIButton *)createBtn
{
    if (!_createBtn) {
        _createBtn = [[UIButton alloc] init];
        _createBtn.tag = 1;
        [_createBtn setTitle:@"创建钱包".localized forState:UIControlStateNormal];
        [_createBtn setTitleColor:SGColorFromRGB(0x333649) forState:UIControlStateNormal];
        [_createBtn.titleLabel setFont:[UIFont systemFontOfSize: 15]];
        [_createBtn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
        [_createBtn setBackgroundColor:SGColorFromRGB(0xffffff)];
        [_createBtn.layer setCornerRadius:20.f];
        
    }
    
    return _createBtn;
}

- (UIButton *)importBtn
{
    if (!_importBtn) {
        _importBtn = [[UIButton alloc] init];
        _importBtn.tag = 2;
        [_importBtn setTitle:@"导入钱包".localized forState:UIControlStateNormal];
        [_importBtn setTitleColor:SGColorFromRGB(0xffffff) forState:UIControlStateNormal];
        [_importBtn.titleLabel setFont:[UIFont systemFontOfSize:15.f]];
        [_importBtn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
        [_importBtn setBackgroundColor:SGColorFromRGB(0x7a90ff)];
        [_importBtn.layer setCornerRadius:20.f];
    }
    
    return _importBtn;
}


@end
