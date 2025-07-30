//
//  PWChoiceChainViewController.m
//  PWallet
//
//  Created by 郑晨 on 2019/10/21.
//  Copyright © 2019 陈健. All rights reserved.
//

#import "PWChoiceChainViewController.h"
#import "PWChoiceChainCell.h"
#import "ImportAddressViewController.h"

#define chainNameArray @[@"BTC",@"BTY",@"ETH",@"DCR"]
#define chainImageNameArray @[@"chain_btc",@"chain_bty",@"chain_eth",@"chain_dcr"]

@interface PWChoiceChainViewController ()
<UITableViewDelegate,UITableViewDataSource,PWChoiceChainCellDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataArray;

@end

@implementation PWChoiceChainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"选择主链".localized ;
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self getWalletSupportChain];
}
#pragma mark - uitableviewdelegate datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identity = @"chaincell";
    PWChoiceChainCell *cell = [tableView dequeueReusableCellWithIdentifier:identity];
    if (!cell) {
        cell = [[PWChoiceChainCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identity];
    }
    cell.coinLab.text = [self.dataArray[indexPath.section] objectForKey:@"name"];
    [cell.logoImageView sd_setImageWithURL:[NSURL URLWithString:[self.dataArray[indexPath.section] objectForKey:@"icon"]]];
    cell.delegate = self;
    if ([cell.coinLab.text isEqualToString:_chainStr])
    {
        [cell.choiceBtn setImage:[UIImage imageNamed:@"chain_selected"] forState:UIControlStateNormal];
    }
    else
    {
        [cell.choiceBtn setImage:[UIImage imageNamed:@"chain_unselected"] forState:UIControlStateNormal];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return .1f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (_choiceType) {
        case ChoiceTypPri:
        {
            if (self.choiceChainBlock)
            {
                self.choiceChainBlock([self.dataArray[indexPath.section] objectForKey:@"chain"], [self.dataArray[indexPath.section] objectForKey:@"icon"],[self.dataArray[indexPath.section] objectForKey:@"name"]);
                [self.navigationController popViewControllerAnimated:YES];
                
            }
        }
            break;
        case ChoiceTypeAdd:
        {
            ImportAddressViewController *addressVC = [[ImportAddressViewController alloc] initWithChainName:[self.dataArray[indexPath.section] objectForKey:@"chain"]
                                                                                                  ChainIcon:[self.dataArray[indexPath.section] objectForKey:@"icon"]
                                                                                                   CoinName:[self.dataArray[indexPath.section] objectForKey:@"name"]];
            addressVC.title = @"导入观察钱包";
            
            [self.navigationController pushViewController:addressVC animated:YES];
        }
            break;
        default:
            break;
    }
   
}

#pragma mark - 获取钱包支持的主链和可以导入的币种信息
- (void)getWalletSupportChain
{
    NSString *url = [NSString stringWithFormat:@"%@%@",WalletURL,SUPPORTEDCHAIN];
    WEAKSELF
    [self showProgressWithMessage:@""];
    [PWNetworkingTool getRequestWithUrl:url
                             parameters:nil
                           successBlock:^(id object) {
        [self hideProgress];
        NSLog(@"objectis %@",object);
        if([object isKindOfClass:[NSNull class]])
        {
            return ;
        }
        NSArray *array = (NSArray*)object;
        weakSelf.dataArray = array;
        [self.tableView reloadData];
    } failureBlock:^(NSError *error) {
        [self hideProgress];
        [self showError:error hideAfterDelay:2.f];
    }];
}


#pragma mark - PWChoiceChainCellDelegate
- (void)choiceChain:(UIButton *)sender cell:(UITableViewCell *)cell
{
    PWChoiceChainCell *choiceCell = (PWChoiceChainCell *)cell;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:choiceCell];
    _chainStr = [self.dataArray[indexPath.section] objectForKey:@"name"];
    
    [self.tableView reloadData];
    
    switch (_choiceType) {
        case ChoiceTypPri:
        {
            if (self.choiceChainBlock)
            {
                self.choiceChainBlock([self.dataArray[indexPath.section] objectForKey:@"chain"], [self.dataArray[indexPath.section] objectForKey:@"icon"],[self.dataArray[indexPath.section] objectForKey:@"name"]);
                [self.navigationController popViewControllerAnimated:YES];
                
            }
        }
            break;
        default:
            break;
    }

}

#pragma mark - getter and setter
- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = SGColorFromRGB(0xf8f8fa);
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
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
