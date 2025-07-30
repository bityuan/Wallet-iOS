//
//  ImportPriKeyViewController.m
//  PWallet
//
//  Created by 郑晨 on 2019/10/21.
//  Copyright © 2019 陈健. All rights reserved.
//

#import "ImportPriKeyViewController.h"
#import "PWChoiceChainViewController.h"
#import "CommonTextField.h"
#import "NSString+CommonUseTool.h"
#import "PWDataBaseManager.h"
#import <Walletapi/Walletapi.h>
#import "LocalWallet.h"
#import "LTSafeKeyboard.h"

@interface ImportPriKeyViewController ()
<UITextViewDelegate,UITextFieldDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIButton *choiceChainBtn; // 选择主链按钮
@property (nonatomic, strong) UILabel *addressTipLab;// 私钥提示语
@property (nonatomic, strong) UILabel *walletNameLab; // 钱包名称
@property (nonatomic, strong) CommonTextField *walletNameTextField;// 钱包名称
@property (nonatomic, strong) CommonTextField *setWalletPwdTextField; // 设置钱包密码
@property (nonatomic, strong) UILabel *promptPwdLab;
@property (nonatomic, strong) CommonTextField *confirWalletPwdTextField; // 确认钱包密码
@property (nonatomic, strong) UILabel *tipLab;
@property (nonatomic, strong) UILabel *pwdTipLab;
@property (nonatomic, strong) UILabel *nameTipLab;
@property (nonatomic, strong) UIButton *importBtn; // 导入按钮
@property (nonatomic, strong) NSString *chainName; // 主链名字
@property (nonatomic, strong) NSString *coinName;// 币的名字
@property (nonatomic, strong) UILabel *chainLab; // 主链：
@property (nonatomic, strong) UIImageView *logoImageView; // 主链图标
@property (nonatomic, strong) UILabel *chainNameLab; // 主链名称

@property (nonatomic,strong)LocalWallet *oldWallet;

@end

@implementation ImportPriKeyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.whiteColor;
     self.showMaskLine = false;
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
   
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
}



- (void)initView
{
    _scrollView = [[UIScrollView alloc] init];

    [self.view addSubview:_scrollView];

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
    
    
    [self.scrollView addSubview:_choiceChainBtn];

    
    _chainLab = [[UILabel alloc] init];
    _chainLab.text = @"主链:".localized ;
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
    
    [self.scrollView addSubview:_addressTextView];

    
    _palceHoldLab = [[UILabel alloc] init];
    _palceHoldLab.textColor = SGColorFromRGB(0x8e92a3);
    _palceHoldLab.font = [UIFont systemFontOfSize:16.f];
    _palceHoldLab.text = @"请输入私钥或者扫描私钥生成的二维码录入".localized ;
    _palceHoldLab.textAlignment = NSTextAlignmentLeft;
    _palceHoldLab.numberOfLines = 0;
    [self.scrollView addSubview:_palceHoldLab];

    UILabel *addressTipLab = [[UILabel alloc] init];
    addressTipLab.textColor = TipRedColor;
    addressTipLab.textAlignment = NSTextAlignmentLeft;
    addressTipLab.font = CMTextFont13;
    addressTipLab.text = @"请输入私钥或者扫描私钥生成的二维码录入".localized ;
    addressTipLab.numberOfLines = 0;
    [self.scrollView addSubview:addressTipLab];
    self.addressTipLab = addressTipLab;
    [addressTipLab setHidden:YES];
    
    _walletNameLab = [[UILabel alloc] init];
    _walletNameLab.text = @"钱包名称".localized ;
    _walletNameLab.textColor = SGColorFromRGB(0x8e92a3);
    _walletNameLab.textAlignment = NSTextAlignmentLeft;
    _walletNameLab.font = [UIFont systemFontOfSize:14.f];

    [self.scrollView addSubview:_walletNameLab];
    //设置钱包名称
    NSInteger maxID = [[PWDataBaseManager shared] queryMaxWalletId];
    CommonTextField *walletNameText = [[CommonTextField alloc] init];
    walletNameText.textColor = CMColorFromRGB(0x333649);
    walletNameText.placeholder = @"设置钱包名称".localized ;
    [walletNameText setValue:CMColorFromRGB(0x8E92A3) forKeyPath:@"placeholderLabel.textColor"];
    walletNameText.text = [NSString stringWithFormat:@"%@%li",@"钱包".localized ,(long)maxID + 1];
    walletNameText.delegate = self;
    [self.scrollView addSubview:walletNameText];
    self.walletNameTextField = walletNameText;
    [walletNameText setAttributedPlaceholderDefault];
    
    //请输入8～16位字符 提示
    UILabel *promptPwdLab = [[UILabel alloc] init];
    promptPwdLab.text = @"设置钱包密码 8-16位数字、字母组合".localized ;
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
    PwdText.placeholder = @"请设置钱包密码".localized ;
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
    PwdAgainText.placeholder = @"确认钱包密码".localized ;
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
       
    
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    self.scrollView.contentSize = CGSizeMake(SCREENBOUNDS.size.width,scrollViewHeight);

    [self.choiceChainBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.scrollView).offset(20);
        make.left.equalTo(self.scrollView).offset(18);
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
        make.height.mas_equalTo(13);
        
    }];
    
    [self.palceHoldLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.addressTextView).offset(9);
        make.top.equalTo(self.addressTextView).offset(23);
        make.right.equalTo(self.addressTextView).offset(-10);
        make.height.mas_equalTo(20);
        
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

