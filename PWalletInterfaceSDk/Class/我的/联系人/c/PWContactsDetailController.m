//
//  PWContactsDetailController.m
//  PWallet
//  联系人详情
//  Created by 陈健 on 2018/5/31.
//  Copyright © 2018年 陈健. All rights reserved.
//

#import "PWContactsDetailController.h"
#import "PWContactsDetailCell.h"
#import "PWContactsCoin.h"
#import "PWEditContactsController.h"
#import "TransferViewController.h"
#import "PWContactsNameView.h"
#import "PWContactsTool.h"

/*用于表示当前没有选中任何地址**/
NSInteger PWContactsDetailCellSelectedNull = -1010;

@interface PWContactsDetailController ()<UITableViewDelegate,UITableViewDataSource>
//tableView
@property(nonatomic,weak) UITableView *tableView;
/*记录选中了那个地址**/
@property(nonatomic,assign) NSInteger selectedIndex;
/**昵称 手机号 view*/
@property (nonatomic,weak) PWContactsNameView *namePhoneView;

/** 支持币种 */
@property (nonatomic, strong) NSArray *coinArray;

@end

@implementation PWContactsDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    
   
    [self createView];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if (self.tableView) {
        [self.tableView reloadData];
    }


    if (self.namePhoneView) {
        self.namePhoneView.name = self.contacts.nickName;
        self.namePhoneView.phoneNumber = self.contacts.phoneNumber;
    }
}

- (void)createView {
    
    self.showMaskLine = false;
    self.statusBarStyle = UIStatusBarStyleLightContent;
    if (@available(iOS 15, *))
    {
        UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];

        appearance.backgroundColor = SGColorFromRGB(0x39477A);

        appearance.backgroundEffect = nil;
        appearance.shadowColor = UIColor.clearColor;
        appearance.titleTextAttributes = @{NSFontAttributeName : [UIFont boldSystemFontOfSize:18], NSForegroundColorAttributeName : [UIColor whiteColor]};
        self.navigationController.navigationBar.standardAppearance = appearance;
        self.navigationController.navigationBar.scrollEdgeAppearance = appearance;
    }
    else
    {
        self.navigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName : [UIFont boldSystemFontOfSize:18], NSForegroundColorAttributeName : [UIColor whiteColor]};

        [self.navigationController.navigationBar setBackgroundImage:[CommonFunction createImageWithColor:SGColorFromRGB(0x39477A)] forBarMetrics:UIBarMetricsDefault];

         
    }
    self.navigationItem.title = @"联系人详情".localized;
    self.selectedIndex = PWContactsDetailCellSelectedNull;
    self.view.backgroundColor = SGColorFromRGB(0xFCFCFF);
    if (self.contacts) {
        [self initViews];
    }
}

- (void)initViews {
    //顶部右侧"编辑"按钮
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 20, 40, 40)];
    [btn addTarget:self action:@selector(editButtonPress) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitle:@"编辑".localized forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:16];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    UIImageView *blackView = [[UIImageView alloc]init];
    blackView.backgroundColor = SGColorFromRGB(0x39477A);

    [self.view addSubview:blackView];
    [blackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.view);
        make.height.mas_equalTo(70);
    }];
    
    PWContactsNameView *namePhoneView = [[PWContactsNameView alloc]init];
    [self.view addSubview:namePhoneView];
    self.namePhoneView = namePhoneView;
    namePhoneView.name = self.contacts.nickName;
    namePhoneView.phoneNumber = self.contacts.phoneNumber;
    [namePhoneView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(15);
        make.centerX.equalTo(self.view);
        make.width.mas_equalTo(kScreenWidth);
        make.height.mas_equalTo(110);
    }];
    
 
    //去转账button
    UIButton *transferBtn = [[UIButton alloc]init];
    [self.view addSubview:transferBtn];
    [transferBtn addTarget:self action:@selector(transferButtonPress:)forControlEvents:UIControlEventTouchUpInside];
    [transferBtn setBackgroundColor:SGColorFromRGB(0x333649)];
    [transferBtn setTitle:@"去转账".localized forState:UIControlStateNormal];

   
    transferBtn.layer.cornerRadius = 6;
    transferBtn.layer.masksToBounds = transferBtn;
    [transferBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(16);
        make.right.equalTo(self.view).offset(-16);
        make.height.mas_equalTo(44);
        make.bottom.equalTo(self.view).offset(-30 - kIphoneXBottomOffset);
    }];
    
    //UITableView
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    [self.view addSubview:tableView];
    self.tableView = tableView;
    
    tableView.backgroundColor = self.view.backgroundColor;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.showsVerticalScrollIndicator = false;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 30)];
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(namePhoneView.mas_bottom);
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(transferBtn.mas_top);
    }];
}

