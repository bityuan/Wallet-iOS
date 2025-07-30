//
//  PWNewsSearchCoinViewController.m
//  PWallet
//
//  Created by 郑晨 on 2020/1/3.
//  Copyright © 2020 陈健. All rights reserved.
//

#import "PWNewsSearchCoinViewController.h"
#import "PWSearchCoinChildViewController.h"
#import "CAPSPageMenu.h"
#import "SearchCoinViewController.h"


@interface PWNewsSearchCoinViewController ()
<CAPSPageMenuDelegate,UITextFieldDelegate>

@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) NSMutableArray *titleArray;
@property (nonatomic, strong) NSMutableArray *nameArrray;
@property (nonatomic, strong) UITextField *searchTextField;
@property (nonatomic, strong) CAPSPageMenu *pageMenu;
@property (nonatomic) BOOL exitSearch; // 退出了搜索页面

@end

@implementation PWNewsSearchCoinViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.whiteColor;
    [self initTitleView];
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.searchTextField endEditing:YES];
    });
    
    if (@available(iOS 13.0, *)) {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDarkContent;
    } else {
           // Fallback on earlier versions
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    }
    [self getWalletSupportChain];

}

- (void)initTitleView
{
    _searchTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 257 * kScreenRatio, 36)];
    _searchTextField.placeholder = @"输入Token名称或合约地址".localized;
    _searchTextField.backgroundColor = SGColorFromRGB(0xf8f8fa);
    _searchTextField.font = [UIFont systemFontOfSize:16.f];
    _searchTextField.textColor = SGColorFromRGB(0x333649);
    _searchTextField.leftViewMode = UITextFieldViewModeAlways;
    _searchTextField.delegate = self;
    [_searchTextField setValue:SGColorFromRGB(0x8a97a5) forKeyPath:@"placeholderLabel.textColor"];
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 36, 36)];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(6, 9, 23, 23)];
    imageView.image = [UIImage imageNamed:@"APP搜索"];
    [leftView addSubview:imageView];
    
    _searchTextField.leftView = leftView;


    self.navigationItem.titleView = _searchTextField;
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"取消".localized style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    [rightItem setTintColor:SGColorFromRGB(0x8e92a3)];
    [rightItem setTitleTextAttributes:@{NSForegroundColorAttributeName:SGColorFromRGB(0x8e92a3)} forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    
}

//重写返回方法
- (void)backAction{
    [self cancel];
}

//取消搜索
- (void)cancel {
    [self.view endEditing:true];
    [self.navigationController popViewControllerAnimated:false];
}

- (void)createView
{
    NSMutableArray *childVC = [[NSMutableArray alloc] init];
    for (NSString *title in _titleArray) {
        PWSearchCoinChildViewController *coinChildVc = [[PWSearchCoinChildViewController alloc] init];
        coinChildVc.title = title;
        [childVC addObject:coinChildVc];
    }
    
        
    NSDictionary *parameters = @{
        CAPSPageMenuOptionBottomMenuHairlineColor: SGColorFromRGB(0xececec),
        CAPSPageMenuOptionScrollMenuBackgroundColor: [UIColor whiteColor],
        CAPSPageMenuOptionSelectionIndicatorHeight: @(3),
        CAPSPageMenuOptionMenuHeight:@(40),
        CAPSPageMenuOptionMenuItemWidth:@(75),
        CAPSPageMenuOptionUnselectedMenuItemLabelColor: SGColorFromRGB(0x8e92a3),
        CAPSPageMenuOptionSelectedMenuItemLabelColor: SGColorFromRGB(0x333649),
        CAPSPageMenuOptionSelectionIndicatorColor: SGColorFromRGB(0x333649),
        CAPSPageMenuOptionMenuItemFont:[UIFont boldSystemFontOfSize:16],
        CAPSPageMenuOptionMenuSelectedItemFont:[UIFont boldSystemFontOfSize:16],
        CAPSPageMenuOptionAddBottomMenuHairline:@(YES),
        CAPSPageMenuOptionMenuMargin:@(20),
        CAPSPageMenuOptionMenuItemWidthBasedOnTitleTextWidth:@(YES),
        CAPSPageMenuOptionHideIndicator:@(YES)
    };
    
    self.pageMenu = [[CAPSPageMenu alloc] initWithViewControllers:childVC frame:CGRectMake(0,0, kScreenWidth, kScreenHeight - kBottomOffset - 40) options:parameters];
    self.pageMenu.delegate = self;
    [self addChildViewController:self.pageMenu];
    
    [self.view addSubview:self.pageMenu.view];
    self.pageMenu.currentPageIndex = 0;
    
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if(!self.exitSearch){
        [self searchCoinAction];
    }else{
        self.exitSearch = NO;
    }
    
    return YES;
}

