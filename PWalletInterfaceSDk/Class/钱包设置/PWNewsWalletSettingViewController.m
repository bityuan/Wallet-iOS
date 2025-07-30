//
//  PWNewsWalletSettingViewController.m
//  PWallet
//
//  Created by 郑晨 on 2019/11/11.
//  Copyright © 2019 陈健. All rights reserved.
//

#import "PWNewsWalletSettingViewController.h"
#import "PWMyWalletSetCell.h"
#import "PWDataBaseManager.h"
#import "PWAlertController.h"
#import "AppDelegate.h"
#import "ChangePwdViewController.h"
#import "PWRememberCodeAlertView.h"
#import "BackUpChineseViewController.h"
#import "PWPickerViewController.h"
#import "PWNewInfoAlertView.h"
#import "PWActionSheetView.h"
#import "PWNewsHomeNoWalletViewController.h"
#import "PWWalletForgetPwdViewController.h"
#import "CreateRecoverWalletViewController.h"

@interface PWNewsWalletSettingViewController ()
<UITableViewDelegate, UITableViewDataSource,PWMyWalletSetCellDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray <NSArray *>*dataArray;

@property (nonatomic, strong) NSMutableDictionary *walletInfoMDict;
@end


static NSString *const setWalletCell = @"PWMyWalletSetCell";

@implementation PWNewsWalletSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    UIStatusBarManager *statusBarManager = self.view.window.windowScene.statusBarManager;
    if (@available(iOS 13.0, *))
    {
        
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDarkContent;
    }
    else
    {
            // Fallback on earlier versions
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    }
    self.localWallet = [[PWDataBaseManager shared] queryWallet:self.localWallet.wallet_id];
    [self initValues];
    [self.tableView reloadData];
}

- (void)initValues {
    
    _walletInfoMDict = [[PWAppsettings instance] getWalletInfo];
    if (_walletInfoMDict == nil)
    {
        _walletInfoMDict = [[NSMutableDictionary alloc] init];
    }
    
    NSString *nameStr = @"指纹支付".localized;
    if (isIPhoneXSeries) {
        nameStr = @"面容支付".localized;
    }
    
    self.dataArray = @[@[@"修改密码".localized,@"忘记密码".localized,@"修改钱包名称".localized,nameStr],@[@"导出助记词".localized,@"导出私钥".localized,@"导出公钥".localized,@"绑定找回钱包".localized]];
    if(self.localWallet.wallet_issmall == 2 || self.localWallet.wallet_issmall == 4){
        self.dataArray = @[@[@"修改密码".localized,@"忘记密码".localized,@"修改钱包名称".localized],@[@"导出私钥".localized]];
    }else if (self.localWallet.wallet_issmall == 3){
        // 观察钱包
        self.dataArray = @[@[@"修改钱包名称".localized],@[]];
    }
    
}



- (void)createView {
    
    self.title = @"钱包设置".localized;
    self.view.backgroundColor = SGColorFromRGB(0xf8f8fa);
    
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: CMColorFromRGB(0x333649),NSFontAttributeName : [UIFont boldSystemFontOfSize:18]};
    
    [self.view addSubview:self.tableView];
    
    [self.tableView registerClass:[PWMyWalletSetCell class] forCellReuseIdentifier:setWalletCell];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.view);
        make.bottom.equalTo(self.view).with.offset(0);
    }];
    
}

