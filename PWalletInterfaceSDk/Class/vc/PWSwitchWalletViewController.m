//
//  PWSwitchWalletViewController.m
//  PWallet
//
//  Created by 郑晨 on 2019/11/7.
//  Copyright © 2019 陈健. All rights reserved.
//

#import "PWSwitchWalletViewController.h"
#import "PWSwitchWalletCell.h"
#import "ImportWalletHomeViewController.h"
#import "PWDataBaseManager.h"
#import "LocalWallet.h"
#import "CreateWalletViewController.h"
#import "ImportWalletHomeViewController.h"
#import "PWNewsWalletSettingViewController.h"
#import "NoRecordView.h"
#import "PWChoiceChainViewController.h"
#import "ScanViewController.h"



@interface PWSwitchWalletViewController ()
<UITableViewDelegate,UITableViewDataSource,PWSwitchWalletCellDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UISegmentedControl *segmentControl;
@property (nonatomic, strong) UIView *footView; // 底部view
@property (nonatomic, strong) UIButton *createWalletBtn; // 创建钱包按钮
@property (nonatomic, strong) UIButton *importWalletBtn; // 导入钱包按钮
@property (nonatomic, strong) UIView *lineView; // 底部上的一条线

@property (nonatomic, strong) NSArray *allWalletArray; // 全部钱包
@property (nonatomic, strong) NSArray *normalArray; // 普通钱包+托管钱包
@property (nonatomic, strong) NSArray *observeArray; // 观察钱包
@property (nonatomic, assign) BOOL haveEscrowWallet;
@property (nonatomic, assign) BOOL observeWalletIsCurrentWallet;// 判断地址钱包是否为当前选择的钱包
@property (nonatomic, strong) NoRecordView *noRecodeView;

@property(nonatomic,assign)NSInteger isKJ;//是否开始快捷模式

@end

@implementation PWSwitchWalletViewController
//点击首页右上角进入
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"loginBack"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(backAction)];
    self.view.backgroundColor = [UIColor whiteColor];
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    self.isKJ = [[user objectForKey:@"isKJ"] intValue];
    self.showMaskLine = false;

    [self createTitleView];

    [self.view addSubview:self.tableView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(- 60 - kIphoneXBottomOffset);
    }];
    [self createFootView];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(becomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
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
    
    [self.navigationController.navigationBar lt_setBackgroundColor:UIColor.whiteColor];
    
    [self initData];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.navigationController.navigationBar lt_reset];
}

- (void)backAction
{
   [self.navigationController popViewControllerAnimated:YES];
}

- (void)becomeActive
{
    [self initData];
}

- (void)initData
{
    NSArray *dataArray = [[PWDataBaseManager shared] queryAllWallets];
    NSMutableArray *normalMarray  = [[NSMutableArray alloc] init];
    NSMutableArray *observeMarray = [[NSMutableArray alloc] init];
    _haveEscrowWallet = NO;
    _observeWalletIsCurrentWallet = NO;
    if (dataArray.count > 0)
    {
        for (LocalWallet *wallet in dataArray) {
            
            if (wallet.wallet_issmall == 3)
            {
                // 观察钱包
                if (wallet.wallet_isselected == 1)
                {
                    // 如果观察钱包是当前钱包，那么把该钱包放在第一位
                    _observeWalletIsCurrentWallet = YES;
                    [observeMarray insertObject:wallet atIndex:0];
                }
                else
                {
                    [observeMarray addObject:wallet];
                }

            }
            else
            {
                // 创建导入钱包
                [normalMarray addObject:wallet];

            }
        }
                
        self.normalArray = [NSArray arrayWithArray:normalMarray];
        self.observeArray = [NSArray arrayWithArray:observeMarray];
    }
    else
    {
        self.normalArray  = [[NSArray alloc] init];
        self.observeArray = [[NSArray alloc] init];
    }
    self.allWalletArray = [NSArray arrayWithArray:dataArray];
    if (_switchWalletType == SwitchWalletTypeExplore)
    {
        self.segmentControl.selectedSegmentIndex = 0;
    }
    else
    {
        if (_observeWalletIsCurrentWallet) {
            self.segmentControl.selectedSegmentIndex = 1;
        }
    }
    [self selected:self.segmentControl];

//    if (self.isKJ != 1) {
//        self.segmentControl.selectedSegmentIndex = 0;
//    }
    if (self.isKJ == 1) {
        BOOL isSelect = NO;
        for (LocalWallet *wa in self.normalArray) {
            if (wa.wallet_isselected == 1) {
                isSelect = YES;
            }
        }
        if (isSelect == NO) {
            for (LocalWallet *wa in self.normalArray) {
                if (wa.isKJ == 1) {
                    wa.wallet_isselected = 1;
                }
            }
        }
    }
    [self.tableView reloadData];
}


