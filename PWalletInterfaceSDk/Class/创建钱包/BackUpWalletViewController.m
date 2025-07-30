//
//  BackUpWalletViewController.m
//  PWallet
//
//  Created by 宋刚 on 2018/5/24.
//  Copyright © 2018年 陈健. All rights reserved.
//

#import "BackUpWalletViewController.h"
#import "PWSuggestionsCoinTool.h"
#import "PWNewsHomeViewController.h"
#import "PreCoin.h"

@interface BackUpWalletViewController ()

@property (nonatomic,strong) UILabel *titleTipLab;
@property (nonatomic,strong) EnglishCodeBackUpView *backupView;
@property (nonatomic, strong) UIView *bottomBgView;
@property (nonatomic, strong) UILabel *bottomTipLab;
@property (nonatomic,strong) EnglishCodeChooseView *itemChooseview;
@property (nonatomic, strong) UIButton *okBtn;
@end

@implementation BackUpWalletViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.showMaskLine = false;
    
}

#pragma mark - 重写父类方法
- (UIBarButtonItem *)rt_customBackItemWithTarget:(id)target
                                          action:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"返回箭头"] forState:UIControlStateNormal];
    
    if (@available(iOS 11.0, *)) {
        
    }else{
        button.imageEdgeInsets = UIEdgeInsetsMake(0,10, 0, -10);
    }
    
    //添加空格字符串 增加点击面积
    [button setTitle:@"    " forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:44];
    [button sizeToFit];
    [button addTarget:self
               action:@selector(backAction)
     forControlEvents:UIControlEventTouchUpInside];
    
    return [[UIBarButtonItem alloc] initWithCustomView:button];
}

//设置字体颜色
- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    [self createView];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (@available(iOS 13.0, *)) {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDarkContent;
    } else {
           // Fallback on earlier versions
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    }
   
}

- (void)createView {

    UIColor *backColor = CMColorFromRGB(0x333649);
    UIColor *lineColor = CMColorFromRGB(0x5D6377);
    self.view.backgroundColor = backColor;
    if (@available(iOS 15, *))
    {
        UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
        appearance.backgroundColor = backColor;
        appearance.backgroundEffect = nil;
        appearance.shadowColor = UIColor.clearColor;
        self.navigationController.navigationBar.standardAppearance = appearance;
        self.navigationController.navigationBar.scrollEdgeAppearance = appearance;
    }else{
        self.navigationController.navigationBar.barTintColor = backColor;
        self.navigationController.navigationBar.backgroundColor = backColor;
    }
    
    UILabel *titleTipLab = [[UILabel alloc] init];
    titleTipLab.text = @"验证您备份的助记词".localized;
    titleTipLab.font = CMTextFont14;
    titleTipLab.textAlignment = NSTextAlignmentCenter;
    titleTipLab.textColor = CMColorFromRGB(0x8E92A3);
    [self.view addSubview:titleTipLab];
    self.titleTipLab = titleTipLab;
    
    __weak typeof(self) weakself = self;
    EnglishCodeBackUpView *backupView = [[EnglishCodeBackUpView alloc] init];
    backupView.backgroundColor = backColor;
    [self.view addSubview:backupView];
    self.backupView = backupView;
    backupView.cancelSelectItem = ^(NSString *itemStr) {
        [weakself.itemChooseview cancelPressedState:itemStr];
        [weakself setPressedEnabled:NO];
    };
    
    backupView.remakeSelfHeight = ^(CGFloat height) {
        height = height > 150 ? height : 150;
        weakself.backupView.frame = CGRectMake(0, weakself.backupView.frame.origin.y, weakself.backupView.frame.size.width, height);
        weakself.itemChooseview.frame = CGRectMake(0, weakself.backupView.frame.origin.y + height, weakself.itemChooseview.frame.size.width, 180);
    };
    
    UIView *bottomBgView = [[UIView alloc] init];
    bottomBgView.backgroundColor = CMColorFromRGB(0x2B292F);
    [self.view addSubview:bottomBgView];
    self.bottomBgView = bottomBgView;
    
    UILabel *bottomTipLab = [[UILabel alloc] init];
    bottomTipLab.text = @"请按照正确的顺序点击每个单词".localized;
    bottomTipLab.font = CMTextFont14;
    bottomTipLab.textAlignment = NSTextAlignmentLeft;
    bottomTipLab.textColor = CMColorFromRGB(0xFFFFFF);
    [bottomBgView addSubview:bottomTipLab];
    self.bottomTipLab = bottomTipLab;
    
    EnglishCodeChooseView *itemChooseview = [[EnglishCodeChooseView alloc] init];
    itemChooseview.items = [_englishCode componentsSeparatedByString:@" "];
    [bottomBgView addSubview:itemChooseview];
    self.itemChooseview = itemChooseview;
    itemChooseview.pressItem = ^(NSString *itemStr) {
        [weakself.backupView addItem:itemStr];
        NSInteger codeCount = [weakself.backupView getEnglishCodeCount];
        if (codeCount == 12) {
            [weakself setPressedEnabled:YES];
        }
    };
    
    UIButton *okBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [okBtn setTitle:@"确定".localized forState:UIControlStateNormal];
    okBtn.backgroundColor = lineColor;
    [okBtn setTitleColor:CMColorFromRGB(0xFFFFFF) forState:UIControlStateNormal];
    okBtn.titleLabel.font = [UIFont systemFontOfSize:17];
    okBtn.layer.cornerRadius = 6.f;
    okBtn.clipsToBounds = YES;
    [bottomBgView addSubview:okBtn];
    [okBtn addTarget:self action:@selector(sureAction) forControlEvents:UIControlEventTouchUpInside];
    self.okBtn = okBtn;
    [self setPressedEnabled:NO];
}