#pragma mark - UITableView delegate  datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *array = self.dataArray[section];
    return array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PWMyWalletSetCell *cell = [self.tableView dequeueReusableCellWithIdentifier:setWalletCell forIndexPath:indexPath];
    NSArray *array = self.dataArray[indexPath.section];
    cell.titleName = array[indexPath.row];
    cell.switchBtn.hidden = YES;
    cell.nextImg.hidden = NO;
    cell.switchBtn.hidden = YES;
    cell.nextImg.hidden = NO;
    cell.blueToothLabel.hidden = YES;
    cell.delegate = self;
    NSString *nameStr = @"指纹支付".localized;
    if (isIPhoneXSeries) {
        nameStr = @"面容支付".localized;
    }
    if ([cell.titleName isEqualToString:nameStr])
    {
        cell.switchBtn.hidden = NO;
        cell.nextImg.hidden = YES;
        
        if (self.walletInfoMDict.count == 0)
        {
            [cell.switchBtn setImage:[UIImage imageNamed:@"pay_un"] forState:UIControlStateNormal];
        }
        else
        {
            NSString *walletId = [NSString stringWithFormat:@"%ld",_localWallet.wallet_id];
            NSString *passwd = [self.walletInfoMDict objectForKey:walletId];
            if (passwd != nil)
            {
                [cell.switchBtn setImage:[UIImage imageNamed:@"pay_on"] forState:UIControlStateNormal];
            }
            else
            {
                [cell.switchBtn setImage:[UIImage imageNamed:@"pay_un"] forState:UIControlStateNormal];
            }
        }
        
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
   return 60.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellText = self.dataArray[indexPath.section][indexPath.row];
    if ([cellText isEqualToString:@"修改密码".localized])
    {
        [self updatePwd];
    }
    else if ([cellText isEqualToString:@"忘记密码".localized])
    {
        [self forgetPwd];
    }
    else if ([cellText isEqualToString:@"修改钱包名称".localized])
    {
        [self updateWalletName];
    }
    else if ([cellText isEqualToString:@"导出助记词".localized])
    {
        [self exportRememberCode];
    }
    else if ([cellText isEqualToString:@"导出私钥".localized])
    {
        [self newsExportPrikey];
    }
    else if ([cellText isEqualToString:@"导出公钥".localized])
    {
        [self newsExportPublick];
    }
    else if ([cellText isEqualToString:@"绑定找回钱包".localized])
    {
        [self bindingRecoverWallet];
    }
}


- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 0)];
    
    UIButton *deleteBtn = [[UIButton alloc] init];
    [deleteBtn setTitle:@"删除钱包".localized forState:UIControlStateNormal];
    [deleteBtn setTitleColor:SGColorFromRGB(0xcc3939) forState:UIControlStateNormal];
    [deleteBtn.titleLabel setFont:[UIFont systemFontOfSize:16.f]];
    [deleteBtn.layer setCornerRadius:8.f];
    [deleteBtn.layer setBorderColor:SGColorFromRGB(0xcc3939).CGColor];
    [deleteBtn.layer setBorderWidth:1.f];
    
    [deleteBtn addTarget:self action:@selector(deleteWallet) forControlEvents:UIControlEventTouchUpInside];
    [footView addSubview:deleteBtn];
    
    [deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(footView);
        make.top.equalTo(footView).offset(31);
        make.height.mas_equalTo(44);
        make.width.mas_equalTo(140);
    }];
    if (section == 0) {
        return nil;
    }
    return footView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        return 10.f;
    }
    return 106;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return .1f;
}

