//
//  CreateWalletViewController.m
//  PWallet
//
//  Created by 宋刚 on 2018/5/23.
//  Copyright © 2018年 陈健. All rights reserved.
//

#import "CreateWalletViewController.h"
#import "NSString+CommonUseTool.h"
#define MAS_SHORTHAND_GLOBALS
#import "LTSafeKeyboard.h"
#import "CommonTextField.h"
#import "WalletTipViewController.h"

@interface CreateWalletViewController ()<UITextFieldDelegate>
@property (nonatomic,strong)UILabel *titleLab;
@property (nonatomic,strong)UIScrollView *scrollView;
@property (nonatomic,strong)CommonTextField *walletNameText;
@property (nonatomic, strong) UILabel *promptPwdLab;
@property (nonatomic,strong)CommonTextField *PwdText;
@property (nonatomic,strong)CommonTextField *PwdAgainText;
@property (nonatomic,strong)UILabel *tipLab;
@property (nonatomic,strong)UILabel *pwdTipLab;
@property (nonatomic,strong)UILabel *nameTipLab;
@property (nonatomic,strong) UIButton *createWalletBtn;
@property (nonatomic, strong) UILabel *walletNameLab;
@end

@implementation CreateWalletViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.showMaskLine = false;
    [ self createView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)createView{
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    [self.view addSubview:scrollView];
    self.scrollView = scrollView;
    scrollView.backgroundColor = [UIColor whiteColor];

    UILabel *titleLab = [[UILabel alloc] init];
    titleLab.font = [UIFont boldSystemFontOfSize:28];
    titleLab.textColor = TextColor51;
    titleLab.textAlignment = NSTextAlignmentLeft;
    titleLab.text = @"创建钱包".localized;
    [scrollView addSubview:titleLab];
    self.titleLab = titleLab;
    
    UILabel *walletNameLab = [[UILabel alloc]init];
    walletNameLab.font = [UIFont systemFontOfSize:14.f];
    walletNameLab.textColor = SGColorFromRGB(0x8e92a3);
    walletNameLab.textAlignment = NSTextAlignmentLeft;
    walletNameLab.text = @"钱包名称".localized;
    [scrollView addSubview:walletNameLab];
    self.walletNameLab = walletNameLab;
    
    //设置钱包名称
    NSInteger maxID = [[PWDataBaseManager shared] queryMaxWalletId];
    CommonTextField *walletNameText = [[CommonTextField alloc] init];
    walletNameText.placeholder = @"设置钱包名称".localized;
    walletNameText.textColor = SGColorRGBA(51, 54, 73, 1);
    walletNameText.font = [UIFont systemFontOfSize:18];
    walletNameText.text = [NSString stringWithFormat:@"%@%li",@"钱包".localized,(long)maxID + 1];
    [scrollView addSubview:walletNameText];
    walletNameText.keyboardType = UIKeyboardTypeDefault;
    walletNameText.delegate = self;
    self.walletNameText = walletNameText;
    [walletNameText addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [walletNameText setAttributedPlaceholderDefault];
    [walletNameText setValue:CMColorFromRGB(0xD9DCE9) forKeyPath:@"placeholderLabel.textColor"];
    
    //请输入8～16位字符 提示
    UILabel *promptPwdLab = [[UILabel alloc] init];
    promptPwdLab.text = @"设置钱包密码 8-16位数字、字母组合".localized;
    promptPwdLab.font = [UIFont systemFontOfSize:14];
    promptPwdLab.textAlignment = NSTextAlignmentLeft;
    promptPwdLab.textColor = SGColorRGBA(51, 54, 73, 1);
    promptPwdLab.numberOfLines = 0;
    [scrollView addSubview:promptPwdLab];
    self.promptPwdLab = promptPwdLab;
    [promptPwdLab setHidden:YES];
    
    //请输入密码
    CommonTextField *PwdText = [[CommonTextField alloc] init];
    PwdText.placeholder = @"请输入密码".localized;
    PwdText.keyboardType = UIKeyboardTypeASCIICapable;
    PwdText.secureTextEntry = YES;
    PwdText.textColor = SGColorRGBA(51, 54, 73, 1);
    PwdText.font = [UIFont systemFontOfSize:18];
    PwdText.delegate = self;
    [scrollView addSubview:PwdText];
    self.PwdText = PwdText;
    [PwdText addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [PwdText setAttributedPlaceholderDefault];
    [PwdText setValue:CMColorFromRGB(0xD9DCE9) forKeyPath:@"placeholderLabel.textColor"];
    LTSafeKeyboard *keyboard = [LTSafeKeyboard focusOnTextFiled:PwdText keyboardType:LTKeyboardTypeLetter];
    keyboard.showHintBubble = YES;
    
    //请重新输入密码
    CommonTextField *PwdAgainText = [[CommonTextField alloc] init];
    PwdAgainText.placeholder = @"请重新输入密码".localized;
    PwdAgainText.keyboardType = UIKeyboardTypeASCIICapable;
    PwdAgainText.secureTextEntry = YES;
    PwdAgainText.delegate = self;
    PwdText.tag = 100;
    PwdAgainText.textColor = SGColorRGBA(51, 54, 73, 1);
    PwdAgainText.font = [UIFont systemFontOfSize:18];
    [scrollView addSubview:PwdAgainText];
    self.PwdAgainText = PwdAgainText;
    [PwdAgainText addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [PwdAgainText setAttributedPlaceholderDefault];
    [PwdAgainText setValue:CMColorFromRGB(0xD9DCE9) forKeyPath:@"placeholderLabel.textColor"];
    LTSafeKeyboard *keyboard1 = [LTSafeKeyboard focusOnTextFiled:PwdAgainText keyboardType:LTKeyboardTypeLetter];
    keyboard1.showHintBubble = YES;

    if (@available(iOS 11.0, *)) {
        PwdText.textContentType = UITextContentTypeName;
        PwdAgainText.textContentType = UITextContentTypeName;
    }
    
    //请输入8～16位字符
    UILabel *tipLab = [[UILabel alloc] init];
    tipLab.text = @"请输入8～16位数字、字母组合".localized;
    tipLab.font = [UIFont systemFontOfSize:13];;
    tipLab.textColor = ErrorColor;
    tipLab.textAlignment = NSTextAlignmentRight;
    [scrollView addSubview:tipLab];
    self.tipLab = tipLab;
    [tipLab setHidden:YES];
    
    //两次密码不相同
    UILabel *pwdTipLab = [[UILabel alloc] init];
    pwdTipLab.textColor = TipRedColor;
    pwdTipLab.textAlignment = NSTextAlignmentRight;
    pwdTipLab.font = [UIFont systemFontOfSize:13];
    pwdTipLab.text = @"";
    [scrollView addSubview:pwdTipLab];
    self.pwdTipLab = pwdTipLab;
    [pwdTipLab setHidden:NO];
    
    //两次密码不相同
    UILabel *nameTipLab = [[UILabel alloc] init];
    nameTipLab.textColor = TipRedColor;
    nameTipLab.textAlignment = NSTextAlignmentRight;
    nameTipLab.font = [UIFont systemFontOfSize:13];
    nameTipLab.text = @"";
    [scrollView addSubview:nameTipLab];
    self.nameTipLab = nameTipLab;
    [nameTipLab setHidden:NO];
    
    UIButton *createWalletBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [createWalletBtn setTitle:@"创建钱包".localized forState:UIControlStateNormal];
    createWalletBtn.backgroundColor = CMColorFromRGB(0x5D6377);
    [createWalletBtn setTitleColor:CMColorFromRGB(0xFFFFFF) forState:UIControlStateNormal];
    createWalletBtn.titleLabel.font = [UIFont systemFontOfSize:17];
    createWalletBtn.layer.cornerRadius = 6.f;
    createWalletBtn.clipsToBounds = YES;
    [self.view addSubview:createWalletBtn];
    self.createWalletBtn = createWalletBtn;
    [createWalletBtn addTarget:self action:@selector(createWalletAction) forControlEvents:UIControlEventTouchUpInside];
    [createWalletBtn setEnabled:YES];
    
    [walletNameText setKeyBoardInputView:createWalletBtn action:@selector(createWalletAction)];
    [PwdText setKeyBoardInputView:createWalletBtn action:@selector(createWalletAction)];
    [PwdAgainText setKeyBoardInputView:createWalletBtn action:@selector(createWalletAction)];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(400);
        make.top.equalTo(self.view).with.offset(0);
    }];
    
    [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.scrollView).with.offset(15+3);
        make.right.equalTo(self.scrollView).with.offset(-15);
        make.top.equalTo(self.scrollView).with.offset(20);
        make.height.mas_equalTo(40);
    }];
    
    
    [self.walletNameLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleLab);
        make.top.equalTo(self.titleLab.mas_bottom).offset(39);
        make.height.mas_equalTo(20);
    }];
    
    [self.walletNameText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.scrollView).with.offset(15+3);
        make.width.mas_equalTo(SCREENBOUNDS.size.width - 36);
        make.height.mas_equalTo(50);
        make.top.equalTo(self.titleLab.mas_bottom).with.offset(60);
    }];
    
    [self.promptPwdLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.scrollView).with.offset(15);
        make.width.mas_equalTo(SCREENBOUNDS.size.width - 30);
        make.height.mas_equalTo(20);
        
        make.top.equalTo(self.walletNameText.mas_bottom).with.offset(10);
    }];
    
    [self.PwdText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.scrollView).with.offset(15+3);
        make.width.mas_equalTo(SCREENBOUNDS.size.width - 36);
        make.height.mas_equalTo(50);
        make.top.equalTo(self.walletNameText.mas_bottom).with.offset(30);
    }];
    
    [self.PwdAgainText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.scrollView).with.offset(15+3);
        make.width.mas_equalTo(SCREENBOUNDS.size.width - 36);
        make.height.mas_equalTo(50);
        make.top.equalTo(self.PwdText.mas_bottom).with.offset(30);
    }];
    
    [self.tipLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.PwdText.mas_bottom).with.offset(5);
        make.width.mas_equalTo(SCREENBOUNDS.size.width - 30);
        make.left.equalTo(self.scrollView).with.offset(15);
        make.height.mas_equalTo(13);
    }];
    
    [self.pwdTipLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.PwdAgainText.mas_bottom).with.offset(5);
        make.width.mas_equalTo(SCREENBOUNDS.size.width - 30);
        make.left.equalTo(self.scrollView).with.offset(15);
        make.height.mas_equalTo(13);
    }];
    
    
    [self.nameTipLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.walletNameText.mas_bottom).with.offset(5);
        make.width.mas_equalTo(SCREENBOUNDS.size.width - 30);
        make.left.equalTo(self.scrollView).with.offset(15);
        make.height.mas_equalTo(13);
    }];
    
    CGFloat topSpace = 50;
    
    [self.createWalletBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).with.offset(15);
        make.right.equalTo(self.view).with.offset(-15);
        make.height.mas_equalTo(44);
        make.top.equalTo(self.scrollView.mas_bottom).with.offset(topSpace);
    }];
}

