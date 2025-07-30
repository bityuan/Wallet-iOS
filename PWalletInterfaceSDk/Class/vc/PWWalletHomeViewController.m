//
//  PWWalletHomeViewController.m
//  PWalletInterfaceSDk
//
//  Created by 郑晨 on 2022/5/17.
//

#import "PWWalletHomeViewController.h"
#import "PWNFTViewController.h"
#import "PWNewsHomeViewController.h"
#import "CAPSPageMenu.h"
#import "PWSwitchWalletViewController.h"
#import "PWNewsWalletSettingViewController.h"
#import "PWNewsSearchCoinViewController.h"
#import "CreateRecoverWalletViewController.h"
#import "ChoiceWalletTypeViewController.h"

@interface PWWalletHomeViewController ()
<CAPSPageMenuDelegate>

@property (nonatomic, strong) CAPSPageMenu *pageMenu;
@property (nonatomic, strong) PWNewsHomeViewController *homeVC;
@property (nonatomic, strong) PWNFTViewController *nftVC;
@property(nonatomic,strong)LocalWallet *homeWallet; // 当前钱包
@property (nonatomic, strong) UILabel *assetLab;
/** 当前钱包的wallet_id */
@property(nonatomic,assign)NSInteger walletId;

@end

@implementation PWWalletHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"助记词钱包".localized;
    self.showMaskLine = NO;
    self.view.backgroundColor = SGColorFromRGB(0xf8f8fa);
    self.navigationItem.rightBarButtonItem = [self rightBarButtonItem];
    self.homeWallet = [[PWDataBaseManager shared] queryWalletIsSelected];
    [self initView];
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (@available(iOS 13.0, *)) {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    } else {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    }
}

- (void)initView{
   
    [self createView];
    
    self.homeVC = [[PWNewsHomeViewController alloc]init];
    self.homeVC.title = @"资产".localized;
   
//    self.homeVC.homeViewBlock = ^{
//        // 不显示人民币
//      [weakSelf caculateTotalAsset];
//    };
    self.nftVC = [[PWNFTViewController alloc]init];
    self.nftVC.title = @"NFT";
    
    NSArray *vcArray = [NSArray arrayWithObjects:self.homeVC,self.nftVC, nil];
   
    NSDictionary *parameters = @{
                                 CAPSPageMenuOptionBottomMenuHairlineColor: SGColorRGBA(246, 248, 250, 1),
                                 CAPSPageMenuOptionScrollMenuBackgroundColor: SGColorFromRGB(0xf8f8fa),
                                 CAPSPageMenuOptionSelectionIndicatorHeight: @(2),
                                 CAPSPageMenuOptionMenuItemWidth: @(75),
                                 CAPSPageMenuOptionMenuItemFont: [UIFont systemFontOfSize:15],
                                 CAPSPageMenuOptionUnselectedMenuItemLabelColor: SGColorRGBA(153, 153, 153, 1),
                                 CAPSPageMenuOptionSelectedMenuItemLabelColor: MainColor,
                                 CAPSPageMenuOptionSelectionIndicatorColor: MainColor
                                 };
    self.pageMenu = [[CAPSPageMenu alloc] initWithViewControllers:vcArray frame:CGRectMake(0, PageVCNavBarHeight + 90, kScreenWidth, kScreenHeight - PageVCNavBarHeight - 90) options:parameters];
    self.pageMenu.delegate = self;
    [self addChildViewController:self.pageMenu];
    
    [self.view addSubview:self.pageMenu.view];
}


