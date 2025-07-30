//
//  PWWalletForgetPwdViewController.m
//  PWallet
//
//  Created by 郑晨 on 2021/3/5.
//  Copyright © 2021 陈健. All rights reserved.
//

#import "PWWalletForgetPwdViewController.h"
#import "PWDataBaseManager.h"
#import "PWWalletForgetPwdTwoViewController.h"

@interface PWWalletForgetPwdViewController ()
<UITextViewDelegate>

@property (nonatomic, strong) UITextView *addressTextView; // 助记词
@property (nonatomic, strong) UILabel *palceHoldLab; // 占位符
@property (nonatomic, strong) UILabel *addressTipLab;// 提示语
@property (nonatomic, strong) UILabel *mnemonicWordTipLab;
@property (nonatomic, strong) UIButton *importBtn; // 导入按钮

@end

@implementation PWWalletForgetPwdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"校验助记词".localized;
    self.view.backgroundColor = UIColor.whiteColor;
    self.showMaskLine = false;
    
    [self initView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)initView
{
    _addressTextView = [[UITextView alloc] init];
    _addressTextView.font = [UIFont systemFontOfSize:16.f];
    _addressTextView.textColor = SGColorFromRGB(0x333649);
    _addressTextView.backgroundColor = SGColorFromRGB(0xf8f8fa);
    _addressTextView.layer.cornerRadius = 5.f;
    _addressTextView.textAlignment = NSTextAlignmentLeft;
    _addressTextView.delegate = self;
    _addressTextView.contentInset = UIEdgeInsetsMake(15, 14, 0, 0);
    
    [self.view addSubview:_addressTextView];

    _palceHoldLab = [[UILabel alloc] init];
    _palceHoldLab.textColor = SGColorFromRGB(0x8e92a3);
    _palceHoldLab.font = [UIFont systemFontOfSize:16.f];
    _palceHoldLab.text = @"请输入助记词，用空格分隔".localized;
    _palceHoldLab.textAlignment = NSTextAlignmentLeft;
    _palceHoldLab.numberOfLines = 0;
    
    [self.view addSubview:_palceHoldLab];

    UILabel *addressTipLab = [[UILabel alloc] init];
    addressTipLab.textColor = SGColorFromRGB(0x7a90ff);
    addressTipLab.textAlignment = NSTextAlignmentCenter;
    addressTipLab.font = [UIFont systemFontOfSize:14];
    addressTipLab.text = @"钱包支持导入所有遵循BIP标准生成的助记词".localized;
    addressTipLab.numberOfLines = 0;
    [self.view addSubview:addressTipLab];
    self.addressTipLab = addressTipLab;
    
    UILabel *mnemonicWordTipLab = [[UILabel alloc] init];
    mnemonicWordTipLab.text = @"请输入助记词，用空格分隔".localized;
    mnemonicWordTipLab.textAlignment = NSTextAlignmentCenter;
    mnemonicWordTipLab.textColor = TipRedColor;
    mnemonicWordTipLab.font = [UIFont systemFontOfSize:12];
    [self.view addSubview:mnemonicWordTipLab];
    self.mnemonicWordTipLab = mnemonicWordTipLab;
    [mnemonicWordTipLab setHidden: YES];
    
    UIButton *createWalletBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [createWalletBtn setTitle:@"开始校验".localized forState:UIControlStateNormal];
    createWalletBtn.backgroundColor = CMColorFromRGB(0x333649);
    [createWalletBtn setTitleColor:CMColorFromRGB(0xFFFFFF) forState:UIControlStateNormal];
    createWalletBtn.titleLabel.font = [UIFont systemFontOfSize:17];
    createWalletBtn.layer.cornerRadius = 6.f;
    createWalletBtn.clipsToBounds = YES;
    [self.view addSubview:createWalletBtn];
    self.importBtn = createWalletBtn;
    [createWalletBtn addTarget:self action:@selector(verMnem:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.addressTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(16);
        make.right.equalTo(self.view).offset(-16);
        make.top.equalTo(self.view).offset(20);
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

    [self.importBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.addressTextView);
        make.height.mas_equalTo(44);
        make.top.equalTo(self.addressTextView.mas_bottom).offset(85);
    }];
}


- (void)verMnem:(UIButton *)sender
{
    if (self.addressTextView.text.length == 0) {
        self.mnemonicWordTipLab.hidden = NO;
        return;
    }
    NSString *mnemonicWordStr = [PWUtils removeSpaceAndNewline:self.addressTextView.text];
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
        [self verMnemonic:str];
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
            [self verMnemonic:self.addressTextView.text];
        }
        else
        {
            [self showCustomMessage:@"校验失败".localized hideAfterDelay:2.f];
            return;
        }
    }
}

- (void)verMnemonic:(NSString *)Mnem
{
    NSError *error;
    WalletapiHDWallet *hdWallet = WalletapiNewWalletFromMnemonic_v2(@"BTY",Mnem,&error);
    NSString *btyPubkey = [[hdWallet newKeyPub:0 error:&error] hexString];
    NSArray *coinArray = [[PWDataBaseManager shared] queryCoinArrayBasedOnSelectedWalletID];
    NSMutableArray *marray = [[NSMutableArray alloc] init];
    for (LocalCoin *coin in coinArray) {
        [marray addObject:coin.coin_pubkey];
    }
    
    if ([marray containsObject:btyPubkey])
    {
        // 校验成功
        [self showCustomMessage:@"校验成功".localized hideAfterDelay:2.f];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            PWWalletForgetPwdTwoViewController *fortwoVC = [[PWWalletForgetPwdTwoViewController alloc] init];
            fortwoVC.wallet = self.localWallet;
            fortwoVC.mnemonicStr = self.addressTextView.text;
            
            [self.navigationController pushViewController:fortwoVC animated:YES];
        });
        
    }
    else
    {
        // 校验失败
        [self showCustomMessage:@"校验失败".localized hideAfterDelay:2.f];
    }
    
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
