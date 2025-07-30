//
//  ContactCoinViewController.m
//  PWallet
//
//  Created by 宋刚 on 2018/6/14.
//  Copyright © 2018年 陈健. All rights reserved.
//

#import "ContactCoinViewController.h"
#import "PWSuggestionsCoinTool.h"

#define whiteViewWidth (kScreenWidth * 0.81)

@interface ContactCoinViewController ()<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate>
@property (nonatomic,strong) UIView *blackView;
@property (nonatomic,strong) UIView *whiteView;
@property (nonatomic,strong) UISearchBar *searchBar;
@property (nonatomic,strong) UITableView *coinTableView;
@property (nonatomic,assign) NSInteger page;
@property (nonatomic,strong) NSMutableArray *datasourceArray;
@end

static const NSInteger limit = 10;

@implementation ContactCoinViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _page = 1;
    
    [self allocDatasourceArray];
    
    // Do any additional setup after loading the view.
    [self createView];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.blackView.alpha = 1;
        [self.whiteView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.view);
        }];
        [self.view layoutIfNeeded];
    } completion:nil];
    
}

- (void)hideCompletion:(void(^)(void))completion {
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        [self.whiteView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.view).offset(whiteViewWidth);
        }];
        [self.view layoutIfNeeded];
        self.blackView.alpha = 0;
    } completion:^(BOOL finished) {
        [self dismissViewControllerAnimated:false completion:^{
            if (completion) {
                completion();
            }
        }];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) allocDatasourceArray{
    self.datasourceArray = [[NSMutableArray alloc] init];
    [PWSuggestionsCoinTool loadSuggestionsCoin:@"1" successBlock:^(id object) {
        NSArray *coinArray = (NSArray*)object;
        [self.datasourceArray addObjectsFromArray:coinArray];
        [self.coinTableView reloadData];
        
    } failureBlock:^(NSError *error) {
      
        NSArray *coinArray = [COINDEFAULT componentsSeparatedByString:@","];
        NSArray *platArray = [PLATFORMDEFAULT componentsSeparatedByString:@","];
        for (int i = 0; i < coinArray.count; i ++) {
            NSString *coinStr = [coinArray objectAtIndex:i];
            NSString *platStr = [platArray objectAtIndex:i];
            CoinPrice *coinPrice = [[PWDataBaseManager shared] queryCoinPriceBasedOn:coinStr platform:platStr andTreaty:1];
            if (coinPrice != nil && ![coinPrice isEqual:[NSNull null]]) {
                [self.datasourceArray addObject:coinPrice];
            }else
            {
                
            }
        }
         [self->_coinTableView reloadData];
        
    }];
};


- (void)createView
{
    UIView *blackView = [[UIView alloc] init];
    blackView.backgroundColor = CMColorRGBA(0, 0, 0, 0.5);
    [self.view addSubview:blackView];
    self.blackView = blackView;
    self.blackView.alpha = 0;
    
    UIView *whiteView = [[UIView alloc] init];
    whiteView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:whiteView];
    self.whiteView = whiteView;
    
    UISearchBar *searchBar = [[UISearchBar alloc] init];
    [whiteView addSubview:searchBar];
    self.searchBar = searchBar;
    searchBar.placeholder = @"搜索币种".localized;
//    searchBar.backgroundColor = CMColor(248, 248, 250);
    searchBar.showsCancelButton = NO;
    searchBar.barTintColor = CMColor(248, 248, 250);[UIColor whiteColor];
    searchBar.delegate = self;
    searchBar.layer.cornerRadius = 6;
    searchBar.layer.masksToBounds = YES;
    
    UIImageView *barImageView = [[[searchBar.subviews firstObject] subviews] firstObject];
    barImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    barImageView.layer.borderWidth = 1;
    UITextField *searchField = [searchBar valueForKey:@"searchField"];
    if(searchField) {
        [searchField setBackgroundColor:CMColor(248, 248, 250)];
        
        searchField.textColor = TextColor51;
        searchField.font= [UIFont systemFontOfSize:16];
        [searchField setValue:[UIFont systemFontOfSize:15] forKeyPath:@"placeholderLabel.font"];
        [searchField setValue:SGColorFromRGB(0x8e92a3) forKeyPath:@"placeholderLabel.textColor"];
        searchField.clearButtonMode = UITextFieldViewModeWhileEditing;
    }
   
    
    UITableView *coinTableView = [[UITableView alloc] init];
    coinTableView.delegate = self;
    coinTableView.dataSource = self;
    coinTableView.rowHeight = 51;
    coinTableView.backgroundColor = BgColor;
    coinTableView.showsVerticalScrollIndicator = NO;
    coinTableView.separatorColor = LineColor;
    coinTableView.backgroundColor = [UIColor whiteColor];
    [whiteView addSubview:coinTableView];
    self.coinTableView = coinTableView;
    
    //防止刷新出现闪动
    coinTableView.estimatedRowHeight = 0;
    coinTableView.estimatedSectionFooterHeight = 0;
    coinTableView.estimatedSectionHeaderHeight = 0;
    
    coinTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMore)];
    coinTableView.mj_footer.hidden = true;
    
    UITapGestureRecognizer *tapGesturRecognizer=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
    [self.blackView addGestureRecognizer:tapGesturRecognizer];
    
    UIView *bottomView = [[UIView alloc] init];
    coinTableView.tableFooterView = bottomView;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    [self.blackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(self.view);
    }];
    
    [self.whiteView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self.view);
        make.right.equalTo(self.view).offset(whiteViewWidth).priority(1);
        make.width.mas_equalTo(whiteViewWidth);
    }];
    //    self.whiteView.frame = CGRectMake(kScreenWidth, 0, whiteViewWidth, kScreenHeight);
    
    [self.searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.whiteView).with.offset(30);
        make.right.equalTo(self.whiteView).with.offset(-30);
        make.top.equalTo(self.whiteView).with.offset(kTopOffset - 34);
        make.height.mas_equalTo(40);
    }];
    
    [self.coinTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.whiteView);
        make.top.equalTo(self.searchBar.mas_bottom).with.offset(10);
    }];
    
}