- (void)createTitleView
{

    NSArray *titleArray = @[@"创建/导入".localized,@"观察钱包".localized];
    _segmentControl = [[UISegmentedControl alloc] initWithItems:titleArray];
    CGFloat width = 180;
    if ([LocalizableService getAPPLanguage] == LanguageEnglish || [LocalizableService getAPPLanguage] == LanguageJapanese || [LocalizableService getAPPLanguage] == LanguageKorean) {
        width = 260;
    }

    _segmentControl.frame = CGRectMake(0, 0, width, 32);
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake((kScreenWidth - _segmentControl.frame.size.width) / 2, 16, _segmentControl.frame.size.width, 32)];
    [_segmentControl setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16.f],NSForegroundColorAttributeName:SGColorFromRGB(0x8e92a3)} forState:UIControlStateNormal];
    [_segmentControl setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16.f],NSForegroundColorAttributeName:SGColorFromRGB(0xffffff)} forState:UIControlStateSelected];
    if (@available(iOS 13, *))
    {
        _segmentControl.selectedSegmentTintColor = SGColorFromRGB(0x333649);
    }
    else
    {
        _segmentControl.tintColor = SGColorFromRGB(0x333649);
    }
       
    _segmentControl.backgroundColor = UIColor.whiteColor;
    _segmentControl.layer.cornerRadius = 5.f;
    _segmentControl.layer.borderColor = SGColorFromRGB(0x8e92a3).CGColor;
    _segmentControl.layer.borderWidth = .5f;
    _segmentControl.selectedSegmentIndex = 0;
       
    [_segmentControl addTarget:self action:@selector(selected:) forControlEvents:UIControlEventValueChanged];
    [titleView addSubview:_segmentControl];
    titleView.backgroundColor = UIColor.clearColor;
    
    
    self.navigationItem.titleView = titleView;
       
}
#pragma mark - 切换钱包类型
- (void)selected:(UISegmentedControl *)segmentedControl
{

    if (segmentedControl.selectedSegmentIndex == 1) {
        if (_observeArray.count == 0)
        {
            _noRecodeView.hidden = NO;
        }
        
        [self.createWalletBtn setTitle:@"导入钱包".localized forState:UIControlStateNormal];
        [self.importWalletBtn setTitle:@"冷钱包导入" forState:UIControlStateNormal];
        self.importWalletBtn.hidden = YES;
        [self.createWalletBtn setImage:nil forState:UIControlStateNormal];
        self.createWalletBtn.backgroundColor = SGColorFromRGB(0x7190ff);
        [self.createWalletBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
       
        
        [self.createWalletBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.footView).offset(46);
            make.right.equalTo(self.footView).offset(-36);
            make.top.equalTo(self.footView).offset(16);
            make.height.mas_equalTo(44);
        
        }];
        
       
    }
    else
    {
        if (_normalArray.count == 0)
        {
            _noRecodeView.hidden = NO;
        }
        else
        {
            _noRecodeView.hidden = YES;
        }
        
        [self.importWalletBtn setTitle:@"导入钱包".localized forState:UIControlStateNormal];
        [self.createWalletBtn setTitle:@"创建钱包".localized forState:UIControlStateNormal];
        [self.createWalletBtn setImage:[UIImage imageNamed:@"build_wallet"] forState:UIControlStateNormal];
        [self.createWalletBtn setTitleColor:SGColorFromRGB(0x7190ff) forState:UIControlStateNormal];
        self.createWalletBtn.backgroundColor = [UIColor whiteColor];
        
        CGFloat width = (kScreenWidth - 75) / 2.f;
        
        [self.createWalletBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.footView).offset(26);
            make.top.equalTo(self.footView).offset(16);
            make.height.mas_equalTo(44);
            make.width.mas_equalTo(width);
        }];
        [self.createWalletBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 7)];
        [self.createWalletBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 7, 0, 0)];
        self.importWalletBtn.hidden = NO;
        [self.importWalletBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.footView).offset(-26);
            
            make.top.width.height.equalTo(self.createWalletBtn);
        }];

    }

    [self.tableView reloadData];
}

