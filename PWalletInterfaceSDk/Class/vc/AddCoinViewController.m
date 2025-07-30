//
//  AddCoinViewController.m
//  PWallet
//
//  Created by 宋刚 on 2018/5/28.
//  Copyright © 2018年 陈健. All rights reserved.
//

#import "AddCoinViewController.h"
#import "UIViewController+RTRootNavigationController.h"
#import "PWAlertController.h"
#import "LocalCoin.h"


@interface AddCoinViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong) UITableView *coinTableView;
/**搜索框*/
@property (nonatomic,strong) UIView *searchView;
@property (nonatomic,strong) UIView *titleLine;
@property (nonatomic,strong) NSMutableArray *coinArray;
/**记录coinArray 判断coinArray中的LocalCoin数量和显示状态是否改变 改变则需要进行回调*/
@property (nonatomic,strong) NSArray *oldCoinArray;
@end

@implementation AddCoinViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.rt_disableInteractivePop = true;

    self.title = @"添加币种".localized ;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self createView];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.coinArray = [NSMutableArray arrayWithArray:[[PWDataBaseManager shared] queryCoinArrayBasedOnSelectedWalletID]];
    [self.coinTableView reloadData];
    
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: CMColorRGBA(51,51,51,1),NSFontAttributeName : [UIFont boldSystemFontOfSize:18]};
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)setCoinArray:(NSArray *)coinArray {
    if (_coinArray == nil) {
        _coinArray = [NSMutableArray arrayWithArray:coinArray];
    
        NSMutableArray *array = [NSMutableArray array];
        for (LocalCoin *coin in _coinArray) {
            [array addObject:[coin copy]];
        }
        self.oldCoinArray = [NSArray arrayWithArray:array];
        
    }
    else {
        self.oldCoinArray = _coinArray;
        _coinArray = [NSMutableArray arrayWithArray:coinArray];
    }
}

- (void)createView{
    
    UIView *titleLine = [[UIView alloc] init];
    titleLine.backgroundColor = LineColor;
    [self.view addSubview:titleLine];
    self.titleLine = titleLine;
    
//    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"管理"  style:UIBarButtonItemStylePlain target:self action:@selector(management)];
//    self.navigationItem.rightBarButtonItem = rightItem;
    [self.navigationController.navigationBar setTintColor:TextColor51];

    UITableView *coinTableView = [[UITableView alloc] init];
    coinTableView.delegate = self;
    coinTableView.dataSource = self;
    coinTableView.rowHeight = 80;
    coinTableView.backgroundColor = self.view.backgroundColor;
    coinTableView.showsVerticalScrollIndicator = NO;
    coinTableView.separatorColor = LineColor;
    [self.view addSubview:coinTableView];
    self.coinTableView = coinTableView;
    
    UIView *searchView = [[UIView alloc]init];
    [self.view addSubview:searchView];
    searchView.backgroundColor = self.view.backgroundColor;
    YYLabel *label = [[YYLabel alloc]init];
    [searchView addSubview:label];
    label.backgroundColor = SGColorFromRGB(0xF8F8FA);
    label.textColor = SGColorFromRGB(0x8E92A3);
    label.font = [UIFont systemFontOfSize:16];
    label.text = @"输入Token名称或合约地址".localized;
    label.layer.cornerRadius = 3;
    
    label.textContainerInset = UIEdgeInsetsMake(0, 82, 0, 0);
    
    
    WEAKSELF
    label.textTapAction = ^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
        [weakSelf searchCoinAction];
    };
    
    searchView.translatesAutoresizingMaskIntoConstraints = NO;
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(39);
        make.left.equalTo(searchView.mas_left).offset(23);
        make.right.equalTo(searchView.mas_right).offset(-23);
        make.top.equalTo(searchView).offset(10);
    }];
    
    UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"APP搜索"]];
    [label addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(20);
        make.left.equalTo(label).offset(53);
        make.centerY.equalTo(label).offset(-1);
    }];
    
    self.searchView = searchView;
    
    UIView *bottomView = [[UIView alloc] init];
    coinTableView.tableFooterView = bottomView;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    [self.titleLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.view).with.offset(0);
        make.height.mas_equalTo(0.5);
    }];
    
    [self.searchView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLine.mas_bottom);
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(68);
    }];
    
    [self.coinTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.searchView.mas_bottom);
        make.bottom.equalTo(self.view);
    }];
}

#pragma mark-
#pragma mark UITableView的数据源和代理
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return self.coinArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    CoinTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[CoinTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.font = CMTextFont18;
    cell.textLabel.textColor = TextColor51;
    cell.detailTextLabel.font = CMTextFont14;
    cell.detailTextLabel.textColor = PlaceHolderColor;
    cell.separatorInset = UIEdgeInsetsMake(0, 66, 0, 0);
    __block typeof(cell) weakCell = cell;
    cell.addCoin = ^(LocalCoin *coin, BOOL isOn) {
        // 要弹框
        LocalWallet *selectedWallet = [[PWDataBaseManager shared] queryWalletIsSelected];
        PWAlertController *alertVC = [[PWAlertController alloc] initWithTitle:@"请输入钱包密码".localized  withTextValue:@""  leftButtonName:nil rightButtonName:@"确定".localized  handler:^(ButtonType type, NSString *text) {
            if (type == ButtonTypeRight) {
                if ([GoFunction checkPassword:text hash:selectedWallet.wallet_password]) {
                    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
                    dispatch_async(queue, ^{
                        [GoFunction addChainCoinIntoWallet:coin password:text];
                    });
                    
                } else {
                    weakCell.switchBtn.on = NO;
                    [self showCustomMessage:@"密码错误".localized  hideAfterDelay:1];
                }
            }
            else
            {
                weakCell.switchBtn.on = NO;
            }
            
        }];
        alertVC.closeVC = ^{
            weakCell.switchBtn.on = NO;
        };
        alertVC.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
        [self presentViewController:alertVC animated:false completion:nil];
    };
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    LocalCoin *coin = [self.coinArray objectAtIndex:indexPath.row];
    CoinTableViewCell *coinCell = (CoinTableViewCell *)cell;
    coinCell.coin = coin;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1;
}

#pragma mark-
#pragma mark 类方法

//管理
- (void)management {
    
}

- (void)backAction{
    [super backAction];
    
    BOOL isChange; //用于判断币的展示信息是否改变
    BOOL isOldCoin;//添加该币是不是新添加的
    
    for (LocalCoin *coinInTableView in self.coinArray) {
        isChange = true;
        isOldCoin = false;
        for (LocalCoin *oldCoin in self.oldCoinArray) {
            if (oldCoin.coin_id == coinInTableView.coin_id) {
                isOldCoin = true;
                if (oldCoin.coin_show == coinInTableView.coin_show) {
                    isChange = false;
                }
                break;
            }
        }
        if (isChange) {
            if (isOldCoin) {
                self.reloadHomePage();
                return;
            } else if (coinInTableView.coin_show == 1) {
                //添加了新币种 并且添加的新币种的coin_show == 1 进行回调
                self.reloadHomePage();
                return;
            }
        }
    }
    
}

/**
 * 搜索币种
 */
- (void)searchCoinAction
{
    SearchCoinViewController *vc = [[SearchCoinViewController alloc] init];
 
    [self.navigationController pushViewController:vc
                                         animated:false];
}

#pragma mark-

@end