#pragma mark - 导入钱包
- (void)createWalletAction
{
    NSLog(@"我要导入钱包啦");
    
    NSString *walletNameText = self.walletNameTextField.text;
    NSString *pwdText = self.setWalletPwdTextField.text;
    NSString *pwdAgainText = self.confirWalletPwdTextField.text;
        
    if (self.chainNameLab.text.length == 0
        || self.chainNameLab.text == nil) {
        [self showCustomMessage:@"请选择主链".localized  hideAfterDelay:2.f];
        
        return;
    }
    
    
    if ([walletNameText isEqualToString:@""]) {
        self.nameTipLab.text = @"请设置钱包名称！".localized ;
        return;
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
    NSString *prikeyStr = [PWUtils removeSpaceAndNewline:self.addressTextView.text];
    
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
    NSData *pubKeyData = WalletapiPrivkeyToPub_v2(self.chainName, WalletapiHexTobyte(prikeyHexStr), &error);
    if (!pubKeyData) {
        [self showCustomMessage:@"私钥有误".localized  hideAfterDelay:2.f];
        return;
    }
    NSString *address = WalletapiPubToAddress_v2(self.chainName, pubKeyData, &error);
    if (!address) {
        [self showCustomMessage:@"私钥有误".localized  hideAfterDelay:2.f];
        return;
    }
    NSLog(@"chain is %@,address is %@", self.chainName, address);
    
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
    [self addCoinIntoWallet:prikeyHexStr andAddress:address pubkey:pubKeyData];
    
    
}

- (void)addCoinIntoWallet:(NSString *)prikeyHexStr andAddress:(NSString *)address pubkey:(NSData *)pubkey
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
        [weakSelf addCoinDetailOperation:priceArray prikeyHexKey:prikeyHexStr address:address pubkey:pubkey];
        
    } failure:^(NSString * _Nullable errorMessage) {
        
    }];
    
}

/**
 * 获取到推荐币种后的操作
 */
- (void)addCoinDetailOperation:(NSArray *)coinArray  prikeyHexKey:(NSString *)prikeyHexkey address:(NSString *)address pubkey:(NSData *)pubkey
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
            coin.coin_pubkey = [pubkey hexString];
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
    wallet.wallet_issmall = 2; // 导入私钥创建的钱包
       
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
