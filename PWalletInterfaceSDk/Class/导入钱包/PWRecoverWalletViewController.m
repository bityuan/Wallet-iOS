//
//  PWRecoverWalletViewController.m
//  PWalletInterfaceSDk
//
//  Created by 郑晨 on 2023/1/4.
//  Copyright © 2023 fzm. All rights reserved.
//

#import "PWRecoverWalletViewController.h"
#import "LTSafeKeyboard.h"
#import "ScanViewController.h"
#import "NSString+CommonUseTool.h"
#import "AppDelegate.h"

@interface PWRecoverWalletViewController ()
<UITextViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UITextView *prikeyTextView; // 控制私钥
@property (nonatomic, strong) UITextView *addressTextView; // 找回地址
@property (nonatomic, strong) UILabel *addressTipLab; // 占位符
@property (nonatomic, strong) UILabel *prikeyTipLab; // 占位符
@property (nonatomic, strong) UIButton *prikeyScanBtn;
@property (nonatomic, strong) UIButton *addrScanBtn;
@property (nonatomic, strong) UILabel *prikeyPalceHoldLab; // 占位符
@property (nonatomic, strong) UILabel *palceHoldLab; // 占位符
@property (nonatomic, strong) UILabel *walletNameLab; // 钱包名称
@property (nonatomic, strong) UILabel *tipLab;
@property (nonatomic, strong) UILabel *pwdTipLab;
@property (nonatomic, strong) UILabel *nameTipLab;
@property (nonatomic, strong) UIButton *importBtn; // 导入按钮
@property (nonatomic, strong) CommonTextField *walletNameTextField;// 钱包名称
@property (nonatomic, strong) CommonTextField *setWalletPwdTextField; // 设置钱包密码
@property (nonatomic, strong) UILabel *promptPwdLab;
@property (nonatomic, strong) CommonTextField *confirWalletPwdTextField; // 确认钱包密码
@property (nonatomic,strong)LocalWallet *oldWallet;
@end

@implementation PWRecoverWalletViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.whiteColor;
     self.showMaskLine = false;
    [self createView];
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
   
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
}