- (void)createFootView
{
    _noRecodeView = [[NoRecordView alloc] initWithImage:[UIImage imageNamed:@"notraderecord"] title:@""];
    [self.tableView addSubview:_noRecodeView];
    _noRecodeView.hidden = YES;
    
    _footView = [[UIView alloc] init];
    _footView.backgroundColor = UIColor.whiteColor;
    
    [self.view addSubview:self.footView];
    
    _lineView = [[UIView alloc] init];
    _lineView.backgroundColor = SGColorFromRGB(0xececec);
    
    [_footView addSubview:_lineView];
    
    _createWalletBtn = [[UIButton alloc] init];
    [_createWalletBtn setTitle:@"创建钱包".localized forState:UIControlStateNormal];
    [_createWalletBtn setImage:[UIImage imageNamed:@"build_wallet"] forState:UIControlStateNormal];
    [_createWalletBtn setTitleColor:SGColorFromRGB(0x7190ff) forState:UIControlStateNormal];
    [_createWalletBtn.titleLabel setFont:[UIFont systemFontOfSize:17.f]];
    [_createWalletBtn.layer setCornerRadius:6.f];
    [_createWalletBtn.layer setBorderColor:SGColorFromRGB(0x7190ff).CGColor];
    [_createWalletBtn.layer setBorderWidth:1.f];
    [_createWalletBtn addTarget:self action:@selector(createWallet:) forControlEvents:UIControlEventTouchUpInside];
    [_createWalletBtn setTag:1];
    
    [_footView addSubview:_createWalletBtn];
    
    _importWalletBtn = [[UIButton alloc] init];
    [_importWalletBtn setTitle:@"导入钱包".localized forState:UIControlStateNormal];
    [_importWalletBtn setTitleColor:SGColorFromRGB(0xffffff) forState:UIControlStateNormal];
    [_importWalletBtn.titleLabel setFont:[UIFont systemFontOfSize:17.f]];
    [_importWalletBtn setBackgroundColor:SGColorFromRGB(0x333649)];
    [_importWalletBtn.layer setCornerRadius:6.f];
    [_importWalletBtn addTarget:self action:@selector(importWallet:) forControlEvents:UIControlEventTouchUpInside];
    
    [_footView addSubview:_importWalletBtn];
    
    if ([LocalizableService getAPPLanguage] == LanguageJapanese) {
        [_importWalletBtn.titleLabel setFont:[UIFont systemFontOfSize:12.f]];
        [_createWalletBtn.titleLabel setFont:[UIFont systemFontOfSize:12.f]];
    }
    
    [self.footView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view);
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(60 + kIphoneXBottomOffset);
    }];
    
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.footView);
        make.left.right.equalTo(self.footView);
        make.height.mas_equalTo(.5f);
    }];
    
    CGFloat width = (kScreenWidth - 75) / 2.f;
    
    [self.createWalletBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.footView).offset(26);
        make.top.equalTo(self.footView).offset(16);
        make.height.mas_equalTo(44);
        make.width.mas_equalTo(width);
    }];
    [self.createWalletBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 7)];
    [self.createWalletBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 7, 0, 0)];
    [self.importWalletBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.footView).offset(-26);
        make.top.width.height.equalTo(self.createWalletBtn);
    }];
    
     [self.noRecodeView mas_makeConstraints:^(MASConstraintMaker *make) {
           make.left.equalTo(self.tableView );
           make.top.equalTo(self.tableView);
           make.width.equalTo(self.tableView);
           make.height.equalTo(self.tableView);
    }];

}

