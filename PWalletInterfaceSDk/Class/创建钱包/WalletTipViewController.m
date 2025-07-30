//
//  WalletTipViewController.m
//  PWalletInterfaceSDk
//
//  Created by 郑晨 on 2024/3/12.
//  Copyright © 2024 fzm. All rights reserved.
//

#import "WalletTipViewController.h"
#import "CreateWalletSecondViewController.h"

@interface WalletTipViewController ()
{
    BOOL _selecetd[3];
}
@property (nonatomic, strong) UILabel *tipLab;
@property (nonatomic, strong) UIView *tipOneView;
@property (nonatomic, strong) UILabel *tipOneLab;
@property (nonatomic, strong) UIImageView *tipOneImgView;
@property (nonatomic, strong) UIView *tipTwoView;
@property (nonatomic, strong) UILabel *tipTwoLab;
@property (nonatomic, strong) UIImageView *tipTwoImgView;
@property (nonatomic, strong) UIView *tipThreeView;
@property (nonatomic, strong) UILabel *tipThreeLab;
@property (nonatomic, strong) UIImageView *tipThreeImgView;
@property (nonatomic, strong) UIButton *nextBn;


@end

@implementation WalletTipViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    for (int i = 0; i < 2; i++) {
        _selecetd[i] = NO;
    }
    self.showMaskLine = NO;
    
    self.title = @"创建钱包";
    [self initView];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}


- (void)initView
{
    self.view.backgroundColor = SGColorFromRGB(0xf8f8f8);
    
    [self.view addSubview:self.tipLab];
    [self.view addSubview:self.tipOneView];
    [self.tipOneView addSubview:self.tipOneLab];
    [self.tipOneView addSubview:self.tipOneImgView];
    [self.view addSubview:self.tipTwoView];
    [self.tipTwoView addSubview:self.tipTwoLab];
    [self.tipTwoView addSubview:self.tipTwoImgView];
    [self.view addSubview:self.tipThreeView];
    [self.tipThreeView addSubview:self.tipThreeLab];
    [self.tipThreeView addSubview:self.tipThreeImgView];
    [self.view addSubview:self.nextBn];
    
    [self.tipLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(32);
        make.right.equalTo(self.view).offset(-32);
        make.height.mas_equalTo(80);
        make.top.equalTo(self.view).offset(64);
    }];
    
    [self.tipOneView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(16);
        make.right.equalTo(self.view).offset(-16);
        make.height.mas_equalTo(80);
        make.top.equalTo(self.tipLab.mas_bottom).offset(24);
    }];
    
    [self.tipOneLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.tipOneView).offset(16);
        make.right.equalTo(self.tipOneView).offset(-64);
        make.height.mas_equalTo(60);
        make.top.equalTo(self.tipOneView).offset(10);
    }];
    
    [self.tipOneImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.tipOneView);
        make.width.height.mas_equalTo(20);
        make.right.equalTo(self.tipOneView).offset(-16);
    }];
    
    [self.tipTwoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(16);
        make.right.equalTo(self.view).offset(-16);
        make.height.mas_equalTo(80);
        make.top.equalTo(self.tipOneView.mas_bottom).offset(24);
    }];
    
    [self.tipTwoLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.tipTwoView).offset(16);
        make.right.equalTo(self.tipTwoView).offset(-64);
        make.height.mas_equalTo(60);
        make.top.equalTo(self.tipTwoView).offset(10);
    }];
    
    [self.tipTwoImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.tipTwoView);
        make.width.height.mas_equalTo(20);
        make.right.equalTo(self.tipTwoView).offset(-16);
    }];
    
    [self.tipThreeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(16);
        make.right.equalTo(self.view).offset(-16);
        make.height.mas_equalTo(80);
        make.top.equalTo(self.tipTwoView.mas_bottom).offset(24);
    }];
    
    [self.tipThreeLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.tipThreeView).offset(16);
        make.right.equalTo(self.tipThreeView).offset(-64);
        make.height.mas_equalTo(60);
        make.top.equalTo(self.tipThreeView).offset(10);
    }];
    
    [self.tipThreeImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.tipThreeView);
        make.width.height.mas_equalTo(20);
        make.right.equalTo(self.tipThreeView).offset(-16);
    }];
    
    [self.nextBn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(16);
        make.right.equalTo(self.view).offset(-16);
        make.height.mas_equalTo(40);
        make.top.equalTo(self.tipThreeView.mas_bottom).offset(80);
    }];
    
}