- (void)createView
{
    _scrollView = [[UIScrollView alloc] init];

    [self.view addSubview:_scrollView];
    
    _prikeyTextView = [[UITextView alloc] init];
    _prikeyTextView.font = [UIFont systemFontOfSize:16.f];
    _prikeyTextView.textColor = SGColorFromRGB(0x333649);
    _prikeyTextView.backgroundColor = SGColorFromRGB(0xf8f8fa);
    _prikeyTextView.layer.cornerRadius = 5.f;
    _prikeyTextView.textAlignment = NSTextAlignmentLeft;
    _prikeyTextView.delegate = self;
    _prikeyTextView.contentInset = UIEdgeInsetsMake(15, 5, 0, 0);
    
    [self.scrollView addSubview:_prikeyTextView];

    
    _prikeyPalceHoldLab = [[UILabel alloc] init];
    _prikeyPalceHoldLab.textColor = SGColorFromRGB(0x8e92a3);
    _prikeyPalceHoldLab.font = [UIFont systemFontOfSize:16.f];
    _prikeyPalceHoldLab.text = @"请输入控制地址的私钥".localized ;
    _prikeyPalceHoldLab.textAlignment = NSTextAlignmentLeft;
    _prikeyPalceHoldLab.numberOfLines = 0;
    [self.scrollView addSubview:_prikeyPalceHoldLab];
    
    UILabel *prikeyTipLab = [[UILabel alloc] init];
    prikeyTipLab.textColor = TipRedColor;
    prikeyTipLab.textAlignment = NSTextAlignmentLeft;
    prikeyTipLab.font = CMTextFont13;
    prikeyTipLab.text = @"请输入私钥或者扫描私钥生成的二维码录入".localized ;
    prikeyTipLab.numberOfLines = 0;
    [self.scrollView addSubview:prikeyTipLab];
    self.prikeyTipLab = prikeyTipLab;
    [prikeyTipLab setHidden:YES];
    
    _prikeyScanBtn = [[UIButton alloc] init];
    _prikeyScanBtn.tag = 100;
    [_prikeyScanBtn setImage:[UIImage imageNamed:@"import_scan"] forState:UIControlStateNormal];
    [_prikeyScanBtn setImage:[UIImage imageNamed:@"import_scan"] forState:UIControlStateHighlighted];
    [_prikeyScanBtn setContentMode:UIViewContentModeScaleAspectFit];
    [_prikeyScanBtn addTarget:self action:@selector(importScan:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.scrollView addSubview:_prikeyScanBtn];
    
    
    _addressTextView = [[UITextView alloc] init];
    _addressTextView.font = [UIFont systemFontOfSize:16.f];
    _addressTextView.textColor = SGColorFromRGB(0x333649);
    _addressTextView.backgroundColor = SGColorFromRGB(0xf8f8fa);
    _addressTextView.layer.cornerRadius = 5.f;
    _addressTextView.textAlignment = NSTextAlignmentLeft;
    _addressTextView.delegate = self;
    _addressTextView.contentInset = UIEdgeInsetsMake(15, 5, 0, 0);
    
    [self.scrollView addSubview:_addressTextView];

    
    _palceHoldLab = [[UILabel alloc] init];
    _palceHoldLab.textColor = SGColorFromRGB(0x8e92a3);
    _palceHoldLab.font = [UIFont systemFontOfSize:16.f];
    _palceHoldLab.text = @"请输入找回地址".localized ;
    _palceHoldLab.textAlignment = NSTextAlignmentLeft;
    _palceHoldLab.numberOfLines = 0;
    [self.scrollView addSubview:_palceHoldLab];

    UILabel *addressTipLab = [[UILabel alloc] init];
    addressTipLab.textColor = TipRedColor;
    addressTipLab.textAlignment = NSTextAlignmentLeft;
    addressTipLab.font = CMTextFont13;
    addressTipLab.text = @"请输入找回地址或扫码找回地址生成的二维码录入".localized ;
    addressTipLab.numberOfLines = 0;
    [self.scrollView addSubview:addressTipLab];
    self.addressTipLab = addressTipLab;
    [addressTipLab setHidden:YES];
    
    
    _addrScanBtn = [[UIButton alloc] init];
    _addrScanBtn.tag = 101;
    [_addrScanBtn setImage:[UIImage imageNamed:@"import_scan"] forState:UIControlStateNormal];
    [_addrScanBtn setImage:[UIImage imageNamed:@"import_scan"] forState:UIControlStateHighlighted];
    [_addrScanBtn setContentMode:UIViewContentModeScaleAspectFit];
    [_addrScanBtn addTarget:self action:@selector(importScan:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.scrollView addSubview:_addrScanBtn];
    
    
    _walletNameLab = [[UILabel alloc] init];
    _walletNameLab.text = @"账户名称".localized ;
    _walletNameLab.textColor = SGColorFromRGB(0x8e92a3);
    _walletNameLab.textAlignment = NSTextAlignmentLeft;
    _walletNameLab.font = [UIFont systemFontOfSize:14.f];

    [self.scrollView addSubview:_walletNameLab];
    //设置钱包名称
    NSInteger maxID = [[PWDataBaseManager shared] queryMaxWalletId];
    CommonTextField *walletNameText = [[CommonTextField alloc] init];
    walletNameText.textColor = CMColorFromRGB(0x333649);
    walletNameText.placeholder = @"设置账户名称".localized ;
    [walletNameText setValue:CMColorFromRGB(0x8E92A3) forKeyPath:@"placeholderLabel.textColor"];
    walletNameText.text = [NSString stringWithFormat:@"%@%li",@"找回账户".localized ,(long)maxID + 1];
    walletNameText.delegate = self;
    [self.scrollView addSubview:walletNameText];
    self.walletNameTextField = walletNameText;
    [walletNameText setAttributedPlaceholderDefault];
    
    //请输入8～16位字符 提示
    UILabel *promptPwdLab = [[UILabel alloc] init];
    promptPwdLab.text = @"设置账户密码 8-16位数字、字母组合".localized ;
    promptPwdLab.font = [UIFont systemFontOfSize:14];
    promptPwdLab.textColor = CMColorFromRGB(0x8E92A3);
    promptPwdLab.textAlignment = NSTextAlignmentLeft;
    promptPwdLab.numberOfLines = 0;
    [self.scrollView addSubview:promptPwdLab];
    self.promptPwdLab = promptPwdLab;
    [promptPwdLab setHidden:YES];

    //请输入密码
    CommonTextField *PwdText = [[CommonTextField alloc] init];
    PwdText.textColor = CMColorFromRGB(0x333649);
    PwdText.placeholder = @"请设置账户密码".localized ;
    PwdText.keyboardType = UIKeyboardTypeEmailAddress;
    PwdText.secureTextEntry = YES;
    PwdText.delegate = self;
    PwdText.tag = 100;
    [self.scrollView addSubview:PwdText];
    self.setWalletPwdTextField = PwdText;
    [PwdText setAttributedPlaceholderDefault];
    LTSafeKeyboard *keyboard = [LTSafeKeyboard focusOnTextFiled:PwdText keyboardType:LTKeyboardTypeLetter];
    keyboard.showHintBubble = YES;

    //请重新输入密码
    CommonTextField *PwdAgainText = [[CommonTextField alloc] init];
    PwdAgainText.textColor = CMColorFromRGB(0x333649);
    PwdAgainText.placeholder = @"确认账户密码".localized ;
    PwdAgainText.keyboardType = UIKeyboardTypeEmailAddress;
    PwdAgainText.secureTextEntry = YES;
    PwdAgainText.delegate = self;
    [self.scrollView addSubview:PwdAgainText];
    self.confirWalletPwdTextField = PwdAgainText;
    [PwdAgainText setAttributedPlaceholderDefault];
    LTSafeKeyboard *keyboard1 = [LTSafeKeyboard focusOnTextFiled:PwdAgainText keyboardType:LTKeyboardTypeLetter];
    keyboard1.showHintBubble = YES;

    if (@available(iOS 11.0, *)) {
    PwdText.textContentType = UITextContentTypeName;
    PwdAgainText.textContentType = UITextContentTypeName;
    }

    //请输入8～16位字符
    UILabel *tipLab = [[UILabel alloc] init];
    tipLab.text = @"请输入8～16位数字、字母组合".localized ;
    tipLab.font = CMTextFont13;
    tipLab.textColor = ErrorColor;
    tipLab.textAlignment = NSTextAlignmentRight;
    [self.scrollView addSubview:tipLab];
    self.tipLab = tipLab;
    [tipLab setHidden:YES];

    //两次密码不相同
    UILabel *pwdTipLab = [[UILabel alloc] init];
    pwdTipLab.textColor = TipRedColor;
    pwdTipLab.textAlignment = NSTextAlignmentRight;
    pwdTipLab.font = CMTextFont13;
    pwdTipLab.text = @"";
    [self.scrollView addSubview:pwdTipLab];
    self.pwdTipLab = pwdTipLab;
    [pwdTipLab setHidden:NO];

    //两次密码不相同
    UILabel *nameTipLab = [[UILabel alloc] init];
    nameTipLab.textColor = TipRedColor;
    nameTipLab.textAlignment = NSTextAlignmentRight;
    nameTipLab.font = CMTextFont13;
    nameTipLab.text = @"";
    [self.scrollView addSubview:nameTipLab];
    self.nameTipLab = nameTipLab;
    [nameTipLab setHidden:NO];

    UIButton *createWalletBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [createWalletBtn setTitle:@"开始导入".localized  forState:UIControlStateNormal];
    createWalletBtn.backgroundColor = CMColorFromRGB(0x7190FF);
    [createWalletBtn setTitleColor:CMColorFromRGB(0xFFFFFF) forState:UIControlStateNormal];
    createWalletBtn.titleLabel.font = [UIFont systemFontOfSize:17];
    createWalletBtn.layer.cornerRadius = 6.f;
    createWalletBtn.clipsToBounds = YES;
    [self.scrollView addSubview:createWalletBtn];
    self.importBtn = createWalletBtn;
    [createWalletBtn addTarget:self action:@selector(createWalletAction) forControlEvents:UIControlEventTouchUpInside];

    [_walletNameTextField setKeyBoardInputView:createWalletBtn action:@selector(createWalletAction)];
    [_setWalletPwdTextField setKeyBoardInputView:createWalletBtn action:@selector(createWalletAction)];
    [_confirWalletPwdTextField setKeyBoardInputView:createWalletBtn action:@selector(createWalletAction)];
    [_addressTextView setKeyBoardInputView:createWalletBtn action:@selector(createWalletAction)];
    [_prikeyTextView setKeyBoardInputView:createWalletBtn action:@selector(createWalletAction)];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    self.scrollView.contentSize = CGSizeMake(SCREENBOUNDS.size.width,scrollViewHeight);

    [self.prikeyTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.scrollView).offset(18);
        make.width.mas_equalTo(kScreenWidth - 80);
        make.top.equalTo(self.scrollView).offset(20);
        make.height.mas_equalTo(100);
    }];
    
    [self.prikeyPalceHoldLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.prikeyTextView).offset(9);
        make.top.equalTo(self.prikeyTextView).offset(23);
        make.right.equalTo(self.prikeyTextView).offset(-10);
        make.height.mas_equalTo(20);
    }];
    
    [self.prikeyTipLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.prikeyTextView);
        make.top.equalTo(self.prikeyTextView.mas_bottom).offset(1);
        make.right.equalTo(self.prikeyTextView).offset(-10);
        make.height.mas_equalTo(13);
    }];
    
    [self.prikeyScanBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.prikeyTextView.mas_right).offset(10);
        make.centerY.equalTo(self.prikeyTextView);
        make.width.height.mas_equalTo(30);
    }];
    
    [self.addressTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.prikeyTextView);
        make.top.equalTo(self.prikeyTextView.mas_bottom).offset(15);
        make.height.mas_equalTo(40);
    }];

    [self.palceHoldLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.addressTextView).offset(9);
        make.centerY.equalTo(self.addressTextView);
        make.right.equalTo(self.addressTextView).offset(-10);
        make.height.mas_equalTo(20);
    }];

    [self.addressTipLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.addressTextView);
        make.top.equalTo(self.addressTextView.mas_bottom).offset(1);
        make.right.equalTo(self.addressTextView).offset(-10);
        make.height.mas_equalTo(13);
    }];
    [self.addrScanBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.addressTextView.mas_right).offset(10);
        make.centerY.equalTo(self.addressTextView);
        make.width.height.mas_equalTo(30);
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

    [self.promptPwdLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.walletNameTextField);
        make.height.mas_equalTo(20);
        make.top.equalTo(self.walletNameTextField.mas_bottom).with.offset(10);
    }];

    [self.setWalletPwdTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.walletNameTextField);
        make.height.mas_equalTo(50);
        make.top.equalTo(self.walletNameTextField.mas_bottom).with.offset(32);
    }];

    [self.confirWalletPwdTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.walletNameTextField);
        make.height.mas_equalTo(50);
        make.top.equalTo(self.setWalletPwdTextField.mas_bottom).with.offset(32);
    }];

    [self.nameTipLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.walletNameTextField.mas_bottom).with.offset(5);
        make.left.right.equalTo(self.walletNameTextField);
        make.height.mas_equalTo(13);
    }];

    [self.tipLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.setWalletPwdTextField.mas_bottom).with.offset(5);
        make.left.right.equalTo(self.walletNameTextField);
        make.height.mas_equalTo(13);
    }];

    [self.pwdTipLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.confirWalletPwdTextField.mas_bottom).with.offset(5);
        make.left.right.equalTo(self.walletNameTextField);
        make.height.mas_equalTo(13);
    }];

    [self.importBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.walletNameTextField);
        make.height.mas_equalTo(44);
        make.bottom.equalTo(self.view).with.offset(- 31 - kIphoneXBottomOffset);
        
    }];
}

