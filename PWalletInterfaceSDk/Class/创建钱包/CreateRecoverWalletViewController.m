//
//  CreateRecoverWalletViewController.m
//  PWalletInterfaceSDk
//
//  Created by 郑晨 on 2022/8/31.
//  Copyright © 2022 fzm. All rights reserved.
//

#import "CreateRecoverWalletViewController.h"
#import "ScanViewController.h"
#import "PWAlertController.h"
#import "PWNewInfoAlertView.h"
#import "PWImageAlertView.h"
#import "UIImage+Screenshot.h"
#import <pop/POP.h>

#define  MyDaoPrikey @"02059f401bfabd8e1c8cf099ced414fbe2fca5dae7e931a82d837c1dfd7ece17c9" // 官方备份私钥

@interface CreateRecoverWalletViewController ()
<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *headView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UILabel *controlAddrLab;
@property (nonatomic, strong) UILabel *controlAddrDetailLab;
@property (nonatomic, strong) UIButton *controlQrcodebtn;
@property (nonatomic, strong) UILabel *btyLab;
@property (nonatomic, strong) UIButton *btyBtn;
@property (nonatomic, strong) UILabel *yccLab;
@property (nonatomic, strong) UIButton *yccBtn;
@property (nonatomic, strong) UILabel *balanceLab;
@property (nonatomic, strong) UILabel *balanceDetailLab;
@property (nonatomic, strong) UIButton *refreshBalanceBtn;
@property (nonatomic, strong) UILabel *backUpAddrLab;
@property (nonatomic, strong) UITextField *backUpAddrTextfield;
@property (nonatomic, strong) UIButton *scanBtb;
@property (nonatomic, strong) UILabel *thridpartBackUpAddrLab;
@property (nonatomic, strong) UILabel *thridpartBackUpAddrDetailLab;
@property (nonatomic, strong) UITextField *recoverEmailTextfield;
//@property (nonatomic, strong) UITextField *codeTextfield;
//@property (nonatomic, strong) UIButton *getCodeBtn;
@property (nonatomic, strong) UIView *recoverTimeSetView;
@property (nonatomic, strong) UILabel *recoverTimeSetLab;
@property (nonatomic, strong) UIButton *recoverSet7btn;
@property (nonatomic, strong) UILabel *recoverSet7Lab;
@property (nonatomic, strong) UIButton *recoverSet30btn;
@property (nonatomic, strong) UILabel *recoverSet30Lab;
@property (nonatomic, strong) UIButton *recoverSet60btn;
@property (nonatomic, strong) UILabel *recoverSet60Lab;
@property (nonatomic, strong) UIButton *createWalletBtn;
@property (nonatomic, strong) UILabel *recoverTipLab;
// 倒计时
@property (nonatomic, strong) NSTimer *countDownTimer;// 计时器
@property (nonatomic, assign) int seconds; // 倒计时总长

@property (nonatomic, strong) LocalCoin *localCoin;

@end

@implementation CreateRecoverWalletViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.showMaskLine = NO;
    self.title = @"设置找回参数".localized;
    // 默认选择7天找回
    self.view.backgroundColor = UIColor.whiteColor;
    self.recoverTimeType = RecoverTimeType7;
    self.recoverCoinType = RecoverCoinTypeBTY;
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

}


#pragma mark - tableview
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [UITableViewCell new];
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    self.headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    [self.headView addSubview:self.contentView];
    [self.headView addSubview:self.recoverTimeSetView];
    [self.headView addSubview:self.createWalletBtn];
//    [self.headView addSubview:self.recoverTipLab];
    
    [self.contentView addSubview:self.controlAddrLab];
    [self.contentView addSubview:self.controlAddrDetailLab];
    [self.contentView addSubview:self.controlQrcodebtn];
    [self.contentView addSubview:self.btyBtn];
    [self.contentView addSubview:self.btyLab];
    [self.contentView addSubview:self.yccBtn];
    [self.contentView addSubview:self.yccLab];
    [self.contentView addSubview:self.balanceLab];
    [self.contentView addSubview:self.balanceDetailLab];
    [self.contentView addSubview:self.refreshBalanceBtn];
    [self.contentView addSubview:self.backUpAddrLab];
    [self.contentView addSubview:self.backUpAddrTextfield];
    [self.contentView addSubview:self.scanBtb];
    [self.contentView addSubview:self.thridpartBackUpAddrLab];
    [self.contentView addSubview:self.thridpartBackUpAddrDetailLab];
    [self.contentView addSubview:self.recoverEmailTextfield];
//    [self.contentView addSubview:self.codeTextfield];
//    [self.contentView addSubview:self.getCodeBtn];
    
    [self.recoverTimeSetView addSubview:self.recoverTimeSetLab];
    [self.recoverTimeSetView addSubview:self.recoverSet7btn];
    [self.recoverTimeSetView addSubview:self.recoverSet7Lab];
    [self.recoverTimeSetView addSubview:self.recoverSet30btn];
    [self.recoverTimeSetView addSubview:self.recoverSet30Lab];
    [self.recoverTimeSetView addSubview:self.recoverSet60btn];
    [self.recoverTimeSetView addSubview:self.recoverSet60Lab];
    
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.headView);
        make.height.mas_equalTo(442);
    }];
    
    [self.recoverTimeSetView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.headView);
        make.top.equalTo(self.contentView.mas_bottom).offset(10);
        make.height.mas_equalTo(114);
    }];
    
    [self.createWalletBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.headView).offset(16);
        make.right.equalTo(self.headView).offset(-16);
        make.height.mas_equalTo(44);
        make.top.equalTo(self.recoverTimeSetView.mas_bottom).offset(38);
    }];
    
//    [self.recoverTipLab mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.headView).offset(17);
//        make.right.equalTo(self.headView).offset(-16);
//        make.top.equalTo(self.createWalletBtn.mas_bottom).offset(38);
//    }];
    
    [self.controlAddrLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(25);
        make.top.equalTo(self.contentView).offset(28);
        make.height.mas_equalTo(19);
    }];
    [self.controlAddrDetailLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(25);
        make.top.equalTo(self.controlAddrLab.mas_bottom).offset(8);
        make.height.mas_equalTo(20);
        make.right.equalTo(self.contentView).offset(-115);
    }];
    
    [self.controlQrcodebtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).offset(-21);
        make.width.mas_equalTo(64);
        make.height.mas_equalTo(32);
        make.top.equalTo(self.contentView).offset(31);
    }];
    
    [self.btyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(25);
        make.top.equalTo(self.controlAddrDetailLab.mas_bottom).offset(18);
        make.height.width.mas_equalTo(20);
    }];
    
    [self.btyLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.btyBtn.mas_right).offset(5);
        make.width.mas_equalTo(40);
        make.height.mas_equalTo(19);
        make.centerY.equalTo(self.btyBtn);
    }];
    
    [self.yccBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.btyLab.mas_right).offset(15 * kScreenWidth / 375.0);
        make.top.height.width.equalTo(self.btyBtn);
    }];
    
    [self.yccLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.yccBtn.mas_right).offset(5);
        make.width.mas_equalTo(40);
        make.height.mas_equalTo(19);
        make.centerY.equalTo(self.yccBtn);
    }];
    
