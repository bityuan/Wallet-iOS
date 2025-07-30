//
//  PWSearchCoinChildViewController.m
//  PWallet
//
//  Created by 郑晨 on 2020/1/7.
//  Copyright © 2020 陈健. All rights reserved.
//

#import "PWSearchCoinChildViewController.h"
#import "UIViewController+RTRootNavigationController.h"
#import "PWAlertController.h"
#import "LocalCoin.h"
#import "PWDataBaseManager.h"
#import "CoinTableViewCell.h"


@interface PWSearchCoinChildViewController ()
<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *coinTableView;
@property (nonatomic, strong) NSMutableArray *coinArray;
@property (nonatomic, strong) NSString *titleStr;
@property (nonatomic) BOOL isEditing;
@property (nonatomic, strong) UIButton *completeBtn;

@end

@implementation PWSearchCoinChildViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.whiteColor;
    self.coinArray = [NSMutableArray arrayWithArray:[[PWDataBaseManager shared] queryCoinArrayBasedOnSelectedWalletID]];
    [self.view addSubview:self.coinTableView];
    [self.coinTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    _titleStr = @"首页币种".localized;
//    [self requestRecommendCoinWithChain:@""];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changeDatasource:)
                                                 name:SEARCHCOINNOTIFICATION
                                               object:nil];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.view endEditing:YES];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: CMColorRGBA(51,51,51,1),NSFontAttributeName : [UIFont boldSystemFontOfSize:18]};
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self logoutSort];
}

- (void)changeDatasource:(NSNotification *)notification
{
   
    NSLog(@"no is %@",notification);
    NSDictionary *dict = notification.object;
    _titleStr = [dict objectForKey:@"name"];
    NSArray *coinArray = [dict objectForKey:@"coinArray"];
    self.completeBtn.hidden = YES;
    if ([_titleStr isEqualToString:@"首页币种".localized])
    {
        self.completeBtn.hidden = !self.coinTableView.isEditing;
        self.coinArray = [NSMutableArray arrayWithArray:[[PWDataBaseManager shared] queryCoinArrayBasedOnSelectedWalletID]];
    }
    else
    {

        self.coinArray = [[NSMutableArray alloc] init];
        for (int i = 0; i < coinArray.count; i ++) {
            NSDictionary *dic = [coinArray objectAtIndex:i];
            LocalCoin *coin = [[LocalCoin alloc] init];
            
            coin.coin_walletid = [[PWDataBaseManager shared] queryWalletIsSelected].wallet_id;
            coin.coin_type = dic[@"name"];
            coin.coin_address = [[PWDataBaseManager shared] queryAddressBasedOnChain:dic[@"chain"]];
            coin.coin_balance = 0;
            coin.coin_pubkey = @"";
            coin.coin_show = 0;
            coin.coin_platform = dic[@"platform"];
            coin.treaty = [dic[@"treaty"] integerValue];
            coin.coin_chain = dic[@"chain"];
            coin.coin_coinid = [dic[@"id"] integerValue];
            coin.icon = dic[@"icon"];
            coin.coin_type_nft = 2;
            NSMutableArray *muarray = [NSMutableArray arrayWithArray:[[PWDataBaseManager shared] queryCoinArrayBasedOnSelectedWalletID]];
            for (int i = 0; i < muarray.count; i++) {
                LocalCoin *localCoin = [muarray objectAtIndex:i];
                if ([localCoin.coin_type isEqualToString:dic[@"name"]] && localCoin.coin_coinid == [dic[@"id"] integerValue])
                {
                    coin.coin_show = localCoin.coin_show;
                    coin.coin_id = localCoin.coin_id;
                    coin.coin_balance = localCoin.coin_balance;
                }
            }
            [self.coinArray addObject:coin];
        }
    }
    [self.coinTableView reloadData];
}