- (void)viewWillLayoutSubviews {
    
    [super viewWillLayoutSubviews];
    
    CGFloat topSpace = 20;
   
    
    [self.titleTipLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).with.offset(15);
        make.right.equalTo(self.view).with.offset(-15);
        make.height.mas_equalTo(14);
        make.top.equalTo(self.view).with.offset(topSpace);
    }];
    
    [self.backupView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.titleTipLab.mas_bottom).with.offset(15);
        make.height.mas_equalTo(200);
    }];
    
    [self.bottomBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.backupView.mas_bottom).with.offset(10);
        make.bottom.mas_equalTo(self.view.mas_bottom);
    }];
    
    [self.bottomTipLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bottomBgView).offset(15);
        make.right.equalTo(self.bottomBgView).offset(-15);
        make.top.equalTo(self.bottomBgView).with.offset(35);
        make.height.mas_offset(18);
    }];
    
    CGFloat viewHeight = 220;
    [self.itemChooseview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.bottomBgView);
        make.top.equalTo(self.bottomTipLab.mas_bottom);
        make.height.mas_equalTo(viewHeight);
    }];
    
    [self.okBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bottomBgView).offset(15);
        make.right.equalTo(self.bottomBgView).offset(-15);
        make.height.mas_equalTo(44);
        make.bottom.equalTo(self.view.mas_bottom).offset(- 30 - kIphoneXBottomOffset);
    }];
}

- (void)setPressedEnabled:(BOOL)enabled {
    self.okBtn.enabled = enabled;

    if (enabled) {
        self.okBtn.backgroundColor = CMColorFromRGB(0x7190FF);
    } else {
        self.okBtn.backgroundColor = CMColorFromRGB(0x5D6377);
    }
   
}

#pragma mark-
#pragma mark 类方法
/**
 * 确定按钮点击事件
 */
- (void)sureAction
{
    
    NSString *backupCode = [self.backupView getEnglishCode];
    if (![_englishCode isEqualToString:backupCode]) {
         [self showCustomMessage:@"助记词错误".localized hideAfterDelay:2.0];
        return;
    }
    
    if (_parentFrom == ParentViewControllerFromKeyBackUpWallet) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    [self showProgressWithMessage:@""];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        [self addCoinIntoWallet];
        
    });
}