//    UIView *controlLineView = [[UIView alloc] init];
//    controlLineView.backgroundColor = SGColorFromRGB(0xECECEC);
//    [self.contentView addSubview:controlLineView];
//    [controlLineView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.contentView).offset(16);
//        make.right.equalTo(self.contentView).offset(-16);
//        make.top.equalTo(self.controlQrcodebtn.mas_bottom).offset(19);
//        make.height.mas_equalTo(.5);
//    }];
    
    [self.balanceLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(25);
        make.top.equalTo(self.btyBtn.mas_bottom).offset(26);
        make.height.mas_equalTo(19);
    }];
    [self.balanceDetailLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(25);
        make.top.equalTo(self.balanceLab.mas_bottom).offset(5);
        make.height.mas_equalTo(20);
    }];
    
    [self.refreshBalanceBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).offset(-36);
        make.width.mas_equalTo(19);
        make.height.mas_equalTo(21);
        make.top.equalTo(self.balanceLab.mas_top).offset(13);
    }];
    
    UIView *balanceLineView = [[UIView alloc] init];
    balanceLineView.backgroundColor = SGColorFromRGB(0xECECEC);
    [self.contentView addSubview:balanceLineView];
    [balanceLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(16);
        make.right.equalTo(self.contentView).offset(-16);
        make.top.equalTo(self.refreshBalanceBtn.mas_bottom).offset(10);
        make.height.mas_equalTo(.5);
    }];
    
    [self.backUpAddrLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(25);
        make.top.equalTo(balanceLineView.mas_bottom).offset(25);
        make.height.mas_equalTo(19);
    }];
    [self.backUpAddrTextfield mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(16);
        make.right.equalTo(self.contentView).offset(-16);
        make.top.equalTo(self.backUpAddrLab.mas_bottom).offset(7);
        make.height.mas_equalTo(50);
    }];
    
    [self.scanBtb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.backUpAddrTextfield.mas_right).offset(-18);
        make.width.mas_equalTo(21);
        make.height.mas_equalTo(22);
        make.centerY.equalTo(self.backUpAddrTextfield);
    }];
    
    [self.thridpartBackUpAddrLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(25);
        make.top.equalTo(self.backUpAddrTextfield.mas_bottom).offset(23);
        make.height.mas_equalTo(19);
    }];
    [self.thridpartBackUpAddrDetailLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(25);
        make.right.equalTo(self.contentView).offset(-25);
        make.top.equalTo(self.thridpartBackUpAddrLab.mas_bottom).offset(8);
        make.height.mas_equalTo(20);
    }];
    UIView *backupLineView = [[UIView alloc] init];
    backupLineView.backgroundColor = SGColorFromRGB(0xECECEC);
    [self.contentView addSubview:backupLineView];
    [backupLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(16);
        make.right.equalTo(self.contentView).offset(-16);
        make.top.equalTo(self.thridpartBackUpAddrDetailLab.mas_bottom).offset(11);
        make.height.mas_equalTo(.5);
    }];
    
    [self.recoverEmailTextfield mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(16);
        make.right.equalTo(self.contentView).offset(-16);
        make.top.equalTo(backupLineView.mas_bottom).offset(15);
        make.height.mas_equalTo(50);
    }];
//    [self.codeTextfield mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.contentView).offset(16);
//        make.width.mas_equalTo(222 * kScreenWidth / 375.0);
//        make.top.equalTo(self.recoverEmailTextfield.mas_bottom).offset(10);
//        make.height.mas_equalTo(50);
//    }];
//    [self.getCodeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.right.equalTo(self.contentView).offset(-16);
//        make.top.height.equalTo(self.codeTextfield);
//        make.width.mas_equalTo(111 * kScreenWidth / 375.0);
//    }];
    
    [self.recoverTimeSetLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.recoverTimeSetView).offset(16);
        make.top.equalTo(self.recoverTimeSetView).offset(19);
        make.height.mas_equalTo(19);
    }];
    
    [self.recoverSet7btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.recoverTimeSetView).offset(25);
        make.top.equalTo(self.recoverTimeSetLab.mas_bottom).offset(18);
        make.height.width.mas_equalTo(20);
    }];
    
    [self.recoverSet7Lab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.recoverSet7btn.mas_right).offset(5);
        make.width.mas_equalTo(45);
        make.height.mas_equalTo(19);
        make.centerY.equalTo(self.recoverSet7btn);
    }];
    
    [self.recoverSet30btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.recoverSet7Lab.mas_right).offset(20 * kScreenWidth / 375.0);
        make.top.height.width.equalTo(self.recoverSet7btn);
    }];
    
    [self.recoverSet30Lab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.recoverSet30btn.mas_right).offset(5);
        make.width.mas_equalTo(55);
        make.height.mas_equalTo(19);
        make.centerY.equalTo(self.recoverSet30btn);
    }];
    
    [self.recoverSet60btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.recoverSet30Lab.mas_right).offset(20 * kScreenWidth / 375.0);
        make.top.height.width.equalTo(self.recoverSet7btn);
    }];
    
    [self.recoverSet60Lab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.recoverSet60btn.mas_right).offset(5);
        make.width.mas_equalTo(55);
        make.height.mas_equalTo(19);
        make.centerY.equalTo(self.recoverSet7btn);
    }];
    
    [self.backUpAddrTextfield setKeyBoardInputView:self.createWalletBtn action:@selector(createWallet:)];
    [self.recoverEmailTextfield setKeyBoardInputView:self.createWalletBtn action:@selector(createWallet:)];
//    [self.codeTextfield setKeyBoardInputView:self.createWalletBtn action:@selector(createWallet:)];
    NSArray *coinArray = [[PWDataBaseManager shared] queryCoinArrayBasedOnSelectedWalletID];
    if(self.recoverCoinType == RecoverCoinTypeBTY){
        // bty
        for (LocalCoin *coin in coinArray) {
            if([coin.coin_type isEqualToString:@"BTY"] && [coin.coin_chain isEqualToString:@"BTY"]){
                self.localCoin = coin;
            }
        }
    }else if (self.recoverCoinType == RecoverCoinTypeYCC){
        // ycc
        for (LocalCoin *coin in coinArray) {
            if([coin.coin_type isEqualToString:@"YCC"] && [coin.coin_chain isEqualToString:@"ETH"]){
                self.localCoin = coin;
            }
        }
    }
    self.controlAddrDetailLab.text = self.localCoin.coin_address;
    self.balanceDetailLab.text = [CommonFunction removeZeroFromMoney:self.localCoin.coin_balance withMaxLength:6];
    
    return self.headView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGRect rect = [self.recoverTipLab.text boundingRectWithSize:CGSizeMake(kScreenWidth - 32, MAXFLOAT)
                                                        options:NSStringDrawingUsesLineFragmentOrigin
                                                     attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]}
                                                        context:nil];
    return 556 + rect.size.height + kBottomOffset;
}