#pragma mark - pwmywalletsetcelldelegate
- (void)switchPay:(UIButton *)sender
{
    // 先输入钱包密码
    WEAKSELF
    
    NSString *walletId = [NSString stringWithFormat:@"%ld", weakSelf.localWallet.wallet_id];
    NSString *passwd = [weakSelf.walletInfoMDict objectForKey:walletId];
    
    if (passwd == nil)
    {
        // 保存密码
        PWAlertController *alertVC = [[PWAlertController alloc] initWithTitle:@"请输入钱包密码".localized withTextValue:@""  leftButtonName:nil rightButtonName:@"确定".localized handler:^(ButtonType type, NSString *text) {
            if (type == ButtonTypeRight) {
                if ([GoFunction checkPassword:text hash:weakSelf.localWallet.wallet_password]) {
                    // 没有保存密码，z那么就保存密码。如果保存了密码，那么就删除密码
                    [self authPayWithPasswd:text walletID:walletId];
                    
                } else {
                    [self showCustomMessage:@"密码错误".localized hideAfterDelay:1];
                }
            }
            
        }];
        alertVC.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
        [self presentViewController:alertVC animated:false completion:nil];
    }
    else
    {
        // 询问是否要关闭
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil
                                                                         message:isIPhoneXSeries ? @"确定关闭面容支付?".localized : @"确定关闭指纹支付?".localized
                                                                  preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消".localized
                                                               style:UIAlertActionStyleCancel
                                                             handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        UIAlertAction *confimAction = [UIAlertAction actionWithTitle:@"确定".localized
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * _Nonnull action) {
            [self.walletInfoMDict removeObjectForKey:walletId];
            [[PWAppsettings instance] deleteWalletInfo];
            [[PWAppsettings instance] saveWalletInfo:weakSelf.walletInfoMDict];
            [weakSelf.tableView reloadData];
        }];
        
        [alertVC addAction:cancelAction];
        [alertVC addAction:confimAction];
        [self presentViewController:alertVC animated:YES completion:nil];
    }
}


#pragma mark -- 指纹or面容支付
- (void)authPayWithPasswd:(NSString *)passwd walletID:(NSString *)walletId
{
    YZAuthID *authId = [[YZAuthID alloc] init];
    
    [authId yz_showAuthIDWithDescribe:nil block:^(YZAuthIDState state, NSError *error) {
        switch (state) {
            case YZAuthIDStateNotSupport:
            {
                NSLog(@"当前设备不支持TouchId、FaceId");
                
            }
                break;
            case YZAuthIDStateSuccess:
            {
                NSLog(@"验证成功");
                NSString *text = [PWUtils encryptString:passwd];
                [self.walletInfoMDict setValue:text forKey:walletId];
                [self showCustomMessage:@"开通成功".localized hideAfterDelay:2.f];
                
                [[PWAppsettings instance] deleteWalletInfo];
                [[PWAppsettings instance] saveWalletInfo:self.walletInfoMDict];
                [self.tableView reloadData];
            }
                break;
            case YZAuthIDStateFail:
            {
                NSLog(@" 验证失败");
            }
                break;
            case YZAuthIDStateUserCancel:
            {
                NSLog(@"TouchID/FaceID 被用户手动取消");
            }
                break;
            case YZAuthIDStateInputPassword:
            {
                NSLog(@"用户不使用TouchID/FaceID,选择手动输入密码");
            }
                break;
            case YZAuthIDStateSystemCancel:
            {
                NSLog(@"TouchID/FaceID 被系统取消 (如遇到来电,锁屏,按了Home键等)");
            }
                break;
            case YZAuthIDStatePasswordNotSet:
            {
                NSLog(@" TouchID/FaceID 无法启动,因为用户没有设置密码");
            }
                break;
            case YZAuthIDStateTouchIDNotSet:
            {
                NSLog(@"TouchID/FaceID 无法启动,因为用户没有设置TouchID/FaceID");
            }
                break;
            case YZAuthIDStateTouchIDNotAvailable:
            {
                NSLog(@"TouchID/FaceID 无效");
            }
                break;
            case YZAuthIDStateTouchIDLockout:
            {
                NSLog(@"TouchID/FaceID 被锁定(连续多次验证TouchID/FaceID失败,系统需要用户手动输入密码)");
            }
                break;
            case YZAuthIDStateAppCancel:
            {
                NSLog(@"当前软件被挂起并取消了授权 (如App进入了后台等)");
            }
                break;
            case YZAuthIDStateInvalidContext:
            {
                NSLog(@" 当前软件被挂起并取消了授权 (LAContext对象无效)");
            }
                break;
            case YZAuthIDStateVersionNotSupport:
            {
                NSLog(@"系统版本不支持TouchID/FaceID (必须高于iOS 8.0才能使用)");
            }
                break;
                
            default:
                break;
        }
    }];
}


