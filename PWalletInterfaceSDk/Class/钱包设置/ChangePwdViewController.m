//
//  ChangePwdViewController.m
//  PWallet
//
//  Created by 宋刚 on 2018/6/4.
//  Copyright © 2018年 陈健. All rights reserved.
//

#import "ChangePwdViewController.h"
#import "NSString+CommonUseTool.h"

@interface ChangePwdViewController ()<UITextFieldDelegate>
{
    BOOL _enableClick;
}
@property (nonatomic,strong)UIScrollView *scrollView;
@property (nonatomic,strong)CommonTextField *oldPwdtext;
@property (nonatomic,strong)CommonTextField *pwdText;
@property (nonatomic,strong)CommonTextField *pwdAgainText;
@property (nonatomic,strong)BlueButton *sureBtn;
@property (nonatomic,strong)UILabel *tipLab;
@property (nonatomic,strong)UILabel *pwdWrongError;
@property (nonatomic,strong)UILabel *pwdDiffError;
@end

@implementation ChangePwdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _enableClick = YES;
    [self createView];
    
    //  添加观察者，监听键盘弹出
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardDidShow:) name:UIKeyboardWillShowNotification object:nil];
    //  添加观察者，监听键盘收起
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardDidHide:) name:UIKeyboardWillHideNotification object:nil];
    
}

- (void)keyBoardDidShow:(NSNotification*)notifiction {
    if(isIPhone6P || isIPhoneXSeries) {
        
    }else{
        self.sureBtn.alpha = 0;
    }
}

- (void)keyBoardDidHide:(NSNotification*)notification {
    if(isIPhone6P || isIPhoneXSeries) {
        
    }else{
        self.sureBtn.alpha = 1;
    }
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (@available(iOS 13.0, *))
    {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDarkContent;
    }
    else
    {
               // Fallback on earlier versions
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    }
}

- (void)createView{
    self.title = @"修改密码".localized;
    self.view.backgroundColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTintColor:TextColor51];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: CMColorRGBA(51,51,51,1),NSFontAttributeName : [UIFont boldSystemFontOfSize:18]};
    
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    [self.view addSubview:scrollView];
    self.scrollView = scrollView;
    scrollView.backgroundColor = [UIColor whiteColor];
    
    //请输入旧密码
    CommonTextField *oldPwdText = [[CommonTextField alloc] init];
    oldPwdText.placeholder = @"请输入旧密码".localized;
    oldPwdText.keyboardType = UIKeyboardTypeEmailAddress;
    oldPwdText.delegate = self;
    oldPwdText.textColor = SGColorRGBA(51, 54, 73, 1);
    oldPwdText.secureTextEntry = YES;
    [scrollView addSubview:oldPwdText];
    self.oldPwdtext = oldPwdText;
    [oldPwdText setAttributedPlaceholderDefault];
    
    //请输入新密码
    CommonTextField *pwdText = [[CommonTextField alloc] init];
    pwdText.placeholder = @"请输入新密码".localized;
    pwdText.delegate = self;
    pwdText.textColor = SGColorRGBA(51, 54, 73, 1);
    pwdText.keyboardType = UIKeyboardTypeEmailAddress;
    pwdText.secureTextEntry = YES;
    [scrollView addSubview:pwdText];
    self.pwdText = pwdText;
    [pwdText setAttributedPlaceholderDefault];
    
    //重新输入新密码
    CommonTextField *pwdAgainText = [[CommonTextField alloc] init];
    pwdAgainText.placeholder = @"重新输入新密码".localized;
    pwdAgainText.delegate = self;
    pwdAgainText.textColor = SGColorRGBA(51, 54, 73, 1);
    pwdAgainText.keyboardType = UIKeyboardTypeEmailAddress;
    pwdAgainText.secureTextEntry = YES;
    [scrollView addSubview:pwdAgainText];
    self.pwdAgainText = pwdAgainText;
    [pwdAgainText setAttributedPlaceholderDefault];
    
    if (@available(iOS 11.0, *)) {
        oldPwdText.textContentType = UITextContentTypeName;
        pwdText.textContentType = UITextContentTypeName;
        pwdAgainText.textContentType = UITextContentTypeName;
    }
    
    BlueButton *sureBtn = [[BlueButton alloc] init];
    [sureBtn setTitle:@"确定".localized forState:UIControlStateNormal];
     [sureBtn setBackgroundColor:SGColorFromRGB(0x333649)];
    [sureBtn addTarget:self action:@selector(sureBtnClickAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:sureBtn];
    self.sureBtn = sureBtn;
    
    //请输入8～16位字符
    UILabel *tipLab = [[UILabel alloc] init];
    tipLab.text = @"8-16位数字、字母组合".localized;
    tipLab.font = [UIFont systemFontOfSize:14];
    tipLab.textColor = SGColorRGBA(142, 146, 163, 1);
    tipLab.textAlignment = NSTextAlignmentLeft;
    [scrollView addSubview:tipLab];
    self.tipLab = tipLab;
    
    //密码错误
    UILabel *pwdWrongError = [[UILabel alloc] init];
    pwdWrongError.textColor = SGColorRGBA(234, 37, 81, 1);
    pwdWrongError.font = [UIFont systemFontOfSize:13];
    pwdWrongError.textAlignment = NSTextAlignmentLeft;
    pwdWrongError.text = @"";
    [scrollView addSubview:pwdWrongError];
    self.pwdWrongError = pwdWrongError;
    [pwdWrongError setHidden:NO];
    
    //两次密码不相同
    UILabel *pwdDiffError = [[UILabel alloc] init];
    pwdDiffError.textColor = SGColorRGBA(234, 37, 81, 1);
    pwdDiffError.font = [UIFont systemFontOfSize:13];
    pwdDiffError.textAlignment = NSTextAlignmentLeft;
    pwdDiffError.text = @"";
    [scrollView addSubview:pwdDiffError];
    self.pwdDiffError = pwdDiffError;
    [pwdDiffError setHighlighted:NO];
    
    if(isIPhone6P || isIPhoneXSeries)
    {
        
    }else{
        [oldPwdText setKeyBoardInputView:sureBtn action:@selector(sureBtnClickAction)];
        [pwdText setKeyBoardInputView:sureBtn action:@selector(sureBtnClickAction)];
        [pwdAgainText setKeyBoardInputView:sureBtn action:@selector(sureBtnClickAction)];
    }
}



- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(300);
        make.top.equalTo(self.view).with.offset(0);
    }];
    
    [self.oldPwdtext mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).with.offset(15);
        make.right.equalTo(self.view).with.offset(-15);
        make.height.mas_equalTo(50);
        make.top.equalTo(self.scrollView).with.offset(40);
    }];
    
    [self.pwdText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).with.offset(15);
        make.right.equalTo(self.view).with.offset(-15);
        make.height.mas_equalTo(50);
        make.top.equalTo(self.oldPwdtext.mas_bottom).with.offset(30);
    }];
    
    [self.pwdAgainText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).with.offset(15);
        make.right.equalTo(self.view).with.offset(-15);
        make.height.mas_equalTo(50);
        make.top.equalTo(self.pwdText.mas_bottom).with.offset(30);
    }];
    
    [self.sureBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).with.offset(15);
        make.right.equalTo(self.view).with.offset(-15);
        make.height.mas_equalTo(44);
        make.top.equalTo(self.pwdAgainText.mas_bottom).with.offset(50);
    }];
    
    [self.tipLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.pwdText.mas_top);
        make.width.mas_equalTo(SCREENBOUNDS.size.width - 30);
        make.left.equalTo(self.scrollView).with.offset(15);
        make.height.mas_equalTo(13);
    }];
    
    [self.pwdWrongError mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.oldPwdtext.mas_top);
        make.width.mas_equalTo(SCREENBOUNDS.size.width - 30);
        make.left.equalTo(self.scrollView).with.offset(15);
        make.height.mas_equalTo(13);
    }];
    
    [self.pwdDiffError mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.pwdAgainText.mas_top);
        make.width.mas_equalTo(SCREENBOUNDS.size.width - 30);
        make.left.equalTo(self.scrollView).with.offset(15);
        make.height.mas_equalTo(13);
    }];
}

/**
 * 确定按钮点击事件
 */
- (void)sureBtnClickAction
{
    if (_enableClick == NO) {
        return;
    }
    _enableClick = NO;
    NSString *rightPwd = self.wallet.wallet_password;
    NSString *oldPwd = self.oldPwdtext.text;
    NSString *newPwd = self.pwdText.text;
    NSString *newAgainPwd = self.pwdAgainText.text;
    
    BOOL oldPwdIsRight = NO;
    if ([GoFunction checkPassword:oldPwd hash:rightPwd]) {
        self.pwdWrongError.text = @"";
        oldPwdIsRight = YES;
    }else{
        self.pwdWrongError.text = @"密码错误".localized;
        oldPwdIsRight = NO;
    }
    
    if (![newPwd isRightPassword]) {
        self.tipLab.textColor = SGColorRGBA(234, 37, 81, 1);
    }else
    {
        self.tipLab.textColor = PlaceHolderColor;
    }
    
    if ([newPwd isEqualToString:newAgainPwd])
    {
        self.pwdDiffError.text = @"";
    }else
    {
        self.pwdDiffError.text = @"两次密码不相同".localized;
    }
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSString *gamePwd = appDelegate.gamePwdStr;
    NSInteger gameWalletId = appDelegate.gameWalletId;
    
    if (oldPwdIsRight && [newPwd isEqualToString:newAgainPwd] && [newPwd isRightPassword]) {
        self.wallet.wallet_password = [GoFunction passwordhash:self.pwdText.text];
        
        NSString *rememberCode = [GoFunction deckey:self.wallet.wallet_remembercode password:oldPwd];
        NSString *newRememberCode = [GoFunction enckey:rememberCode password:self.pwdText.text];
        
        if(![newRememberCode isEqualToString:@""] && ![rememberCode isEqualToString:@""])
        {
            self.wallet.wallet_remembercode = newRememberCode;
            BOOL result = [[PWDataBaseManager shared] updateWallet:self.wallet];
            if (result) {
                
                if (![gamePwd isEqual:[NSNull null]] ) {
                    if (gameWalletId == self.wallet.wallet_id) {
                        appDelegate.gamePwdStr = self.pwdText.text;
                        appDelegate.gameWalletId = -1;
                    }
                }
                self.wallet.wallet_issetpwd = 1;
                [self showCustomMessage:@"密码修改成功".localized hideAfterDelay:3.0];
                [self.navigationController popViewControllerAnimated:YES];
                _enableClick = YES;
            }
        }else{
            _enableClick = YES;
            [self showCustomMessage:@"密码重复设置".localized hideAfterDelay:3.0];
        }
    }else
    {
        _enableClick = YES;
    }
}

#pragma mark-
#pragma mark UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField.text.length + string.length > 16) {
        return NO;
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    CommonTextField *textF = (CommonTextField *)textField;
    textF.lineColor = CMColorFromRGB(0x333649);
    [textF setNeedsDisplay];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    CommonTextField *textF = (CommonTextField *)textField;
    textF.lineColor = CMColorFromRGB(0xCED7E0);
    [textF setNeedsDisplay];
}
@end
