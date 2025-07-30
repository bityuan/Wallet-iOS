//
//  ChoiceWalletTypeViewController.m
//  PWalletInterfaceSDk
//
//  Created by 郑晨 on 2022/9/5.
//  Copyright © 2022 fzm. All rights reserved.
//

#import "ChoiceWalletTypeViewController.h"
#import "CreateRecoverWalletViewController.h"
#import "ChoiceWalletTypeCell.h"

@interface ChoiceWalletTypeViewController ()
<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataArray;


@end

@implementation ChoiceWalletTypeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.showMaskLine = NO;
    self.title = @"钱包类型".localized;
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self initData];
    
    
}

- (void)initData
{
    _dataArray = @[@{@"bg":@"nor_wallet",@"type":@"助记词钱包".localized},
                   @{@"bg":@"rec_wallet",@"type":@"找回钱包".localized}];
    [self.tableView reloadData];
}

#pragma mark -- tableview
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identity = @"typecell";
    ChoiceWalletTypeCell *cell = [tableView dequeueReusableCellWithIdentifier:identity];
    if (!cell) {
        cell = [[ChoiceWalletTypeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identity];
    }
    
    cell.bgImgView.image = [UIImage imageNamed:[_dataArray[indexPath.row] objectForKey:@"bg"]];
    cell.walletTypeImgView.image = [UIImage imageNamed:[_dataArray[indexPath.row] objectForKey:@"type"]];
    cell.confirBtn.backgroundColor = indexPath.row == 0 ? SGColorFromRGB(0xF8EBCC):SGColorFromRGB(0x7190FF);
    [cell.confirBtn setTitleColor:indexPath.row == 0 ? SGColorFromRGB(0x333649):SGColorFromRGB(0xFFFFFF) forState:UIControlStateNormal];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 136.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
        {
            
        }
            break;
        case 1:
        {
            CreateRecoverWalletViewController *vc = [[CreateRecoverWalletViewController alloc] init];
            
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        default:
            break;
    }
}

#pragma mark - getter setter
- (UITableView *)tableView
{
    if (!_tableView)
    {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.backgroundColor = SGColorFromRGB(0xffffff);
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