#pragma mark - UITextField Delegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    if (textField.tag == 100) {
        self.promptPwdLab.hidden = NO;
    }
    CommonTextField *textF = (CommonTextField *)textField;
    textF.lineColor = CMColorFromRGB(0x333649);
    [textF setNeedsDisplay];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    if (textField.tag == 100) {
        self.promptPwdLab.hidden = YES;
    }
    
    CommonTextField *textF = (CommonTextField *)textField;
    textF.lineColor = CMColorFromRGB(0xCED7E0);
    [textF setNeedsDisplay];
}

#pragma mark-
#pragma mark 类方法
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField.text.length + string.length > 16) {
        return NO;
    }
    return YES;
}

/**
 * 监听TextField的输入
 */
-(void)textFieldDidChange :(UITextField *)theTextField{
    
    
    if (theTextField == self.walletNameText) {
        
    }else if (theTextField == self.PwdText)
    {
        
    }else if (theTextField == self.PwdAgainText)
    {
        
    }
}

- (BOOL)allTextWriten
{
    NSString *walletNameText = self.walletNameText.text;
    NSString *pwdText = self.PwdText.text;
    NSString *pwdAgainText = self.PwdAgainText.text;
    if ([walletNameText isEqualToString:@""] || [pwdText isEqualToString:@""] || [pwdAgainText isEqualToString:@""]) {
        return NO;
    }else{
        if ([pwdText isEqualToString:pwdAgainText]) {
            return YES;
        }else{
            return NO;
        }
    }
}