#pragma mark - Action

- (void)editButtonPress {
    PWEditContactsController *addContactVC = [[PWEditContactsController alloc]init];
    addContactVC.contacts = self.contacts;
    [self.navigationController pushViewController:addContactVC animated:true];
}

- (void)transferButtonPress:(UIButton*)sender {
    if (self.contacts.coinArray.count == 0)
    {
        return;
    }
    PWContactsCoin *pwcoin = self.contacts.coinArray[self.selectedIndex];
    NSArray *coinArray = [[PWDataBaseManager shared] queryCoinArrayBasedOnSelectedWalletID];
    
    for (int i = 0; i < coinArray.count; i ++) {
        LocalCoin *localCoin = [coinArray objectAtIndex:i];
        if ([localCoin.coin_type isEqualToString:pwcoin.coinName]) {
            
           
                CoinPrice *coinPrice = [[PWDataBaseManager shared] queryCoinPriceBasedOn:localCoin.coin_type
                                                                                platform:localCoin.coin_platform
                                                                               andTreaty:localCoin.treaty];
                if (coinPrice.lock == 1)
                {
                    [self showCustomMessage:@"该币种维护中...".localized hideAfterDelay:2.f];
                    return;
                }
                TransferViewController *vc = [[TransferViewController alloc] init];
                vc.fromTag = TransferFromContact;
                vc.coin = localCoin;
                vc.selectIndex = self.selectedIndex;
                vc.pwcontact = _contacts;
                [self.navigationController pushViewController:vc animated:YES];
            
            
            return;
        }
    }
    NSString *tipStr = [NSString stringWithFormat:@"首页钱包不含%@",pwcoin.coinName];
    [self showCustomMessage:tipStr hideAfterDelay:2.0];
    
    
}

#pragma mark - tableView 代理和数据源

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.contacts.coinArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 120;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    PWContactsDetailCell *cell =  [[PWContactsDetailCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.coinNameText = self.contacts.coinArray[indexPath.row].optional_name;
    cell.addressText = self.contacts.coinArray[indexPath.row].coinAddress;
    if (indexPath.row == 0) {
        [cell setselectCell];
        self.selectedIndex = indexPath.row;
    }
    __weak typeof(self) weakSelf = self;
    cell.copyAddressBlock = ^(NSString *address) {
        UIPasteboard *pboard = [UIPasteboard generalPasteboard];
        pboard.string = address;
        [weakSelf showCustomMessage:@"地址复制成功".localized hideAfterDelay:1];
    };
    return cell;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PWContactsDetailCell *selectedCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectedIndex inSection:indexPath.section]];
    [selectedCell deselectCell];
    PWContactsDetailCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell setselectCell];
    self.selectedIndex = indexPath.row;
}


#pragma mark - tableView 高度 header footer配置
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 34;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    YYLabel *label = [[YYLabel alloc]init];
    label.backgroundColor = tableView.backgroundColor;
    label.font = [UIFont boldSystemFontOfSize:14];
    label.textColor = SGColorFromRGB(0x333649);
    label.text = [NSString stringWithFormat:@"        %@",@"地址".localized];
    label.textVerticalAlignment = YYTextVerticalAlignmentBottom;
    //竖线
    UILabel *verticalLab = [[UILabel alloc]initWithFrame:CGRectMake(18, 17, 3, 14)];
    verticalLab.backgroundColor = SGColorFromRGB(0x7190FF);
    [label addSubview:verticalLab];
    return label;
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

@end