#pragma mark - textview delegate

- (void)textViewDidChange:(UITextView *)textView
{
    if(textView == self.prikeyTextView)
    {
        if (_prikeyTextView.text.length != 0)
        {
            self.prikeyPalceHoldLab.hidden = YES;
        }
        else
        {
            self.prikeyPalceHoldLab.hidden = NO;
        }
    }
    else if (textView == self.addressTextView)
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
    
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    text = [PWUtils removeSpaceAndNewline:text];
    if(textView == self.prikeyTextView)
    {
        
        if (_prikeyTextView.text.length != 0)
        {
            self.prikeyPalceHoldLab.hidden = YES;
        }
        else
        {
            self.prikeyPalceHoldLab.hidden = NO;
        }
        return YES;
        
    }
    else if (textView == self.addressTextView)
    {
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
    }
    

    return YES;
}

#pragma mark - UITextField Delegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    if (textField.tag == 100) {
        self.promptPwdLab.hidden = NO;
    }
    
    CommonTextField *textF = (CommonTextField *)textField;
    textF.lineColor = CMColorFromRGB(0x7190FF);
    
    [textF setNeedsDisplay];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    if (textField.tag == 100) {
        self.promptPwdLab.hidden = YES;
    }
    
    CommonTextField *textF = (CommonTextField *)textField;
    textF.lineColor = CMColorFromRGB(0x8E92A3);
    [textF setNeedsDisplay];
}