- (void)clickTipView:(UITapGestureRecognizer *)tap
{
    NSInteger tag = tap.view.tag;
    switch (tag) {
        case 100:
        {
            if (_selecetd[0]) {
                _selecetd[0] = NO;
                self.tipOneView.layer.borderColor = SGColorFromRGB(0xffffff).CGColor;
                self.tipOneView.layer.borderWidth = 0;
                self.tipOneView.backgroundColor = SGColorFromRGB(0xffffff);
                [self.tipOneImgView setImage:[UIImage imageNamed:@"unselected_icon"]];
            }else{
                _selecetd[0] = YES;
                self.tipOneView.layer.borderColor = SGColorFromRGB(0x7190ff).CGColor;
                self.tipOneView.layer.borderWidth = 1;
                self.tipOneView.backgroundColor = SGColorFromRGB(0xf8f8f8);
                [self.tipOneImgView setImage:[UIImage imageNamed:@"selected_icon"]];
            }
        }
            break;
        case 200:
        {
            if (_selecetd[1]) {
                _selecetd[1] = NO;
                self.tipTwoView.layer.borderColor = SGColorFromRGB(0xffffff).CGColor;
                self.tipTwoView.layer.borderWidth = 0;
                self.tipTwoView.backgroundColor = SGColorFromRGB(0xffffff);
                [self.tipTwoImgView setImage:[UIImage imageNamed:@"unselected_icon"]];
            }else{
                _selecetd[1] = YES;
                self.tipTwoView.layer.borderColor = SGColorFromRGB(0x7190ff).CGColor;
                self.tipTwoView.layer.borderWidth = 1;
                self.tipTwoView.backgroundColor = SGColorFromRGB(0xf8f8f8);
                [self.tipTwoImgView setImage:[UIImage imageNamed:@"selected_icon"]];
            }
        }
            break;
        case 300:
        {
            if (_selecetd[2]) {
                _selecetd[2] = NO;
                self.tipThreeView.layer.borderColor = SGColorFromRGB(0xffffff).CGColor;
                self.tipThreeView.layer.borderWidth = 0;
                self.tipThreeView.backgroundColor = SGColorFromRGB(0xffffff);
                [self.tipThreeImgView setImage:[UIImage imageNamed:@"unselected_icon"]];
            }else{
                _selecetd[2] = YES;
                self.tipThreeView.layer.borderColor = SGColorFromRGB(0x7190ff).CGColor;
                self.tipThreeView.layer.borderWidth = 1;
                self.tipThreeView.backgroundColor = SGColorFromRGB(0xf8f8f8);
                [self.tipThreeImgView setImage:[UIImage imageNamed:@"selected_icon"]];
            }
        }
            break;
            
        default:
            break;
    }
    
    if (_selecetd[0] && _selecetd[1] &&_selecetd[2]) {
        self.nextBn.hidden = NO;
    }else{
        self.nextBn.hidden = YES;
    }
}

- (void)clickBtn:(UIButton *)sender
{
    
    
    CreateWalletSecondViewController *vc = [[CreateWalletSecondViewController alloc] init];
    vc.walletName = self.walletName;
    vc.password = self.password;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark -- setter getter
- (UILabel *)tipLab{
    if (!_tipLab) {
        UILabel *tipLab = [UILabel getLabWithFont:[UIFont boldSystemFontOfSize:15]
                                        textColor:SGColorFromRGB(0x333649)
                                    textAlignment:NSTextAlignmentLeft
                                             text:@"点击下一步，将看到钱包的助记词，请谨记以下安全点"];
        tipLab.numberOfLines = 0;
        _tipLab = tipLab;
    }
    
    return _tipLab;
}

- (UIView *)tipOneView{
    if (!_tipOneView) {
        UIView *view = [[UIView alloc] init];
        view.layer.cornerRadius = 5.f;
        view.backgroundColor = UIColor.whiteColor;
        view.tag = 100;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickTipView:)];
        tap.numberOfTapsRequired = 1;
        
        _tipOneView = view;
        [_tipOneView addGestureRecognizer:tap];
        _tipOneView.userInteractionEnabled = YES;
    }
    
    return _tipOneView;
}