#pragma mark -- method
- (void)selectCoin:(UIButton *)sender
{
    switch (sender.tag) {
        case 101:
        {
            [self.btyBtn setImage:[UIImage imageNamed:@"selected_icon"] forState:UIControlStateNormal];
            [self.yccBtn setImage:[UIImage imageNamed:@"unselected_icon"] forState:UIControlStateNormal];
            self.recoverCoinType = RecoverCoinTypeBTY;
        }
            break;
        case 102:
        {
            [self.btyBtn setImage:[UIImage imageNamed:@"unselected_icon"] forState:UIControlStateNormal];
            [self.yccBtn setImage:[UIImage imageNamed:@"selected_icon"] forState:UIControlStateNormal];
            self.recoverCoinType = RecoverCoinTypeYCC;
        }
            break;
        default:
            break;
    }
    NSArray *coinArray = [[PWDataBaseManager shared] queryCoinArrayBasedOnSelectedWalletID];
    if(self.recoverCoinType == RecoverCoinTypeBTY){
        // bty
        for (LocalCoin *coin in coinArray) {
            if([coin.coin_type isEqualToString:@"BTY"] && [coin.coin_chain isEqualToString:@"BTY"]){
                self.localCoin = coin;
            }
        }
    }else if (self.recoverCoinType == RecoverCoinTypeYCC){
        // ycc
        for (LocalCoin *coin in coinArray) {
            if([coin.coin_type isEqualToString:@"YCC"] && [coin.coin_chain isEqualToString:@"ETH"]){
                self.localCoin = coin;
            }
        }
    }
    self.controlAddrDetailLab.text = self.localCoin.coin_address;
    self.balanceDetailLab.text = [CommonFunction removeZeroFromMoney:self.localCoin.coin_balance withMaxLength:6];
}

- (void)tapCoin:(UITapGestureRecognizer *)tap
{
    switch (tap.view.tag) {
        case 101:
        {
            [self.btyBtn setImage:[UIImage imageNamed:@"selected_icon"] forState:UIControlStateNormal];
            [self.yccBtn setImage:[UIImage imageNamed:@"unselected_icon"] forState:UIControlStateNormal];
            self.recoverCoinType = RecoverCoinTypeBTY;
        }
            break;
        case 102:
        {
            [self.btyBtn setImage:[UIImage imageNamed:@"unselected_icon"] forState:UIControlStateNormal];
            [self.yccBtn setImage:[UIImage imageNamed:@"selected_icon"] forState:UIControlStateNormal];
            self.recoverCoinType = RecoverCoinTypeYCC;
        }
            break;
        default:
            break;
    }
    
    NSArray *coinArray = [[PWDataBaseManager shared] queryCoinArrayBasedOnSelectedWalletID];
    if(self.recoverCoinType == RecoverCoinTypeBTY){
        // bty
        for (LocalCoin *coin in coinArray) {
            if([coin.coin_type isEqualToString:@"BTY"] && [coin.coin_chain isEqualToString:@"BTY"]){
                self.localCoin = coin;
            }
        }
    }else if (self.recoverCoinType == RecoverCoinTypeYCC){
        // ycc
        for (LocalCoin *coin in coinArray) {
            if([coin.coin_type isEqualToString:@"YCC"] && [coin.coin_chain isEqualToString:@"ETH"]){
                self.localCoin = coin;
            }
        }
    }
    self.controlAddrDetailLab.text = self.localCoin.coin_address;
    self.balanceDetailLab.text = [CommonFunction removeZeroFromMoney:self.localCoin.coin_balance withMaxLength:6];
}

- (void)selectTime:(UIButton *)sender
{
    switch (sender.tag)
    {
        case 7:
        {
            [self.recoverSet7btn  setImage:[UIImage imageNamed:@"selected_icon"]   forState:UIControlStateNormal];
            [self.recoverSet30btn setImage:[UIImage imageNamed:@"unselected_icon"] forState:UIControlStateNormal];
            [self.recoverSet60btn setImage:[UIImage imageNamed:@"unselected_icon"] forState:UIControlStateNormal];
            self.recoverTimeType = RecoverTimeType7;
        }
            break;
        case 30:
        {
            [self.recoverSet7btn  setImage:[UIImage imageNamed:@"unselected_icon"] forState:UIControlStateNormal];
            [self.recoverSet30btn setImage:[UIImage imageNamed:@"selected_icon"]   forState:UIControlStateNormal];
            [self.recoverSet60btn setImage:[UIImage imageNamed:@"unselected_icon"] forState:UIControlStateNormal];
            self.recoverTimeType = RecoverTimeType30;
        }
            break;
        case 60:
        {
            [self.recoverSet7btn  setImage:[UIImage imageNamed:@"unselected_icon"] forState:UIControlStateNormal];
            [self.recoverSet30btn setImage:[UIImage imageNamed:@"unselected_icon"] forState:UIControlStateNormal];
            [self.recoverSet60btn setImage:[UIImage imageNamed:@"selected_icon"]   forState:UIControlStateNormal];
            self.recoverTimeType = RecoverTimeType90;
        }
            break;
            
        default:
            break;
    }
}

- (void)tapTime:(UITapGestureRecognizer *)tap
{
    switch (tap.view.tag)
    {
        case 7:
        {
            [self.recoverSet7btn setImage:[UIImage imageNamed:@"selected_icon"] forState:UIControlStateNormal];
            [self.recoverSet30btn setImage:[UIImage imageNamed:@"unselected_icon"] forState:UIControlStateNormal];
            [self.recoverSet60btn setImage:[UIImage imageNamed:@"unselected_icon"] forState:UIControlStateNormal];
            self.recoverTimeType = RecoverTimeType7;
        }
            break;
        case 30:
        {
            [self.recoverSet30btn setImage:[UIImage imageNamed:@"selected_icon"] forState:UIControlStateNormal];
            [self.recoverSet7btn setImage:[UIImage imageNamed:@"unselected_icon"] forState:UIControlStateNormal];
            [self.recoverSet60btn setImage:[UIImage imageNamed:@"unselected_icon"] forState:UIControlStateNormal];
            self.recoverTimeType = RecoverTimeType30;
        }
            break;
        case 60:
        {
            [self.recoverSet60btn setImage:[UIImage imageNamed:@"selected_icon"] forState:UIControlStateNormal];
            [self.recoverSet7btn setImage:[UIImage imageNamed:@"unselected_icon"] forState:UIControlStateNormal];
            [self.recoverSet30btn setImage:[UIImage imageNamed:@"unselected_icon"] forState:UIControlStateNormal];
            self.recoverTimeType = RecoverTimeType90;
        }
            break;
            
        default:
            break;
    }
}