#pragma mark - 创建钱包
- (void)createWallet:(UIButton *)sender
{
    //==1观察钱包->普通导入    否则 创建/导入 ->创建钱包
    if (_segmentControl.selectedSegmentIndex == 1){
        PWChoiceChainViewController *choievc = [[PWChoiceChainViewController alloc] init];
        choievc.choiceType = ChoiceTypeAdd;
        [self.navigationController pushViewController:choievc animated:YES];
    }else{
        CreateWalletViewController *vc = [[CreateWalletViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - 导入钱包
- (void)importWallet:(UIButton *)sender
{
    //==1观察钱包->冷钱包导入    否则 创建/导入 ->导入钱包
    if (_segmentControl.selectedSegmentIndex == 1)
    {
        
        ScanViewController *vc = [[ScanViewController alloc] init];
        vc.fromType = 1;
        vc.scanResult = ^(NSString *address) {
//               NSLog(@"address is %@",address);
        };
        [self.navigationController pushViewController:vc animated:YES];
    }
    else
    {
        ImportWalletHomeViewController *homeVc = [[ImportWalletHomeViewController alloc] init];
        
        [self.navigationController pushViewController:homeVc animated:YES];
    }


}

#pragma mark - uitableviewdelegate datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_segmentControl.selectedSegmentIndex == 0) {
        return self.normalArray.count;
    }
    else if (_segmentControl.selectedSegmentIndex == 1)
    {
        return self.observeArray.count;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identity = @"swtichcell";
    PWSwitchWalletCell *cell = [tableView dequeueReusableCellWithIdentifier:identity];
    
    if (!cell) {
        cell = [[PWSwitchWalletCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identity];
    }
    cell.delegate = self;
    if (_segmentControl.selectedSegmentIndex == 0)
    {
        cell.loginBtn.hidden = YES;
        cell.assetLab.hidden = NO;
        cell.walletDesLab.hidden = NO;
        cell.localWallet = self.normalArray[indexPath.row];
        
    }
    else if (_segmentControl.selectedSegmentIndex == 1)
    {
        
        cell.loginBtn.hidden = YES;
        cell.assetLab.hidden = NO;
        cell.walletDesLab.hidden = NO;
        cell.localWallet = self.observeArray[indexPath.row];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100.f + 12.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 26.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    

    
    if (_segmentControl.selectedSegmentIndex == 0){
        
        LocalWallet *wallet = [self.normalArray objectAtIndex:indexPath.row];
        
        if (wallet.isKJ == 1) {
            [[NSNotificationCenter defaultCenter]postNotificationName:@"iskj" object:nil];
        }else{
            [[NSNotificationCenter defaultCenter]postNotificationName:@"nokj" object:nil];
        }
    }
    switch (_switchWalletType) {
        case SwitchWalletTypeSwitch:
        {

            [[PWAppsettings instance] deleteAddress];
            [[PWAppsettings instance] deleteHomeCoinPrice];
            [[PWAppsettings instance] deleteHomeLocalCoin];
            if (_segmentControl.selectedSegmentIndex == 0)
            {
               
                for (int i = 0 ; i < self.allWalletArray.count; i ++) {
                    LocalWallet *wallet = [self.allWalletArray objectAtIndex:i];
                    if (wallet.wallet_isselected == 1) {
                        wallet.wallet_isselected = 0;
                        
                        [[PWDataBaseManager shared] updateWallet:wallet];
                        break;
                    }
                }
                LocalWallet *selectedWallet = self.normalArray[indexPath.row];
                selectedWallet.wallet_isselected = 1;
                [[PWDataBaseManager shared] updateWallet:selectedWallet];
                if (self.refreshHomeView) {
                    self.refreshHomeView(selectedWallet.wallet_id);
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.navigationController popViewControllerAnimated:YES];
                });
                
                
            }
            else if (_segmentControl.selectedSegmentIndex == 1)
            {
                for (int i = 0 ; i < self.allWalletArray.count; i ++) {
                    LocalWallet *wallet = [self.allWalletArray objectAtIndex:i];
                    if (wallet.wallet_isselected == 1) {
                        wallet.wallet_isselected = 0;
                            
                        [[PWDataBaseManager shared] updateWallet:wallet];
                        break;
                    }
                }
                LocalWallet *selectedWallet = self.observeArray[indexPath.row];
                selectedWallet.wallet_isselected = 1;
                [[PWDataBaseManager shared] updateWallet:selectedWallet];
                if (self.refreshHomeView) {
                    self.refreshHomeView(selectedWallet.wallet_id);
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.navigationController popViewControllerAnimated:YES];
                });
            }
        }
            break;
        case SwitchWalletTypeManage:
        {
            if (_segmentControl.selectedSegmentIndex == 0)
            {
                
                [self toSettingVC:self.normalArray[indexPath.row]];
               
                
            }
            else if (_segmentControl.selectedSegmentIndex == 1)
            {
                // 观察钱包
                [self toSettingVC:self.observeArray[indexPath.row]];
            }
        }
            break;
            case SwitchWalletTypeExplore:
        {
            [[PWAppsettings instance] deleteAddress];
            [[PWAppsettings instance] deleteHomeCoinPrice];
            [[PWAppsettings instance] deleteHomeLocalCoin];
            [[PWAppsettings instance] deleteEscrowInfo];
            if (_segmentControl.selectedSegmentIndex == 0)
            {
                
                for (int i = 0 ; i < self.allWalletArray.count; i ++) {
                    LocalWallet *wallet = [self.allWalletArray objectAtIndex:i];
                    if (wallet.wallet_isselected == 1) {
                        wallet.wallet_isselected = 0;
                        
                        [[PWDataBaseManager shared] updateWallet:wallet];
                        break;
                    }
                }
                LocalWallet *selectedWallet = self.normalArray[indexPath.row];
                selectedWallet.wallet_isselected = 1;
                [[PWDataBaseManager shared] updateWallet:selectedWallet];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.navigationController popViewControllerAnimated:YES];
                });
                
                
            }
            else if (_segmentControl.selectedSegmentIndex == 1)
            {
                for (int i = 0 ; i < self.allWalletArray.count; i ++) {
                    LocalWallet *wallet = [self.allWalletArray objectAtIndex:i];
                    if (wallet.wallet_isselected == 1) {
                        wallet.wallet_isselected = 0;
                            
                        [[PWDataBaseManager shared] updateWallet:wallet];
                        break;
                    }
                }
                LocalWallet *selectedWallet = self.observeArray[indexPath.row];
                selectedWallet.wallet_isselected = 1;
                [[PWDataBaseManager shared] updateWallet:selectedWallet];
                    
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.navigationController popViewControllerAnimated:YES];
                });
            }
        }
            break;
        default:
            break;
    }
    
}

- (void)toSettingVC:(LocalWallet *)localWallet
{
    PWNewsWalletSettingViewController *settingVc = [[PWNewsWalletSettingViewController alloc] init];
    settingVc.localWallet = localWallet;
    
    [self.navigationController pushViewController:settingVc animated:YES];
}

#pragma mark - getter and setter

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = UIColor.whiteColor;
    }
    return  _tableView;
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