- (UILabel *)tipOneLab{
    if (!_tipOneLab) {
        UILabel *tipLab = [UILabel getLabWithFont:[UIFont boldSystemFontOfSize:15]
                                        textColor:SGColorFromRGB(0x333649)
                                    textAlignment:NSTextAlignmentLeft
                                             text:@"如果我弄丢了助记词，我的资产将永远丢失"];
        tipLab.numberOfLines = 0;
        _tipOneLab = tipLab;
    }
    
    return _tipOneLab;
}

- (UIImageView *)tipOneImgView{
    if (!_tipOneImgView)
    {
        UIImageView *imgView = [[UIImageView alloc] init];
        imgView.image = [UIImage imageNamed:@"unselected_icon"];
        _tipOneImgView = imgView;
    }
    
    return _tipOneImgView;
}

- (UIView *)tipTwoView{
    if (!_tipTwoView) {
        UIView *view = [[UIView alloc] init];
        view.layer.cornerRadius = 5.f;
        view.backgroundColor = UIColor.whiteColor;
        view.tag = 200;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickTipView:)];
        tap.numberOfTapsRequired = 1;
        
        _tipTwoView = view;
        [_tipTwoView addGestureRecognizer:tap];
        _tipTwoView.userInteractionEnabled = YES;
    }
    
    return _tipTwoView;
}

- (UILabel *)tipTwoLab{
    if (!_tipTwoLab) {
        UILabel *tipLab = [UILabel getLabWithFont:[UIFont boldSystemFontOfSize:15]
                                        textColor:SGColorFromRGB(0x333649)
                                    textAlignment:NSTextAlignmentLeft
                                             text:@"如果我向任何人透露或分享我的助记词，我的资产可能会被盗"];
        tipLab.numberOfLines = 0;
        _tipTwoLab = tipLab;
    }
    
    return _tipTwoLab;
}

- (UIImageView *)tipTwoImgView{
    if (!_tipTwoImgView)
    {
        UIImageView *imgView = [[UIImageView alloc] init];
        imgView.image = [UIImage imageNamed:@"unselected_icon"];
        _tipTwoImgView = imgView;
    }
    
    return _tipTwoImgView;
}

- (UIView *)tipThreeView{
    if (!_tipThreeView) {
        UIView *view = [[UIView alloc] init];
        view.layer.cornerRadius = 5.f;
        view.backgroundColor = UIColor.whiteColor;
        view.tag = 300;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickTipView:)];
        tap.numberOfTapsRequired = 1;
        
        _tipThreeView = view;
        [_tipThreeView addGestureRecognizer:tap];
        _tipThreeView.userInteractionEnabled = YES;
    }
    
    return _tipThreeView;
}

- (UILabel *)tipThreeLab{
    if (!_tipThreeLab) {
        UILabel *tipLab = [UILabel getLabWithFont:[UIFont boldSystemFontOfSize:15]
                                        textColor:SGColorFromRGB(0x333649)
                                    textAlignment:NSTextAlignmentLeft
                                             text:@"保护好助记词的安全的责任全部在于我"];
        tipLab.numberOfLines = 0;
        _tipThreeLab = tipLab;
    }
    
    return _tipThreeLab;
}

- (UIImageView *)tipThreeImgView
{
    if (!_tipThreeImgView)
    {
        UIImageView *imgView = [[UIImageView alloc] init];
        imgView.image = [UIImage imageNamed:@"unselected_icon"];
        _tipThreeImgView = imgView;
    }
    
    return _tipThreeImgView;
}

- (UIButton *)nextBn
{
    if (!_nextBn)
    {
        UIButton *nextBtn = [[UIButton alloc] init];
        [nextBtn setTitle:@"下一步".localized forState:UIControlStateNormal];
        nextBtn.layer.cornerRadius = 5.f;
        [nextBtn.titleLabel setFont:[UIFont systemFontOfSize:17]];
        nextBtn.backgroundColor = SGColorFromRGB(0x7190ff);
        [nextBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        [nextBtn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
        nextBtn.hidden = YES;
        _nextBn = nextBtn;
    }
    
    return _nextBn;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