#pragma mark 类方法

- (void)keyboardWillShow:(NSNotification *)noti
{

    [self.view layoutIfNeeded];

    [self.importBtn setHidden:YES];
}

- (void)keyboardWillHide:(NSNotification *)noti
{

    [self.view layoutIfNeeded];

    [self.importBtn setHidden:NO];
}

- (void)closeKeyBoard
{
    [self.view endEditing:YES];
}


- (void)importScan:(UIButton *)sender
{
    WEAKSELF
    ScanViewController *vc = [[ScanViewController alloc] init];
    [self.navigationController pushViewController:vc animated:true];
    vc.scanResult = ^(NSString *address) {
        
        switch (sender.tag) {
            case 100:
            {
                weakSelf.prikeyTextView.text = address;
                self.prikeyPalceHoldLab.hidden = YES;
            }
                break;
            case 101:
            {
                weakSelf.addressTextView.text = address;
                self.palceHoldLab.hidden = YES;
            }
                break;
            default:
                break;
        }
    };
    
}

- (void)createWalletAction
{
    NSString *walletNameText = self.walletNameTextField.text;
    NSString *pwdText = self.setWalletPwdTextField.text;
    NSString *pwdAgainText = self.confirWalletPwdTextField.text;
    if ([walletNameText isEqualToString:@""]) {
        self.nameTipLab.text = @"请设置钱包名称！".localized ;
        return;
    }
    
    if (_prikeyTextView.text.length == 0)
    {
        self.prikeyTipLab.hidden = NO;
    }
    else
    {
        self.prikeyTipLab.hidden = YES;
    }
    
    if (_addressTextView.text.length == 0)
    {
        self.addressTipLab.hidden = NO;
    }
    else
    {
        self.addressTipLab.hidden = YES;
    }
    
    if(![pwdText isRightPassword])
    {
        self.tipLab.hidden = NO;
    }
    else
    {
        self.tipLab.hidden = YES;
    }
        
    if ([pwdText isEqualToString:pwdAgainText] && ![walletNameText isEqualToString:@""])
    {
        self.pwdTipLab.text = @"";
        if ([pwdText isRightPassword]  && [pwdAgainText isRightPassword])
        {
            // 导入钱包操作
            [self createWallet];
        }
    }
    else
    {
        self.pwdTipLab.text = @"两次密码不相同".localized ;
    }
}