#pragma mark -- scan
- (void)scanAddr:(UIButton *)sender
{
    [self.view endEditing:true];
    ScanViewController *vc = [[ScanViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
    vc.scanResult = ^(NSString *address)
    {
        if ([address containsString:@","])
        {
            NSArray *array = [address componentsSeparatedByString:@","];
            if (array.count == 3)
            {
                NSString *add = [NSString stringWithFormat:@"%@",array[2]];
                self.backUpAddrTextfield.text = add;
            }
            else if (array.count == 2)
            {
                NSString *add = [NSString stringWithFormat:@"%@",array[1]];
                self.backUpAddrTextfield.text = add;
            }
        }
        else
        {
            self.backUpAddrTextfield.text = address;
        }
    };
}

//#pragma mark - 获取验证码
//- (void)getCode:(UIButton *)sender
//{
//
//    [self startCountDown];
//}

//- (void)startCountDown
//{
//    [self.getCodeBtn setTitle:@"60s后可重新获取" forState:UIControlStateNormal];
//    self.getCodeBtn.userInteractionEnabled = NO;
//    _seconds = 60;
//    _countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1
//                                                       target:self
//                                                     selector:@selector(timeCountDown)
//                                                     userInfo:nil
//                                                      repeats:YES];
//}
//
//- (void)timeCountDown
//{
//    _seconds--;
//    if (_seconds > 0)
//    {
//        [self.getCodeBtn setTitle:[NSString stringWithFormat:@"%ds后可重新获取",_seconds] forState:UIControlStateNormal];
//    }
//    else
//    {
//        [_countDownTimer invalidate];
//        [self.getCodeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
//        self.getCodeBtn.userInteractionEnabled = YES;
//    }
//}
#pragma mark - 显示地址二维码
- (void)getQRImage:(UIButton *)sender
{
    UIImage *qrimage = [CommonFunction createImgQRCodeWithString:self.localCoin.coin_address centerImage:nil];
    
    PWImageAlertView *imageAlerView = [[PWImageAlertView alloc] initWithTitle:@"控制地址".localized image:qrimage address:self.localCoin.coin_address];
    WEAKSELF
    typeof(imageAlerView) __weak weakImageAlertView = imageAlerView;
    imageAlerView.cancelBlock = ^(id obj) {
        [weakSelf animationHideImageAlertView:weakImageAlertView toView:sender];
    };
    imageAlerView.okBlock = ^(id obj) {
        NSString *str = obj;
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = str;
        [self showCustomMessage:@"复制成功".localized hideAfterDelay:2.0];
    };
    [self animationShowImageAlertView:imageAlerView fromView:sender];

}

#pragma mark - 动画展示和隐藏
- (void)animationShowImageAlertView:(PWImageAlertView*)imageAlerView fromView:(UIView*)fromView {

    [imageAlerView layoutIfNeeded];
    UIView *whiteView = imageAlerView.subviews.firstObject;
    UIImage *imageFromView = [UIImage getImageFromView:whiteView];
    CGRect senderViewOriginalFrame = [fromView.superview convertRect:fromView.frame toView:nil];

    UIView *fadeView = [[UIView alloc] initWithFrame:[UIApplication sharedApplication].keyWindow.bounds];
    fadeView.backgroundColor = [UIColor clearColor];
    [[UIApplication sharedApplication].keyWindow addSubview:fadeView];

    UIImageView *resizableImageView = [[UIImageView alloc] initWithImage:imageFromView];
    resizableImageView.frame = senderViewOriginalFrame;
    resizableImageView.clipsToBounds = YES;
    resizableImageView.contentMode = UIViewContentModeScaleAspectFit;
    resizableImageView.backgroundColor = [UIColor clearColor];
    [[UIApplication sharedApplication].keyWindow addSubview:resizableImageView];

    void (^completion)(void) = ^() {
        [fadeView removeFromSuperview];
        [resizableImageView removeFromSuperview];
        [[UIApplication sharedApplication].keyWindow addSubview:imageAlerView];
    };

    [UIView animateWithDuration:0.28 animations:^{
        fadeView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
    } completion:nil];
    CGRect finalImageViewFrame = CGRectMake((kScreenWidth - whiteView.frame.size.width) * 0.5, (kScreenHeight - whiteView.frame.size.height) * 0.5, whiteView.frame.size.width, whiteView.frame.size.height);
    [self animateView:resizableImageView
              toFrame:finalImageViewFrame
           completion:completion];

}

- (void)animationHideImageAlertView:(PWImageAlertView*)imageAlerView toView:(UIView*)toView{
   
    UIView *fadeView = [[UIView alloc] initWithFrame:[UIApplication sharedApplication].keyWindow.bounds];
    fadeView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
    [[UIApplication sharedApplication].keyWindow addSubview:fadeView];

    UIView *whiteView = imageAlerView.subviews.firstObject;
    UIImage *imageFromView = [UIImage getImageFromView:whiteView];
    CGRect senderViewOriginalFrame = CGRectMake((kScreenWidth - whiteView.frame.size.width) * 0.5, (kScreenHeight - whiteView.frame.size.height) * 0.5, whiteView.frame.size.width, whiteView.frame.size.height);
    UIImageView *resizableImageView = [[UIImageView alloc] initWithImage:imageFromView];
    resizableImageView.frame = senderViewOriginalFrame;
    resizableImageView.clipsToBounds = YES;
    resizableImageView.contentMode =  toView.contentMode;
    resizableImageView.backgroundColor = [UIColor clearColor];
    [[UIApplication sharedApplication].keyWindow addSubview:resizableImageView];

    void (^completion)(void) = ^() {
        [fadeView removeFromSuperview];
        [resizableImageView removeFromSuperview];
        [imageAlerView removeFromSuperview];
    };
    imageAlerView.alpha = 0;
    [UIView animateWithDuration:0.28 animations:^{
        fadeView.backgroundColor = [UIColor clearColor];
    } completion:nil];
    CGRect finalImageViewFrame = [toView.superview convertRect:toView.frame toView:nil];
    [self animateView:resizableImageView
              toFrame:finalImageViewFrame
           completion:completion];
    [UIView animateWithDuration:0.4 animations:^{
        resizableImageView.alpha = 0;
    } completion:nil];
}

- (void)animateView:(UIView *)view toFrame:(CGRect)frame completion:(void (^)(void))completion
{
    POPSpringAnimation *animation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewFrame];
    [animation setSpringBounciness:6];
    [animation setDynamicsMass:1];
    [animation setToValue:[NSValue valueWithCGRect:frame]];
    [view pop_addAnimation:animation forKey:nil];

    if (completion)
    {
        [animation setCompletionBlock:^(POPAnimation *animation, BOOL finished) {
            completion();
        }];
    }
}

#pragma mark - 获取余额
- (void)refreshBalance:(UIButton*)sender
{
    
    NSData *balanceData;
    NSError *error;
    CGFloat balance = 0;
    
    WalletapiWalletBalance *walletbalance = [[WalletapiWalletBalance alloc] init];
    
    [walletbalance setCointype:self.recoverCoinType == RecoverCoinTypeBTY ? @"BTY" : @"YCC"];
    [walletbalance setAddress:self.controlAddrDetailLab.text];
    [walletbalance setTokenSymbol:@""];
    WalletapiUtil *util = [[WalletapiUtil alloc] init];
    [util setNode:GoNodeUrl];
    [walletbalance setUtil:util];
    
    balanceData = WalletapiGetbalance(walletbalance, &error);
    
    if (balanceData == nil)
    {
        balance = 0;
        self.balanceDetailLab.text = @"0.000000";
        return;
    }
    
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:balanceData options:NSJSONReadingMutableLeaves error:nil];
  
    if ([jsonDict[@"result"] isEqual:[NSNull null]] || jsonDict[@"result"] == nil)
    {
        balance = 0;
        self.balanceDetailLab.text = @"0.000000";
        return;
    }
    NSDictionary *resultDict = jsonDict[@"result"];
    balance = [resultDict[@"balance"] doubleValue];
    self.balanceDetailLab.text = [CommonFunction removeZeroFromMoney:balance withMaxLength:6];
}

