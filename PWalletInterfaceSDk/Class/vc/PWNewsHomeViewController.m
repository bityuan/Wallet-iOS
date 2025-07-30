//
//  PWNewsHomeViewController.m
//  PWallet
//
//  Created by 郑晨 on 2019/11/29.
//  Copyright © 2019 陈健. All rights reserved.
//

#import "PWNewsHomeViewController.h"
#import "LocalWallet.h"
#import "PWDataBaseManager.h"
#import "APPDelegate.h"
#import "HomeCoinTableViewCell.h"
#import "PWNoCoinViewCell.h"
#import "CoinDetailViewController.h"
#import "CoinPrice.h"
#import <NSObject+YYModel.h>
#import "ScanViewController.h"
#import "TransferViewController.h"
#import "PWSwitchWalletViewController.h"
#import "PWNewsWalletSettingViewController.h"
#import "PWActionSheetView.h"
#import "PWNesReceiptMoneyViewController.h"
#import "PWLoginTool.h"
#import "PWNewsSearchCoinViewController.h"

#import "PWalletInterfaceSDK-Swift.h"

#import <JhtMarquee/JhtVerticalMarquee.h>
#import "PWHomeNoticeModel.h"
#import "PWMessageCenterController.h"
#import "MainTabBarController.h"
#import "PWContractVC.h"
#import "PWContractRequest.h"

static NSString *reuseID = @"tableview";

@interface PWNewsHomeViewController ()
<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property(nonatomic,strong)NSMutableArray *coinDatasource; // 币种信息
@property(nonatomic,strong)NSMutableArray *priceArray;
@property(nonatomic,strong)LocalWallet *homeWallet; // 当前钱包
/** 当前钱包的wallet_id */
@property(nonatomic,assign)NSInteger walletId;
/** */
@property(nonatomic,strong)NSURLSessionDataTask *sessionTask;
@property(nonatomic,strong)dispatch_source_t timer;


// 跑马灯
@property (nonatomic, strong) NSArray *noticeArray;
@property (nonatomic, strong) NSArray *noticeTitleArray;
@property (nonatomic, strong) JhtVerticalMarquee *verticalMarquee;

@property (nonatomic, strong) LocalCoin *localCoin;
@property(nonatomic,strong)NSMutableArray *localArray;



@end

@implementation PWNewsHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.navigationItem.leftBarButtonItem = [self leftBarButtonItem];
    self.navigationItem.rightBarButtonItem = [self rightBarButtonItem];
//    self.navigationItem.rightBarButtonItems = @[[self rightBarButtonItem],[self TrightBarButtonItem]];
    self.view.backgroundColor = SGColorFromRGB(0xffffff);
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [self initValue];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeLanguage) name:kChangeLanguageNotification object:nil];//nokj
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkUpdate:) name:@"walletupdatenotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initValue) name:@"kChangeWalletNameNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initValue) name:@"kDeleteWalletNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initValue) name:@"kWebChangeAccountNotifition" object:nil];
    self.localArray = [NSMutableArray array];
//    [self.coinDatasource removeAllObjects];
    [self downRefresh];
   
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
    [self.localArray removeAllObjects];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self openGCDBalance];
        
        [self getNoticeWithType:@"1"];// 跑马灯样式的公告消息
    });
     
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self stopGCDBalance];
}

- (void)initValue{

    self.homeWallet = [[PWDataBaseManager shared] queryWalletIsSelected];
    self.priceArray = [[NSMutableArray alloc] init];
    self.coinDatasource = [NSMutableArray arrayWithArray:[[PWDataBaseManager shared] queryCoinArrayBasedOnWalletIDAndShow]];

    [self.tableView reloadData];
}//娘雾义  圈饰真  昂萧旺  质载薄  诉委士

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
        
        [weakSelf downRefresh];
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

/**
 * 下拉刷新
 */
