//
//  PWImportWalletViewController.m
//  PWallet
//
//  Created by 郑晨 on 2019/11/4.
//  Copyright © 2019 陈健. All rights reserved.
//

#import "PWImportWalletViewController.h"
#import "CommonTextField.h"
#import "NSString+CommonUseTool.h"
#import "LocalWallet.h"
#import "AppDelegate.h"
#import "PWDataBaseManager.h"
#import <Walletapi/Walletapi.h>
#import "PWNewsHomeViewController.h"
#import "LTSafeKeyboard.h"
#import "PreCoin.h"

@interface PWImportWalletViewController ()
<UITextViewDelegate,UITextFieldDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UILabel *addressTipLab;// 提示语
@property (nonatomic, strong) UILabel *mnemonicWordTipLab;
@property (nonatomic, strong) UILabel *walletNameLab; // 钱包名称
@property (nonatomic, strong) CommonTextField *walletNameTextField;// 钱包名称
@property (nonatomic, strong) CommonTextField *setWalletPwdTextField; // 设置钱包密码
@property (nonatomic, strong) UILabel *promptPwdLab;
@property (nonatomic, strong) CommonTextField *confirWalletPwdTextField; // 确认钱包密码
@property (nonatomic, strong) UILabel *tipLab;
@property (nonatomic, strong) UILabel *pwdTipLab;
@property (nonatomic, strong) UILabel *nameTipLab;
@property (nonatomic, strong) UIButton *importBtn; // 导入按钮

@property (nonatomic,strong)LocalWallet *oldWallet;

@end