#pragma mark - uitableviewdalegate datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _coinArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CoinTableViewCell *cell = [[CoinTableViewCell alloc] init];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.font = CMTextFont18;
    cell.textLabel.textColor = TextColor51;
    cell.detailTextLabel.font = CMTextFont14;
    cell.detailTextLabel.textColor = PlaceHolderColor;
    cell.separatorInset = UIEdgeInsetsMake(0, 66, 0, 0);
    __block typeof(cell) weakCell = cell;
    if (self.coinTableView.editing) {
        cell.switchBtn.hidden = YES;
    }
    else
    {
        cell.switchBtn.hidden = NO;
    }
    
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
    if (self.coinArray.count < indexPath.row + 1)
    {
        return;
    }
    LocalCoin *coin = [self.coinArray objectAtIndex:indexPath.row];
    CoinTableViewCell *coinCell = (CoinTableViewCell *)cell;
    coinCell.coin = coin;
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80.f;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    if ([_titleStr isEqualToString:@"首页币种".localized ]) {
        return YES;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    NSLog(@"old is %@",self.coinArray);
    LocalCoin *coin = self.coinArray[sourceIndexPath.row];
    [self.coinArray removeObjectAtIndex:sourceIndexPath.row];
    [self.coinArray insertObject:coin atIndex:destinationIndexPath.row];
    NSLog(@"new is %@",self.coinArray);
    LocalWallet *localWallet = [[PWDataBaseManager shared] queryWalletIsSelected];
   if( [[PWDataBaseManager shared] deleteCoin:localWallet])
   {
       for (LocalCoin *localCoin in self.coinArray) {
           LocalCoin *newCoin = [[LocalCoin alloc] init];
           newCoin.coin_walletid = localWallet.wallet_id;
           newCoin.coin_type = localCoin.coin_type;
           newCoin.coin_address = localCoin.coin_address;
           newCoin.coin_balance = localCoin.coin_balance;
           newCoin.coin_pubkey = localCoin.coin_pubkey;
           
           newCoin.coin_show = localCoin.coin_show;
           newCoin.coin_platform = localCoin.coin_platform;
           newCoin.coin_coinid = localCoin.coin_coinid;
           newCoin.treaty = localCoin.treaty;
           newCoin.coin_chain = localCoin.coin_chain;
           newCoin.coin_type_nft = localCoin.coin_type_nft;
           [[PWDataBaseManager shared] addCoin:newCoin];
       }
   }
    self.coinArray = [NSMutableArray arrayWithArray:[[PWDataBaseManager shared] queryCoinArrayBasedOnSelectedWalletID]];
    [self.coinTableView reloadData];
    
}


#pragma mark - 首页推荐
- (void)longPressGestureRecognized:(UIGestureRecognizer *)sender
{
    if (![_titleStr isEqualToString:@"首页币种".localized ]) {
        return ;
    }
    if (sender.state == UIGestureRecognizerStateBegan)
    {
        self.completeBtn.hidden = NO;
        [self.coinTableView setEditing:YES animated:YES];
        [self.coinTableView reloadData];
    }
    else
    {
        // do nothing
    }
    
}

- (void)logoutSort
{
    for (UIView *view in [UIApplication sharedApplication].keyWindow.subviews) {
        if ([view isKindOfClass:[UIButton class]] && view.tag == 1001) {
            view.hidden = YES;
        }
    }
    [self.coinTableView setEditing:NO animated:YES];
    [self.coinTableView reloadData];
}



#pragma mark - setter and getter
- (UITableView *)coinTableView
{
    if (!_coinTableView) {
        _isEditing = NO;
        UITableView *coinTableView = [[UITableView alloc] init];
        coinTableView.delegate = self;
        coinTableView.dataSource = self;
        coinTableView.rowHeight = 70;
        coinTableView.backgroundColor = self.view.backgroundColor;
        coinTableView.showsVerticalScrollIndicator = NO;
        coinTableView.separatorColor = LineColor;
        _coinTableView = coinTableView;
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureRecognized:)];
        longPress.minimumPressDuration = 0.8;
        [_coinTableView addGestureRecognizer:longPress];
        
    }
    return _coinTableView;
}

- (UIButton *)completeBtn
{
    if (!_completeBtn) {
        _completeBtn = [[UIButton alloc] init];
        [_completeBtn setTitle:@"退出排序".localized  forState:UIControlStateNormal];
        [_completeBtn setTitleColor:SGColorFromRGB(0xffffff) forState:UIControlStateNormal];
        [_completeBtn setBackgroundColor:SGColorFromRGB(0x7190ff)];
        [_completeBtn.layer setCornerRadius:(CGFloat)23.f];
        [_completeBtn.titleLabel setFont:[UIFont systemFontOfSize:16.f]];
        _completeBtn.layer.shadowOpacity = 1;
        _completeBtn.layer.shadowOffset = CGSizeMake(0, 0);
        _completeBtn.layer.shadowColor = CMColorFromRGB(0xebedf8).CGColor;
        [_completeBtn addTarget:self action:@selector(logoutSort) forControlEvents:UIControlEventTouchUpInside];
        _completeBtn.hidden = YES;
        _completeBtn.tag = 1001;
        UIWindow *keywindow = [UIApplication sharedApplication].keyWindow;
        [keywindow addSubview:_completeBtn];
        
        [_completeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(keywindow).offset(-100);
            make.centerX.equalTo(keywindow);
            make.height.mas_equalTo(46);
            make.width.mas_equalTo(122);
        }];
    }
    return _completeBtn;
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