- (void)downRefresh
{
    WEAKSELF
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    dispatch_async(queue, ^{
        [self requestQuationList];
    });

    for (int i = 0; i < self.coinDatasource.count; i ++) {
        dispatch_async(queue, ^{
            if (weakSelf.coinDatasource.count != 0)
            {

                LocalCoin *coin = [weakSelf.coinDatasource objectAtIndex:i];
                // 防止出现币种没有地址的情况
                if (coin.coin_address == nil
                    || [coin.coin_address isEqualToString:@""]
                    || coin.coin_address.length <= 0)
                {
                    for (LocalCoin *localCoin in weakSelf.coinDatasource)
                    {
                        if ([localCoin.coin_chain isEqualToString:coin.coin_chain] && [localCoin.coin_chain isEqualToString:localCoin.coin_type]) {
                            coin.coin_address = localCoin.coin_address;
                        }
                        
                    }
                }

                if (coin.coin_type_nft == 10) { // 合约币
                    [PWContractRequest getBalancewithCoinType:coin.coin_chain
                                                      address:coin.coin_address
                                                       execer:coin.coin_pubkey
                                                      success:^(id  _Nonnull object) {
                        NSError *error;
                        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:object options:NSJSONReadingAllowFragments error:&error];
                        NSLog(@"result %@",result);
                        if (![result[@"result"] isKindOfClass:[NSNull class]]) {
                            CGFloat balance = [result[@"result"][@"balance"] doubleValue];
                            if (balance != -1)
                            {
                                // 有余额
                                coin.coin_balance = balance;

                                if(i < weakSelf.coinDatasource.count)
                                {
                                    [weakSelf.coinDatasource replaceObjectAtIndex:i withObject:coin];
                                }
                                [[PWDataBaseManager shared] updateCoin:coin];
                            }
                        }
                    } failure:^(NSString * _Nonnull errorMsg) {
                        
                    }];
                    
                }else{
                    CGFloat balance = [GoFunction goGetBalance:coin.coin_type platform:coin.coin_platform address:coin.coin_address andTreaty:coin.treaty];
                    if (balance != -1)
                    {
                        // 有余额
                        coin.coin_balance = balance;

                        if(i < weakSelf.coinDatasource.count)
                        {
                            [weakSelf.coinDatasource replaceObjectAtIndex:i withObject:coin];
                        }
                        [[PWDataBaseManager shared] updateCoin:coin];
                    }
                }
            }
        });
    }
}

#pragma mark 网络请求
- (void)requestQuationList
{
    
    NSMutableArray *nameArray = [[NSMutableArray alloc] init];
    NSArray *coinArray =  [NSArray arrayWithArray:[[PWDataBaseManager shared] queryCoinArrayBasedOnSelectedWalletID]];
    for (int i = 0; i < coinArray.count; i ++) {
        LocalCoin *coin = [coinArray objectAtIndex:i];
        NSString *name = [NSString stringWithFormat:@"%@,%@",coin.coin_type,coin.coin_platform];

        if (![nameArray containsObject:name])
        {
            [nameArray addObject:name];
        }
    }
    __weak typeof(self)weakself = self;
    
    NSDictionary *param = @{@"names":nameArray};
    _sessionTask = [[SGNetWork defaultManager] sendRequestMethod:HTTPMethodPOST serverUrl:WalletURL apiPath:HOMECOININDEX parameters:param progress:nil success:^(BOOL isSuccess, id  _Nullable responseObject) {
NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
        NSLog(@"home result is %@",result);
        [weakself.priceArray removeAllObjects];
        if ([result[@"data"] isEqual:[NSNull null]]) {
            return ;
        }
        NSArray *priceArray = result[@"data"];
        
        for(int i = 0;i < priceArray.count; i++)
        {
            NSDictionary *dic = [priceArray objectAtIndex:i];
            
            if ([dic isKindOfClass:[NSNull class]]) {
                continue;
            }
            
            if([dic[@"platform"] isEqualToString:@"OTHER"])
            {
                continue;
            }
            
            if (![dic[@"name"] isEqualToString:@"TEST"]) {
                [[PWDataBaseManager shared] upadateCoin:[dic[@"id"] integerValue] platform:dic[@"platform"] cointype:dic[@"name"]];
            }
           
            
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
            [weakself.priceArray addObject:coinPrice];
            [[PWDataBaseManager shared] addCoinPrice:coinPrice];
            
        }
//        if (weakself.homeViewBlock) {
//            weakself.homeViewBlock();
//        }
        [self.tableView reloadData];
        
    } failure:^(NSString * _Nullable errorMessage) {
        [self hideProgress];
    }];
}

