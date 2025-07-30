//
//  WebChangeAccountSheetView.m
//  PWalletInterfaceSDk
//
//  Created by 郑晨 on 2024/1/11.
//  Copyright © 2024 fzm. All rights reserved.
//

#import "WebChangeAccountSheetView.h"
#import "PWSwitchWalletCell.h"

@interface WebChangeAccountSheetView()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UIView *contentsView;
@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *walletArr;
@property (nonatomic, strong) NSArray *allWalletArray;
@end

@implementation WebChangeAccountSheetView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.backgroundColor = SGColorRGBA(0, 0, 0, .5f);
        [self initView];
    }
    
    return self;
}
- (void)initView
{
    
    NSArray *dataArray = [[PWDataBaseManager shared] queryAllWallets];
    self.allWalletArray = [NSArray arrayWithArray:dataArray];
    NSMutableArray *normalMarray  = [[NSMutableArray alloc] init];
    if (dataArray.count > 0)
    {
        for (LocalWallet *wallet in dataArray) {
            
            if (wallet.wallet_issmall == 1)
            {
                // 创建导入钱
                [normalMarray addObject:wallet];
            }
        }
        self.walletArr = [NSArray arrayWithArray:normalMarray];
    }
    else
    {
        self.walletArr  = [[NSArray alloc] init];
    }
    
    [self addSubview:self.bgView];
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self);
        make.height.mas_equalTo(kScreenHeight - 120);
    }];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
    tap.numberOfTapsRequired = 1;
    [self.bgView addGestureRecognizer:tap];
    self.bgView.userInteractionEnabled = YES;
    
    
    [self addSubview:self.contentsView];
    
    self.contentsView.frame = CGRectMake(0, kScreenHeight, kScreenWidth, 632);
    [PWUtils setViewTopRightandLeftRaduisForView:self.contentsView size:CGSizeMake(6,6)];
    
    [self.contentsView addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentsView);
    }];
}

#pragma mark - uitableview
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.walletArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identity = @"swtichcell";
    PWSwitchWalletCell *cell = [tableView dequeueReusableCellWithIdentifier:identity];
    
    if (!cell) {
        cell = [[PWSwitchWalletCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identity];
    }
    cell.loginBtn.hidden = YES;
    cell.assetLab.hidden = NO;
    cell.walletDesLab.hidden = NO;
    cell.localWallet = self.walletArr[indexPath.row];
    cell.walletDesLab.text =  [PWUtils getEthBtyAddressWithWallet:self.walletArr[indexPath.row]];
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
    for (int i = 0 ; i < self.allWalletArray.count; i ++) {
        LocalWallet *wallet = [self.allWalletArray objectAtIndex:i];
        if (wallet.wallet_isselected == 1) {
            wallet.wallet_isselected = 0;
            
            [[PWDataBaseManager shared] updateWallet:wallet];
            break;
        }
    }
    LocalWallet *selectedWallet = self.walletArr[indexPath.row];
    selectedWallet.wallet_isselected = 1;
    [[PWDataBaseManager shared] updateWallet:selectedWallet];
    
    if (self.changeBlock) {
        self.changeBlock(selectedWallet);
    }
    [self dismiss];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kWebChangeAccountNotifition" object:nil];
    
}

#pragma mark - show
- (void)showWithView:(UIView *)view
{
    
    UIWindow *window = [PWUtils getKeyWindowWithView:view];
    [window addSubview:self];
    [UIView animateWithDuration:.3 animations:^{
        CGRect frame = self.contentsView.frame;
        frame.origin.y -= frame.size.height;
        self.contentsView.frame = frame;
    }];

}

#pragma mark - hide
- (void)dismiss
{
    
    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = self.contentsView.frame;
        frame.origin.y += frame.size.height;
        self.contentsView.frame = frame;
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self removeFromSuperview];
    });
}
#pragma mark - getter setter
- (UIView *)contentsView
{
    if (!_contentsView) {
        UIView *contentView = [[UIView alloc] init];
        contentView.backgroundColor = SGColorFromRGB(0xf8f8fa);
        
        _contentsView = contentView;
    }
    return _contentsView;
}
- (UIView *)bgView
{
    if (!_bgView) {
        UIView *contentView = [[UIView alloc] init];
        contentView.backgroundColor = SGColorRGBA(0, 0, 0, .5f);
        
        _bgView = contentView;
    }
    return _bgView;
}

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

@end
