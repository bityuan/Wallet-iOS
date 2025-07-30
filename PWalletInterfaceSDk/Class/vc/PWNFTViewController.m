//
//  PWNFTViewController.m
//  PWalletInterfaceSDk
//
//  Created by 郑晨 on 2022/5/17.
//

#import "PWNFTViewController.h"
#import "HomeCoinTableViewCell.h"
#import "PWNoCoinViewCell.h"
#import "CoinDetailViewController.h"

@interface PWNFTViewController ()
<UITableViewDelegate, UITableViewDataSource>

/** */
@property(nonatomic,strong)NSURLSessionDataTask *sessionTask;
@property(nonatomic,strong)dispatch_group_t group;
@property(nonatomic,strong)dispatch_source_t timer;

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *nftDataArray;
@property(nonatomic,strong)NSMutableArray *priceArray;
@property(nonatomic,strong)LocalWallet *homeWallet; // 当前钱包

@end

@implementation PWNFTViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _group = dispatch_group_create();
    self.view.backgroundColor = SGColorFromRGB(0xf8f8f8);
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [self initValue];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.showMaskLine = false;
    if (@available(iOS 13.0, *)) {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDarkContent;
    } else {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self requestNFT];
        [self requestBalance];
        [self openGCDBalance];
    });
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self stopGCDBalance];
}

- (void)initValue{

    if (self.priceArray == nil) {
        self.priceArray = [[NSMutableArray alloc] init];
    }
    self.homeWallet = [[PWDataBaseManager shared] queryWalletIsSelected];
    self.nftDataArray = [NSMutableArray arrayWithArray:[[PWDataBaseManager shared] queryNFTArrayBasedOnWalletIDAndShow]];

    [self.tableView reloadData];
}

/**
 * 轮询
 */
- (void)openGCDBalance
{
    NSTimeInterval period = 8.0; //设置时间间隔
    WEAKSELF
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, 0);
    dispatch_source_set_timer(_timer, start, period * NSEC_PER_SEC, 0); //每秒执行

    dispatch_source_set_event_handler(_timer, ^{
        
        [weakSelf requestBalance];
    });
    dispatch_resume(_timer);
}

/**
 * 停止轮询
 */
- (void)stopGCDBalance
{
     NSLog(@"停止查余额啦！！！");
    if (_timer)
    {
        dispatch_source_cancel(_timer);
        _timer = nil;
    }

}
#pragma mark - tableview delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.nftDataArray.count == 0) {
        return 1;
    }
    return self.nftDataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.nftDataArray.count==0){
        static NSString *CellIdentifier = @"NoCoinCell";
        PWNoCoinViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[PWNoCoinViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }else{
        static NSString *CellIdentifier = @"Cell";
        HomeCoinTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[HomeCoinTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{

    HomeCoinTableViewCell *homeCell = (HomeCoinTableViewCell *)cell;
    homeCell.backgroundColor = SGColorFromRGB(0xf8f8fa);
    if(indexPath.row < self.nftDataArray.count)
    {
        LocalCoin *coin = [self.nftDataArray objectAtIndex:indexPath.section];
        homeCell.coin = coin;
        BOOL existState = NO;
        NSString *coinType = coin.coin_type;
        for (int j = 0; j < _priceArray.count; j ++) {
            CoinPrice *coinPrice = [self.priceArray objectAtIndex:j];
            if ([coinPrice.coinprice_name isEqualToString:coinType] && [coin.coin_platform isEqualToString:coinPrice.coinprice_platform]) {
                homeCell.coinPrice = coinPrice;
                existState = YES;
                break;
            }
        }
        if (!existState) {
            homeCell.coinPrice = nil;
        }
    }

}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10.f;

}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return .0001f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.nftDataArray.count == 0) {
        return kScreenHeight - 100;
    }
    return 70.f;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < self.nftDataArray.count)
    {
        LocalCoin *coin = [self.nftDataArray objectAtIndex:indexPath.section];
        CoinDetailViewController *vc = [[CoinDetailViewController alloc] init];
        vc.hidesBottomBarWhenPushed = YES;
        vc.selectedCoin = coin;
        [self.navigationController pushViewController:vc animated:YES];
    }

}