- (void)createView
{
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 150)];
    headView.backgroundColor = SGColorFromRGB(0xf8f8fa);
    [self.view addSubview:headView];
    
    UIImageView *bgImgView = [[UIImageView alloc] init];
    bgImgView.image = [UIImage imageNamed:@"home_hd_bg"];

    [headView addSubview:bgImgView];

    UILabel *titleLab = [[UILabel alloc]init];
    titleLab.font = [UIFont systemFontOfSize:14.f];
    titleLab.textColor = SGColorRGBA(255, 255, 255, .7f);
    titleLab.textAlignment = NSTextAlignmentLeft;
    [headView addSubview:titleLab];

    UIButton *moreBtn = [[UIButton alloc] init];
    [moreBtn setImage:[UIImage imageNamed:@"home_more"] forState:UIControlStateNormal];
    [moreBtn setContentMode:UIViewContentModeScaleAspectFit];
    [moreBtn addTarget:self action:@selector(showMore:) forControlEvents:UIControlEventTouchUpInside];

    [headView addSubview:moreBtn];

    UIImageView *iconImageView = [[UIImageView alloc] init];
    iconImageView.contentMode = UIViewContentModeScaleAspectFit;
    iconImageView.hidden = YES;
    [headView addSubview:iconImageView];

    UILabel *assetLab = [[UILabel alloc]init];
    assetLab.font = [UIFont systemFontOfSize:36.f];
    assetLab.textColor = SGColorFromRGB(0xffffff);
    assetLab.textAlignment = NSTextAlignmentLeft;
    [headView addSubview:titleLab];
    [headView addSubview:assetLab];
    self.assetLab = assetLab;
    
    UIButton *addCoinBtn = [[UIButton alloc] init];
    [addCoinBtn setImage:[UIImage imageNamed:@"home_addcoin"] forState:UIControlStateNormal];
    [addCoinBtn addTarget:self action:@selector(toSearchVC:) forControlEvents:UIControlEventTouchUpInside];
    [addCoinBtn setContentMode:UIViewContentModeScaleAspectFit];
    
    [headView addSubview:addCoinBtn];
    
    titleLab.text = [NSString stringWithFormat:@"%@",self.homeWallet.wallet_name];

    [bgImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(headView).offset(16);
        make.right.equalTo(headView).offset(-16);
        make.top.equalTo(headView).offset(10);
        make.height.mas_equalTo(130);
    }];

    [titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(headView).offset(36);
        make.top.equalTo(headView).offset(20);
        make.height.mas_equalTo(20);
    }];


    [moreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(headView).offset(-36);
        make.top.equalTo(headView).offset(10);
        make.width.mas_equalTo(21);
        make.height.mas_equalTo(25);
    }];
    
    [assetLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(headView).offset(36);
        make.right.equalTo(moreBtn);
        make.height.mas_equalTo(42);
        make.top.equalTo(titleLab.mas_bottom).offset(8);
    }];
    
    [addCoinBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(headView).offset(-30);
        make.width.height.mas_equalTo(36 * kScreenRatio);
        make.top.equalTo(headView).offset(78);
    }];
}


- (void)caculateTotalAsset
{
    double totalAssest = [[PWDataBaseManager shared] caculateTotalAssets:_homeWallet];
    _homeWallet.wallet_totalassets = totalAssest;
   self.assetLab.text = [NSString stringWithFormat:@"%.2f", totalAssest];
}

- (void)showMore:(UIButton *)sender
{
    PWNewsWalletSettingViewController *settingVC = [[PWNewsWalletSettingViewController alloc] init];
    settingVC.localWallet = self.homeWallet;
    settingVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:settingVC animated:YES];
}

- (UIBarButtonItem *)rightBarButtonItem
{
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [btn setImage:[UIImage imageNamed:@"home_switch"] forState:UIControlStateNormal];
    [btn setContentMode:UIViewContentModeScaleAspectFit];
    btn.tag = 2;
    [btn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];

    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:btn];

    return item;
}//折渔般  峡鸣活  薄待移  通元等  绳汗物

- (void)btnAction:(UIButton *)sender
{
    ChoiceWalletTypeViewController *vc = [[ChoiceWalletTypeViewController alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
    return;
    [self.navigationController pushViewController:[self createPWMyWalletVCWithSwitchType:SwitchWalletTypeSwitch] animated:YES];
}

- (UIViewController *)createPWMyWalletVCWithSwitchType:(SwitchWalletType)switchWalletType
{
    PWSwitchWalletViewController *switchVC = [[PWSwitchWalletViewController alloc] init];
    switchVC.switchWalletType = switchWalletType; // 切换钱包
    switchVC.hidesBottomBarWhenPushed = YES;
    switchVC.refreshHomeView = ^(NSInteger walletId) {
        self.walletId = walletId;
        [self initView];
    };
    return switchVC;
}



#pragma mark - 去添加币种
- (void)toSearchVC:(UIButton *)sender
{
    

    PWNewsSearchCoinViewController *newsSearchVC = [[PWNewsSearchCoinViewController alloc] init];
    newsSearchVC.hidesBottomBarWhenPushed = YES;
    newsSearchVC.selectedWallet = self.homeWallet;
//    newsSearchVC.localArray = self.localArray;
    [self.navigationController pushViewController:newsSearchVC animated:YES];
    
}

#pragma mark -- CAPSPageMenuDelegate
- (void)didMoveToPage:(UIViewController *)controller index:(NSInteger)index
{
    NSLog(@"did move index is %li",(long)index);
   
}

- (void)willMoveToPage:(UIViewController *)controller index:(NSInteger)index
{
    NSLog(@"will move index is %li",(long)index);
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