#pragma mark - 删除钱包
- (void)deleteWallet
{
    if (self.localWallet.wallet_issmall == 0 && self.localWallet.wallet_issetpwd == 0) {
        [self confirmAlert];
        return;
        
    }
       // 删除地址钱包
    if (self.localWallet.wallet_issmall == 3)
    {
        [self confirmAlert];
        return;
    }
        

    LocalWallet *selectedWallet = self.localWallet;
    PWAlertController *alertVC = [[PWAlertController alloc] initWithTitle:@"请输入钱包密码".localized withTextValue:@""  leftButtonName:nil rightButtonName:@"确定".localized handler:^(ButtonType type, NSString *text) {
        if (type == ButtonTypeLeft) { }
        if (type == ButtonTypeRight) {
            if ([GoFunction checkPassword:text hash:selectedWallet.wallet_password]) {
                [self confirmAlert];
            } else {
                [self showCustomMessage:@"密码错误".localized hideAfterDelay:1];
            }
        }
    }];
    alertVC.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    [self presentViewController:alertVC animated:false completion:nil];
}

- (void)confirmAlert{
    NSString *titleStr = @"安全警告".localized;
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:titleStr message:@"\n删除钱包仅能通过助记词和私钥找回，是否确定删除该钱包".localized preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"删除".localized style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self confirmDeleteWallet];
    }];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"取消".localized style:UIAlertActionStyleCancel handler:nil];
    
    NSMutableAttributedString *alertControllerStr = [[NSMutableAttributedString alloc] initWithString:titleStr];
    [alertControllerStr addAttribute:NSForegroundColorAttributeName value:SGColorRGBA(220, 40, 40, 1) range:NSMakeRange(0, titleStr.length)];
    [alertControllerStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:17] range:NSMakeRange(0, titleStr.length)];
    [alert setValue:alertControllerStr forKey:@"attributedTitle"];
    
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)confirmDeleteWallet
{
   [self showProgressWithMessage:@""];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        BOOL state = [[PWDataBaseManager shared] deleteWallet:self.localWallet];
        NSArray *coinArray = [[PWDataBaseManager shared] queryCoinArrayBasedOnWallet:self.localWallet];
        NSMutableArray *muArr = [[NSMutableArray alloc] init];
        for (LocalCoin *coin in coinArray) {
            if (coin.coin_type != nil && coin.coin_address != nil) {
                NSDictionary *dict = @{@"cointype":coin.coin_type,
                                       @"address":coin.coin_address
                };
                
                [muArr addObject:dict];
            }
           
        }
        [GoFunction muDelAddr:[NSArray arrayWithArray:muArr]];
        
        [[PWDataBaseManager shared] deleteCoin:self.localWallet];
        if(self.localWallet.wallet_isselected == 1) {
            NSArray *walletArray = [[PWDataBaseManager shared] queryAllWallets];
            if (walletArray.count > 0) {
                LocalWallet *wallet = [walletArray firstObject];
                wallet.wallet_isselected = 1;
                [[PWDataBaseManager shared] updateWallet:wallet];
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self hideProgress];
                    AppDelegate *appdelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
                    [appdelegate switchRootViewController];
                });
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideProgress];
            if (state) {
                [self showCustomMessage:@"删除成功".localized hideAfterDelay:2.0];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"kDeleteWalletNotification" object:nil userInfo:nil];
                [self.navigationController popViewControllerAnimated:YES];
            }
            else {
                [self showCustomMessage:@"删除失败".localized hideAfterDelay:2.0];
            }
        });
    });
}