@implementation PWImportWalletViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.whiteColor;
    self.showMaskLine = false;
    [self initView];
    self.title = @"导入钱包".localized;
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

    _addressTextView = [[UITextView alloc] init];
    _addressTextView.font = [UIFont systemFontOfSize:16.f];
    _addressTextView.textColor = SGColorFromRGB(0x333649);
    _addressTextView.backgroundColor = SGColorFromRGB(0xf8f8fa);
    _addressTextView.layer.cornerRadius = 5.f;
    _addressTextView.textAlignment = NSTextAlignmentLeft;
    _addressTextView.delegate = self;
    _addressTextView.contentInset = UIEdgeInsetsMake(15, 14, 0, 0);
    
    [self.scrollView addSubview:_addressTextView];

    _palceHoldLab = [[UILabel alloc] init];
    _palceHoldLab.textColor = SGColorFromRGB(0x8e92a3);
    _palceHoldLab.font = [UIFont systemFontOfSize:16.f];
    _palceHoldLab.text = @"请输入助记词，用空格分隔".localized;
    _palceHoldLab.textAlignment = NSTextAlignmentLeft;
    _palceHoldLab.numberOfLines = 0;
    
    [self.scrollView addSubview:_palceHoldLab];

    UILabel *addressTipLab = [[UILabel alloc] init];
    addressTipLab.textColor = SGColorFromRGB(0x7a90ff);
    addressTipLab.textAlignment = NSTextAlignmentCenter;
    addressTipLab.font = [UIFont systemFontOfSize:14.f];
    _palceHoldLab.text = @"请输入助记词，用空格分隔".localized;;
    addressTipLab.text = @"钱包支持导入所有遵循BIP标准生成的助记词".localized;
    
    addressTipLab.numberOfLines = 0;
    [self.scrollView addSubview:addressTipLab];
    self.addressTipLab = addressTipLab;
    
    UILabel *mnemonicWordTipLab = [[UILabel alloc] init];
    mnemonicWordTipLab.text = @"请输入助记词，用空格分隔".localized;
    mnemonicWordTipLab.textAlignment = NSTextAlignmentCenter;
    mnemonicWordTipLab.textColor = TipRedColor;
    mnemonicWordTipLab.font = [UIFont systemFontOfSize:14];
    _palceHoldLab.text = @"请输入助记词，用空格分隔".localized;;
    [self.scrollView addSubview:mnemonicWordTipLab];
    self.mnemonicWordTipLab = mnemonicWordTipLab;
    [mnemonicWordTipLab setHidden: YES];
    
    _walletNameLab = [[UILabel alloc] init];
    _walletNameLab.text = @"钱包名称".localized;
    _walletNameLab.textColor = SGColorFromRGB(0x8e92a3);
    _walletNameLab.textAlignment = NSTextAlignmentLeft;
    _walletNameLab.font = [UIFont systemFontOfSize:14.f];

    [self.scrollView addSubview:_walletNameLab];
    //设置钱包名称
    NSInteger maxID = [[PWDataBaseManager shared] queryMaxWalletId];
    CommonTextField *walletNameText = [[CommonTextField alloc] init];
    walletNameText.textColor = CMColorFromRGB(0x333649);
    walletNameText.placeholder = @"设置钱包名称".localized;
    [walletNameText setValue:CMColorFromRGB(0x8E92A3) forKeyPath:@"placeholderLabel.textColor"];
    walletNameText.text = [NSString stringWithFormat:@"%@%li",@"钱包".localized,(long)maxID + 1];
    walletNameText.delegate = self;
    [self.scrollView addSubview:walletNameText];
    self.walletNameTextField = walletNameText;
    [walletNameText setAttributedPlaceholderDefault];

    //请输入8～16位字符 提示
    UILabel *promptPwdLab = [[UILabel alloc] init];
    promptPwdLab.text = @"设置钱包密码 8-16位数字、字母组合".localized;
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
    PwdText.placeholder = @"请设置钱包密码".localized;
    PwdText.keyboardType = UIKeyboardTypeASCIICapable;
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
    PwdAgainText.placeholder = @"确认钱包密码".localized;
    PwdAgainText.keyboardType = UIKeyboardTypeASCIICapable;
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
    tipLab.text = @"请输入8～16位数字、字母组合".localized;
    tipLab.font = [UIFont systemFontOfSize:13];
    tipLab.textColor = ErrorColor;
    tipLab.textAlignment = NSTextAlignmentRight;
    [self.scrollView addSubview:tipLab];
    self.tipLab = tipLab;
    [tipLab setHidden:YES];

    //两次密码不相同
    UILabel *pwdTipLab = [[UILabel alloc] init];
    pwdTipLab.textColor = TipRedColor;
    pwdTipLab.textAlignment = NSTextAlignmentRight;
    pwdTipLab.font = [UIFont systemFontOfSize:13];
    pwdTipLab.text = @"";
    [self.scrollView addSubview:pwdTipLab];
    self.pwdTipLab = pwdTipLab;
    [pwdTipLab setHidden:NO];

    //两次密码不相同
    UILabel *nameTipLab = [[UILabel alloc] init];
    nameTipLab.textColor = TipRedColor;
    nameTipLab.textAlignment = NSTextAlignmentRight;
    nameTipLab.font = [UIFont systemFontOfSize:13];
    nameTipLab.text = @"";
    [self.scrollView addSubview:nameTipLab];
    self.nameTipLab = nameTipLab;
    [nameTipLab setHidden:NO];

    UIButton *createWalletBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [createWalletBtn setTitle:@"开始导入".localized forState:UIControlStateNormal];
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

    [self.addressTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(16);
        make.right.equalTo(self.view).offset(-16);
        make.top.equalTo(self.scrollView.mas_bottom).offset(20);
        make.height.mas_equalTo(110);
    }];

    [self.addressTipLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.addressTextView);
        make.top.equalTo(self.addressTextView.mas_bottom).offset(16);
        make.height.mas_equalTo(17);
    }];
    
    [self.mnemonicWordTipLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.addressTextView);
        make.top.equalTo(self.addressTextView.mas_bottom);
        make.height.mas_equalTo(16);
    }];
    
    [self.palceHoldLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.addressTextView).offset(18);
        make.right.equalTo(self.addressTextView).offset(-18);
        
        make.height.mas_equalTo(20);
        make.top.equalTo(self.addressTextView).offset(23);
    
    }];

    [self.walletNameLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.addressTextView);
        make.height.mas_equalTo(20);
        make.top.equalTo(self.addressTextView.mas_bottom).offset(85);
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
         make.bottom.equalTo(self.view).with.offset(- 31 - 44);
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
    if (_addressTextView.text.length != 0)
    {
        self.palceHoldLab.hidden = YES;
    }
    else
    {
        if (text.length != 0)
        {
           self.palceHoldLab.hidden = YES;
        }
        else
        {
           self.palceHoldLab.hidden = NO;
        }
        
    }
    
    if ([PWUtils isChineseWithstr:text])
    {
        if (text.length == 0) {
            return YES;
        }
        NSString *textStr = textView.text;
        textStr = [textStr stringByReplacingCharactersInRange:range withString:text];
        textStr = [textStr stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSString *newString = @"";
        while (textStr.length > 0) {
            NSString *subString = [textStr substringToIndex:MIN(textStr.length, 3)];
            newString = [newString stringByAppendingString:subString];
            if (subString.length == 3) {
                newString = [newString stringByAppendingString:@" "];
            }
            textStr = [textStr substringFromIndex:MIN(textStr.length, 3)];
        }
        
        textView.text = newString;
       
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

#pragma mark - 导入钱包
- (void)createWalletAction
{
    NSLog(@"我要导入钱包啦");
    NSString *walletNameText = self.walletNameTextField.text;
    NSString *pwdText = self.setWalletPwdTextField.text;
    NSString *pwdAgainText = self.confirWalletPwdTextField.text;
        
    if ([walletNameText isEqualToString:@""]) {
        self.nameTipLab.text = @"请设置钱包名称！".localized;
        return;
    }
    
    if (_addressTextView.text.length == 0)
    {
       // 提示语
        self.mnemonicWordTipLab.hidden = NO;
        
    }
    else
    {
        self.mnemonicWordTipLab.hidden = YES;
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
         NSString *mnemonicWordStr = [PWUtils removeSpaceAndNewline:self.addressTextView.text];
        if ([pwdText isRightPassword]  && [pwdAgainText isRightPassword])
        {
            // 导入钱包操作
           
            if ([PWUtils isChineseWithstr:mnemonicWordStr])
            {
                // 全中文 ，创建中文助记词钱包
                NSLog(@"is  chinese");
                
                NSString *codeStr = [PWUtils removeSpaceAndNewline:self.addressTextView.text];
                NSMutableString *str = [NSMutableString new];
                for (int i = 0; i < codeStr.length; i ++) {
                    [str appendString:[codeStr substringWithRange:NSMakeRange(i, 1)]];
                    if (i != codeStr.length - 1) {
                        [str appendString:@" "];
                    }
                }
                
                [self createWalletWithRemeberCode:str];
                
            }
            else
            {
                NSString *regex = @"^[A-Za-z]+$";
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
                BOOL result = [predicate evaluateWithObject:mnemonicWordStr];
                if (result)
                {
                    // 全英文
                    NSLog(@"is english");
                    
                    [self createWalletWithRemeberCode:self.addressTextView.text];
                }
                else
                {
                    [self showCustomMessage:@"助记词不存在".localized hideAfterDelay:2.f];
                }
            }
        }
    }
    else
    {
        self.pwdTipLab.text = @"两次密码不相同".localized;
    }
    
}

- (void)closeKeyBoard
{
    [self.view endEditing:YES];
}


#pragma mark - 创建中文钱包
- (void)createWalletWithRemeberCode:(NSString *)remeberCode
{
   
    if([[PWDataBaseManager shared] checkExistRememberCode:remeberCode])
    {
        [self showCustomMessage:@"助记词已存在".localized hideAfterDelay:2.0];
        return;
    }
    if([[PWDataBaseManager shared] checkExistWalletName:self.walletNameTextField.text])
    {
        [self showCustomMessage:@"钱包名称已存在".localized hideAfterDelay:2.0];
        return;
    }
        
    [self closeKeyBoard];
    [self showProgressWithMessage:@""];
    [self addCoinIntoWallet:remeberCode];

        
}

- (BOOL)addWalletIntoDB:(NSString *)rememberCode
{
    LocalWallet *wallet = [[LocalWallet alloc] init];
    //下面使用kvc是为了不产生警告
    wallet.wallet_name = [self valueForKeyPath:@"walletNameTextField.text"];
    wallet.wallet_password = [GoFunction passwordhash:[self valueForKeyPath:@"setWalletPwdTextField.text"]];
    wallet.wallet_remembercode = [GoFunction enckey:rememberCode password:[self valueForKeyPath:@"setWalletPwdTextField.text"]];
    wallet.wallet_totalassets = 0;
    wallet.wallet_issmall = 1;
    
    LocalWallet *selectedWallet = [[PWDataBaseManager shared] queryWalletIsSelected];
    selectedWallet.wallet_isselected = 0;
    self.oldWallet = selectedWallet;
    
    [[PWDataBaseManager shared] updateWallet:selectedWallet];
    wallet.wallet_isbackup = 1;
    wallet.wallet_isselected = 1;
    wallet.wallet_issetpwd = 1;
    return [[PWDataBaseManager shared] addWallet:wallet];
}

/**
 * 添加币到钱包
 */
- (void)addCoinIntoWallet:(NSString *)rememberCode
{
    WEAKSELF
//    NSArray *coinArray = [[PWAppsettings instance] getHomeCoinInfo];
//    if (coinArray != nil) {
//        if ([self addWalletIntoDB:rememberCode]) {
//            
//        }else{
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self showCustomMessage:@"钱包创建失败".localized hideAfterDelay:2.0];
//                return ;
//            });
//        }
//        [weakSelf addCoinDetailOperation:coinArray code:rememberCode];
//    }else{
        
        if ([self addWalletIntoDB:rememberCode]) {
        
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showCustomMessage:@"钱包创建失败".localized hideAfterDelay:2.0];
                return ;
            });
        }
        

        
        NSArray *array = [PreCoin getPreCoinArr];
        
        [weakSelf addCoinDetailOperation:array code:rememberCode];