#pragma mark-
#pragma mark UITableViewDelegate & UITableViewDatasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return self.datasourceArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    ContactCoinTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[ContactCoinTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    
    id object = [self.datasourceArray objectAtIndex:indexPath.row];
    if([object isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *dic = (NSDictionary *)object;
        ContactCoinTableViewCell *coinCell = (ContactCoinTableViewCell *)cell;
        coinCell.searchDic = dic;
    }else if ([object isKindOfClass:[CoinPrice class]])
    {
        CoinPrice *coinPrice = (CoinPrice *)object;
        ContactCoinTableViewCell *coinCell = (ContactCoinTableViewCell *)cell;
        coinCell.coinPrice = coinPrice;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self hideCompletion:nil];
    });
    
    id object = [self.datasourceArray objectAtIndex:indexPath.row];
    if([object isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *dic = (NSDictionary *)object;
        self.selectCoin(IS_BLANK(dic[@"optional_name"]) ? dic[@"name"] : dic[@"optional_name"],dic[@"name"],dic[@"platform"]);
    }else if ([object isKindOfClass:[CoinPrice class]])
    {
        CoinPrice *coinPrice = (CoinPrice *)object;
        self.selectCoin(coinPrice.coinprice_optional_name,coinPrice.coinprice_name,coinPrice.coinprice_platform);
    }
}

#pragma mark-
#pragma mark-UISearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    [self requestQuationList];
}

#pragma mark-
#pragma mark 网络请求
- (void)requestQuationList
{
    [self showProgressWithMessage:@""];
    
    NSString *nameStr = self.searchBar.text;
    __weak typeof(self)weakself = self;
    _page = 1;
    NSString *platformId = 0;
    
    NSDictionary *param = @{@"name":nameStr,@"page":@(_page),@"limit":@(limit),@"platform_id":platformId};
    [[SGNetWork defaultManager] sendRequestMethod:HTTPMethodPOST serverUrl:WalletURL apiPath:SEARCHCOINBYNAME parameters:param progress:nil success:^(BOOL isSuccess, id  _Nullable responseObject) {
        [self hideProgress];
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
        [weakself.datasourceArray removeAllObjects];
        NSArray *dataArrays = result[@"data"];
        if (dataArrays.count != 0) {
            weakself.page ++;
            [weakself.datasourceArray addObjectsFromArray:dataArrays];
        }
        [self.coinTableView reloadData];
        
        //返回的数据小于一页 隐藏上拉加载更多
        if (self.datasourceArray.count < limit) {
            self.coinTableView.mj_footer.hidden = true;
        } else {
            self.coinTableView.mj_footer.hidden = false;
            [self.coinTableView.mj_footer resetNoMoreData];
        }
    } failure:^(NSString * _Nullable errorMessage) {
        [self hideProgress];
    }];
}

/**
 * 加载更多
 */
- (void)loadMore
{
    __weak typeof(self)weakself = self;
    NSString *nameStr = self.searchBar.text;
    NSString *platformId = 0;
        
    NSDictionary *param = @{@"name":nameStr,@"page":@(_page),@"limit":@(limit),@"platform_id":platformId};
    [[SGNetWork defaultManager] sendRequestMethod:HTTPMethodPOST serverUrl:WalletURL apiPath:SEARCHCOINBYNAME parameters:param progress:nil success:^(BOOL isSuccess, id  _Nullable responseObject) {
        [self hideProgress];
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
        NSArray *dataArray = result[@"data"];
        if (dataArray.count != 0) {
            weakself.page ++;
            [weakself.datasourceArray addObjectsFromArray:dataArray];
            [weakself.coinTableView.mj_footer endRefreshing];
        } else {
            [weakself.coinTableView.mj_footer endRefreshingWithNoMoreData];
        }
        [self.coinTableView reloadData];
        
    } failure:^(NSString * _Nullable errorMessage) {
       
    }];
}

-(void)tapAction:(id)tap
{
    [self.searchBar resignFirstResponder];
    [self hideCompletion:nil];
}

@end