#pragma mark - 检查更新
- (void)checkUpdate:(NSNotification *)infoNotification {
    
    NSDictionary *data = [infoNotification userInfo][@"updatekey"];
    
    [PWLoginTool checkUpdate:self data:data];
}
#pragma mark - UITableViewDelegate UITableViewDatasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(_coinDatasource.count==0){
        return 1;
    }else{
        return _coinDatasource.count;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.coinDatasource.count > 0) {
        LocalCoin *coin = [_coinDatasource objectAtIndex:section];
        if (![self.localArray containsObject:coin.coin_chain] && coin.coin_chain != nil) {
            [self.localArray addObject:coin.coin_chain];
        }
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(_coinDatasource.count==0){
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

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{

    HomeCoinTableViewCell *homeCell = (HomeCoinTableViewCell *)cell;
    homeCell.backgroundColor = SGColorFromRGB(0xf8f8fa);
    if(indexPath.row < _coinDatasource.count)
    {
        LocalCoin *coin = [_coinDatasource objectAtIndex:indexPath.section];
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

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
        
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
        assetLab.font = [UIFont systemFontOfSize:30.f];
        assetLab.textColor = SGColorFromRGB(0xffffff);
        assetLab.textAlignment = NSTextAlignmentLeft;
        [headView addSubview:titleLab];
        [headView addSubview:assetLab];
        
        UIButton *addCoinBtn = [[UIButton alloc] init];
        [addCoinBtn setImage:[UIImage imageNamed:@"home_addcoin"] forState:UIControlStateNormal];
        [addCoinBtn addTarget:self action:@selector(toSearchVC:) forControlEvents:UIControlEventTouchUpInside];
        [addCoinBtn setContentMode:UIViewContentModeScaleAspectFit];
        
        [headView addSubview:addCoinBtn];
        
        titleLab.text = [NSString stringWithFormat:@"%@",self.homeWallet.wallet_name];

        switch (self.homeWallet.wallet_issmall) {
            case 1:
            {
                // HD钱包
                bgImgView.image = [UIImage imageNamed:@"home_hd_bg"];
                assetLab.text = @"助记词钱包".localized;
            }
                break;
            case 2:
            {
                //  导入私钥创建的钱包
                bgImgView.image = [UIImage imageNamed:@"home_hd_bg"];
                assetLab.text = @"私钥钱包".localized;
                NSArray *array = [[PWDataBaseManager shared] queryCoinArrayBasedOnWallet:self.homeWallet];
                NSString *mainStr = @"";
                LocalCoin *coin = array[0];
                mainStr = coin.coin_chain;
                bgImgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"home_%@_bg",mainStr]];
                iconImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"home_%@_icon",coin.coin_type]];
                if(iconImageView.image==nil){
                    iconImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"home_%@_icon",mainStr]];
                }
            }
                break;
            case 3:
            {
                iconImageView.hidden = NO;
                assetLab.text = @"观察钱包".localized;
                NSArray *infoArray = [self.homeWallet.wallet_password componentsSeparatedByString:@":"];
                bgImgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"home_%@_bg",infoArray[0]]];
                if (bgImgView.image == nil) {
                    bgImgView.image = [UIImage imageNamed:@"home_BTY_bg"];
                }
                iconImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"home_%@_icon",infoArray[0]]];

                if([infoArray[0] isEqualToString:@"BTY"]){
                    iconImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"home_%@_icon",@"BTY"]];
                }
                if(iconImageView.image==nil){
                    iconImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"home_%@_icon",infoArray[0]]];
                }
               
            }
                break;
            case 4:
            {
                // 4 找回钱包
                bgImgView.image = [UIImage imageNamed:@"home_hd_bg"];
                NSArray *array = [[PWDataBaseManager shared] queryCoinArrayBasedOnWallet:self.homeWallet];
                NSString *mainStr = @"";
                LocalCoin *coin = array[0];
                mainStr = coin.coin_chain;
                bgImgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"home_%@_bg",mainStr]];
                iconImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"home_%@_icon",coin.coin_type]];
                if(iconImageView.image==nil){
                    iconImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"home_%@_icon",mainStr]];
                }
                
            }
                break;
            default:
                break;
        }
        
        UIView *noticeView = [[UIView alloc] init];
        noticeView.backgroundColor = SGColorFromRGB(0x8e92a3);
        noticeView.layer.cornerRadius = 15.f;
        
        [headView addSubview:noticeView];
        
        UIImageView *lingImageView = [[UIImageView alloc] init];
        lingImageView.image = [UIImage imageNamed:@"铃铛"];
        lingImageView.contentMode = UIViewContentModeScaleAspectFit;
        
        [noticeView addSubview:lingImageView];
        
        // 跑马灯
        _verticalMarquee = [[JhtVerticalMarquee alloc] initWithFrame:CGRectMake(32, 2, kScreenWidth - 32 - 32 - 10, 26)];
        _verticalMarquee.numberOfLines = 0;
        _verticalMarquee.backgroundColor = SGColorFromRGB(0x8e92a3);
        _verticalMarquee.textColor = SGColorFromRGB(0xffffff);
        _verticalMarquee.scrollDelay = 2.f;
        
        
        UITapGestureRecognizer *vtap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(marqueeTapGes:)];
        [_verticalMarquee addGestureRecognizer:vtap];
        
        [noticeView addSubview:self.verticalMarquee];
        [self.verticalMarquee scrollWithCallbackBlock:^(JhtVerticalMarquee *view, NSInteger currentIndex) {
            
        }];
        
        if (self.noticeArray.count != 0) {
            noticeView.hidden = NO;
            self.verticalMarquee.sourceArray = self.noticeTitleArray;
            [self.verticalMarquee marqueeOfSettingWithState:MarqueeStart_V];
        }
        else
        {
            noticeView.hidden = YES;
            [self.verticalMarquee marqueeOfSettingWithState:MarqueeShutDown_V];
        }
        
        
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
            make.top.equalTo(titleLab.mas_bottom).offset(28);
        }];
        
        [addCoinBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(headView).offset(-30);
            make.width.height.mas_equalTo(36 * kScreenRatio);
            make.top.equalTo(headView).offset(78);
        }];
        
        
        [noticeView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(headView).offset(16);
            make.right.equalTo(headView).offset(-16);
            make.bottom.equalTo(headView).offset(-10);
            make.height.mas_equalTo(30);
        }];
        
        [lingImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(noticeView).offset(14);
            make.top.equalTo(noticeView).offset(8);
            make.width.mas_equalTo(12*kScreenRatio);
            make.height.mas_equalTo(15*kScreenRatio);
        }];
        
        return headView;
    }
    return nil;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        if (self.noticeArray.count != 0)
        {
            return 190.f;
        }
          
        return 150.f;
    }
    
    return 10.f;

}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return .0001f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_coinDatasource.count == 0) {
        return kScreenHeight;
    }
    return 70.f;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < _coinDatasource.count)
    {
        LocalCoin *coin = [_coinDatasource objectAtIndex:indexPath.section];
        CoinDetailViewController *vc = [[CoinDetailViewController alloc] init];
        vc.hidesBottomBarWhenPushed = YES;
        vc.selectedCoin = coin;
        [self.navigationController pushViewController:vc animated:YES];
    }

}