//    }
}

/**
 * 获取到推荐币种后的操作
 */
- (void)addCoinDetailOperation:(NSArray *)coinArray  code:(NSString *)rememberCode
{
    
    __block NSError *error;
    __block BOOL state = YES;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        // 先拿第一个币种来创建一下钱包，然后导入其他的币
        NSDictionary *dict = coinArray[0];
        NSString *chain = dict[@"chain"];
        WalletapiHDWallet *hdWallets = [GoFunction goCreateHDWallet:chain rememberCode:rememberCode];
        if (hdWallets == nil || [hdWallets isEqual:[NSNull null]])
        {
            // 助记词不正确
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.view endEditing:YES];
                [self deleteFailWallet];
                [self showCustomMessage:@"助记词不存在".localized hideAfterDelay:2.0];
            });
            state = NO;
            return;
        }
        else
        {
            NSData *pubKey = [hdWallets newKeyPub:0 error:&error];
            if ([self haveRemWithPubKey:[pubKey hexString]])
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.view endEditing:YES];
                    [self deleteFailWallet];
                    [self showCustomMessage:@"助记词重复!".localized hideAfterDelay:2.0];
                });
                state = NO;
                return;
            }
           
        }
       
        for (int i = 0; i < coinArray.count; i++) {
            
            
            NSDictionary *dic = [coinArray objectAtIndex:i];
            NSString *coinStr = dic[@"name"];
            if ([coinStr isEqual:[NSNull null]]) {
                break;
            }
            NSString *chains = dic[@"chain"];
            NSString *platStr = dic[@"platform"];
            NSInteger treaty = [dic[@"treaty"] integerValue];
            WalletapiHDWallet *hdWallet = [GoFunction goCreateHDWallet:chains rememberCode:rememberCode];
            // 先判断助记词是不是正确的，再判断助记词是不是已经存在，如果没有则开始创建钱包和加入币种
            
            if (hdWallet == nil || [hdWallet isEqual:[NSNull null]])
            {
                // 助记词不正确
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.view endEditing:YES];
                    [self deleteFailWallet];
                    [self showCustomMessage:@"助记词不存在".localized hideAfterDelay:2.0];
                });
                state = NO;
                break;
            }
            else
            {
                NSData *pubKey = [hdWallet newKeyPub:0 error:&error];

                NSString *address = [GoFunction createAddress:hdWallet coinType:coinStr platform:platStr andTreaty:treaty];
                CGFloat balance = [GoFunction goGetBalance:coinStr platform:platStr address:address andTreaty:treaty];
                LocalCoin *coin = [[LocalCoin alloc] init];
                coin.coin_walletid = [[PWDataBaseManager shared] queryMaxWalletId];
                coin.coin_type = coinStr;
                coin.coin_address = address;
                coin.coin_balance = balance == -1 ? 0 : balance;
                coin.coin_pubkey = [pubKey hexString];
                coin.icon = dic[@"icon"];
                coin.coin_show = 1;
                coin.coin_platform = dic[@"platform"];
                coin.coin_coinid = [dic[@"id"] integerValue];
                coin.treaty = [dic[@"treaty"] integerValue];
                coin.coin_chain = dic[@"chain"];
                coin.coin_type_nft = [dic[@"coin_type_nft"] integerValue];
                [[PWDataBaseManager shared] addCoin:coin];
                
            }
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
                
                [[PWAppsettings instance] deletecurrentCoinsName];
                [[PWAppsettings instance] savecurrentCoinsName:@"2"];
                [[PWAppsettings instance] deleteHomeCoinPrice];
                [[PWAppsettings instance] deleteHomeLocalCoin];
                [[PWAppsettings instance] deleteAddress];
                AppDelegate *appdelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
                appdelegate.type = @"2";
                [appdelegate switchRootViewController];
                
            }
        });
    });
}