- (void)createWallet
{
    NSString *prikeyHexStr = @"";
    NSString *prikeyStr = [PWUtils removeSpaceAndNewline:self.prikeyTextView.text];
    NSString *address = [PWUtils removeSpaceAndNewline:self.addressTextView.text];
    
    
    if ([PWUtils isHex:prikeyStr]) {
        prikeyHexStr = prikeyStr;
    }
    else
    {
        // 先判断里面包不包含中文和表情
        if ([PWUtils stringContainsEmoji:prikeyStr])
        {
            [self showCustomMessage:@"私钥有误".localized  hideAfterDelay:2.f];
            return;
        }
        else if ([PWUtils checkIsChinese:prikeyStr])
        {
            [self showCustomMessage:@"私钥有误".localized  hideAfterDelay:2.f];
            return;
        }
        if ([prikeyStr hasPrefix:@"0x"]) {
            prikeyStr =  [prikeyStr stringByReplacingOccurrencesOfString:@"0x" withString:@""];
        }
        prikeyHexStr = WalletapiWifKeyToHex(prikeyStr);
    }
    NSError *error;
    // 传主链
    
   if([[PWDataBaseManager shared] checkExistRememberCode:prikeyHexStr])
   {
       [self showCustomMessage:@"私钥已存在".localized  hideAfterDelay:2.0];
       return;
   }
   if([[PWDataBaseManager shared] checkExistWalletName:self.walletNameTextField.text])
   {
       [self showCustomMessage:@"钱包名称已存在".localized  hideAfterDelay:2.0];
       return;
   }
    
    [self closeKeyBoard];
    [self showProgressWithMessage:@""];
    [self addCoinIntoWallet:prikeyHexStr andAddress:address];
    
    
}