// 获取推荐的NFT列表
- (void)requestNFT
{
    NSString *tiger = @"MEKA,ethereum";
    NSArray *nameArray = @[tiger];
    NSDictionary *param = @{@"names":nameArray};
  WEAKSELF
    [[SGNetWork defaultManager] sendRequestMethod:HTTPMethodPOST
                                        serverUrl:WalletURL
                                          apiPath:HOMECOININDEX
                                       parameters:param
                                         progress:^(NSProgress * _Nullable progress) {
        
    } success:^(BOOL isSuccess, id  _Nullable responseObject) {
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
        NSLog(@"result is %@",result);
        [weakSelf.priceArray removeAllObjects];
        if ([result[@"data"] isKindOfClass:[NSNull class]]) {
            [self showCustomMessage:result[@"msg"] hideAfterDelay:2.f];
        }else{
            if ([result[@"data"] isEqual:[NSNull null]]) {
                return ;
            }
            NSArray *priceArray = result[@"data"];
            
            for(int i = 0;i < priceArray.count; i++)
            {
                NSDictionary *dic = [priceArray objectAtIndex:i];
                
                if([dic[@"platform"] isEqualToString:@"OTHER"])
                {
                    continue;
                }
                
                
                [[PWDataBaseManager shared] upadateCoin:[dic[@"id"] integerValue] platform:dic[@"platform"] cointype:dic[@"name"]];
                
                CoinPrice *coinPrice = [[CoinPrice alloc] init];
                coinPrice.coinprice_name = dic[@"name"];
                coinPrice.coinprice_price = [dic[@"rmb"] doubleValue]; //[CommonFunction handlePrice:priceStr];
                coinPrice.coinprice_dollarPrice = [dic[@"usd"] doubleValue];
                coinPrice.coinprice_icon = dic[@"icon"];
                coinPrice.coinprice_sid = dic[@"sid"];
                coinPrice.coinprice_nickname = dic[@"nickname"];
                coinPrice.coinprice_id = [dic[@"id"] integerValue];
                coinPrice.coinprice_chain = dic[@"chain"];
                coinPrice.coinprice_platform = dic[@"platform"];
                coinPrice.coinprice_heyueAddress = dic[@"contract_address"];
                coinPrice.treaty = [dic[@"treaty"] integerValue];
                coinPrice.coinprice_optional_name = dic[@"optional_name"];
                coinPrice.coinprice_chain_country_rate = [dic[@"chain_country_rate"] doubleValue];
                coinPrice.coinprice_country_rate = [dic[@"country_rate"] doubleValue];
                coinPrice.rmb_country_rate = [dic[@"rmb_country_rate"] doubleValue];
                coinPrice.lock = [dic[@"lock"] integerValue];
                
                [[PWDataBaseManager shared] addCoinPrice:coinPrice];
                [weakSelf.priceArray addObject:coinPrice];
                [self.tableView reloadData];
                
                
            }
            
        }
        
        
    } failure:^(NSString * _Nullable errorMessage) {
        [self showCustomMessage:errorMessage hideAfterDelay:2.f];
    }];
}

- (void)requestBalance
{
    __weak typeof(self) weakself = self;
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    dispatch_group_enter(_group);
    dispatch_async(queue, ^{
        [self requestNFT];
    });
    
    
    
    for (int i = 0; i < self.nftDataArray.count; i ++) {
        dispatch_group_enter(_group);
        dispatch_async(queue, ^{
//            [PWNFTRequest requestERC721NFTBalanceWith:@"BTY"
//                                              nftType:@"ERC721"
//                                         contractAddr:@"14uy1WZCTRojYuvTpaeJqVP3Ngfbwd7bHr"
//                                             fromAddr:@"197k3nMRp7HzbHvsHhrAPwDehZFY8TMuHb"
//                                              success:^(id  _Nonnull object) {
//                NSDictionary *result = [NSJSONSerialization JSONObjectWithData:object options:NSJSONReadingAllowFragments error:nil];
//                NSLog(@"erc721 balance result is %@",result);
//            } failure:^(NSString * _Nonnull errorMsg) {
//
//            }];
//
//            [PWNFTRequest requestERC1155NFTBalanceWith:@"BTY"
//                                               nftType:@"ERC1155"
//                                               tokenId:@"1655976285316"
//                                          contractAddr:@"1NY7MMMha2wajBaoGLanxn68eqwnXKCWVC"
//                                              fromAddr:@"197k3nMRp7HzbHvsHhrAPwDehZFY8TMuHb"
//                                               success:^(id  _Nonnull object) {
//                NSDictionary *result = [NSJSONSerialization JSONObjectWithData:object options:NSJSONReadingAllowFragments error:nil];
//                NSLog(@"erc1155 balance result is %@",result);
//            } failure:^(NSString * _Nonnull errorMsg) {
//
//            }];
//
//            [PWNFTRequest requstSLGTxsByCoinType:@"BTY"
//                                         address:@"12dyEw2De26DZH6bnWg1pNx72FiPirNkTU"
//                                    contractAddr:@"1NY7MMMha2wajBaoGLanxn68eqwnXKCWVC"
//                                           index:0
//                                           count:20
//                                       direction:0
//                                            type:0
//                                         success:^(id  _Nonnull object) {
//                NSDictionary *result = [NSJSONSerialization JSONObjectWithData:object options:NSJSONReadingAllowFragments error:nil];
//                NSLog(@"erc721 tx result is %@",result);
//            } failure:^(NSString * _Nonnull errorMsg) {
//
//            }];
            
            if (weakself.nftDataArray.count != 0)
            {
                
                LocalCoin *coin = [weakself.nftDataArray objectAtIndex:i];
                CoinPrice *coinPrice = [[PWDataBaseManager shared] queryCoinPriceBasedOn:coin.coin_type platform:coin.coin_platform andTreaty:coin.treaty];
                [PWNFTRequest requestNFTBalanceWithCoinType:coin.coin_chain
                                                       from:coin.coin_address
                                               contractAddr:coinPrice.coinprice_heyueAddress
                                                    success:^(id  _Nonnull object) {
                    NSDictionary *result = [NSJSONSerialization JSONObjectWithData:object options:NSJSONReadingAllowFragments error:nil];
                    NSLog(@"balance result is %@",result);
                    
                    if (![result[@"result"] isKindOfClass:[NSNull class]]) {
                        NSInteger balance = [result[@"result"] integerValue];
                        coin.coin_balance = balance;
                        if (i < weakself.nftDataArray.count) {
                            [weakself.nftDataArray replaceObjectAtIndex:i withObject:coin];
                        }
                        
                        [[PWDataBaseManager shared] updateCoin:coin];
                    }
                   
                    
                } failure:^(NSString * _Nullable errorMsg) {
                    
                }];
                
                dispatch_group_leave(weakself.group);
            }
           
            
        });
    }
}

#pragma mark - setting and getting
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
        _tableView.backgroundColor = SGColorFromRGB(0xf8f8fa);
    }
    return _tableView;
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