/**
 * 搜索币种
 */
- (void)searchCoinAction
{
    
    SearchCoinViewController *vc = [[SearchCoinViewController alloc] init];
    vc.dismissBlock = ^{
        self.exitSearch = YES;
    };
    [self.navigationController pushViewController:vc
                                         animated:false];
}

#pragma mark -- CAPSPageMenuDelegate
- (void)didMoveToPage:(UIViewController *)controller index:(NSInteger)index
{
    NSLog(@"did move index is %li",(long)index);
    [[NSNotificationCenter defaultCenter] postNotificationName:SEARCHCOINNOTIFICATION object:_nameArrray[index]];
}

- (void)willMoveToPage:(UIViewController *)controller index:(NSInteger)index
{
    NSLog(@"will move index is %li",(long)index);

}

#pragma mark - 获取主链币种
- (void)getWalletSupportChain
{
    NSString *url = [NSString stringWithFormat:@"%@%@",WalletURL,RECOMMENDCOIN];
    WEAKSELF
    [PWNetworkingTool getRequestWithUrl:url
                             parameters:nil
                           successBlock:^(id object) {
        NSLog(@"objectis %@",object);
        if([object isKindOfClass:[NSNull class]])
        {
            return ;
        }
        NSArray *array = (NSArray*)object;
        [self initData:array];
        
    } failureBlock:^(NSError *error) {
        weakSelf.titleArray = [[NSMutableArray alloc] init];
        weakSelf.nameArrray = [[NSMutableArray alloc] init];
        [weakSelf.titleArray addObject:@"首页币种".localized];
        [weakSelf.nameArrray addObject:@{@"name":@"首页币种".localized,
                                    @"coinArray":@[]}];
        [self createView];
    }];
}