#pragma mark - 创建钱包
- (void)createWallet:(UIButton *)sender
{
    NSLog(@"创建钱包");
    
    // 先判断用户有没有输入公钥
    if(self.backUpAddrTextfield.text.length == 0){
        [self showCustomMessage:@"请输入备份公钥".localized hideAfterDelay:2.f];
        return;
    }
    // 再判断用户有没有输入找回邮箱
    if(self.recoverEmailTextfield.text.length == 0){
        [self showCustomMessage:@"请输入找回邮箱".localized hideAfterDelay:2.f];
        return;
    }
    LocalWallet *selectedWallet = [[PWDataBaseManager shared] queryWalletIsSelected];
    WEAKSELF
    PWAlertController *alertVC = [[PWAlertController alloc] initWithTitle:@"请输入钱包密码".localized withTextValue:@"" leftButtonName:nil rightButtonName:@"确定".localized handler:^(ButtonType type, NSString *text) {
        if (type == ButtonTypeLeft) { }
        if (type == ButtonTypeRight) {
            if ([GoFunction checkPassword:text hash:selectedWallet.wallet_password]) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [weakSelf createRecoverWallet:text withLocalWallet:selectedWallet];
                });
                
            } else {
                [self showCustomMessage:@"密码错误".localized hideAfterDelay:2];
            }
        }
    }];
    alertVC.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    [self presentViewController:alertVC animated:false completion:nil];

}