- (BOOL)addWalletIntoDB
{
    LocalWallet *wallet = [[LocalWallet alloc] init];
    wallet.wallet_name = self.walletName;
    wallet.wallet_password = [GoFunction passwordhash:self.password];                            //self.password;
    wallet.wallet_remembercode = [GoFunction enckey:self.englishCode password:self.password];                        //self.chineseCode;
    wallet.wallet_totalassets = 0;
    wallet.wallet_issmall = 1;
    
    LocalWallet *selectedWallet = [[PWDataBaseManager shared] queryWalletIsSelected];
    selectedWallet.wallet_isselected = 0;
    [[PWDataBaseManager shared] updateWallet:selectedWallet];
    
    wallet.wallet_isbackup = 1;
    wallet.wallet_isselected = 1;
    wallet.wallet_issetpwd = 1;

    return [[PWDataBaseManager shared] addWallet:wallet];
}

/**
 * 添加币到钱包
 */
- (void)addCoinIntoWallet
{
    WEAKSELF
//    NSArray *coinArray = [[PWAppsettings instance] getHomeCoinInfo];
//    
//    if (coinArray != nil) {
//        if ([self addWalletIntoDB]) {
//            
//        }else{
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self showCustomMessage:@"钱包创建失败".localized hideAfterDelay:2.0];
//                return ;
//            });
//        }
//        [weakSelf addCoinDetailOperation:coinArray code:self.englishCode];
//    }else{
        if ([self addWalletIntoDB]) {
            
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showCustomMessage:@"钱包创建失败".localized hideAfterDelay:2.0];
                return ;
            });
        }
        NSArray *array = [PreCoin getPreCoinArr];
        [weakSelf addCoinDetailOperation:array code:self.englishCode];
//    }
}

/**
 * 获取到推荐币种后的操作
 */
- (void)addCoinDetailOperation:(NSArray *)coinArray  code:(NSString *)rememberCode
{
   
    __block NSError *error;
    for (int i = 0; i < coinArray.count; i++) {
        
        NSDictionary *dic = [coinArray objectAtIndex:i];
        NSString *coinStr = dic[@"name"];
        NSString *platStr = dic[@"platform"];
        NSInteger treaty = [dic[@"treaty"] integerValue];
        NSString *chain = dic[@"chain"];
        WalletapiHDWallet *hdWallet = [GoFunction goCreateHDWallet:chain rememberCode:rememberCode];
        NSData *pubKey = [hdWallet newKeyPub:0 error:&error];
     
        NSString *address = [GoFunction createAddress:hdWallet coinType:coinStr platform:platStr andTreaty:treaty];
        CGFloat balance = [GoFunction goGetBalance:coinStr platform:platStr address:address andTreaty:treaty];
        
        LocalCoin *coin = [[LocalCoin alloc] init];
        coin.coin_walletid = [[PWDataBaseManager shared] queryMaxWalletId];
        coin.coin_type = coinStr;
        coin.coin_address = address;
        coin.coin_balance = balance == -1 ? 0 : balance;
        coin.coin_pubkey = [pubKey hexString];
        coin.coin_show = 1;
        coin.coin_platform = dic[@"platform"];
        coin.coin_coinid = [dic[@"id"] integerValue];
        coin.treaty = [dic[@"treaty"] integerValue];
        coin.coin_chain = dic[@"chain"];
        coin.coin_type_nft = [dic[@"coin_type_nft"] integerValue];
        [[PWDataBaseManager shared] addCoin:coin];
    }
    [self hideProgress];
    
    NSArray *coinsArray = [[PWDataBaseManager shared] queryCoinArrayBasedOnSelectedWalletID];
    NSMutableArray *muArr = [[NSMutableArray alloc] init];
    NSString *addr = @"";
    for (LocalCoin *coin in coinsArray) {
        NSDictionary *dict = @{@"cointype":coin.coin_type,
                               @"address":coin.coin_address
        };
        if ([coin.coin_chain isEqualToString:@"BTY"]) {
            addr = coin.coin_address;
        }
        [muArr addObject:dict];
    }
   
    [GoFunction muImpAddr:[NSArray arrayWithArray:muArr]];
    dispatch_async(dispatch_get_main_queue(), ^{
        AppDelegate *appdelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
        appdelegate.type = @"1";
        [[PWAppsettings instance] deletecurrentCoinsName];
        [[PWAppsettings instance] savecurrentCoinsName:@"1"];
        [[PWAppsettings instance] deleteAddress];
        [[PWAppsettings instance] deleteHomeCoinPrice];
        [[PWAppsettings instance] deleteHomeLocalCoin];
       [appdelegate switchRootViewController];
       
    });
   
}
@end
