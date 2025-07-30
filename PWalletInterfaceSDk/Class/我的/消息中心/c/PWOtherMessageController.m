//
//  PWOtherMessageController.m
//  PWallet
//
//  Created by 陈健 on 2018/11/16.
//  Copyright © 2018 陈健. All rights reserved.
//

#import "PWOtherMessageController.h"
#import "PWMessage+Request.h"
#import "PWMessageCell.h"
#import "PWOtherMessageModel.h"
#import <MJRefresh/MJRefresh.h>
#import "TradeDetailViewController.h"
#import "CAPSPageMenu.h"

@interface PWOtherMessageController ()<UITableViewDelegate,UITableViewDataSource>
/**tableview*/
@property (nonatomic,weak) UITableView *tableView;
/**数据源*/
@property (nonatomic,strong) NSArray *dataArray;
@property (nonatomic, assign) NSInteger page;
@property (nonatomic, assign) NSInteger badge;
@property (nonatomic,weak) UIView *badgeView;
@end

@implementation PWOtherMessageController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = SGColorRGBA(247, 247, 251, 1);
    self.page = 1;
    self.badge = 0;
    [self initViews];
    [self.tableView.mj_header beginRefreshing];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(readAllHandler) name:@"readAllNotification" object:nil];
}

- (void)initViews {
    //UITableView
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
    [self.view addSubview:tableView];
    self.tableView = tableView;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    tableView.backgroundColor = self.view.backgroundColor;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.estimatedRowHeight = 0;
    tableView.estimatedSectionFooterHeight = 0;
    tableView.estimatedSectionHeaderHeight = 0;
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-(isIPhoneXSeries ? 34 : 10));
    }];
    
    //下拉刷新
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadData)];
    tableView.mj_header = header;
    tableView.mj_header.automaticallyChangeAlpha = YES;
    header.lastUpdatedTimeLabel.hidden = YES;
}

-(void)loadData {
    self.page = 1;
    self.dataArray=[[PWOtherMessageModel sharedManager] loadData];
    if (IS_BLANK(self.dataArray)) {
//        [self showCustomMessage:@"暂无消息".localized hideAfterDelay:1];
        self.badge=0;
    }else{
        self.badge=0;
        for(PWMessage *message in self.dataArray){
            if(!message.readed){
                self.badge++;
            }
        }
        [self.tableView reloadData];
    }

    [self.tableView.mj_header endRefreshing];
    [self addBadgeToTitle];
}

-(void)addBadgeToTitle{
    UIResponder *nextResponder;
    for (UIView* next = [self.view superview]; next; next = next.superview) {
        nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[CAPSPageMenu class]]) {
//            NSLog(@"%@",NSStringFromClass([nextResponder class]));
            break;
        }
    }
    CAPSPageMenu *pageMenu=(CAPSPageMenu*)nextResponder;
    MenuItemView *view= pageMenu.menuItems[0];
//    NSLog(@"%@",view.titleLabel.text);
    
    if (self.badgeView == nil) {
        UILabel *badgeView=[[UILabel alloc] init];
        [view.titleLabel addSubview:badgeView];
        self.badgeView = badgeView;
        badgeView.layer.backgroundColor = [UIColor colorWithRed:204/255.0 green:57/255.0 blue:105/255.0 alpha:1.0].CGColor;
            //圆角为宽度的一半
        badgeView.layer.cornerRadius = 7;
        [badgeView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.equalTo(view.titleLabel.mas_right).offset(-5);
            make.centerX.equalTo(view.titleLabel).offset(view.titleLabel.textWidth/2+3);
            make.height.mas_equalTo(14);
            make.width.mas_equalTo(18);
            make.top.equalTo(view.titleLabel).offset(5);
        }];
        UILabel *badgeNum=[[UILabel alloc] init];
        [badgeView addSubview:badgeNum];
        badgeNum.numberOfLines = 0;
        badgeNum.text=[NSString stringWithFormat: @"%ld", (long)self.badge];
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:badgeNum.text attributes: @{NSFontAttributeName: [UIFont fontWithName:@"PingFangSC-Semibold" size: 10],NSForegroundColorAttributeName: [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0]}];

        badgeNum.attributedText = string;
        badgeNum.textAlignment = NSTextAlignmentLeft;
        badgeNum.alpha = 1.0;
        [badgeNum mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.equalTo(view.titleLabel.mas_right).offset(-5);
//            make.top.equalTo(view.titleLabel).offset(5);
            make.center.equalTo(badgeView);
        }];
    }else{
        UILabel *badgeNum=[self.badgeView subviews][0];
        badgeNum.text=[NSString stringWithFormat: @"%ld", (long)self.badge];
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:badgeNum.text attributes: @{NSFontAttributeName: [UIFont fontWithName:@"PingFangSC-Semibold" size: 10],NSForegroundColorAttributeName: [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0]}];
        badgeNum.attributedText = string;
    }
    if(self.badge==0){
        [self.badgeView removeFromSuperview];
    }
}

#pragma mark - 实例方法
-(void)readAllHandler{
    for (PWMessage *message in self.dataArray) {
        if(!message.readed){
            message.readed=YES;
            [[PWOtherMessageModel sharedManager] updateMessage:message];
        }
    }
    self.badge=0;
    [self.tableView reloadData];
    [self.badgeView removeFromSuperview];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

#pragma mark - UITableView  datasource delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"identifier";
    PWMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[PWMessageCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
//    cell.message = self.dataArray[[self.dataArray count]- indexPath.row-1];
    cell.message = self.dataArray[indexPath.row];
    [cell hideContent:false];
    if(!cell.message.readed){
        [cell showBadge];
    }else{
        [cell hideBadge];
    }
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell.frame.size.height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    PWMessage *message=self.dataArray[indexPath.row];
    if(!message.readed){
        message.readed=YES;
        [[PWOtherMessageModel sharedManager] updateMessage:message];
        self.badge--;
        [self addBadgeToTitle];
    }
    TradeDetailViewController *vc = [[TradeDetailViewController alloc]init];
    vc.pushedByNotification = true;
//    vc.coinType = IS_BLANK(tokensymbol) ? coinType : tokensymbol;
//    vc.tradeHash = message.;
    
//    [self.navigationController pushViewController:vc animated:false];


    PWMessageCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell hideBadge];
}

@end