- (void)initData:(NSArray *)array
{
    self.dataArray = array;
    self.titleArray = [[NSMutableArray alloc] init];
    self.nameArrray = [[NSMutableArray alloc] init];
    [self.titleArray addObject:@"首页币种".localized];
    [self.nameArrray addObject:@{@"name":@"首页币种".localized,
                                 @"coinArray":@[]}];
    
    for (int i = 0; i < self.dataArray.count; i++) {
        // 导航栏
        NSString *nameStr = [NSString stringWithFormat:@"%@",[self.dataArray[i] objectForKey:@"name"]];
        if (IS_BLANK(nameStr)) {
            continue;
        }
        if (isPriKeyWallet )
        {
            NSString *titleStr = [NSString stringWithFormat:@"%@",[self.dataArray[i] objectForKey:@"name"]];
            NSArray *arr = [[PWDataBaseManager shared] queryCoinArrayBasedOnWallet:self.selectedWallet];
            NSString *mainStr = @"";
            LocalCoin *coin = arr[0];
            mainStr = coin.coin_chain;
            if (i == 0)
            {
                [self.titleArray addObject:titleStr];
                NSArray *coinArray = [self.dataArray[i] objectForKey:@"items"];
                for(int i = 0;i < coinArray.count; i++)
                {

                    NSDictionary *dic = [coinArray objectAtIndex:i];
                    CoinPrice *localCoinprice = [[PWDataBaseManager shared] queryCoinPriceBasedOn:dic[@"name"] platform:dic[@"platform"] andTreaty:[dic[@"treaty"] integerValue]];
                    CoinPrice *coinPrice = [[CoinPrice alloc] init];
                    coinPrice.coinprice_name = dic[@"name"];
                    coinPrice.coinprice_price = localCoinprice == nil ? 0.00 : localCoinprice.coinprice_price; //[CommonFunction handlePrice:priceStr];
                    coinPrice.coinprice_dollarPrice = localCoinprice == nil ? 0.00 : localCoinprice.coinprice_dollarPrice;
                    coinPrice.coinprice_icon = dic[@"icon"];
                    coinPrice.coinprice_sid = dic[@"sid"];
                    coinPrice.coinprice_nickname = dic[@"nickname"];
                    coinPrice.coinprice_id = [dic[@"id"] integerValue];
                    coinPrice.coinprice_chain = dic[@"chain"];
                    coinPrice.coinprice_platform = dic[@"platform"];
                    coinPrice.coin_sort = [dic[@"sort"] integerValue];
                    coinPrice.treaty = [dic[@"treaty"] integerValue];
                    coinPrice.coinprice_optional_name = dic[@"optional_name"];
                    coinPrice.coinprice_chain_country_rate = localCoinprice == nil ? 0.00 : localCoinprice.coinprice_chain_country_rate;
                    coinPrice.coinprice_country_rate = localCoinprice == nil ? 0.00 : localCoinprice.coinprice_country_rate;
                    coinPrice.lock = localCoinprice == nil ? 0 : localCoinprice.lock;
                    
                    [[PWDataBaseManager shared] addCoinPrice:coinPrice];
                }

                NSMutableArray *nameArray = [NSMutableArray array];
                for (NSDictionary *coin in coinArray) {
                    NSString *chainStr = coin[@"chain"];
                    if (![coin[@"platform"] isEqualToString:@"other"])
                    {
                        for (NSString * name in self.localArray) {
                            if ([chainStr isEqualToString:name]) {
                                [nameArray addObject:coin];
                            }
                        }
//                        if ([mainStr isEqualToString:chainStr])
//                        {
//                            [nameArray addObject:coin];
//                        }
                    }
                }

                NSDictionary *dict = @{@"name":nameStr,
                                       @"coinArray":nameArray};
                [self.nameArrray addObject:dict];
            }
           
            if ([nameStr containsString:mainStr])
            {
                [self.titleArray addObject:titleStr];
                NSArray *coinArray = [self.dataArray[i] objectForKey:@"items"];
                for(int i = 0;i < coinArray.count; i++)
                {
                    NSDictionary *dic = [coinArray objectAtIndex:i];
                    CoinPrice *localCoinprice = [[PWDataBaseManager shared] queryCoinPriceBasedOn:dic[@"name"] platform:dic[@"platform"] andTreaty:[dic[@"treaty"] integerValue]];
                    CoinPrice *coinPrice = [[CoinPrice alloc] init];
                    coinPrice.coinprice_name = dic[@"name"];
                    coinPrice.coinprice_price = localCoinprice == nil ? 0.00 : localCoinprice.coinprice_price; //[CommonFunction handlePrice:priceStr];
                    coinPrice.coinprice_dollarPrice = localCoinprice == nil ? 0.00 : localCoinprice.coinprice_dollarPrice;
                    coinPrice.coinprice_icon = dic[@"icon"];
                    coinPrice.coinprice_sid = dic[@"sid"];
                    coinPrice.coinprice_nickname = dic[@"nickname"];
                    coinPrice.coinprice_id = [dic[@"id"] integerValue];
                    coinPrice.coinprice_chain = dic[@"chain"];
                    coinPrice.coinprice_platform = dic[@"platform"];
                    coinPrice.coin_sort = [dic[@"sort"] integerValue];
                    coinPrice.treaty = [dic[@"treaty"] integerValue];
                    coinPrice.coinprice_optional_name = dic[@"optional_name"];
                    coinPrice.coinprice_chain_country_rate = localCoinprice == nil ? 0.00 : localCoinprice.coinprice_chain_country_rate;
                    coinPrice.coinprice_country_rate = localCoinprice == nil ? 0.00 : localCoinprice.coinprice_country_rate;
                    coinPrice.lock = localCoinprice == nil ? 0 : localCoinprice.lock;
                    [[PWDataBaseManager shared] addCoinPrice:coinPrice];
                }
                
                NSMutableArray *nameArray = [NSMutableArray array];
                for (NSDictionary *coin in coinArray) {
                    if (![coin[@"platform"] isEqualToString:@"other"])
                    {
                        
                        [nameArray addObject:coin];
                    }
                }
                NSDictionary *dict = @{@"name":nameStr,
                                       @"coinArray":nameArray};
                [self.nameArrray addObject:dict];
            }
            
#pragma mark =====以下代码放在if里面
        }
        else
        {
            NSString *titleStr = [NSString stringWithFormat:@"%@",[self.dataArray[i] objectForKey:@"name"]];
            [self.titleArray addObject:titleStr];
            if (i == 0) {
                nameStr = [NSString stringWithFormat:@"%i",i + 1];
            }
            
            NSArray *coinArray = [self.dataArray[i] objectForKey:@"items"];
            for(int i = 0;i < coinArray.count; i++)
            {
                NSDictionary *dic = [coinArray objectAtIndex:i];
                if ([dic[@"name"] isKindOfClass:[NSNull class]]) {
                    continue;
                }
                CoinPrice *localCoinprice = [[PWDataBaseManager shared] queryCoinPriceBasedOn:dic[@"name"] platform:dic[@"platform"] andTreaty:[dic[@"treaty"] integerValue]];
                CoinPrice *coinPrice = [[CoinPrice alloc] init];
                coinPrice.coinprice_name = dic[@"name"];
                coinPrice.coinprice_price = localCoinprice == nil ? 0.00 : localCoinprice.coinprice_price; //[CommonFunction handlePrice:priceStr];
                coinPrice.coinprice_dollarPrice = localCoinprice == nil ? 0.00 : localCoinprice.coinprice_dollarPrice;
                coinPrice.coinprice_icon = dic[@"icon"];
                coinPrice.coinprice_sid = dic[@"sid"];
                coinPrice.coinprice_nickname = dic[@"nickname"];
                coinPrice.coinprice_id = [dic[@"id"] integerValue];
                coinPrice.coinprice_chain = dic[@"chain"];
                coinPrice.coinprice_platform = dic[@"platform"];
                coinPrice.coin_sort = [dic[@"sort"] integerValue];
                coinPrice.treaty = [dic[@"treaty"] integerValue];
                coinPrice.coinprice_optional_name = dic[@"optional_name"];
                coinPrice.coinprice_chain_country_rate = localCoinprice == nil ? 0.00 : localCoinprice.coinprice_chain_country_rate;
                coinPrice.coinprice_country_rate = localCoinprice == nil ? 0.00 : localCoinprice.coinprice_country_rate;
                coinPrice.lock = localCoinprice == nil ? 0 : localCoinprice.lock;
                [[PWDataBaseManager shared] addCoinPrice:coinPrice];
            }
            
            NSMutableArray *nameArray = [NSMutableArray array];
            for (NSDictionary *coin in coinArray) {
                if ([coin[@"platform"] isKindOfClass:[NSNull class]]) {
                    continue;
                }
                if (![coin[@"platform"] isEqualToString:@"other"])
                {
                    
                    [nameArray addObject:coin];
                }
            }
            
            NSDictionary *dict = @{@"name":nameStr,
                                   @"coinArray":nameArray};
            [self.nameArrray addObject:dict];
        }
    }
    
    [self createView];
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