- (void)createRecoverWallet:(NSString *)passwd withLocalWallet:(LocalWallet *)wallet
{
    [self showKeywindowProgressWithMessage:@""];
    NSError *error;
    
    NSString *remembercode = [GoFunction deckey:wallet.wallet_remembercode password:passwd];//助记词
   
    WalletapiHDWallet *hdWallet;
    switch (self.recoverCoinType) {
        case RecoverCoinTypeBTY:
        {
            hdWallet = [GoFunction goCreateHDWallet:@"BTY" rememberCode:remembercode];
        }
            break;
        case RecoverCoinTypeYCC:
        {
            hdWallet = [GoFunction goCreateHDWallet:@"ETH" rememberCode:remembercode];
        }
            break;
        default:
            break;
    }
    NSString *priKey = [[hdWallet newKeyPriv:0 error:&error] hexString]; // 控制地址私钥
    NSString *pubKey = [[hdWallet newKeyPub:0 error:&error] hexString]; // 控制地址公钥
    
    WalletapiWalletRecover *recover = [[WalletapiWalletRecover alloc] init];
    WalletapiWalletRecoverParam *param = [[WalletapiWalletRecoverParam alloc] init];
    param.ctrPubKey = pubKey; //控制地址公钥
    param.recoverPubKeys = self.backUpAddrTextfield.text; // 备份地址的公钥
    param.thirdPartyPubKey = self.thridpartBackUpAddrDetailLab.text; // mydao官方备份公钥
    param.addressID = self.recoverCoinType == RecoverCoinTypeBTY ? 0 : 2;
    param.chainID = self.recoverCoinType == RecoverCoinTypeBTY ? 0 : 999;
    // 找回时间设置
    switch (self.recoverTimeType) {
        case RecoverTimeType7:
        {
            param.relativeDelayTime = 7; // 7天找回
        }
            break;
        case RecoverTimeType30:
        {
            param.relativeDelayTime = 30; // 30天找回
        }
            break;
        case RecoverTimeType90:
        {
            param.relativeDelayTime = 90; // 90天找回
        }
            break;
        default:
            break;
    }
    
    recover.param = param;
    NSString *recoverAddr = [recover getWalletRecoverAddr:&error];
    NSLog(@"recoverAddr------>%@",recoverAddr);
    
    // 将找回数据上传给后端服务器
    WalletapiContact *contactInfo = [[WalletapiContact alloc] init];
    contactInfo.email = self.recoverEmailTextfield.text;
    // 使用用户的私钥对联系方式进行签名
    WalletapiWalletRecover *signRevover = [[WalletapiWalletRecover alloc] init];
    NSString *contactSign = [signRevover signContact:priKey contact:contactInfo error:&error];
    if(error!= nil){
        [self hideProgressWithkeyWindow];
        [self showCustomMessage:error.localizedDescription hideAfterDelay:2.f];
        return;
    }
    NSLog(@"对用户联系方式签名的结果------>%@",contactSign);
    // 计算签名结果的hash
    NSString *contactSignHash = [signRevover calculateHash:WalletapiHexTobyte(contactSign)];
    NSLog(@"联系方式签名结果的hash------>%@",contactSignHash);
    // 用第三方的公钥对用户的联系方式和联系方式的签名信息进行加密
    WalletapiEncryptContactResult *encryptContact = [signRevover encryptContact:self.thridpartBackUpAddrDetailLab.text
                                                                        contact:contactInfo
                                                               contactSignature:contactSign
                                                                          error:&error];
    if(error!= nil){
        [self hideProgressWithkeyWindow];
        [self showCustomMessage:error.localizedDescription hideAfterDelay:2.f];
        return;
    }
    NSLog(@"未加密的内容------>%@\n加密后的结果------>%@",encryptContact.originData,encryptContact.encryptedData);
    WalletapiRecoverMemo *meno = [[WalletapiRecoverMemo alloc] init];
    meno.contactSigHash = contactSignHash;
    meno.encryptedContact = encryptContact.encryptedData;
    param.memo = meno;
    
    signRevover.param = param;
    // 对需要上链的信息进行序列化并进行十六机制编码，作为上链交易的备注
    NSString *paramNote = [signRevover encodeRecoverParam:param error:&error];
    if(error!= nil){
        [self hideProgressWithkeyWindow];
        [self showCustomMessage:error.localizedDescription hideAfterDelay:2.f];
        return;
    }
    NSLog(@"上链交易的备注------>%@",paramNote);
    WalletapiWalletTx *txparam = [[WalletapiWalletTx alloc] init];
    txparam.cointype = self.recoverCoinType == RecoverCoinTypeBTY ? @"BTY" : @"YCC";
    txparam.tokenSymbol = @"";
    WalletapiTxdata *txdata = [[WalletapiTxdata alloc] init];
    txdata.from = self.controlAddrLab.text;
    txdata.amount = 0.1;
    txdata.fee = 0.003;
    txdata.note = paramNote;
    txdata.to = recoverAddr; // 找回地址
    txparam.tx = txdata;
    WalletapiUtil *util = [[WalletapiUtil alloc] init];
    util.node = GoNodeUrl;
    txparam.util = util;
    
    NSData *txResult = WalletapiCreateRawTransaction(txparam, &error);
    if(error!= nil){
        [self hideProgressWithkeyWindow];
        [self showCustomMessage:error.localizedDescription hideAfterDelay:2.f];
        return;
    }
    NSDictionary *txResultDict = [NSJSONSerialization JSONObjectWithData:txResult options:NSJSONReadingAllowFragments error:&error];
    NSDictionary *result = txResultDict[@"result"];
    NSData *resultData = [result yy_modelToJSONData];
    WalletapiSignData *dataToSign = [[WalletapiSignData alloc] init];
    dataToSign.cointype = self.recoverCoinType == RecoverCoinTypeBTY ? @"BTY" : @"YCC";
    dataToSign.data = resultData;
    dataToSign.privKey = priKey;
    dataToSign.addressID = self.recoverCoinType == RecoverCoinTypeBTY ? 0 : 2;
    
    NSString *signedTx = WalletapiSignRawTransaction(dataToSign, &error);
    if(error != nil){
        [self hideProgressWithkeyWindow];
        [self showCustomMessage:error.localizedDescription hideAfterDelay:2.f];
        return;
    }
    NSLog(@"signedTx------->%@",signedTx);
    
    WalletapiSubmitRecoverParam *submitRecoverParam = [[WalletapiSubmitRecoverParam alloc] init];
    submitRecoverParam.cointype = self.recoverCoinType == RecoverCoinTypeBTY ? @"BTY" : @"YCC";
    submitRecoverParam.tokensymbol = @"";
    submitRecoverParam.address = recoverAddr;
    submitRecoverParam.signedTx = signedTx;
    submitRecoverParam.contact = contactInfo;
    submitRecoverParam.contactSig = contactSign;
    submitRecoverParam.encodeRecoverInfo = paramNote;
    NSString *submitResult = [signRevover transportSubmitTxWithRecoverInfo:submitRecoverParam util:util error:&error];
    if(error != nil){
        [self hideProgressWithkeyWindow];
        [self showCustomMessage:error.localizedDescription hideAfterDelay:2.f];
        return;
    }
    [self hideProgressWithkeyWindow];
    [self.view endEditing:YES];
    NSLog(@"submitResult------->%@",submitResult);
    PWNewInfoAlertView *view = [[PWNewInfoAlertView alloc]initWithTitle:@"您的找回地址".localized message:recoverAddr buttonName:@"复制".localized];
    view.coinName = self.recoverCoinType == RecoverCoinTypeBTY ? @"BTY" : @"YCC";;
    view.wallet_name = wallet.wallet_name;
    view.message = recoverAddr;
    view.okBlock = ^(id obj) {
        UIPasteboard *pboard = [UIPasteboard generalPasteboard];
        pboard.string = recoverAddr == nil ? @"" : recoverAddr;
        [self showCustomMessage:@"找回地址复制成功".localized hideAfterDelay:1];
    };
    [[UIApplication sharedApplication].keyWindow addSubview:view];

}

#pragma mark - getter and setter

- (UIView *)contentView
{
    if (!_contentView)
    {
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = [UIColor whiteColor];
    }
    return _contentView;
}

- (UILabel *)controlAddrLab
{
    if (!_controlAddrLab)
    {
        _controlAddrLab = [UILabel getLabWithFont:[UIFont fontWithName:@"PingFangSC-Medium" size:14.f]
                                        textColor:SGColorFromRGB(0x7190ff)
                                    textAlignment:NSTextAlignmentLeft
                                             text:@"控制地址:".localized];
    }
    return _controlAddrLab;
}

- (UILabel *)controlAddrDetailLab
{
    if (!_controlAddrDetailLab)
    {
        _controlAddrDetailLab = [UILabel getLabWithFont:[UIFont systemFontOfSize:14.f]
                                        textColor:SGColorFromRGB(0x333649)
                                    textAlignment:NSTextAlignmentLeft
                                             text:@""];
        _controlAddrDetailLab.lineBreakMode = NSLineBreakByTruncatingMiddle;
    }
    return _controlAddrDetailLab;
}

