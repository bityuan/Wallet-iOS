//
//  ImportAddressViewController.m
//  PWallet
//
//  Created by 郑晨 on 2019/10/21.
//  Copyright © 2019 陈健. All rights reserved.
//

#import "ImportAddressViewController.h"
#import "PWChoiceChainViewController.h"
#import "LocalWallet.h"
#import "PWDataBaseManager.h"
#import "AppDelegate.h"
#import "CommonTextField.h"
#import "ScanViewController.h"


@interface ImportAddressViewController ()
<UITextViewDelegate,UITextFieldDelegate>

@property (nonatomic, strong) UIButton *choiceChainBtn; // 选择主链按钮
@property (nonatomic, strong) UILabel *addressTipLab;// 私钥提示语
@property (nonatomic, strong) UILabel *walletNameLab; // 钱包名称
@property (nonatomic, strong) CommonTextField *walletNameTextField;// 钱包名称
@property (nonatomic, strong) UIButton *importBtn; // 导入按钮
@property (nonatomic, strong) NSString *chainName; // 主链名字
@property (nonatomic, strong) NSString *coinName; // 币的名字
@property (nonatomic, strong) NSString *chainIcon; // 主链图标
@property (nonatomic, strong) UILabel *chainLab; // 主链：
@property (nonatomic, strong) UIImageView *logoImageView; // 主链图标
@property (nonatomic, strong) UILabel *chainNameLab; // 主链名称

@property (nonatomic, strong) LocalWallet *oldWallet;

@end

@implementation ImportAddressViewController