- (void)addCoinIntoWallet:(NSString *)prikeyHexStr andAddress:(NSString *)address
{
    NSArray *array = [[NSArray alloc] init];
    if([address hasPrefix:@"1"]){
        // BTY找回地址
        array = @[@"BTY"];
    }else if ([address hasPrefix:@"0x"]){
        // YCC找回地址
        array = @[@"YCC"];
    }
    
    NSDictionary *param = @{@"names":array};
    WEAKSELF
    [[SGNetWork defaultManager] sendRequestMethod:HTTPMethodPOST
                                        serverUrl:WalletURL
                                          apiPath:HOMECOININDEX
                                       parameters:param
                                         progress:nil
                                          success:^(BOOL isSuccess, id  _Nullable responseObject) {
       
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
        NSArray *priceArray = result[@"data"];
        [weakSelf addCoinDetailOperation:priceArray prikeyHexKey:prikeyHexStr address:address];
        
    } failure:^(NSString * _Nullable errorMessage) {
        
    }];
    
}

/**
 * 获取到推荐币种后的操作
 */
- (void)addCoinDetailOperation:(NSArray *)coinArray  prikeyHexKey:(NSString *)prikeyHexkey address:(NSString *)address
{
    if ([self addWalletIntoDB:prikeyHexkey])
    {
        
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showCustomMessage:@"钱包创建失败".localized  hideAfterDelay:2.0];
            return ;
            
        });
        
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
            #if DouziWallet || STOWallet
            if ([dic[@"recommend"] isEqualToString:@"2"]) {
                coin.coin_show = 0;
            }
            #endif
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
                
                [GoFunction muImpAddr:[NSArray arrayWithArray:muArr]];
                
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



- (BOOL)addWalletIntoDB:(NSString *)prkeyHexStr
{
    LocalWallet *wallet = [[LocalWallet alloc] init];
       //下面使用kvc是为了不产生警告
    wallet.wallet_name = [self valueForKeyPath:@"walletNameTextField.text"];
    wallet.wallet_password = [GoFunction passwordhash:[self valueForKeyPath:@"setWalletPwdTextField.text"]];
    wallet.wallet_remembercode = [GoFunction enckey:prkeyHexStr password:[self valueForKeyPath:@"setWalletPwdTextField.text"]];
    wallet.wallet_totalassets = 0;
    wallet.wallet_issmall = 4; // 找回钱包
       
    LocalWallet *selectedWallet = [[PWDataBaseManager shared] queryWalletIsSelected];
    selectedWallet.wallet_isselected = 0;
    self.oldWallet = selectedWallet;
       
    [[PWDataBaseManager shared] updateWallet:selectedWallet];
    wallet.wallet_isbackup = 1;
    wallet.wallet_isselected = 1;
    wallet.wallet_issetpwd = 1;
    return [[PWDataBaseManager shared] addWallet:wallet];
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
