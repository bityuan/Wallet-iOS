//
//  CreateWalletSecondViewController.m
//  PWallet
//
//  Created by 宋刚 on 2018/5/23.
//  Copyright © 2018年 陈健. All rights reserved.
//

#import "CreateWalletSecondViewController.h"
#import "BackUpWalletViewController.h"

@interface CreateWalletSecondViewController ()
@property (nonatomic,strong)UILabel *titleLab;
@property (nonatomic,strong)UILabel *topTipLab;
@property (nonatomic,strong)UIView *midView;
@property (nonatomic,strong)UILabel *codeLab;

@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UIButton *changeCodeBtn;
@property (nonatomic, strong) UIButton *okBtn;
@property (nonatomic,strong)YYLabel *bottomTip;

@property (nonatomic,copy)NSString *englishCode;
@property (nonatomic,copy)NSString *chineseCode;
@end

@implementation CreateWalletSecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.showMaskLine = false;
    [self createView];
    [self initRememberCode];
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setHidden:NO];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    UIColor *backColor = CMColorFromRGB(0x333649);
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
    self.navigationController.navigationBar.barTintColor = UIColor.whiteColor;
    self.navigationController.navigationBar.backgroundColor = UIColor.whiteColor;
   
}

- (void)createView
{
    UIColor *backColor = CMColorFromRGB(0x333649);
    UIColor *lineColor = CMColorFromRGB(0x7a90ff);

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

  
    UILabel *titleLab = [[UILabel alloc] init];
    titleLab.font = [UIFont boldSystemFontOfSize:30];
    titleLab.textColor = CMColorFromRGB(0xFFFFFF);
    titleLab.textAlignment = NSTextAlignmentLeft;
    titleLab.text = @"备份助记词".localized;
    titleLab.numberOfLines = 0;
    [self.view addSubview:titleLab];
    self.titleLab = titleLab;
    
    UILabel *topTipLab = [[UILabel alloc] init];
    topTipLab.text = @"请务必妥善保存助记词，确定之后将进行校验".localized;
    topTipLab.font = [UIFont systemFontOfSize:14];
    topTipLab.textColor = SGColorRGBA(142, 146, 163, 1);
    topTipLab.textAlignment = NSTextAlignmentCenter;
    topTipLab.numberOfLines = 0;
    [self.view addSubview:topTipLab];
    self.topTipLab = topTipLab;
    
    UIView *midView = [[UIView alloc] init];
    midView.backgroundColor = backColor;
    midView.layer.borderColor = CMColorFromRGB(0xFFFFFF).CGColor;
    midView.layer.borderWidth = 0.5;
    midView.layer.cornerRadius = 3.f;
    midView.clipsToBounds = YES;
    [self.view addSubview:midView];
    self.midView = midView;
    
    UILabel *codeLab = [[UILabel alloc] init];
    codeLab.font = [UIFont boldSystemFontOfSize:18];
    codeLab.textColor = CMColorFromRGB(0xFFFFFF);
    codeLab.text = @"床前明 月光疑 是地上 霜举头 望明月";
    codeLab.textAlignment = NSTextAlignmentCenter;
    codeLab.numberOfLines = 0;
    codeLab.preferredMaxLayoutWidth = kScreenWidth - 30;
    codeLab.translatesAutoresizingMaskIntoConstraints = NO;
    [midView addSubview:codeLab];
    self.codeLab = codeLab;
    
    UIView *bottomView = [[UIView alloc] init];
    bottomView.backgroundColor = CMColorFromRGB(0x2B292F);
    [self.view addSubview:bottomView];
    self.bottomView = bottomView;
    
    YYLabel *bottomTip = [[YYLabel alloc] init];
    bottomTip.text = @"提示：请勿直接截图保存！如果有人获取你的助记词将直接获取您的资产！\n\n正确做法：\n\n方式一：使用另一离线设备，拍照保存。\n方式二：正确抄写助记词，存放在安全的地方。\n\n点击［开始备份］后，需要对你记住的助记词进行校验。".localized;
    bottomTip.numberOfLines = 0;
    bottomTip.font = [UIFont systemFontOfSize:13];;
    bottomTip.textColor = CMColorFromRGB(0xFFFFFF);
    [self.bottomView addSubview:bottomTip];
    self.bottomTip = bottomTip;
    
    UIButton *changeCodeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [changeCodeBtn setTitle:@"更换助记词".localized forState:UIControlStateNormal];
    [changeCodeBtn setTitleColor:CMColorFromRGB(0xFFFFFF) forState:UIControlStateNormal];
    changeCodeBtn.titleLabel.font = [UIFont systemFontOfSize:17];
    changeCodeBtn.layer.borderColor = CMColorFromRGB(0xFFFFFF).CGColor;
    changeCodeBtn.layer.borderWidth = 0.5;
    changeCodeBtn.layer.cornerRadius = 6.f;
    changeCodeBtn.clipsToBounds = YES;
    [self.bottomView addSubview:changeCodeBtn];
    self.changeCodeBtn = changeCodeBtn;
    [changeCodeBtn addTarget:self action:@selector(initRememberCode) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *okBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [okBtn setTitle:@"开始备份".localized forState:UIControlStateNormal];
    okBtn.backgroundColor = lineColor;
    [okBtn setTitleColor:CMColorFromRGB(0xFFFFFF) forState:UIControlStateNormal];
    okBtn.titleLabel.font = [UIFont systemFontOfSize:17];
    okBtn.layer.cornerRadius = 6.f;
    okBtn.clipsToBounds = YES;
    [self.bottomView addSubview:okBtn];
    [okBtn addTarget:self action:@selector(okBtnClickAction) forControlEvents:UIControlEventTouchUpInside];
    self.okBtn = okBtn;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).with.offset(15);
        make.height.mas_equalTo(42);
         make.width.mas_offset(kScreenWidth * 0.5);
        make.top.equalTo(self.view).with.offset(20);
        
    }];
    
    [self.topTipLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).with.offset(15);
        make.right.equalTo(self.view).with.offset(-15);
        make.top.equalTo(self.titleLab.mas_bottom).with.offset(30);
    }];
    
    [self.midView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(100);
        make.left.equalTo(self.view).offset(15);
        make.right.equalTo(self.view).offset(-15);
        make.top.equalTo(self.topTipLab.mas_bottom).with.offset(20);
    }];
    [self.codeLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.midView).with.offset(10);
        make.right.equalTo(self.midView).with.offset(-10);
        make.top.bottom.equalTo(self.midView);
    }];
    
    if (IS_BLANK(self.chineseCode)) {
        [self initRememberCode];
    } else {
        self.codeLab.textAlignment = NSTextAlignmentCenter;
        self.codeLab.text = self.chineseCode;// [self rehandleChineseCode:self.chineseCode];
        NSLog(@"self.codelab.text is %@",self.codeLab.text);
    }
    
    
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view).with.offset(0);
        make.top.equalTo(self.midView.mas_bottom).offset(70);
    }];
    
    CGRect rect = [self.bottomTip.text boundingRectWithSize:CGSizeMake(kScreenWidth - 30, MAXFLOAT)
                                                    options:NSStringDrawingUsesLineFragmentOrigin
                                                 attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13]}
                                                    context:nil];
    
    [self.bottomTip mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).with.offset(15);
        make.right.equalTo(self.view).with.offset(-15);
        make.height.mas_equalTo(rect.size.height+ 5);
       
        make.top.equalTo(self.bottomView.mas_top).with.offset(35);
    }];
    
    CGFloat width = (SCREENBOUNDS.size.width - 60)/2;
    
    CGFloat bottomSpace = -60;
    
    [self.changeCodeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).with.offset(15);
        make.bottom.equalTo(self.view).with.offset(bottomSpace);
        make.width.mas_equalTo(width);
        make.height.mas_equalTo(44);
    }];
    
    [self.okBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view).with.offset(-15);
        make.bottom.equalTo(self.view).with.offset(bottomSpace);
        make.width.mas_equalTo(width);
        make.height.mas_equalTo(44);
    }];
    
}