- (BOOL)haveRemWithPubKey:(NSString *)key
{
    NSArray *walletArray = [[PWDataBaseManager shared] queryAllWallets];
    for (LocalWallet *wallet in walletArray)
    {
        // 防止出现导入了私钥钱包而出现的助记词重复bug
        if (wallet.wallet_issmall == 2 || wallet.wallet_issmall == 3 || wallet.wallet_isEscrow == 1) {
            continue;
        }
        NSArray *localCoinArray = [[PWDataBaseManager shared] queryCoinArrayBasedOnWallet:wallet];
        for (LocalCoin *coin in localCoinArray) {
            if ([coin.coin_pubkey isEqualToString:key]) {
                return YES;
            }
        }

    }
    return NO;
}

#pragma mark UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField.text.length + string.length > 16) {
        return NO;
    }
    return YES;
}

#pragma mark -- 导入钱包失败之后删除当前钱包
- (void)deleteFailWallet
{
    // 如果有钱包
    [[PWDataBaseManager shared] deleteWallet:[[PWDataBaseManager shared] queryWalletIsSelected]];
    
    NSArray *walletArray = [[PWDataBaseManager shared] queryAllWallets];
    if (walletArray.count > 0) {
        LocalWallet *wallet = [walletArray firstObject];
        wallet.wallet_isselected = 1;
        [[PWDataBaseManager shared] updateWallet:wallet];
    }
    else {
       
    }
}


@end