#pragma mark - showMore
- (void)showMore:(id)sender
{
    PWNewsWalletSettingViewController *settingVC = [[PWNewsWalletSettingViewController alloc] init];
    settingVC.localWallet = self.homeWallet;
    settingVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:settingVC animated:YES];

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

#pragma mark - 消息中心
- (void)getNoticeWithType:(NSString *)type
{
    NSDictionary *param = @{@"size":@(3),
                            @"type":type
    };
    NSString *url = [NSString stringWithFormat:@"%@%@",WalletURL,HOME_NOTICE_URL];
    
    
   WEAKSELF
    [PWNetworkingTool getRequestWithUrl:url
                             parameters:param
                           successBlock:^(id object) {
        NSLog(@"获取消息成功，返回数据：%@",object);
        NSArray *array = object[@"list"];
        if (![array isKindOfClass:[NSNull class]])
        {
            if (type.integerValue == 1)
            {
                if (array.count == 0)
                {
                    [self.verticalMarquee marqueeOfSettingWithState:MarqueeShutDown_V];
                    [weakSelf.tableView reloadData];
                }
                else
                {
                    NSMutableArray *marray = [[NSMutableArray alloc] init];
                    NSMutableArray *nameArray = [[NSMutableArray alloc] init];
                    for (NSDictionary *dic in array) {
                        PWHomeNoticeModel *model = [PWHomeNoticeModel yy_modelWithDictionary:dic];
                        [nameArray addObject:model.title];
                        [marray addObject:model];
                    }
                    weakSelf.noticeArray = [NSArray arrayWithArray:marray];
                    weakSelf.noticeTitleArray = [NSArray arrayWithArray:nameArray];
                    [self.tableView reloadData];
                }
            }
        }
            
    } failureBlock:^(NSError *error) {
        
    }];
}
#pragma mark - 设置导航栏左右的按钮
- (UIBarButtonItem *)leftBarButtonItem
{
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [btn setImage:[UIImage imageNamed:@"home_scan"] forState:UIControlStateNormal];
    [btn setContentMode:UIViewContentModeScaleAspectFit];
    btn.tag = 1;
    [btn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    return item;

    
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


- (UIBarButtonItem *)TrightBarButtonItem
{
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [btn setImage:[UIImage imageNamed:@"home_scan"] forState:UIControlStateNormal];
    [btn setContentMode:UIViewContentModeScaleAspectFit];
    btn.tag = 3;
    [btn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];

    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:btn];

    return item;
}//折渔般  峡鸣活  薄待移  通元等  绳汗物

- (void)btnAction:(UIButton *)sender
{
    switch (sender.tag) {
        case 1:
        {
            ScanViewController *vc = [[ScanViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
            vc.scanResult = ^(NSString *address) {
                if([address hasPrefix:@"wc:"]){
                    // walletconnect
                    // 获取控制器
                    AppDelegate *appdelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
                    UIViewController *rootVc = appdelegate.window.rootViewController;
                    for (UIViewController *controller in rootVc.childViewControllers) {
                        if ([controller isKindOfClass:[PWNavigationController class]]) {
                            [controller removeFromParentViewController];
                        }
                    }
                    UIViewController *tmpController = [[UIViewController alloc] init];
                    appdelegate.window.rootViewController = tmpController;
                    
                    V2DappViewController *dappvc = [[V2DappViewController alloc] init];
                    PWNavigationController *dappNC = [[PWNavigationController alloc] initWithRootViewController:dappvc];
                    dappvc.wcurl = address;
                    
                    NSArray *coinArray = [[PWDataBaseManager shared] queryCoinArrayBasedOnWalletIDAndShow];
                    for (LocalCoin *coin in coinArray) {
                        if ([coin.coin_type isEqualToString:@"BTY"] && [coin.coin_chain isEqualToString:@"ETH"]) {
                            dappvc.btyCoin = coin;
                        }
                        if ([coin.coin_type isEqualToString:@"ETH"] && [coin.coin_chain isEqualToString:@"ETH"]) {
                            dappvc.ethCoin = coin;
                            
                        }
                        if ([coin.coin_type isEqualToString:@"BNB"] && [coin.coin_chain isEqualToString:@"BNB"]) {
                            dappvc.bnbCoin = coin;
                        }
                    }
                    
                    [tmpController addChildViewController:rootVc];
                    [tmpController addChildViewController:dappNC];
                    [tmpController.view addSubview:rootVc.view];
                    
                    [tmpController transitionFromViewController:rootVc
                                               toViewController:dappNC
                                                       duration:0.1
                                                        options:UIViewAnimationOptionTransitionCurlUp
                                                     animations:^{
                        
                    } completion:^(BOOL finished) {
//                        self.showDappVc = YES;
                    }];
                    
//                    [self.navigationController pushViewController:dappvc animated:YES];
                    return;
                }
            };
        }
            break;
        case 2:
        {
            [self.navigationController pushViewController:[self createPWMyWalletVCWithSwitchType:SwitchWalletTypeSwitch] animated:YES];
        }
            break;
        case 3:
        {
            PWContractVC *vc = [[PWContractVC alloc] init];
            vc.hidesBottomBarWhenPushed = true;
            vc.contractBlock = ^{
                [self initValue];
            };
            [self.navigationController pushViewController:vc animated:true];
        }
            break;
        default:
            break;
    }
    
}

- (UIViewController *)createPWMyWalletVCWithSwitchType:(SwitchWalletType)switchWalletType
{
    PWSwitchWalletViewController *switchVC = [[PWSwitchWalletViewController alloc] init];
    switchVC.switchWalletType = switchWalletType; // 切换钱包
    switchVC.hidesBottomBarWhenPushed = YES;
    switchVC.refreshHomeView = ^(NSInteger walletId) {
        self.walletId = walletId;
        [self initValue];
    };
    return switchVC;
}



#pragma mark - 跑马灯
- (void)marqueeTapGes:(id)sender
{
    PWMessageCenterController *vc = [[PWMessageCenterController alloc] init];
    //    PWSystemMessageController *vc = [[PWSystemMessageController alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    vc.index = 1;
    vc.title = @"消息中心".localized;
    [self.navigationController pushViewController:vc animated:YES];
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


@end