#pragma mark-
#pragma mark 类方法
/**
 * 确定按钮点击事件
 */
- (void)okBtnClickAction{
//    BackUpChineseViewController *vc = [[BackUpChineseViewController alloc] init];
//    vc.chineseCode = self.chineseCode;
//    vc.walletName = self.walletName;
//    vc.password = self.password;
//    vc.labCode = self.codeLab.text;
//    vc.parentFrom = ParentViewControllerFromKeyCreateWallet;
//    [self.navigationController pushViewController:vc animated:YES];
    
    BackUpWalletViewController *vc = [[BackUpWalletViewController alloc] init];
    vc.englishCode = self.chineseCode;
    vc.walletName = self.walletName;
    vc.password = self.password;
    vc.parentFrom = ParentViewControllerFromKeyCreateWallet;
    [self.navigationController pushViewController:vc animated:YES];
}

/**
 * 生成助记码
 */
- (void)initRememberCode{
    NSError *error;
    NSString *rememberCode;
    rememberCode = WalletapiNewMnemonicString(0, 128, &error);
    self.chineseCode = rememberCode;
    self.codeLab.text = rememberCode; //[self rehandleChineseCode:rememberCode];
    self.codeLab.font = [UIFont systemFontOfSize:19];
    self.codeLab.textAlignment = NSTextAlignmentCenter;
}

/**
 * 对生成的中文助记词重新处理
 */
- (NSString *)rehandleChineseCode:(NSString *)chineseCode
{
    NSMutableString *str = [@"" mutableCopy];
    for (int i = 0; i < chineseCode.length; i ++) {
        NSString *indexStr = [chineseCode substringWithRange:NSMakeRange(i, 1)];
        if (![indexStr isEqualToString:@" "]) {
            [str appendString:indexStr];
        }
    }
    [str insertString:@"  " atIndex:12];
    [str insertString:@"  " atIndex:9];
    [str insertString:@"  " atIndex:6];
    [str insertString:@"  " atIndex:3];
    
    return str;
}
@end