/**
 * 创建钱包点击事件
 */
- (void)createWalletAction
{
    NSString *walletNameText = self.walletNameText.text;
    NSString *pwdText = self.PwdText.text;
    NSString *pwdAgainText = self.PwdAgainText.text;
    if ([walletNameText isEqualToString:@""]) {
        self.nameTipLab.text = @"请设置钱包名称！".localized;
    }
    if(![pwdText isRightPassword])
    {
        self.tipLab.hidden = NO;
    }else {
        self.tipLab.hidden = YES;
    }
    
    if([[PWDataBaseManager shared] checkExistWalletName:walletNameText])
    {
        [self showCustomMessage:@"钱包名称已存在".localized hideAfterDelay:2.0];
        return;
    }
    
    if ([pwdText isEqualToString:pwdAgainText] && ![walletNameText isEqualToString:@""]) {
        self.pwdTipLab.text = @"";
        if ([pwdText isRightPassword]  && [pwdAgainText isRightPassword]) {
            WalletTipViewController *vc = [[WalletTipViewController alloc] init];
            vc.walletName = walletNameText;
            vc.password = pwdText;
            [self.navigationController pushViewController:vc animated:YES];
        }
       
    }else{
        self.pwdTipLab.text = @"两次密码不相同".localized;
    }
}

@end