//导入观察钱包
- (instancetype)initWithChainName:(NSString *)chainName ChainIcon:(NSString *)chainIcon CoinName:(NSString *)coinName
{
    if (self) {
        self.chainName = chainName;
        self.coinName  = coinName;
        self.chainIcon = chainIcon;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.whiteColor;

    self.navigationItem.rightBarButtonItem = [self rightNavigationItem];

    [self initView];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (@available(iOS 13.0, *)) {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDarkContent;
    } else {
           // Fallback on earlier versions
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    }
    
}

- (void)initView
{
    
    _choiceChainBtn = [[UIButton alloc] init];
    [_choiceChainBtn setTitle:@"选择主链".localized forState:UIControlStateNormal];
    [_choiceChainBtn setTitleColor:SGColorFromRGB(0x7190ff) forState:UIControlStateNormal];
    [_choiceChainBtn.layer setCornerRadius:6.f];
    [_choiceChainBtn.layer setBorderColor:SGColorFromRGB(0x7190ff).CGColor];
    [_choiceChainBtn.layer setBorderWidth:1.f];
    [_choiceChainBtn.titleLabel setFont:[UIFont systemFontOfSize:16.f]];
    [_choiceChainBtn addTarget:self action:@selector(choiceChain:) forControlEvents:UIControlEventTouchUpInside];
    [_choiceChainBtn setImage:[UIImage imageNamed:@"choiceChain"] forState:UIControlStateNormal];
    [self.choiceChainBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [self.choiceChainBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, -(kScreenWidth - 34))];
    
    [self.view addSubview:_choiceChainBtn];
    
    _chainLab = [[UILabel alloc] init];
    _chainLab.text = @"主链:".localized;
    _chainLab.textColor  = SGColorFromRGB(0x7190ff);
    _chainLab.textAlignment = NSTextAlignmentLeft;
    _chainLab.font = [UIFont systemFontOfSize:14.f];
    [_choiceChainBtn addSubview:_chainLab];
    _chainLab.hidden = YES;
       
    _logoImageView = [[UIImageView alloc] init];
       
    [_choiceChainBtn addSubview:_logoImageView];
    _logoImageView.hidden = YES;
       
    _chainNameLab = [[UILabel alloc] init];
    _chainNameLab.text = @"";
    _chainNameLab.font = [UIFont systemFontOfSize:14.f];
    _chainNameLab.textColor = SGColorFromRGB(0x333649);
    _chainNameLab.textAlignment = NSTextAlignmentRight;
       
    [_choiceChainBtn addSubview:_chainNameLab];
    _chainNameLab.hidden = YES;
    
    _addressTextView = [[UITextView alloc] init];
    _addressTextView.font = [UIFont systemFontOfSize:16.f];
    _addressTextView.textColor = SGColorFromRGB(0x333649);
    _addressTextView.backgroundColor = SGColorFromRGB(0xf8f8fa);
    _addressTextView.layer.cornerRadius = 5.f;
    _addressTextView.textAlignment = NSTextAlignmentLeft;
    _addressTextView.delegate = self;
    _addressTextView.contentInset = UIEdgeInsetsMake(15, 5, 0, 0);
    [self.view addSubview:_addressTextView];

    _palceHoldLab = [[UILabel alloc] init];
    _palceHoldLab.textColor = SGColorFromRGB(0x8e92a3);
    _palceHoldLab.font = [UIFont systemFontOfSize:16.f];
    _palceHoldLab.text = @"请输入地址或者扫描地址生成的二维码录入".localized;
    _palceHoldLab.textAlignment = NSTextAlignmentLeft;
    _palceHoldLab.numberOfLines = 0;
    [self.view addSubview:_palceHoldLab];
    
    UILabel *addressTipLab = [[UILabel alloc] init];
    addressTipLab.textColor = TipRedColor;
    addressTipLab.textAlignment = NSTextAlignmentLeft;
    addressTipLab.font = CMTextFont13;
    addressTipLab.text = @"请输入地址或者扫描地址生成的二维码录入".localized;
    addressTipLab.numberOfLines = 0;
    
    [self.view addSubview:addressTipLab];
    self.addressTipLab = addressTipLab;
    [addressTipLab setHidden:YES];
    
    
    _walletNameLab = [[UILabel alloc] init];
    _walletNameLab.text = @"钱包名称".localized;
    _walletNameLab.textColor = SGColorFromRGB(0x8e92a3);
    _walletNameLab.textAlignment = NSTextAlignmentLeft;
    _walletNameLab.font = [UIFont systemFontOfSize:14.f];

    [self.view addSubview:_walletNameLab];
      //设置钱包名称
    NSInteger maxID = [[PWDataBaseManager shared] queryMaxWalletId];
    CommonTextField *walletNameText = [[CommonTextField alloc] init];
    walletNameText.textColor = CMColorFromRGB(0x333649);
    walletNameText.placeholder = @"设置钱包名称".localized;
    [walletNameText setValue:CMColorFromRGB(0x8E92A3) forKeyPath:@"placeholderLabel.textColor"];
    walletNameText.text = [NSString stringWithFormat:@"%@%li",@"钱包".localized,(long)maxID + 1];
    walletNameText.delegate = self;
    [self.view addSubview:walletNameText];
    self.walletNameTextField = walletNameText;
    [walletNameText setAttributedPlaceholderDefault];

    
    
    UIButton *createWalletBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [createWalletBtn setTitle:@"开始导入".localized forState:UIControlStateNormal];
    createWalletBtn.backgroundColor = CMColorFromRGB(0x7190FF);
    [createWalletBtn setTitleColor:CMColorFromRGB(0xFFFFFF) forState:UIControlStateNormal];
    createWalletBtn.titleLabel.font = [UIFont systemFontOfSize:17];
    createWalletBtn.layer.cornerRadius = 6.f;
    createWalletBtn.clipsToBounds = YES;
    [self.view addSubview:createWalletBtn];
    self.importBtn = createWalletBtn;
    [createWalletBtn addTarget:self action:@selector(createWalletAction) forControlEvents:UIControlEventTouchUpInside];


    [_addressTextView setKeyBoardInputView:createWalletBtn action:@selector(createWalletAction)];

    [self.choiceChainBtn setTitle:@"" forState:UIControlStateNormal];
    [self.choiceChainBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, -(kScreenWidth - 98))];
    self.chainLab.hidden = NO;
    self.logoImageView.hidden = NO;
    [self.logoImageView sd_setImageWithURL:[NSURL URLWithString:self.chainIcon]];
    self.chainNameLab.hidden = NO;
    self.chainNameLab.text = self.coinName;
    self.chainName = self.chainName;
    self.coinName = self.coinName;

}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    [self.choiceChainBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(20);
        make.left.equalTo(self.view).offset(18);
        make.width.mas_equalTo(kScreenWidth - 34);
        make.height.mas_equalTo(44);
    }];
    [self.chainLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.choiceChainBtn).offset(16);
        make.top.equalTo(self.choiceChainBtn).offset(14);
        make.height.mas_equalTo(20);
    }];
       
    [self.logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.choiceChainBtn).offset(140);
        make.top.equalTo(self.choiceChainBtn).offset(12);
        make.width.height.mas_equalTo(20);
    }];
       
    [self.chainNameLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.logoImageView.mas_right).offset(10);
        make.top.equalTo(self.choiceChainBtn).offset(11);
        make.height.mas_equalTo(22);
    }];
    
    [self.addressTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.choiceChainBtn);
        make.top.equalTo(self.choiceChainBtn.mas_bottom).offset(20);
        make.height.mas_equalTo(110);
    }];

    [self.addressTipLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.addressTextView);
        make.top.equalTo(self.addressTextView.mas_bottom).offset(5);
         make.right.equalTo(self.addressTextView).offset(-10);
        if ([LocalizableService getAPPLanguage] == LanguageEnglish || [LocalizableService getAPPLanguage] == LanguageJapanese) {
            make.height.mas_equalTo(40);
        }
        else
        {
            make.height.mas_equalTo(13);
        }
    }];
    
    [self.walletNameLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.addressTextView);
        make.height.mas_equalTo(20);
        make.top.equalTo(self.addressTextView.mas_bottom).offset(21);
    }];

    [self.walletNameTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.addressTextView);
        make.height.mas_equalTo(50);
        make.top.equalTo(self.walletNameLab.mas_bottom);
    }];
    
    [self.palceHoldLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.addressTextView).offset(9);
        make.top.equalTo(self.addressTextView).offset(23);
        make.right.equalTo(self.addressTextView).offset(-10);
        if ([LocalizableService getAPPLanguage] == LanguageEnglish || [LocalizableService getAPPLanguage] == LanguageJapanese) {
            make.height.mas_equalTo(40);
        }
        else
        {
            make.height.mas_equalTo(20);
        }
    }];
    [self.importBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.addressTextView);
        make.height.mas_equalTo(44);
        make.bottom.equalTo(self.view).with.offset(- 31 - kIphoneXBottomOffset);
    }];
    
}