- (UIButton *)controlQrcodebtn
{
    if (!_controlQrcodebtn)
    {
        _controlQrcodebtn = [[UIButton alloc] init];
        [_controlQrcodebtn setTitle:@"二维码".localized forState:UIControlStateNormal];
        [_controlQrcodebtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
        _controlQrcodebtn.layer.cornerRadius = 5.f;
        _controlQrcodebtn.backgroundColor = SGColorFromRGB(0x333649);
        [_controlQrcodebtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        [_controlQrcodebtn addTarget:self action:@selector(getQRImage:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _controlQrcodebtn;
}

- (UIButton *)btyBtn
{
    if (!_btyBtn)
    {
        _btyBtn = [[UIButton alloc] init];
        _btyBtn.tag = 101;
        [_btyBtn setImage:[UIImage imageNamed:@"selected_icon"] forState:UIControlStateNormal];
        [_btyBtn addTarget:self action:@selector(selectCoin:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _btyBtn;
}

- (UILabel *)btyLab
{
    if (!_btyLab)
    {
        _btyLab = [UILabel getLabWithFont:[UIFont systemFontOfSize:14.f]
                                        textColor:SGColorFromRGB(0x333649)
                                    textAlignment:NSTextAlignmentLeft
                                             text:@"BTY"];
        _btyLab.tag = 101;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapCoin:)];
        tap.numberOfTapsRequired = 1;
        _btyLab.userInteractionEnabled = YES;
        [_btyLab addGestureRecognizer:tap];
    }
    return _btyLab;
}

- (UIButton *)yccBtn
{
    if (!_yccBtn)
    {
        _yccBtn = [[UIButton alloc] init];
        _yccBtn.tag = 102;
        [_yccBtn setImage:[UIImage imageNamed:@"unselected_icon"] forState:UIControlStateNormal];
        [_yccBtn addTarget:self action:@selector(selectCoin:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _yccBtn;
}

- (UILabel *)yccLab
{
    if (!_yccLab)
    {
        _yccLab = [UILabel getLabWithFont:[UIFont systemFontOfSize:14.f]
                                        textColor:SGColorFromRGB(0x333649)
                                    textAlignment:NSTextAlignmentLeft
                                             text:@"YCC"];
        _yccLab.tag = 102;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapCoin:)];
        tap.numberOfTapsRequired = 1;
        _yccLab.userInteractionEnabled = YES;
        [_yccLab addGestureRecognizer:tap];
    }
    return _yccLab;
}


- (UILabel *)balanceLab
{
    if (!_balanceLab)
    {
        _balanceLab = [UILabel getLabWithFont:[UIFont fontWithName:@"PingFangSC-Medium" size:14.f]
                                        textColor:SGColorFromRGB(0x7190ff)
                                    textAlignment:NSTextAlignmentLeft
                                             text:@"余额:".localized];
    }
    return _balanceLab;
}

- (UILabel *)balanceDetailLab
{
    if (!_balanceDetailLab)
    {
        _balanceDetailLab = [UILabel getLabWithFont:[UIFont systemFontOfSize:14.f]
                                        textColor:SGColorFromRGB(0x333649)
                                    textAlignment:NSTextAlignmentLeft
                                             text:@"10000BTY"];
    }
    return _balanceDetailLab;
}

- (UIButton *)refreshBalanceBtn
{
    if (!_refreshBalanceBtn)
    {
        _refreshBalanceBtn = [[UIButton alloc] init];
        [_refreshBalanceBtn setImage:[UIImage imageNamed:@"refresh"] forState:UIControlStateNormal];
        
        [_refreshBalanceBtn addTarget:self action:@selector(refreshBalance:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _refreshBalanceBtn;
}

- (UILabel *)backUpAddrLab
{
    if (!_backUpAddrLab)
    {
        _backUpAddrLab = [UILabel getLabWithFont:[UIFont fontWithName:@"PingFangSC-Medium" size:14.f]
                                        textColor:SGColorFromRGB(0x7190ff)
                                    textAlignment:NSTextAlignmentLeft
                                             text:@"用户备份公钥".localized];
    }
    return _backUpAddrLab;
}

- (UITextField *)backUpAddrTextfield
{
    if (!_backUpAddrTextfield)
    {
        _backUpAddrTextfield = [[UITextField alloc] init];
        _backUpAddrTextfield.backgroundColor = SGColorFromRGB(0xF8F8FA);
        _backUpAddrTextfield.layer.cornerRadius = 5.f;
        _backUpAddrTextfield.textColor = SGColorFromRGB(0x333649);
        NSMutableDictionary *attritubes = [[NSMutableDictionary alloc] init];
        attritubes[NSForegroundColorAttributeName] = SGColorFromRGB(0x8e92a3);
        attritubes[NSFontAttributeName] = [UIFont systemFontOfSize:14];
        _backUpAddrTextfield.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入备份地址对应的公钥".localized attributes:attritubes];
        UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 57, 50)];
        _backUpAddrTextfield.rightView = rightView;
        _backUpAddrTextfield.rightViewMode = UITextFieldViewModeAlways;
        UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 50)];
        _backUpAddrTextfield.leftView = leftView;
        _backUpAddrTextfield.leftViewMode = UITextFieldViewModeAlways;
        
    }
    
    return _backUpAddrTextfield;
}

- (UIButton *)scanBtb
{
    if (!_scanBtb)
    {
        _scanBtb = [[UIButton alloc] init];
        [_scanBtb setImage:[UIImage imageNamed:@"scan"] forState:UIControlStateNormal];
        [_scanBtb addTarget:self action:@selector(scanAddr:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _scanBtb;
}

- (UILabel *)thridpartBackUpAddrLab
{
    if (!_thridpartBackUpAddrLab)
    {
        _thridpartBackUpAddrLab = [UILabel getLabWithFont:[UIFont fontWithName:@"PingFangSC-Medium" size:14.f]
                                        textColor:SGColorFromRGB(0x7190ff)
                                    textAlignment:NSTextAlignmentLeft
                                             text:@"mydao官方备份公钥".localized];
    }
    return _thridpartBackUpAddrLab;
}

- (UILabel *)thridpartBackUpAddrDetailLab
{
    if (!_thridpartBackUpAddrDetailLab)
    {
        _thridpartBackUpAddrDetailLab = [UILabel getLabWithFont:[UIFont systemFontOfSize:14.f]
                                        textColor:SGColorFromRGB(0x333649)
                                    textAlignment:NSTextAlignmentLeft
                                             text:MyDaoPrikey];
        _thridpartBackUpAddrDetailLab.lineBreakMode = NSLineBreakByTruncatingMiddle;
    }
    return _thridpartBackUpAddrDetailLab;
}

- (UITextField *)recoverEmailTextfield
{
    if (!_recoverEmailTextfield)
    {
        _recoverEmailTextfield = [[UITextField alloc] init];
        _recoverEmailTextfield.backgroundColor = SGColorFromRGB(0xF8F8FA);
        _recoverEmailTextfield.layer.cornerRadius = 5.f;
        _recoverEmailTextfield.textColor = SGColorFromRGB(0x333649);
        NSMutableDictionary *attritubes = [[NSMutableDictionary alloc] init];
        attritubes[NSForegroundColorAttributeName] = SGColorFromRGB(0x8e92a3);
        attritubes[NSFontAttributeName] = [UIFont systemFontOfSize:14];
        _recoverEmailTextfield.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入找回邮箱".localized attributes:attritubes];
        UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 50)];
        _recoverEmailTextfield.keyboardType = UIKeyboardTypeEmailAddress;
        _recoverEmailTextfield.leftView = leftView;
        _recoverEmailTextfield.leftViewMode = UITextFieldViewModeAlways;
    }
    
    return _recoverEmailTextfield;
}

//- (UITextField *)codeTextfield
//{
//    if (!_codeTextfield)
//    {
//        _codeTextfield = [[UITextField alloc] init];
//        _codeTextfield.backgroundColor = SGColorFromRGB(0xF8F8FA);
//        _codeTextfield.layer.cornerRadius = 5.f;
//        _codeTextfield.textColor = SGColorFromRGB(0x333649);
//
//        NSMutableDictionary *attritubes = [[NSMutableDictionary alloc] init];
//        attritubes[NSForegroundColorAttributeName] = SGColorFromRGB(0x8e92a3);
//        attritubes[NSFontAttributeName] = [UIFont systemFontOfSize:14];
//        _codeTextfield.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"验证码" attributes:attritubes];
//        UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 50)];
//        _codeTextfield.keyboardType = UIKeyboardTypeNumberPad;
//        _codeTextfield.leftView = leftView;
//        _codeTextfield.leftViewMode = UITextFieldViewModeAlways;
//    }
//
//    return _codeTextfield;
//}
//
//- (UIButton *)getCodeBtn
//{
//    if (!_getCodeBtn)
//    {
//        _getCodeBtn = [[UIButton alloc] init];
//        [_getCodeBtn setTitle:@"发送验证码" forState:UIControlStateNormal];
//        _getCodeBtn.layer.cornerRadius = 5.f;
//        [_getCodeBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
//        _getCodeBtn.backgroundColor = SGColorFromRGB(0x7190ff);
//        [_getCodeBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
//        [_getCodeBtn addTarget:self action:@selector(getCode:) forControlEvents:UIControlEventTouchUpInside];
//    }
//
//    return _getCodeBtn;
//}

- (UIView *)recoverTimeSetView
{
    if (!_recoverTimeSetView)
    {
        _recoverTimeSetView = [[UIView alloc] init];
        _recoverTimeSetView.backgroundColor = UIColor.whiteColor;
    }
    
    return _recoverTimeSetView;
}

- (UILabel *)recoverTimeSetLab
{
    if (!_recoverTimeSetLab)
    {
        _recoverTimeSetLab = [UILabel getLabWithFont:[UIFont fontWithName:@"PingFangSC-Medium" size:14.f]
                                        textColor:SGColorFromRGB(0x333649)
                                    textAlignment:NSTextAlignmentLeft
                                             text:@"找回时间设置".localized];
    }
    return _recoverTimeSetLab;
}

- (UIButton *)recoverSet7btn
{
    if (!_recoverSet7btn)
    {
        _recoverSet7btn = [[UIButton alloc] init];
        _recoverSet7btn.tag = 7;
        [_recoverSet7btn setImage:[UIImage imageNamed:@"selected_icon"] forState:UIControlStateNormal];
        [_recoverSet7btn addTarget:self action:@selector(selectTime:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _recoverSet7btn;
}

- (UILabel *)recoverSet7Lab
{
    if (!_recoverSet7Lab)
    {
        _recoverSet7Lab = [UILabel getLabWithFont:[UIFont systemFontOfSize:14.f]
                                        textColor:SGColorFromRGB(0x333649)
                                    textAlignment:NSTextAlignmentLeft
                                             text:@"7天".localized];
        _recoverSet7Lab.tag = 7;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapTime:)];
        tap.numberOfTapsRequired = 1;
        _recoverSet7Lab.userInteractionEnabled = YES;
        [_recoverSet7Lab addGestureRecognizer:tap];
    }
    return _recoverSet7Lab;
}

- (UIButton *)recoverSet30btn
{
    if (!_recoverSet30btn)
    {
        _recoverSet30btn = [[UIButton alloc] init];
        _recoverSet30btn.tag = 30;
        [_recoverSet30btn setImage:[UIImage imageNamed:@"unselected_icon"] forState:UIControlStateNormal];
        [_recoverSet30btn addTarget:self action:@selector(selectTime:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _recoverSet30btn;
}

- (UILabel *)recoverSet30Lab
{
    if (!_recoverSet30Lab)
    {
        _recoverSet30Lab = [UILabel getLabWithFont:[UIFont systemFontOfSize:14.f]
                                        textColor:SGColorFromRGB(0x333649)
                                    textAlignment:NSTextAlignmentLeft
                                             text:@"30天".localized];
        _recoverSet30Lab.tag = 30;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapTime:)];
        tap.numberOfTapsRequired = 1;
        _recoverSet30Lab.userInteractionEnabled = YES;
        [_recoverSet30Lab addGestureRecognizer:tap];
    }
    return _recoverSet30Lab;
}

- (UIButton *)recoverSet60btn
{
    if (!_recoverSet60btn)
    {
        _recoverSet60btn = [[UIButton alloc] init];
        _recoverSet60btn.tag = 60;
        [_recoverSet60btn setImage:[UIImage imageNamed:@"unselected_icon"] forState:UIControlStateNormal];
        [_recoverSet60btn addTarget:self action:@selector(selectTime:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _recoverSet60btn;
}

- (UILabel *)recoverSet60Lab
{
    if (!_recoverSet60Lab)
    {
        _recoverSet60Lab = [UILabel getLabWithFont:[UIFont systemFontOfSize:14.f]
                                        textColor:SGColorFromRGB(0x333649)
                                    textAlignment:NSTextAlignmentLeft
                                             text:@"90天".localized];
        _recoverSet60Lab.tag = 60;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapTime:)];
        tap.numberOfTapsRequired = 1;
        _recoverSet60Lab.userInteractionEnabled = YES;
        [_recoverSet60Lab addGestureRecognizer:tap];
    }
    return _recoverSet60Lab;
}


- (UIButton *)createWalletBtn
{
    if (!_createWalletBtn)
    {
        _createWalletBtn = [[UIButton alloc] init];
        [_createWalletBtn setTitle:@"创建钱包".localized forState:UIControlStateNormal];
        _createWalletBtn.layer.cornerRadius = 5.f;
        [_createWalletBtn.titleLabel setFont:[UIFont systemFontOfSize:17]];
        _createWalletBtn.backgroundColor = SGColorFromRGB(0x7190ff);
        [_createWalletBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        [_createWalletBtn addTarget:self action:@selector(createWallet:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _createWalletBtn;
}

- (UILabel *)recoverTipLab
{
    if (!_recoverTipLab)
    {
        _recoverTipLab = [UILabel getLabWithFont:[UIFont systemFontOfSize:14.f]
                                        textColor:SGColorFromRGB(0x5E606F)
                                    textAlignment:NSTextAlignmentLeft
                                             text:@"找回钱包使用说明：\n说明文字说明文字说明文字说明文字说明文字说明文字说明文字说明文字说明文字说明文字说明文字说明文字说明文字说明文字说明文字说明文字说明文字说明文字说明文字说明文字说明文字说明文字说明文字说明文字说明文字说明文字说明文字说明文字说明文字说明文字说明文字说明文字说明文字说明文字说明文字说明文字说明文字说明文字说明文字说明文字说明文字说明文字说明文字说明文字说明文字说明文字说明文字说明文字"];
        _recoverTipLab.numberOfLines = 0;
    
    }
    return _recoverTipLab;
}

- (UITableView *)tableView
{
    if (!_tableView)
    {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.backgroundColor = SGColorFromRGB(0xF8F8FA);
    }
    return _tableView;
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