#pragma mark - 修改密码
- (void)updatePwd
{
    ChangePwdViewController *vc = [[ChangePwdViewController alloc] init];
    vc.wallet = self.localWallet;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 忘记密码
- (void)forgetPwd
{
    PWWalletForgetPwdViewController *forgetVC = [[PWWalletForgetPwdViewController alloc] init];
    forgetVC.localWallet = self.localWallet;
    [self.navigationController pushViewController:forgetVC animated:YES];
}
#pragma mark - 修改钱包名称
- (void)updateWalletName
{
    PWAlertController *alertVC = [[PWAlertController alloc] initWithTitle:@"修改钱包名称".localized withTextValue:self.localWallet.wallet_name leftButtonName:nil rightButtonName:@"确定".localized handler:^(ButtonType type, NSString *text) {
        if (type == ButtonTypeLeft) { }
        if (type == ButtonTypeRight) {
            if (IS_BLANK(text) || [text isEqualToString:self.localWallet.wallet_name]) {
                return ;
            }
            self.localWallet.wallet_name = text;
            if ([[PWDataBaseManager shared] updateWallet:self.localWallet]) {
                [self showCustomMessage:@"修改成功".localized hideAfterDelay:1.f];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"kChangeWalletNameNotification" object:nil];
                    [self.navigationController popViewControllerAnimated:YES];
                });
               
            }
        }
    }];
    alertVC.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    [self presentViewController:alertVC animated:false completion:nil];
}
#pragma mark - 导出助记词
- (void)exportRememberCode
{
    LocalWallet *selectedWallet = self.localWallet;
    PWAlertController *alertVC = [[PWAlertController alloc] initWithTitle:@"请输入钱包密码".localized withTextValue:@"" leftButtonName:nil rightButtonName:@"确定".localized handler:^(ButtonType type, NSString *text) {
        if (type == ButtonTypeLeft) { }
        if (type == ButtonTypeRight) {
            if ([GoFunction checkPassword:text hash:selectedWallet.wallet_password]) {
                NSString *rememberCode = [GoFunction deckey:self.localWallet.wallet_remembercode password:text];
                [self createBackUpView:rememberCode withWallet:self.localWallet];
            } else {
                [self showCustomMessage:@"密码错误".localized hideAfterDelay:1];
            }
        }
    }];
    alertVC.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    [self presentViewController:alertVC animated:false completion:nil];
}

/**
 * 创建备份视图
 */
- (void)createBackUpView:(NSString *)codeStr withWallet:(LocalWallet *)wallet {
    WEAKSELF;
    NSInteger backupState = wallet.wallet_isbackup;
    NSString *titleStr = @"查看助记词".localized;
    NSString *rememberCode = [CommonFunction rehandleChineseCode:codeStr];
    NSString *buttonName = @"知道了".localized;
    if (backupState == 0) {
        titleStr = @"查看助记词".localized;
        buttonName = @"下一步".localized;
    }
    PWRememberCodeAlertView *aView = [[PWRememberCodeAlertView alloc] initWithTitle:titleStr rememberCode:rememberCode buttonName:buttonName];
    aView.wallet_name = wallet.wallet_name;
    aView.rememberCode = rememberCode;
    aView.okBlock = ^(id obj) {
        if (backupState == 0) {
            BackUpChineseViewController *vc = [[BackUpChineseViewController alloc] init];
            vc.parentFrom = ParentViewControllerFromKeyBackUpWallet;
            vc.chineseCode = codeStr;
            vc.wallet = self.localWallet;
            [self.navigationController pushViewController:vc animated:YES];
        }
    };
    aView.ClickPastAction = ^(NSString * _Nonnull rememberCode) {
        [weakSelf pastRememberCode:rememberCode];
    };
    [[PWUtils getKeyWindowWithView:self.view] addSubview:aView];
}

//复制助记词
- (void)pastRememberCode:(NSString *)rememberCode{
    UIPasteboard *pab = [UIPasteboard generalPasteboard];
    pab.string = rememberCode;
    [self showCustomMessage:@"已复制".localized hideAfterDelay:2.f];
}