#pragma mark - textview delegate

- (void)textViewDidChange:(UITextView *)textView
{
    if (_addressTextView.text.length != 0)
    {
        self.palceHoldLab.hidden = YES;
    }
    else
    {
        self.palceHoldLab.hidden = NO;
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    text = [PWUtils removeSpaceAndNewline:text];
    if ([PWUtils isInputRuleNotBlank:text andType:@"address"])
    {
        if (_addressTextView.text.length != 0)
        {
            self.palceHoldLab.hidden = YES;
        }
        else
        {
            self.palceHoldLab.hidden = NO;
        }
        return YES;
    }
    else
    {
        return NO;
    }

    return YES;
}


- (void)closeKeyBoard
{
    [self.view endEditing:YES];
}

#pragma mark - UITextField Delegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {

    CommonTextField *textF = (CommonTextField *)textField;
    textF.lineColor = CMColorFromRGB(0x7190FF);
    
    [textF setNeedsDisplay];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    CommonTextField *textF = (CommonTextField *)textField;
    textF.lineColor = CMColorFromRGB(0x8E92A3);
    [textF setNeedsDisplay];
}

#pragma mark - 选择主链
- (void)choiceChain:(UIButton *)sender
{
    NSLog(@"我要去选择主链了");
    PWChoiceChainViewController *vc = [[PWChoiceChainViewController alloc] init];
    vc.chainStr = self.coinName;
    vc.choiceType = ChoiceTypPri;
    WEAKSELF
    vc.choiceChainBlock = ^(NSString * _Nonnull chainName, NSString * _Nonnull chainImageName, NSString * _Nonnull coinName) {
        [weakSelf.choiceChainBtn setTitle:@"" forState:UIControlStateNormal];
        [self.choiceChainBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, -(kScreenWidth - 98))];
        weakSelf.chainLab.hidden = NO;
        weakSelf.logoImageView.hidden = NO;
        [weakSelf.logoImageView sd_setImageWithURL:[NSURL URLWithString:chainImageName]];
        weakSelf.chainNameLab.hidden = NO;
        weakSelf.chainNameLab.text = coinName;
        weakSelf.chainName = chainName;
        weakSelf.coinName = coinName;
        
    };
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 导入地址
- (void)createWalletAction
{
    
     if (self.chainNameLab.text.length == 0
           || self.chainNameLab.text == nil) {
           [self showCustomMessage:@"请选择主链".localized hideAfterDelay:2.f];
           
           return;
         
     }
       
    
    if (_addressTextView.text.length == 0)
    {
        self.addressTipLab.hidden = NO;
        return;
    }
    else
    {
        self.addressTipLab.hidden = YES;
    }
    
    [self closeKeyBoard];

    if (self.walletNameTextField.text.length == 0) {
        [self showCustomMessage:@"请输入钱包名称".localized hideAfterDelay:2.f];
        return;
    }
    
    [self showProgressWithMessage:@""];
   
    [self addCoinIntoWallet:[PWUtils removeSpaceAndNewline:self.addressTextView.text]];
    
}

- (void)addCoinIntoWallet:(NSString *)address
{
    NSDictionary *param = @{@"names":@[self.chainNameLab.text]};
    WEAKSELF
    [[SGNetWork defaultManager] sendRequestMethod:HTTPMethodPOST
                                        serverUrl:WalletURL
                                          apiPath:HOMECOININDEX
                                       parameters:param
                                         progress:nil
                                          success:^(BOOL isSuccess, id  _Nullable responseObject) {
       
       
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
        NSArray *priceArray = result[@"data"];
        [weakSelf addCoinDetailOperation:priceArray address:address];
        
    } failure:^(NSString * _Nullable errorMessage) {
        
    }];
    
   
}

