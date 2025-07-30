//
//  PWWalletForgetPwdTwoViewController.m
//  PWallet
//
//  Created by 郑晨 on 2021/3/5.
//  Copyright © 2021 陈健. All rights reserved.
//

#import "PWWalletForgetPwdTwoViewController.h"
#import "NSString+CommonUseTool.h"
#import "PWDataBaseManager.h"

@interface PWWalletForgetPwdTwoViewController ()
<UITextFieldDelegate>

@property (nonatomic,strong)CommonTextField *pwdText;
@property (nonatomic,strong)CommonTextField *pwdAgainText;
@property (nonatomic,strong)BlueButton *sureBtn;
@property (nonatomic,strong)UILabel *tipLab;
@property (nonatomic,strong)UILabel *pwdWrongError;
@property (nonatomic,strong)UILabel *pwdDiffError;

@end

@implementation PWWalletForgetPwdTwoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self createView];
}

- (void)createView{
    self.title = @"设置密码".localized;
    self.view.backgroundColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTintColor:TextColor51];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: CMColorRGBA(51,51,51,1),NSFontAttributeName : [UIFont boldSystemFontOfSize:18]};
    
    //请输入新密码
    CommonTextField *pwdText = [[CommonTextField alloc] init];
    pwdText.placeholder = @"请输入新密码".localized;
    pwdText.delegate = self;
    pwdText.keyboardType = UIKeyboardTypeEmailAddress;
    pwdText.secureTextEntry = YES;
    [self.view addSubview:pwdText];
    self.pwdText = pwdText;
    [pwdText setAttributedPlaceholderDefault];
    
    //重新输入新密码
    CommonTextField *pwdAgainText = [[CommonTextField alloc] init];
    pwdAgainText.placeholder = @"重新输入新密码".localized;
    pwdAgainText.delegate = self;
    pwdAgainText.keyboardType = UIKeyboardTypeEmailAddress;
    pwdAgainText.secureTextEntry = YES;
    [self.view addSubview:pwdAgainText];
    self.pwdAgainText = pwdAgainText;
    [pwdAgainText setAttributedPlaceholderDefault];
    
    if (@available(iOS 11.0, *)) {
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
    [self.view addSubview:tipLab];
    self.tipLab = tipLab;
    
    //密码错误
    UILabel *pwdWrongError = [[UILabel alloc] init];
    pwdWrongError.textColor = SGColorRGBA(234, 37, 81, 1);
    pwdWrongError.font = [UIFont systemFontOfSize:13];
    pwdWrongError.textAlignment = NSTextAlignmentLeft;
    pwdWrongError.text = @"";
    [self.view addSubview:pwdWrongError];
    self.pwdWrongError = pwdWrongError;
    [pwdWrongError setHidden:NO];
    
    //两次密码不相同
    UILabel *pwdDiffError = [[UILabel alloc] init];
    pwdDiffError.textColor = SGColorRGBA(234, 37, 81, 1);
    pwdDiffError.font = [UIFont systemFontOfSize:13];
    pwdDiffError.textAlignment = NSTextAlignmentLeft;
    pwdDiffError.text = @"";
    [self.view addSubview:pwdDiffError];
    self.pwdDiffError = pwdDiffError;
    [pwdDiffError setHighlighted:NO];
    
    if(isIPhone6P || isIPhoneXSeries)
    {
        
    }else{
        [pwdText setKeyBoardInputView:sureBtn action:@selector(sureBtnClickAction)];
        [pwdAgainText setKeyBoardInputView:sureBtn action:@selector(sureBtnClickAction)];
    }
}



- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    [self.pwdText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).with.offset(15);
        make.right.equalTo(self.view).with.offset(-15);
        make.height.mas_equalTo(50);
        make.top.equalTo(self.view).with.offset(30);
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
        make.left.equalTo(self.view).with.offset(15);
        make.height.mas_equalTo(13);
    }];
    
    [self.pwdDiffError mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.pwdAgainText.mas_top);
        make.width.mas_equalTo(SCREENBOUNDS.size.width - 30);
        make.left.equalTo(self.view).with.offset(15);
        make.height.mas_equalTo(13);
    }];
}

/**
 * 确定按钮点击事件
 */
- (void)sureBtnClickAction
{
    NSString *newPwd = self.pwdText.text;
    NSString *newAgainPwd = self.pwdAgainText.text;
    
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

    if ([newPwd isEqualToString:newAgainPwd] && [newPwd isRightPassword]) {
        self.wallet.wallet_password = [GoFunction passwordhash:self.pwdText.text];
        
        NSString *newRememberCode = [GoFunction enckey:self.mnemonicStr password:self.pwdText.text];
        
        if(![newRememberCode isEqualToString:@""] && ![self.mnemonicStr isEqualToString:@""])
        {
            self.wallet.wallet_remembercode = newRememberCode;
            BOOL result = [[PWDataBaseManager shared] updateWallet:self.wallet];
            if (result) {
                self.wallet.wallet_issetpwd = 1;
                [self showCustomMessage:@"新密码设置成功".localized hideAfterDelay:3.0];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self.navigationController popToRootViewControllerAnimated:YES];
                });
                
            }
        }
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