#pragma mark - 导出私钥新版
- (void)newsExportPrikey
{
     NSArray *array = [[PWDataBaseManager shared]queryCoinArrayBasedOnWallet:self.localWallet];
    PWActionSheetView *actionSheetView = [[PWActionSheetView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)
                                                                       Title:@"请选择币种".localized
                                                                   dataArray:array
                                                                        type:ActionViewTypePrikey];
    WEAKSELF
    actionSheetView.actionSheetViewBlock = ^(LocalCoin * _Nonnull coin, CoinPrice * _Nonnull coinprice) {
        if (weakSelf.localWallet.wallet_issmall == 0 && weakSelf.localWallet.wallet_issetpwd == 0) {
            LocalWallet *localWallet = [[PWDataBaseManager shared] queryWallet:coin.coin_walletid];
            NSString *rememberCode = [GoFunction deckey:localWallet.wallet_remembercode password:@""];
            WalletapiHDWallet *hdWallet = [GoFunction goCreateHDWallet:coin.coin_type rememberCode:rememberCode];
            NSString *priKey = [[hdWallet newKeyPriv:0 error:nil] hexString];
            if(localWallet.wallet_issmall == 2 || localWallet.wallet_issmall == 4){
                // 私钥钱包和找回钱包存入的助记词就是当前钱包的私钥
                priKey = rememberCode;
            }
            PWNewInfoAlertView *view = [[PWNewInfoAlertView alloc]initWithTitle:@"导出私钥".localized message:priKey buttonName:@"复制".localized];
            view.coinName = coin.coin_type;
            view.wallet_name = localWallet.wallet_name;
            view.message = priKey;
            view.okBlock = ^(id obj) {
                UIPasteboard *pboard = [UIPasteboard generalPasteboard];
                pboard.string = priKey == nil ? @"" : priKey;
                [weakSelf showCustomMessage:@"私钥复制成功".localized hideAfterDelay:1];
            };
            [[PWUtils getKeyWindowWithView:self.view] addSubview:view];

        } else {
            PWAlertController *alertVC = [[PWAlertController alloc] initWithTitle:@"请输入钱包密码".localized withTextValue:@""  leftButtonName:nil rightButtonName:@"确定".localized handler:^(ButtonType type, NSString *text) {
                if (type == ButtonTypeLeft) { }
                if (type == ButtonTypeRight) {
                    if ([GoFunction checkPassword:text hash:weakSelf.localWallet.wallet_password]) {
                        LocalWallet *localWallet = [[PWDataBaseManager shared] queryWallet:coin.coin_walletid];
                        NSString *rememberCode = [GoFunction deckey:localWallet.wallet_remembercode password:text];
                        WalletapiHDWallet *hdWallet = [GoFunction goCreateHDWallet:coin.coin_chain rememberCode:rememberCode];
                        NSString *priKey = [[hdWallet newKeyPriv:0 error:nil] hexString];
                        if(localWallet.wallet_issmall == 2 || localWallet.wallet_issmall == 4){
                            // 私钥钱包和找回钱包存入的助记词就是当前钱包的私钥
                            priKey = rememberCode;
                        }
                        PWNewInfoAlertView *view = [[PWNewInfoAlertView alloc]initWithTitle:@"导出私钥".localized message:priKey buttonName:@"复制".localized];
                        view.coinName = coin.coin_type;
                        view.wallet_name = localWallet.wallet_name;
                        view.message = priKey;
                        view.okBlock = ^(id obj) {
                            UIPasteboard *pboard = [UIPasteboard generalPasteboard];
                            pboard.string = priKey == nil ? @"" : priKey;
                            [weakSelf showCustomMessage:@"私钥复制成功".localized hideAfterDelay:1];
                        };
                        [[PWUtils getKeyWindowWithView:self.view] addSubview:view];
                    } else {
                        [weakSelf showCustomMessage:@"密码错误".localized hideAfterDelay:1];
                    }
                }
            }];
            alertVC.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
            [weakSelf presentViewController:alertVC animated:false completion:nil];
        }
    };
    [actionSheetView show];
}