/**
 * 获取到推荐币种后的操作
 */
- (void)addCoinDetailOperation:(NSArray *)coinArray address:(NSString *)address
{
    
    if (![self addWalletIntoDB:address]){
        [self showCustomMessage:@"钱包已经存在，请勿重复导入".localized hideAfterDelay:2.0];
        return ;
    }
    __block BOOL state = YES;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        for (int i = 0; i < coinArray.count; i++) {
            NSDictionary *dic = coinArray[i];
            NSString *coinStr = dic[@"name"];
            NSString *platformStr = dic[@"platform"];
            NSInteger treaty = [dic[@"treaty"] integerValue];
            
            CGFloat balance = [GoFunction goGetBalance:coinStr platform:platformStr address:address andTreaty:treaty];
            LocalCoin *coin = [[LocalCoin alloc] init];
            coin.coin_walletid = [[PWDataBaseManager shared] queryMaxWalletId];
            coin.coin_type = coinStr;
            coin.coin_address = address;
            coin.coin_balance = balance == -1 ? 0 : balance;
            coin.coin_pubkey = @"";
            coin.coin_show = 1;
            coin.coin_platform = dic[@"platform"];
            coin.coin_coinid = [dic[@"id"] integerValue];
            coin.treaty = [dic[@"treaty"] integerValue];
            coin.coin_chain = dic[@"chain"];
            coin.coin_type_nft = 2;
            [[PWDataBaseManager shared] addCoin:coin];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (state) {
                [self hideProgress];
                
                NSArray *coinArray = [[PWDataBaseManager shared] queryCoinArrayBasedOnSelectedWalletID];
                NSMutableArray *muArr = [[NSMutableArray alloc] init];
                for (LocalCoin *coin in coinArray) {
                    NSDictionary *dict = @{@"cointype":coin.coin_type,
                                           @"address":coin.coin_address
                    };
                    
                    [muArr addObject:dict];
                }
                
//                [GoFunction muImpAddr:[NSArray arrayWithArray:muArr]];
                
                AppDelegate *appdelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
                appdelegate.type = @"2";
                [[PWAppsettings instance] deletecurrentCoinsName];
                [[PWAppsettings instance] savecurrentCoinsName:@"2"];
                [[PWAppsettings instance] deleteHomeCoinPrice];
                [[PWAppsettings instance] deleteHomeLocalCoin];
                [[PWAppsettings instance] deleteEscrowInfo];
                [[PWAppsettings instance] deleteAddress];
                [appdelegate switchRootViewController];
            }
        });
    });
}


- (BOOL)addWalletIntoDB:(NSString *)address
{
    LocalWallet *wallet = [[LocalWallet alloc] init];
       //下面使用kvc是为了不产生警告
    wallet.wallet_name = [self valueForKeyPath:@"walletNameTextField.text"];
    wallet.wallet_password = [NSString stringWithFormat:@"%@:%@",self.chainName,[PWUtils removeSpaceAndNewline:self.addressTextView.text]]; // 地址钱包的密码是当前主链的名字和地址
    wallet.wallet_remembercode = [GoFunction enckey:address password:@""];
    wallet.wallet_totalassets = 0;
    wallet.wallet_issmall = 3; // 导入地址创建的钱包
       
    LocalWallet *selectedWallet = [[PWDataBaseManager shared] queryWalletIsSelected];
    selectedWallet.wallet_isselected = 0;
    self.oldWallet = selectedWallet;
       
    [[PWDataBaseManager shared] updateWallet:selectedWallet];
    wallet.wallet_isbackup = 1;
    wallet.wallet_isselected = 1;
    wallet.wallet_issetpwd = 1;
//    BOOL isExistence = [[PWDataBaseManager shared] checkWallectIsExistence:wallet];
    return [[PWDataBaseManager shared] addWallet:wallet];
    
}

- (UIBarButtonItem *)rightNavigationItem
{
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(-10, 0, 60, 60)];
    [btn setImage:[UIImage imageNamed:@"import_scan"] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"import_scan"] forState:UIControlStateHighlighted];
    [btn setContentMode:UIViewContentModeScaleAspectFit];
    [btn addTarget:self action:@selector(importScan:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    return item;
}

- (void)importScan:(UIButton *)sender
{
    ScanViewController *vc = [[ScanViewController alloc] init];
    vc.scanResult = ^(NSString *address) {
           NSLog(@"address is %@",address);
            self.addressTextView.text = address;
            self.palceHoldLab.hidden = YES;
       
    };
       
    [self.navigationController pushViewController:vc animated:YES];
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