#pragma mark - 导出公钥
- (void)newsExportPublick
{
    NSArray *array = [[PWDataBaseManager shared]queryCoinArrayBasedOnWallet:self.localWallet];
   PWActionSheetView *actionSheetView = [[PWActionSheetView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)
                                                                      Title:@"请选择币种".localized
                                                                  dataArray:array
                                                                       type:ActionViewTypePrikey];
   WEAKSELF
   actionSheetView.actionSheetViewBlock = ^(LocalCoin * _Nonnull coin, CoinPrice * _Nonnull coinprice) {
       if (weakSelf.localWallet.wallet_issmall == 0 && weakSelf.localWallet.wallet_issetpwd == 0) {
           LocalWallet *localWallet = [[PWDataBaseManager shared] queryWallet:coin.coin_walletid];
           NSString *rememberCode = [GoFunction deckey:localWallet.wallet_remembercode password:@""];
           WalletapiHDWallet *hdWallet = [GoFunction goCreateHDWallet:coin.coin_type rememberCode:rememberCode];
           NSString *publick = [[hdWallet newKeyPub:0 error:nil] hexString];
//           NSString *priKey = [[hdWallet newKeyPriv:0 error:nil] hexString];
           PWNewInfoAlertView *view = [[PWNewInfoAlertView alloc]initWithTitle:@"导出公钥".localized message:publick buttonName:@"复制".localized];
           view.coinName = coin.coin_type;
           view.wallet_name = localWallet.wallet_name;
           view.message = publick;
           view.okBlock = ^(id obj) {
               UIPasteboard *pboard = [UIPasteboard generalPasteboard];
               pboard.string = publick == nil ? @"" : publick;
               [weakSelf showCustomMessage:@"公钥复制成功".localized hideAfterDelay:1];
           };
           [[PWUtils getKeyWindowWithView:self.view] addSubview:view];

       } else {
           PWAlertController *alertVC = [[PWAlertController alloc] initWithTitle:@"请输入钱包密码".localized withTextValue:@""  leftButtonName:nil rightButtonName:@"确定".localized handler:^(ButtonType type, NSString *text) {
               if (type == ButtonTypeLeft) { }
               if (type == ButtonTypeRight) {
                   if ([GoFunction checkPassword:text hash:weakSelf.localWallet.wallet_password]) {
                       LocalWallet *localWallet = [[PWDataBaseManager shared] queryWallet:coin.coin_walletid];
                       NSString *rememberCode = [GoFunction deckey:localWallet.wallet_remembercode password:text];
                       WalletapiHDWallet *hdWallet = [GoFunction goCreateHDWallet:coin.coin_chain rememberCode:rememberCode];
                       
//                       NSString *priKey = [[hdWallet newKeyPriv:0 error:nil] hexString];
                       NSString *publick = [[hdWallet newKeyPub:0 error:nil] hexString];
                       PWNewInfoAlertView *view = [[PWNewInfoAlertView alloc]initWithTitle:@"导出公钥".localized message:publick buttonName:@"复制".localized];
                       view.coinName = coin.coin_type;
                       view.wallet_name = localWallet.wallet_name;
                       view.message = publick;
                       view.okBlock = ^(id obj) {
                           UIPasteboard *pboard = [UIPasteboard generalPasteboard];
                           pboard.string = publick == nil ? @"" : publick;
                           [weakSelf showCustomMessage:@"公钥复制成功".localized hideAfterDelay:1];
                       };
                       [[PWUtils getKeyWindowWithView:self.view] addSubview:view];
                   } else {
                       [weakSelf showCustomMessage:@"密码错误".localized hideAfterDelay:1];
                   }
               }
           }];
           alertVC.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
           [weakSelf presentViewController:alertVC animated:false completion:nil];
       }
   };
   [actionSheetView show];
}

#pragma mark - 绑定找回钱包
- (void)bindingRecoverWallet
{
    CreateRecoverWalletViewController *vc = [[CreateRecoverWalletViewController alloc] init];
    
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - setter & getter

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
    }
    return _tableView;
}




@end
